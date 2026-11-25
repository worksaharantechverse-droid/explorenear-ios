import Foundation

enum PlaceCategory: String, CaseIterable, Identifiable {
    case coffee
    case restaurants
    case parks
    case museums

    var id: String { rawValue }

    var title: String {
        switch self {
        case .coffee: return "Coffee"
        case .restaurants: return "Restaurants"
        case .parks: return "Parks"
        case .museums: return "Museums"
        }
    }

    var query: String {
        switch self {
        case .coffee: return "coffee shops"
        case .restaurants: return "restaurants"
        case .parks: return "parks"
        case .museums: return "museums"
        }
    }

    var symbol: String {
        switch self {
        case .coffee: return "cup.and.saucer"
        case .restaurants: return "fork.knife"
        case .parks: return "leaf"
        case .museums: return "building.columns"
        }
    }
}
