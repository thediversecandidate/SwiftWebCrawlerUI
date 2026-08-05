# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A SwiftUI iOS app (`WebscraperUI`) that runs an in-app breadth-first web
crawler directly on-device — distinct from `ElasticSearchPOC` (which is a
client for the separate `Webscraping` Django API) and from the `Webscraping`
/ `Webscraping-Maketing` Python scrapers. This one does its own crawling and
keyword search in Swift, with no backend involved.

## Structure

- `ContentView.swift` — both the UI (search-term field, start-URL field,
  result-limit field, two progress bars, a scrolling list of visited URLs)
  and the crawler logic (`Crawler` class) in one file. `Crawler.crawl()`
  recursively visits URLs breadth-first via `URLSession`, checks each page's
  raw HTML for `wordToSearch` via `String.contains` (`parse()` /
  `find(word:)`), and extracts further links with a regex
  (`href="(http://.*?|https://.*?)"`) rather than an HTML parser —
  extending link discovery means editing that regex, not adding a real
  parser, unless you're deliberately upgrading it.
- `ScrapeResults.swift` — `ObservableObject` driving the two progress bars:
  `progress` (pages visited / `maximumPagesToVisit`) and `quality`
  (keyword hits / `maximumPagesToVisit`).
- `ProgressBarView.swift` — the progress bar view used twice above.
- `startUrl`, `wordToSearch`, `maximumPagesToVisit` in `ContentView.swift`
  are top-level `var`/`let`s used as informal shared state between the view
  and `Crawler` — `search()` mutates `wordToSearch` /
  `maximumPagesToVisit` from the UI's `@State` fields before starting a
  crawl, rather than passing them through `Crawler`'s initializer.

## Bugs fixed (2026-08 hardening pass)

- **`collectLinks()`'s `trim(url:)` called `.substring(from:)` on a plain
  `String`.** That method was removed from the Swift standard library in
  Swift 4 (Foundation's `NSString.substring(with:)`, used elsewhere in the
  same function, is unrelated and still valid) — as written, this was a
  **compile error** on any Swift 5 toolchain, meaning the app could not
  build at all. Rewritten with range-based slicing
  (`withoutTrailingQuote[start...]`), and the start index is now computed
  against the already-trailing-trimmed string instead of the original one
  (mixing `String.Index` values computed from two different strings is
  its own latent bug, even when it happens to work for simple ASCII
  input).

## Known issue, not fixed here: crawler state isn't thread-safe

`Crawler.visitedPages` / `.pagesToVisit` (`Set<URL>`) are mutated both from
the main thread (`ContentView.search()` calling `crawl(url:)` directly) and
from `URLSession`'s background delegate queue (inside
`visit(page:)`'s `dataTask` completion handler, and again inside
`parse(document:url:)` -> `collectLinks()`), with no lock or serial queue
protecting them. That's a data race — under real crawl volume this can
corrupt the sets or crash, not just produce wrong results. Not fixed in
this pass: a correct fix means routing all crawler-state mutation through
one serial `DispatchQueue` (or an actor, if targeting Swift concurrency),
and there's no way to build/run this project in the environment this
review was done in to verify a fix actually resolves it rather than
introducing a deadlock. Worth prioritizing before this crawler is used for
anything beyond quick manual testing.

## Building

Standard Xcode project (`WebscraperUI.xcodeproj`) — open and run/build from
Xcode; there's no CLI build script or test target. **No Xcode/Swift
toolchain was available in the environment the `trim(url:)` fix above was
made in** (Linux sandbox) — verified by careful reading against known
Swift stdlib API history, not by an actual build. Build and smoke-test in
Xcode before relying on it.
