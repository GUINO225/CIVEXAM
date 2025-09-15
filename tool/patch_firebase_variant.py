#!/usr/bin/env python3
"""Apply Windows-specific fixes to the Firebase C++ SDK variant header.

The Firebase C++ SDK that ships with FlutterFire for Windows currently uses
`strncpy` in a couple of places inside `firebase/variant.h`.  Newer versions of
MSVC emit warnings (and in some configurations errors) for this unsafe call.
This utility patches the extracted SDK in-place by replacing those invocations
with the safer `strncpy_s` variant that respects the destination buffer size and
truncates automatically.

This script is idempotent – it may be re-run at any time after the SDK has been
extracted into the `build/windows/x64/extracted/firebase_cpp_sdk_windows` folder.

Usage:
  python3 tool/patch_firebase_variant.py
"""

from __future__ import annotations

import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
TARGET = ROOT / "build" / "windows" / "x64" / "extracted" / "firebase_cpp_sdk_windows" / "include" / "firebase" / "variant.h"

OLD_CALL = "strncpy(dst, src, len)"
NEW_CALL = "strncpy_s(dst, len, src, _TRUNCATE)"


def main() -> int:
    if not TARGET.exists():
        print(f"Firebase variant header not found at {TARGET}. Did you run the Windows build first?", file=sys.stderr)
        return 1

    original = TARGET.read_text(encoding="utf-8")
    if OLD_CALL not in original:
        print("No strncpy usage found – the header may already be patched.")
        return 0

    patched = original.replace(OLD_CALL, NEW_CALL)
    if patched == original:
        print("Header already up to date; no changes made.")
        return 0

    TARGET.write_text(patched, encoding="utf-8")
    print("Patched firebase/variant.h to use strncpy_s on Windows.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
