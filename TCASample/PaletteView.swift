import SwiftUI
import ComposableArchitecture
// B Test BBBB
// BBBBBBBBBB
struct Palette: ReducerProtocol {
    struct State: Equatable {
        var colors: IdentifiedArrayOf<ColorViewFeature.State> = []
        var filter: PaletteFilter.State?
        var colorsCache: [ColorViewFeature.State] = []
    }
    
    enum Action {
        case fetch
        case updateColors([ColorViewFeature.State])
        case updateFilters([ColorViewFeature.State])
        case color(id: ColorViewFeature.State.ID, action: ColorViewFeature.Action)
        case filter(PaletteFilter.Action)
    }
    
    @Dependency(\.colorService) var colorService
    // A Test
    // AAAAAA
    // AAAAAA
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetch:
                state.colorsCache = colorService.fetchColors()
                    .map { ColorViewFeature.State(id: .init(), background: $0.color) }
                let colors = state.colorsCache
                return .run { send in
                    await send(.updateColors(colors))
                    await send(.updateFilters(colors))
                }
                
            case let .updateColors(colors):
                state.colors = IdentifiedArrayOf(
                    uniqueElements: colors
                )
                
                return .none
                
            case let .updateFilters(colors):
                let filterList = ColorPalette.allCases.map { palette in
                    let count = colors.filter { $0.background == palette.color }.count
                    return ColorFilter(palette: palette, count: count)
                }
                .map { filter in
                    PaletteFilterChipFeature.State(
                        id: .init(),
                        count: filter.count,
                        backgroundColor: filter.palette.color
                    )
                }
                
                state.filter = PaletteFilter.State(
                    id: .init(),
                    filters: IdentifiedArrayOf(
                        uniqueElements: filterList
                    )
                )
                
                return .none
                
            case let .color(id, .delete):
                state.colorsCache.removeAll(where: { $0.id == id })
                state.colors.removeAll(where: { $0.id == id })
                let displayedColors = state.colors
                let cachedColors = state.colorsCache
                return .run { send in
                    await send(.updateColors(displayedColors.elements))
                    await send(.updateFilters(cachedColors))
                }
                
            case let .filter(.filter(id, .didTapFilter)):
                guard let filter = state.filter?.filters.first(where: { $0.id == id }) else { return .none }
                let filteredColors = state.colorsCache.filter { $0.background == filter.backgroundColor }
                
                return .send(.updateColors(filteredColors))
                
            case .filter(.clear):
                return .send(.updateColors(state.colorsCache))
                
            case let .filter(.remove(color)):
                if var filter = state.filter {
                    filter.filters = IdentifiedArrayOf(
                        uniqueElements: filter.filters.map { filterState in
                            var filterState = filterState
                            if filterState.backgroundColor == color, filterState.count > 0 {
                                filterState.count -= 1
                            }
                            return filterState
                        }
                    )
                    
                    state.filter = filter
                }
                
                return .none
            }
        }
        // 하위 리듀서에서 액션 처리 함
        // ifLet으로 하지 않고 위 Reduce block 내에서 정의하면 상위 reducer에서 처리됨
//        .ifLet(\.filter, action: /Action.filter) {
//            PaletteFilter()
//                .dependency(\.colorService, colorService)
//        }
    }
}

struct PaletteView: View {
    let store: StoreOf<Palette>
    
    init(store: StoreOf<Palette>) {
        self.store = store
        ViewStore(store).send(.fetch)
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                IfLetStore(
                    store.scope(
                        state: \.filter,
                        action: Palette.Action.filter
                    )
                ) { filterStore in
                    PaletteFilterView(store: filterStore)
                }
                .frame(height: 50)
                
                ScrollView(.vertical) {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 16, alignment: .bottom), count: 4), spacing: 16) {
                        ForEachStore(
                            store.scope(
                                state: \.colors,
                                action: Palette.Action.color(id: action:)
                            )
                        ) { childStore in
                            ColorView(store: childStore)
                                .frame(height: 50)
                        }
                    }
                    .padding(.horizontal, 15)
                    .animation(.easeInOut)
                }
            }
        }
    }
}

struct PaletteView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteView(
            store: Store(
                initialState: Palette.State(),
                reducer: Palette()
            )
        )
    }
}
