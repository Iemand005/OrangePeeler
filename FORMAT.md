# Orange `GatewaySettings` Format

Analysis of the `GatewaySettings_<HHMMSS>-<DDMMYY>.bin` files exported by an
Orange gateway identified as the **Askey/Siligence TCG300** (EuroDocsis 3.0
cable modem, Broadcom BCM3384, eCos, web admin 192.168.0.1). The export uses
the Sagemcom F@ST 3284/3686-family header magic (`...-057` suffix) — the
standard Broadcom `GatewaySettings` format of that OEM generation — but a
different device underneath. 22 samples analysed.

## 1. Big picture

Each file is a snapshot the *GatewaySettings* export. It is **not** encrypted
in a cryptographic sense. Structure:

```
+--------+--------------------------------+-----------------------------------+
| 0x0000 | 16-byte Salted MD5 checksum    | md5(file[0x10:] + SALT)           |
+--------+--------------------------------+-----------------------------------+
| 0x0010 | 74-byte ASCII magic            | "6u9e9ewf0jt9y85w690je4669jye4d-" |
|        |                                |  "056t9p48jp4ee6u9ee659jy9e-"     |
|        |                                |  "54e4j6r0j069k-057"               |
+--------+--------------------------------+-----------------------------------+
| 0x005A | u16 version                    | 01 02                             |
+--------+--------------------------------+-----------------------------------+
| 0x005C | u32 big-endian size            | file size - 0x10                  |
+--------+--------------------------------+-----------------------------------+
| 0x0060 | data region                    | XOR-obfuscated settings data      |
+--------+--------------------------------+-----------------------------------+
```

The header (0x00..0x5F) is plaintext. The data region (0x60..EOF) is XORed with
a **per-file 16-byte repeating key**:

```python
for i in range(len(data) - 0x60):
    data[0x60 + i] ^= KEY[i % 16]
```

The key is **self-recovering**: every zero-plaintext block of padding writes the
raw key byte-for-byte into the ciphertext, so the most frequent 16-byte block
(16-byte aligned on the data start) *is* the key.

## 2. Field details

### Checksum (0x00–0x0F)
Salted MD5 over everything after the checksum itself. This is the Broadcom
`generic` profile's `cfg_md5key` already implemented in `bcm2-utils`
(`profiledef.c`):

```python
salt = bytes.fromhex("3250736c633b752865676d64302d2778")  # b"2Pslc;u(egmd0-'x"
md5(file[0x10:] + salt)[:16] == file[0x00:0x10]
```

Verified `OK` for all 22 files.

### Magic (0x10–0x59)
`6u9e9ewf0jt9y85w690je4669jye4d-056t9p48jp4ee6u9ee659jy9e-54e4j6r0j069k-057`

This is the `GWS_DATA_TAG[2]` magic of the F@ST 3284/3686 generation, with the
ISP suffix `-057`. `bcm2-utils` documents the `-056` variant for the
Sagemcom F@ST 3686 (`Fast3686<ISP>056t9p48jp4ee6u9ee659jy9e-54e4j6r0j069k-056`,
known ISPs: DNA, CLARO, SFR-PC20).

### Version (0x5A–0x5B)
`01 02` in every sample.

### Size (0x5C–0x5F)
Big-endian u32, always `len(file) - 0x10`.

### Data region (0x60–EOF)
XOR with the per-file 16-byte key, aligned so that `KEY[0]` lines up with
offset `0x60` (see `--phase` note in §5). Padding inside the region is genuine
`0x00`, which is the property that leaks the key.

## 3. Obfuscation – full analysis

### Key recovery (the “oracle”)
Wherever the plaintext is a run of zeros, the ciphertext equals the key:

```
P[i] = 0  =>  C[i] = P[i] ^ K[i % 16] = K[i % 16]
```

Every file contains tens of such padding runs (600+ full 16-byte blocks each).
Counting the most frequent 16-byte block aligned at `0x60` recovers the whole
key. Example (first sample): key `ba21ec524f2c34503f0bc15e5f6f984f`, seen 641
times as the padding pattern.

Keys are **unique per file** (all 22 differ; see appendix). Sibling exports
11 s apart (`064631` vs `064642`) have different keys. The key is therefore
not derived from the checksum (circular) nor from the export timestamp (295
timestamp/MD5-derived candidates tested, none matched) — it is generated per
export, presumably by the router (RNG or a per-device secret in the firmware).

### Zero-padding structure
All padding runs are 16-byte aligned within the data region. `bcm2-utils`
parses this same region as `nv_group` TLVs (`u16 size` + 4-char magic
+ data); after de-obfuscation **no such TLV groups parse** and there is
no printable ASCII — the records are opaque binary fields.

Searches performed — all negative:
- **Group-TLV scan**: for each of the 22 files, for every key rotation
  0..15, walking `[u16 size][u32 magic]` chains from every start offset in
  the first 0x200 bytes (accepting printable *or* hexspeak high-bit magics
  like the `0xd0c20130` / `0xf2a1f61f` documented ones): **no valid chain
  of 2+ groups anywhere** (besides incidental garbage).
