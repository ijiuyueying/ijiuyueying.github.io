#!/usr/bin/env python3
from __future__ import annotations

import os
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse

SITE = Path(sys.argv[1] if len(sys.argv) > 1 else "_site").resolve()

REQUIRED = [
    "/",
    "/404.html",
    "/articles/",
    "/bank/",
    "/manufacturing/",
    "/ecommerce/",
    "/sql-hive/",
    "/python/",
    "/git/",
    "/nav/",
    "/music/",
    "/gallery/",
    "/videos/",
    "/search/",
]

IGNORE_PREFIXES = (
    "/assets/",
)

class LinkParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links: list[str] = []

    def handle_starttag(self, tag, attrs):
        if tag != "a":
            return
        for key, value in attrs:
            if key == "href" and value:
                self.links.append(value)


def route_to_file(route: str) -> Path:
    parsed = urlparse(route)
    path = parsed.path or "/"
    if path == "/":
        return SITE / "index.html"
    if path.endswith("/"):
        return SITE / path.lstrip("/") / "index.html"
    return SITE / path.lstrip("/")


def exists_route(route: str) -> bool:
    target = route_to_file(route)
    return target.is_file()


def main() -> int:
    if not SITE.is_dir():
        print(f"[VERIFY] Site directory does not exist: {SITE}")
        return 1

    errors: list[str] = []

    print("[VERIFY] Checking required routes...")
    for route in REQUIRED:
        target = route_to_file(route)
        if target.is_file():
            print(f"  OK  {route} -> {target.relative_to(SITE)}")
        else:
            errors.append(f"Missing required route: {route} ({target.relative_to(SITE)})")
            print(f"  ERR {route} -> {target.relative_to(SITE)}")

    print("[VERIFY] Checking internal page links...")
    html_files = list(SITE.rglob("*.html"))
    for html_file in html_files:
        try:
            text = html_file.read_text(encoding="utf-8", errors="replace")
        except Exception as exc:
            errors.append(f"Cannot read {html_file.relative_to(SITE)}: {exc}")
            continue

        parser = LinkParser()
        parser.feed(text)
        for href in parser.links:
            href = href.strip()
            if not href or href.startswith(("#", "mailto:", "tel:", "javascript:")):
                continue
            parsed = urlparse(href)
            if parsed.scheme or parsed.netloc:
                continue
            path = parsed.path
            if not path:
                continue
            if any(path.startswith(prefix) for prefix in IGNORE_PREFIXES):
                continue
            if not path.startswith("/"):
                continue
            if not exists_route(path):
                errors.append(
                    f"Broken internal link in {html_file.relative_to(SITE)}: {href}"
                )

    if errors:
        print("\n[VERIFY] FAILED")
        for item in errors[:100]:
            print(" - " + item)
        if len(errors) > 100:
            print(f" - ... and {len(errors) - 100} more")
        return 1

    print(f"[VERIFY] PASSED: {len(html_files)} HTML files checked.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
