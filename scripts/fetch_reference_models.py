#!/usr/bin/env python3
"""Download and verify the external model used for Rǫdd reference audio."""

from __future__ import annotations

import argparse
import hashlib
import urllib.request
from pathlib import Path


FILES = {
    "is_IS-bui-medium.onnx": {
        "url": "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/is/is_IS/bui/medium/is_IS-bui-medium.onnx",
        "sha256": "3a645b2d2850e4098f01f3765cece931836c03741e01a5cc514d09d39d37c05c",
    },
    "is_IS-bui-medium.onnx.json": {
        "url": "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/is/is_IS/bui/medium/is_IS-bui-medium.onnx.json",
        "sha256": "3cae728572fbb397713d047f2299247bb76b62639d9dfdcd65b26c578b8aba45",
    },
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    args.destination.mkdir(parents=True, exist_ok=True)

    for name, metadata in FILES.items():
        target = args.destination / name
        if not target.exists() or sha256(target) != metadata["sha256"]:
            print(f"Downloading {name}...")
            urllib.request.urlretrieve(metadata["url"], target)
        actual = sha256(target)
        if actual != metadata["sha256"]:
            raise SystemExit(f"SHA-256 mismatch for {target}: {actual}")
        print(f"Verified {target}: {actual}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
