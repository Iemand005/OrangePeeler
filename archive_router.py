#!/usr/bin/env python3
"""Read-only crawler / archiver for the Orange Askey TCG300 web interface.

Archives every page and asset the router serves (HTML, ASP, JS, CSS, images,
XML) into an archive/ tree together with response headers and a manifest.

SAFETY RULES (this tool is deliberately conservative):
  * Only GET requests are ever sent. The single exception is the login POST
    to /goform/OrgLogin, which is required to obtain a session.
  * /goform/* endpoints are NEVER requested via GET (on these firmwares a
    goform URL with query parameters can mutate state).
  * URLs whose path or query match destructive keywords (restart, reset,
    factory, delete, clear, erase, reboot, upgrade, restore, apply, save,
    flush, kill, drop ...) are never requested.
  * Everything is rate limited (--delay, default 0.25 s).

Usage:
  python archive_router.py --password 777753AE
  python archive_router.py --password ... --port 8082 --basic-user admin
"""

import argparse
import hashlib
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone

SAFE_EXT = {
    ".asp", ".htm", ".html", ".js", ".css", ".gif", ".png", ".jpg", ".jpeg",
    ".svg", ".ico", ".xml", ".txt", ".json", ".woff", ".woff2", ".ttf",
    ".eot", ".map", ".swf", ".pdf", ".bin", ".cfg", ".conf", ".tar", ".gz",
    ".zip",
}
SAFE_EXT.update([""])  # extensionless paths (/, /status, ...)

BAD_TOKENS = re.compile(
    r"(restart|reboot|factory|reset|delete|clear|erase|purge|upgrade|"
    r"restore|reboot|apply|commit|save|flush|kill|drop|remove|format|"
    r"deletelog|clearlog|syslog_clear|opendns_clear)",
    re.I,
)

# fetching these would end our own session (Disconnect / logout links)
LOGOUT_TOKENS = re.compile(r"(login\.asp|logout|disconnect)", re.I)

# .asp pages that only exist to trigger a state change -> never requested.
# (GET on this firmware never mutates - actions are goform POSTs - but these
# pages have zero archival value, so we skip them entirely.)
DESTRUCTIVE_PAGES = re.compile(
    r"/(ResetToFactory|Restart|NetworkRestart|WifiReset|WifiWPS|"
    r"ModemPassword|Bridge)(\.asp)?$", re.I)

URL_RE = re.compile(
    r"""(?:href|src|action|data-src|poster)\s*=\s*["']([^"']+)["']"""
    r"""|url\(\s*['"]?([^'")]+)""",
    re.I,
)
# .asp / .js paths mentioned inside inline scripts
PATH_RE = re.compile(r"""['"]([A-Za-z0-9_\-/]+\.(?:asp|js|css|xml|gif|png|jpg|jpeg|svg|ico))['"]""")
# goform names are recorded but never fetched
GOFORM_RE = re.compile(r"""['"]/?goform/([A-Za-z0-9_]+)['"]""", re.I)


def now_iso():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


