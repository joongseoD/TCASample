import SwiftUI
import ComposableArchitecture

struct PaletteFilter: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        var filters: IdentifiedArrayOf<PaletteFilterChipFeature.State> = [
            .init(id: .init(), backgroundColor: .red),
            .init(id: .init(), backgroundColor: .blue),
            .init(id: .init(), backgroundColor: .yellow),
            .init(id: .init(), backgroundColor: .gray)
        ]
        
        var selectedFilter: PaletteFilterChipFeature.State?
    }
    
    enum Action {
        case filter(id: PaletteFilterChipFeature.State.ID, action: PaletteFilterChipFeature.Action)
        case remove(color: Color)
        case clear
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .filter(id, .didTapFilter):
                state.filters = IdentifiedArrayOf(
                    uniqueElements: state.filters.map { filter in
                        var filter = filter
                        filter.isSelected = filter.id == id
                        return filter
                    }
                )
                state.selectedFilter = state.filters.first(where: { $0.isSelected })
                return .none
            case .remove:
                return .none
            case .clear:
                return .none
                
            }
        }
    }
}

struct PaletteFilterView: View {
    let store: StoreOf<PaletteFilter>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView(.horizontal) {
                LazyHStack {
                    Button("ALL") { viewStore.send(.clear) }
                        
                    ForEachStore(
                        store.scope(
                            state: \.filters,
                            action: PaletteFilter.Action.filter(id: action:)
                        )
                    ) { childStore in
                        PaletteFilterChipView(store: childStore)
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

struct PaletteFilterView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteFilterView(
            store: Store(
                initialState: PaletteFilter.State(id: .init()),
                reducer: PaletteFilter()
            )
        )
    }
}
