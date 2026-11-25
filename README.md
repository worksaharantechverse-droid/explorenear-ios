# ExploreNear

A programmatic UIKit nearby-discovery app using CoreLocation, MapKit and `MKLocalSearch`. Browse nearby categories on a map or in a list and open directions.

## Installation

```bash
cd 10-ExploreNear
brew install xcodegen
xcodegen generate
open ExploreNear.xcodeproj
```

## Build

```bash
xcodebuild -project ExploreNear.xcodeproj -scheme ExploreNear \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/ExploreNearDerived CODE_SIGNING_ALLOWED=NO build
```

## Architecture

- **Models**: `Place`, `PlaceCategory`, `PlaceAnnotation`.
- **Services**: `LocationServicing` with CoreLocation, `PlaceSearching` with MapKit `MKLocalSearch`.
- **Fallback**: `LocationFallback` provides a default San Francisco coordinate when permission is unavailable.
- **ViewModel**: `ExploreViewModel` coordinates category selection, search and place state.
- **Views**: `ExploreViewController`, `PlaceDetailViewController`, `DistanceFormatter`.

## Features

- Category chips for coffee, restaurants, parks and museums.
- Map view with custom annotations.
- List of nearby places with distance formatting.
- Detail screen with MapKit metadata and directions link.
- Clear fallback banner when using the default location.
- Light and dark appearance.

## Verification

- Build: passed on Xcode 26.0.1, iOS 17.0 deployment target.
- Test targets compile via `build-for-testing`.
- Unit and UI tests authored; execution skipped at the user's request.
- Installed and launched on iPhone 17 (iOS 26.0) with a simulator location; genuine light and dark screenshots captured.

## Known limitations

- Real GPS accuracy and permission prompts require a physical device.
- `MKLocalSearch` requires internet access.
- Results depend on Apple Maps data availability for the current region.
