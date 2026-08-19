#!/usr/bin/env python3
from __future__ import annotations

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

IGNORE_PREFIXES = ("/assets/",)
FORBIDDEN_PUBLIC_PREFIXES = (
    "/collection_defs/",
    "/menu_defs/",
    "/_collection_defs/",
    "/_menu_defs/",
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


def route_candidates(route: str) -> list[Path]:
    parsed = urlparse(route)
    path = parsed.path or "/"
    if path == "/":
        return [SITE / "index.html"]

    clean = path.lstrip("/")
    if path.endswith("/"):
        return [SITE / clean / "index.html"]

    candidates = [SITE / clean]
    if "." not in Path(clean).name:
        candidates.append(SITE / clean / "index.html")
        candidates.append(SITE / (clean + ".html"))
    return candidates


def exists_route(route: str) -> bool:
    return any(candidate.is_file() for candidate in route_candidates(route))


def main() -> int:
    if not SITE.is_dir():
        print(f"[VERIFY] Site directory does not exist: {SITE}")
        return 1

    fatal_errors: list[str] = []
    warnings: list[str] = []

    print("[VERIFY] Checking required routes...")
    for route in REQUIRED:
        candidates = route_candidates(route)
        found = next((p for p in candidates if p.is_file()), None)
        if found:
            print(f"  OK  {route} -> {found.relative_to(SITE)}")
        else:
            pretty = ", ".join(str(p.relative_to(SITE)) for p in candidates)
            fatal_errors.append(f"Missing required route: {route} ({pretty})")
            print(f"  ERR {route} -> {pretty}")

    print("[VERIFY] Checking internal page links...")
    html_files = list(SITE.rglob("*.html"))

    for html_file in html_files:
        try:
            text = html_file.read_text(encoding="utf-8", errors="replace")
        except Exception as exc:
            warnings.append(f"Cannot read {html_file.relative_to(SITE)}: {exc}")
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
            if not path or not path.startswith("/"):
                continue

            if any(path.startswith(prefix) for prefix in FORBIDDEN_PUBLIC_PREFIXES):
                fatal_errors.append(
                    f"Internal configuration path exposed in {html_file.relative_to(SITE)}: {href}"
                )
                continue

            if any(path.startswith(prefix) for prefix in IGNORE_PREFIXES):
                continue

            if not exists_route(path):
                warnings.append(
                    f"Broken/legacy internal link in {html_file.relative_to(SITE)}: {href}"
                )

    if warnings:
        print("\n[VERIFY] WARNINGS")
        for item in warnings[:50]:
            print(" - " + item)
        if len(warnings) > 50:
            print(f" - ... and {len(warnings) - 50} more")

    if fatal_errors:
        print("\n[VERIFY] FAILED")
        for item in fatal_errors[:100]:
            print(" - " + item)
        return 1

    print(f"\n[VERIFY] PASSED: {len(html_files)} HTML files checked; core routes are complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
