#!/usr/bin/env python3
"""Decrypt Broadcom/Sagemcom GatewaySettings_*.bin (Orange F@ST 3284 family).

The files use a per-file 16-byte repeating-XOR obfuscation over the data
region (0x60 .. EOF). The key is *self-describing*: the zero-plaintext padding
runs throughout the file make the ciphertext there equal the key, so the most
frequent 16-byte block (16-byte aligned on the data start) IS the key.

See FORMAT.md for the full format write-up and references.
"""

import argparse
import glob
import hashlib
import os
import struct
import sys
from collections import Counter

SALT_HEX = "3250736c633b752865676d64302d2778"  # b"2Pslc;u(egmd0-'x"
SALT = bytes.fromhex(SALT_HEX)
DATA_START = 0x60
HDR_MAGIC = slice(0x10, 0x5A)
HDR_VERSION = slice(0x5A, 0x5C)
HDR_SIZEFIELD = slice(0x5C, 0x60)


def parse_header(data):
    """Return (magic, version, size_field)."""
    magic = data[HDR_MAGIC]
    try:
        magic_s = magic.decode("ascii")
    except UnicodeDecodeError:
        magic_s = magic.hex()
    version = data[HDR_VERSION].hex()
    size = int.from_bytes(data[HDR_SIZEFIELD], "big")
    return magic_s, version, size


def verify_checksum(data):
    """Stored 0x00..0x0F == md5(data[0x10:] + SALT)?  (Broadcom generic profile)."""
    stored = data[:0x10]
    calc = hashlib.md5(data[0x10:] + SALT).digest()
    return stored == calc, stored.hex(), calc.hex()


def recover_key(data):
    """Most frequent 16-byte block aligned at DATA_START => the XOR key.

    Returns (key_bytes, top_blocks) where top_blocks lists (block, count)
    for the most common block values, which are the plaintext-zero padding
    runs and any constant plaintext fields.
    """
    body = data[DATA_START:]
    n = len(body) // 16
    blocks = [body[i * 16 : i * 16 + 16] for i in range(n)]
    counts = Counter(blocks)
    top = counts.most_common(3)
    key = top[0][0]
    return key, top


def decrypt(data, key, phase=0):
    """XOR data[DATA_START:] with the 16-byte key (phase rotates the key).

    Returns header bytes (0x00..0x5F verbatim) + decrypted body.
    """
    k = key[phase % 16 :] + key[: phase % 16]
    body = data[DATA_START:]
    out = bytearray(len(body))
    for i in range(len(body)):
        out[i] = body[i] ^ k[i % 16]
    return bytes(data[:DATA_START] + bytes(out))


def summarize_structure(plain, key):
    """Classify each 16-byte block and return a readable structure summary list."""
    body = plain[DATA_START:]
    n = len(body) // 16
    kinds = []  # (offset, kind, length_in_bytes)
    cur_kind = None
    cur_start = DATA_START
    cur_len = 0
    for i in range(n):
        block = body[i * 16 : i * 16 + 16]
        if block == key:
            kind = "pad"
        elif all(b == 0 for b in block):
            kind = "zeros"
        else:
            kind = "data"
        if kind != cur_kind:
            if cur_kind is not None:
                kinds.append((cur_start, cur_kind, cur_len))
            cur_kind = kind
            cur_start = DATA_START + i * 16
            cur_len = 0
        cur_len += 16
    if cur_kind is not None:
        kinds.append((cur_start, cur_kind, cur_len))
    return kinds


def write_dump(plain, key, path):
    body = plain[DATA_START:]
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("; Decrypted GatewaySettings dump (see FORMAT.md)\n")
        fh.write("; key = %s (aligned at 0x%02X)\n\n" % (key.hex(), DATA_START))
        i = 0
        while i < len(body):
            chunk = body[i : i + 16]
            hexs = " ".join("%02X" % b for b in chunk)
            ascii_ = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
            flag = ""
            if chunk == key:
                flag = " [pad: zero plaintext]"
            elif all(b == 0 for b in chunk):
                flag = " [zeros]"
            fh.write("%08X:  %-47s  %s%s\n" % (DATA_START + i, hexs, ascii_, flag))
            i += 16
        fh.write("\n; --- structure summary (block types) ---\n")
        for off, kind, length in summarize_structure(plain, key):
            fh.write("; 0x%08X..+0x%X  %-5s  (%d bytes)\n" % (off, length, kind, length))


def process_file(path, out_dir, phase):
    data = open(path, "rb").read()
    name = os.path.basename(path)
    ok, stored, calc = verify_checksum(data)
    magic, version, size = parse_header(data)
    key, top = recover_key(data)
    plain = decrypt(data, key, phase)

    base = os.path.splitext(name)[0]
    phase_suffix = "" if phase == 0 else ".ph%d" % phase
    out_bin = os.path.join(out_dir, base + phase_suffix + ".dec.bin")
    out_txt = os.path.join(out_dir, base + phase_suffix + ".dec.txt")
    open(out_bin, "wb").write(plain)
    write_dump(plain, key, out_txt)

    print("=== %s ===" % name)
    print("  size          : %d bytes (size-field: %d, matches: %s)"
          % (len(data), size, "yes" if len(data) == size + 0x10 else "NO"))
    print("  checksum      : %s (stored %s, %s salt-md5)" % (ok, stored, calc))
    print("  version       : %s" % version)
    print("  magic         : %r" % magic)
    print("  xor key       : %s  (0x%02X-aligned, %d repeating-pad matches)"
          % (key.hex(), DATA_START, top[0][1]))
    if len(top) > 1:
        print("  const fields  : " + ", ".join("%s (%dx)" % (b.hex(), c)
                                               for b, c in top[1:4]))
    kinds = summarize_structure(plain, key)
    n_data = sum(l for _, k, l in kinds if k == "data")
    n_pad = sum(l for _, k, l in kinds if k == "pad")
    n_zero = sum(l for _, k, l in kinds if k == "zeros")
    print("  structure     : %d data bytes in %d regions, %d plaintext-zero bytes, %d key-repeating blocks"
          % (n_data, sum(1 for _, k, _ in kinds if k == "data"), n_zero, n_pad))
    print("  wrote         : %s and %s" % (out_bin, out_txt))
    print()


def main():
    ap = argparse.ArgumentParser(
        description="Decrypt Orange/Sagemcom GatewaySettings bins "
                    "(per-file 16-byte repeating XOR).")
    ap.add_argument("target", nargs="?",
                    help="a GatewaySettings_*.bin file, or a directory to scan")
    ap.add_argument("--out", default=None, help="output directory (default: alongside input)")
    ap.add_argument("--phase", type=int, default=0,
                    help="rotate the XOR key by N bytes (0..15); 0 = key aligned at 0x60")
    args = ap.parse_args()

    target = args.target or "."
    if os.path.isdir(target):
        files = sorted(glob.glob(os.path.join(target, "GatewaySettings_*.bin")))
    elif os.path.isfile(target):
        files = [target]
    else:
        print("not found: %s" % target, file=sys.stderr)
        sys.exit(1)
    if not files:
        print("no GatewaySettings_*.bin files found in %s" % target, file=sys.stderr)
        sys.exit(1)

    out_dir = args.out
    if out_dir is None:
        out_dir = target if os.path.isdir(target) else os.path.dirname(target)
    os.makedirs(out_dir, exist_ok=True)
    for f in files:
        process_file(f, out_dir, args.phase)


if __name__ == "__main__":
    main()