import CoreLocation
import Foundation

enum DistanceFormatter {
    static func string(from distance: CLLocationDistance) -> String {
        let value = max(0, distance)
        if value < 1_000 {
            return "\(Int(value.rounded())) m"
        }
        return String(format: "%.1f km", value / 1_000)
    }
}
