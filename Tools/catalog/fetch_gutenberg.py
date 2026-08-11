#!/usr/bin/env python3
"""Download the Project Gutenberg plain-text books listed in books.json.

Files are cached in cache/gutenberg/{id}.txt; re-runs skip cached books.
"""
import json
import pathlib
import sys
import time
import urllib.request

HERE = pathlib.Path(__file__).parent
CACHE = HERE / "cache" / "gutenberg"
BOOKS = HERE / "books.json"
RETRIES = 3


def fetch(book_id: int) -> str:
    urls = [
        f"https://www.gutenberg.org/ebooks/{book_id}.txt.utf-8",
        f"https://www.gutenberg.org/cache/epub/{book_id}/pg{book_id}.txt",
    ]
    last_error = None
    for url in urls:
        for attempt in range(1, RETRIES + 1):
            try:
                request = urllib.request.Request(url, headers={"User-Agent": "poetic-catalog-tool"})
                with urllib.request.urlopen(request, timeout=60) as response:
                    return response.read().decode("utf-8-sig")
            except Exception as error:  # noqa: BLE001
                last_error = error
                time.sleep(attempt * 2)
    raise RuntimeError(f"could not fetch book {book_id}: {last_error}")


def main() -> int:
    CACHE.mkdir(parents=True, exist_ok=True)
    books = json.loads(BOOKS.read_text())
    failed = []
    for book in books:
        out = CACHE / f"{book['id']}.txt"
        if out.exists():
            continue
        try:
            text = fetch(book["id"])
            out.write_text(text)
            print(f"{book['id']} {book['book']}: {len(text)} chars")
            time.sleep(1)
        except Exception as error:  # noqa: BLE001
            failed.append((book["id"], str(error)))
            print(f"{book['id']}: FAILED {error}", file=sys.stderr)
    if failed:
        return 1
    print("done — all books cached")
    return 0


if __name__ == "__main__":
    sys.exit(main())
