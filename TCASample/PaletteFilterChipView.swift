import SwiftUI
import ComposableArchitecture

struct PaletteFilterChipFeature: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        var count: Int = 0
        var backgroundColor: Color = .clear
        var isSelected: Bool = false
    }
    
    enum Action {
        case didTapFilter
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        .none
    }
}

struct PaletteFilterChipView: View {
    let store: StoreOf<PaletteFilterChipFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("\(viewStore.count)")
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(viewStore.backgroundColor)
                .cornerRadius(17)
                .onTapGesture { viewStore.send(.didTapFilter) }
                .bold(viewStore.isSelected)
        }
    }
}

struct PaletteFilterChipView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteFilterChipView(
            store: Store(
                initialState: PaletteFilterChipFeature.State(id: .init()),
                reducer: PaletteFilterChipFeature()
            )
        )
    }
}