- **ASCII/UTF-16 string search** across all 16 rotations and a
  byte-swapped variant: no run ≥ 8 chars; known-plaintext needles
  `Orange`, `Orange-aaff0`, `aaff0`, `Terraria`, `Minecraft`, `wireless`,
  `MultiSSID` present in none of the files.
- **Length-prefixed string (p8string) scan** (byte `n` followed by `n`
  printable chars): only ~10–70 hits per file in ~21k non-zero bytes, i.e.
  noise, and the "best" phase is random per file.
- **Same-router static-content check** (`064631`/`064642` 11 s apart and the
  `22161x` cluster): non-zero plaintext agreement ~0.3% (random coin-flip
  level). No persistent static configuration survives across exports.
- **Entropy / compression check**: no zlib/bz2/lzma/gzip/zip streams.
- The documented dynnv **subtraction + swap** cipher
  (16 × 16-byte wrapped keys) also yields no groups or text.

The two remaining live explanations for "no readable config": the data really
is session/state records, or the real transform is an undocumented cipher for
the `-057` magic — `bcm2-utils`' own `doc/gwsettings.md` lists the Sagem F@ST
3284 encryption as *unknown* (``| Sagem | F@st3284 | ? | ? | settings |``), so
no public profile exists to cross-check against.

### Second most-common block / constant fields
Each file has a second 16-byte block repeated ~41–42× (e.g. `e71af56f84464c4dbf
7f4dced8de6f13` in `002047-060225`). It is a constant *plaintext* field written
at a fixed offset across the file (a repeated 224-byte settings record), which
confirms the key’s 16-byte period: same plaintext at the same phase ⇒ same
ciphertext block.

### What the decrypted data looks like
- ~36% of the region is zero padding between records.
- Records are 0xA0-size blobs → 4-byte-looking trailers → zero padding to the
  next 16-byte boundary; e.g. blocks shaped `539a837e0000…` (u32 + 12 zeros) or
  `00000000ba…` (4 zeros + content).
- No readable configuration text, no ASCII strings ≥ 8 chars, no
  zlib/bz2/lzma/gzip stream.
- Non-zero bytes are effectively uniform-random. Exports of the *same* router
  minutes apart agree only at the zero bytes (non-zero agreement ~0.3%, i.e.
  random), so the record *content* is regenerated per export (session/state
  data, e.g. hashed secrets / counters), not persistent static settings.

### Phase / rotation note
Because any of the 16 byte-rotations of the key also zeroes the padding runs,
the exact phase is not provable from the file alone. The canonical choice is the
natural implementation `KEY` aligned at `0x60`; it matches the dominant-block
value directly and keeps the first data byte of the reference sample `0x00`. The
script exposes `--phase N` (0..15) if a different rotation ever turns out to be
the one the firmware uses.

### Where is the WiFi SSID / port-forward config?
This export does **not** contain the user-facing LAN/WiFi configuration. On
this class of DOCSIS cable modem the `GatewaySettings` dump carries
headend/provisioning state (CM config, logging, DHCP, SNMP, admin/userif
settings), while the WiFi SSIDs and port-forward rules live in the router's
separate wireless configuration partition / `dynnv` NVRAM — which this export
does not include. That is consistent with the observed per-export regenerated,
non-persistent content and the total absence of any text.

To obtain the real WiFi / NAT rules:
- **Read the NVRAM partitions from flash** with qkaiser's bootloader tooling
  (`bcm2dump` on the TCG300 — see References). `dynnv.bin`/`permnv.bin`
  contain the applied LAN settings and can be parsed with `bcm2cfg get`.
- Check the admin UI for a **full-backup** export distinct from
  `GatewaySettings` (some Sagemcom/Askey admin pages offer a text/XML
  `Backup` that includes wireless state).
- The modem's working config also comes from the cable headend's CM config
  file, not from any user-visible export.

## 4. Decryption script

`decrypt_gatewaysettings.py` (stdlib only):

```
python decrypt_gatewaysettings.py path\to\GatewaySettings_*.bin [--out DIR] [--phase N]
```

- verifies the salted-MD5 checksum,
- parses/prints header fields,
- recovers the 16-byte key,
- writes `<name>.dec.bin` (de-obfuscated: header + plain region) and
  `<name>.dec.txt` (annotated hexdump with ASCII gutter, `[zeros]` /
  `[pad]` block markers and a block-type structure summary).

Example:

```
python decrypt_gatewaysettings.py . --out decrypted
```

processes every `GatewaySettings_*.bin` in the current directory.

## 5. References