class SafeFetcher:
    def __init__(self, base, delay=0.25, timeout=15, basic_user=None,
                 basic_pass=None):
        self.base = base.rstrip("/")
        self.delay = delay
        self.timeout = timeout
        self.cookie = None
        self.basic = None
        if basic_user is not None:
            tok = ("%s:%s" % (basic_user, basic_pass or "")).encode()
            self.basic = "Basic " + __import__("base64").b64encode(tok).decode()
        self.stats = {"requests": 0, "blocked": 0, "errors": 0, "login": 0}

    # -- safety gate -----------------------------------------------------
    def is_safe(self, url):
        p = urllib.parse.urlsplit(url)
        path = p.path
        if p.query and BAD_TOKENS.search(p.query):
            return False, "query token"
        if path.lower().startswith("/goform/"):
            return False, "goform"
        if LOGOUT_TOKENS.search(path):
            return False, "logout link"
        if DESTRUCTIVE_PAGES.search(path):
            return False, "destructive page"
        ext = os.path.splitext(path)[1].lower()
        if ext not in SAFE_EXT:
            return False, "ext %r" % ext
        return True, ""

    # -- HTTP ------------------------------------------------------------
    def _open(self, req, allow_401=False):
        try:
            return urllib.request.urlopen(req, timeout=self.timeout), None
        except urllib.error.HTTPError as e:
            if e.code == 401 and allow_401:
                return None, e
            return e, None  # HTTPError is also a response object
        except Exception as e:  # noqa: BLE001
            return None, e

    def get(self, url, allow_401=False, retries=3):
        """Returns (status, headers, body_bytes, error_string_or_None)."""
        if not url.startswith("http"):
            url = self.base + ("/" + url if not url.startswith("/") else url)
        ok, why = self.is_safe(url)
        if not ok:
            self.stats["blocked"] += 1
            return None, None, None, "BLOCKED(%s)" % why
        for attempt in range(retries):
            req = urllib.request.Request(url, method="GET")
            req.add_header("User-Agent", "Mozilla/5.0 (archive-research)")
            if self.cookie:
                req.add_header("Cookie", self.cookie)
            if self.basic:
                req.add_header("Authorization", self.basic)
            resp, err = self._open(req, allow_401)
            time.sleep(self.delay)
            if resp is not None:
                break
            if attempt < retries - 1:
                time.sleep(self.delay * (attempt + 1) * 2)
        if resp is None:
            self.stats["errors"] += 1
            return None, None, None, str(err)
        self.stats["requests"] += 1
        body = resp.read()
        headers = dict(resp.headers.items())
        status = getattr(resp, "status", None) or resp.getcode()
        sc = headers.get("Set-Cookie")
        if sc:
            m = re.search(r"(session=[^;]+)", sc)
            if m:
                self.cookie = m.group(1)
        return status, headers, body, None

    def login(self, password):
        """Two-step login: the router issues the session cookie on GET / and
        only honours the login POST if that cookie is replayed.  We use
        http.client so the 302 is NOT followed (urllib would drop the
        Set-Cookie we are after)."""
        import http.client
        sp = urllib.parse.urlsplit(self.base)
        port = sp.port or (443 if sp.scheme == "https" else 80)
        cls = (http.client.HTTPSConnection if sp.scheme == "https"
               else http.client.HTTPConnection)

        def req(method, path, body=None, extra_headers=None):
            headers = {
                "User-Agent": "Mozilla/5.0 (archive-research)",
                "Connection": "close",
            }
            if self.cookie:
                headers["Cookie"] = self.cookie
            if body is not None:
                headers["Content-Type"] = "application/x-www-form-urlencoded"
                headers["Content-Length"] = str(len(body))
            if extra_headers:
                headers.update(extra_headers)
            conn = cls(sp.hostname, port, timeout=self.timeout)
            conn.request(method, path, body=body, headers=headers)
            resp = conn.getresponse()
            status = resp.status
            hdrs = dict(resp.getheaders())
            data = resp.read()
            conn.close()
            m = re.search(r"(session=[^;,\s]+)", hdrs.get("Set-Cookie", ""))
            if m:
                self.cookie = m.group(1)
            return status, hdrs, data

        st, hdrs, _ = req("GET", "/")
        if not self.cookie:
            return False, "no session cookie on GET / (status=%s)" % st
        body = urllib.parse.urlencode({"OrgPassword": password})
        st, hdrs, _ = req("POST", "/goform/OrgLogin", body=body)
        loc = hdrs.get("Location", "")
        time.sleep(self.delay)
        self.stats["login"] += 1
        if st not in (200, 302):
            return False, "status=%s" % st
        # verify the session actually unlocks a protected page
        st2, _, data2, err = self.get(self.base + "/overview.asp")
        ok = st2 == 200 and len(data2 or b"") != 15958
        return ok, "login=%s location=%s verify=%s bytes=%s" % (
            st, loc, st2, len(data2 or b""))


