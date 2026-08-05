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

## Building

Standard Xcode project (`WebscraperUI.xcodeproj`) — open and run/build from
Xcode; there's no CLI build script or test target.
