import SwiftUI
import ComposableArchitecture

struct ColorFilter {
    let palette: ColorPalette
    let count: Int
}

enum ColorPalette: Int, CaseIterable {
    case black
    case red
    case blue
    case green
    case gray
    case yellow
    
    var color: Color {
        switch self {
        case .black:
            return .black
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        case .gray:
            return .gray
        case .yellow:
            return .yellow
        }
    }
}

protocol ColorService: AnyObject {
    var fetchCount: Int { get }
    
    func fetchColors() -> [ColorPalette]
    
    func filters() -> [ColorFilter]
    
    func filteredColors(_ filter: Color) -> [ColorPalette]
}

final class ColorServiceImpl: ColorService {
    let fetchCount: Int = 100
    private var cache: [ColorPalette] = []
    
    func fetchColors() -> [ColorPalette] {
        cache = (0...fetchCount).compactMap { _ -> ColorPalette? in
            guard let randomIndex = (0..<ColorPalette.allCases.count).randomElement() else { return nil }
            return ColorPalette(rawValue: randomIndex)
        }
        
        return cache
    }
    
    func filters() -> [ColorFilter] {
        ColorPalette.allCases.map { palette in
            let count = self.cache.filter { $0 == palette }.count
            return ColorFilter(palette: palette, count: count)
        }
    }
    
    func filteredColors(_ filter: Color) -> [ColorPalette] {
        cache.filter { $0.color == filter }
    }
}

private enum ColorServiceKey: DependencyKey {
    static let liveValue: ColorService = ColorServiceImpl()
}

extension DependencyValues {
    var colorService: ColorService {
        get { self[ColorServiceKey.self] }
        set { self[ColorServiceKey.self] = newValue }
    }
}
