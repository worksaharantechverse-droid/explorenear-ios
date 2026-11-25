# Technical Challenges — ExploreNear

## Keyless local search

`MKLocalSearch` provides nearby points of interest without third-party API keys. Category terms are mapped to Apple Maps search queries.

## Permission fallback

When location permission is denied or unavailable, a fixed San Francisco coordinate is used and clearly surfaced in the UI. This keeps the app usable in the simulator and in restricted environments.

## Map/list coordination

The same `Place` values drive both map annotations and list rows. Selecting a category triggers a new search and updates both representations consistently.

## Pure helpers

Distance formatting and fallback selection are pure functions, allowing deterministic unit tests without touching CoreLocation or MapKit.

## Physical-device testing

GPS accuracy, permission prompts and live Apple Maps results are documented rather than claimed as verified.