class Archiver:
    def __init__(self, out_dir, base, port):
        self.out = os.path.join(out_dir, "%s_%s" %
                                (urllib.parse.urlsplit(base).hostname, port))
        os.makedirs(self.out, exist_ok=True)
        self.base = base.rstrip("/")
        self.manifest = []
        self.seen = set()
        self.goforms = set()
        self.queue = []

    def map_path(self, url):
        p = urllib.parse.urlsplit(url)
        rel = urllib.parse.unquote(p.path.lstrip("/")) or "root"
        if p.query:
            rel += "?" + urllib.parse.unquote(p.query)
        rel = rel.replace(":", "_").replace("*", "_")
        # keep query-string variants distinguishable but filesystem-safe
        rel = re.sub(r"[<>|\"\\]", "_", rel)
        if os.path.splitext(rel)[1] == "":
            rel += ".html"
        return os.path.normpath(os.path.join(self.out, rel))

    def enqueue(self, url, origin):
        if not url:
            return
        url = urllib.parse.urljoin(self.base + "/", url)
        p = urllib.parse.urlsplit(url)
        if p.netloc != urllib.parse.urlsplit(self.base).netloc:
            return  # external
        for g in GOFORM_RE.findall(url):
            self.goforms.add(g)
        clean = urllib.parse.urlunsplit((p.scheme, p.netloc, p.path, p.query, ""))
        if clean in self.seen:
            return
        self.seen.add(clean)
        self.queue.append((clean, origin))

    def fetch_one(self, url, origin):
        status, headers, body, err = self.fetcher.get(url)
        if status is None:
            self.manifest.append({
                "url": url, "origin": origin, "error": err, "at": now_iso()})
            print("  ! %s  %s" % (err, url))
            return
        rel = self.map_path(url)
        os.makedirs(os.path.dirname(rel), exist_ok=True)
        with open(rel, "wb") as fh:
            fh.write(body if body else b"")
        meta = {
            "url": url,
            "origin": origin,
            "status": status,
            "content_type": headers.get("Content-Type"),
            "content_length": headers.get("Content-Length"),
            "sha256": hashlib.sha256(body or b"").hexdigest(),
            "bytes": len(body or b""),
            "headers": headers,
            "saved_to": os.path.relpath(rel, self.out),
            "at": now_iso(),
        }
        self.manifest.append(meta)
        print("  [%s] %6d  %s" % (status, meta["bytes"], url))

        # session-expiry detection: protected pages fall back to the
        # 15958-byte login document when the cookie is no longer accepted.
        if (meta["bytes"] == 15958 and b"<title>login</title>" in (body or b"")
                and urllib.parse.urlsplit(url).path not in ("/", "/index.asp")):
            print("      !! session lost - re-login needed")
            meta["session_lost"] = True

        # harvest links
        text_ext = os.path.splitext(urllib.parse.urlsplit(url).path)[1].lower()
        if text_ext in (".asp", ".htm", ".html", ".js", ".css", ".xml", ""):
            try:
                text = (body or b"").decode("utf-8", "replace")
            except Exception:  # noqa: BLE001
                text = ""
            for m in URL_RE.finditer(text):
                self.enqueue(m.group(1) or m.group(2), url)
            for m in PATH_RE.finditer(text):
                self.enqueue(m.group(1), url)
            if text_ext == ".css":
                for m in re.finditer(r"url\(([^)]+)\)", text):
                    self.enqueue(m.group(1).strip("'\" "), url)

    def run(self, seeds):
        for s in seeds:
            self.enqueue(s, "seed")
        while self.queue:
            url, origin = self.queue.pop(0)
            self.fetch_one(url, origin)

    def write_manifest(self):
        doc = {
            "base": self.base,
            "generated": now_iso(),
            "count": len(self.manifest),
            "goform_endpoints_seen": sorted(self.goforms),
            "entries": self.manifest,
        }
        path = os.path.join(self.out, "_manifest.json")
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(doc, fh, indent=2)
        with open(os.path.join(self.out, "_goforms.txt"), "w",
                  encoding="utf-8") as fh:
            fh.write("\n".join(sorted(self.goforms)) + "\n")
        return path


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--base", default="http://192.168.0.1")
    ap.add_argument("--password", required=True, help="web UI admin password")
    ap.add_argument("--port", type=int, default=None,
                    help="override port in --base (e.g. 8082)")
    ap.add_argument("--basic-user", default=None,
                    help="HTTP basic-auth user (for port 8082 style hosts)")
    ap.add_argument("--basic-pass", default=None)
    ap.add_argument("--out", default="archive")
    ap.add_argument("--delay", type=float, default=0.25)
    ap.add_argument("--seeds", nargs="*", default=None)
    ap.add_argument("--no-login", action="store_true")
    args = ap.parse_args()

    base = args.base
    if args.port:
        sp = urllib.parse.urlsplit(base)
        base = urllib.parse.urlunsplit(
            (sp.scheme, "%s:%d" % (sp.hostname, args.port), "", "", ""))

    fetcher = SafeFetcher(base, delay=args.delay,
                          basic_user=args.basic_user, basic_pass=args.basic_pass)
    if not args.no_login:
        if args.basic_user is None:
            ok, info = fetcher.login(args.password)
            print("login: %s (%s)" % (ok, info))
            if not ok:
                sys.exit(1)

    a = Archiver(args.out, base, args.port or 80)
    a.fetcher = fetcher
    seeds = args.seeds or [
        "/", "/overview.asp", "/Technicalreports.asp", "/Status.asp",
        "/Upstream.asp", "/Downstream.asp", "/EventLog.asp",
        "/Diagnostic.asp", "/NetworkConnectedDevices.asp", "/WiFiClients.asp",
        "/WiFiLogs.asp", "/WiFiNeighborhood.asp", "/wifiAnalyzer.asp",
        "/BasicConfiguration.asp", "/AdvancedConfiguration.asp",
        "/WifiGuest.asp", "/GuestActivationAndScheduling.asp",
        "/GuestWifiConnectedDevices.asp", "/WifiSchedule.asp", "/WifiWPS.asp",
        "/DeviceFiltering.asp", "/ParentalControl.asp", "/ContentControl.asp",
        "/FixedIPAssignation.asp", "/PortOpening.asp", "/DynDns.asp",
        "/Firewall.asp", "/DMZHost.asp", "/RgAdvanced.asp", "/BackupLine.asp",
        "/Bridge.asp", "/ModemHostname.asp", "/ModemPassword.asp",
        "/Languages.asp", "/BackupRestore.asp", "/RemoteAccess.asp",
        "/eRouterLogs.asp", "/SpeedTest.asp",
        "/js/functions.js", "/js/dict_nl.js", "/js/alljquery.js",
        "/css/allcss.css",
    ]
    print("crawling %s  (%d seeds)" % (base, len(seeds)))
    a.run(seeds)
    path = a.write_manifest()
    print("\n%d fetches, %d blocked by safety gate, %d errors"
          % (fetcher.stats["requests"], fetcher.stats["blocked"],
             fetcher.stats["errors"]))
    print("manifest: %s" % path)


if __name__ == "__main__":
    main()