- **jclehner/bcm2-utils** — broadband config tools/CFE analysis library. The
  `gwsettings` CLI targets exactly these files. Sources consulted:
  `gwsettings.cc` (data region, magic table incl. the `-056/-057` suffixes),
  `crypto.cc`, `profiledef.c` (salted-MD5 checksum key, `Fast3686`/`Fast3286`
  profiles). <https://github.com/jclehner/bcm2-utils>
  - Issue #43 documents the reverse-engineering of the Netgear **CG3100**
    (same Broadcom generation): the obfuscation used a byte key *incremental
    with the byte offset*, required **subtract, not XOR**, and a **swap of the
    two bytes of each 16-bit word**. That discovery became the
    `crypt_sub_16x16` transform in bcm2-utils. Those characteristics are *not*
    present in these Orange files (key is constant, decrypts by XOR only), but
    the issue is the best public write-up of this family’s obfuscation habits.
- **io4/fast3284** — F@ST 3284 firmware backup format. In that older
  generation the settings data were XORed with a single byte `0x80` and the
  rest was plaintext. <https://github.com/io4/fast3284>
- **mati7337/orange-config** — Orange modem configuration decryption; shows
  that key material in this product line can be a firmware file
  (`/security/hgwcfg/hgwcfg.key`). <https://github.com/mati7337/orange-config>
- **qkaiser — "A Clockwork Orange" (2021-04-25)** — reverse engineering of the
  **Orange/Askey TCG300**: identifies the modem (BCM3384, EuroDocsis 3.0),
  documents custom `bcm2-utils` bootloader profiles and the `bcm2dump`
  workflow for reading `dynnv`/`permnv` from flash. Blog:
  <https://quentinkaiser.be/security/2021/04/25/orange/>; PDF report:
  <https://quentinkaiser.be/assets/qkaiser_orange_askey_tcg300_vuln_report.pdf>.
  Note: that report's profiles are for the **bootloader** (dump/decrypt of
  NVRAM at boot), not for the `GatewaySettings.bin` *web export* encryption —
  which remains undocumented for the `-057` Sagem variant.
- Sagemcom **F@ST 3284 / 3686** are eCos-based Broadcom gateways; the
  `GatewaySettings.bin` format used here belongs to that family (the Askey
  TCG300 ships the same Broadcom `GWS` loader/format), which is why
  `bcm2-utils` (built around it) was the relevant prior art.

## 6. Open questions

- The source of the per-file 16-byte XOR key (firmware side). A rootfs dump
  (the `mati7337/orange-config` analog `/security/hgwcfg/hgwcfg.key`, or the
  device key read methods in qkaiser's report) or a newer firmware image would
  settle it.
- The internal record/field layout of the decrypted blobs. Content is
  per-export, so it likely needs the router-side producer (a `gwsdyn`/
  `gwslog` equivalent) or an API/HTTP trace to map field-by-field.
- Whether the `-057` data region uses an additional undocumented cipher on top
  of the XOR (bcm2-utils lists F@st3284 encryption as unknown). A firmware
  binary search for the export routine / key generation would answer both this
  and the key-source question at once.

## Appendix A — per-file keys (22 samples)

| File (timestamp)       | 16-byte XOR key                     |
| ---------------------- | ----------------------------------- |
| 002047-060225          | `ba21ec524f2c34503f0bc15e5f6f984f` |
| 022342-040325          | `a0bfe77ffbdb2cfe2a33a482463c22de` |
| 031912-070426          | `ed209d4afaf4421cdcd90e86af3c599b` |
| 040458-060526          | `50bd58ce59d64dd87610e73c1442bf7f` |
| 044303-160926          | `78de35afae8d43a9ca8365c285347aea` |
| 064631-160925          | `c108f366f6b815cb282fab31e7d24089` |
| 064642-160925          | `5db127c2df5ad3ae9e153f07ea167c3a` |
| 144205-111124          | `69884ac645b1a4a22dbc770831a30d22` |
| 165324-090326          | `824a7cf8f1d3c8cb99bb2aa4dc8e007c` |
| 190752-160426          | `ef34b8e245466aa0f9f23b07ebd72798` |
| 194133-280926          | `8f6537af1add5e7ca1dd0ea7833d5260` |
| 194638-280926          | `89a031b030791cf2703bab4875b0877a` |
| 210434-260926          | `d6fc9864efd37be3c3940d9e7d3ebfd8` |
| 221611-280926          | `69386998822a866b1cec2233fdd7be31` |
| 221614-280926          | `5eb0621fd8fb08fc4c51b4dd2c16680f` |
| 221617-280926(1)       | `bba98af0f2ad1fc748e793a3fd0bfd0e` |
| 221617-280926          | `b79235a4e5eddea275288ed11af811d6` |
| 231624-280926          | `72c97befb13c39580287ccf24fc10002` |
| 231733-280926          | `90e4219a67f979cb5a13ce64e105d9f0` |
| 231739-280926          | `4f1fd69150a6e35c2d08769a53407168` |
| 231744-280926          | `909825b7f45ff12bd229104bff4d9063` |
| 231749-280926          | `4a9b70d391d2c1bc888ed2b68998aaa3` |