import SwiftUI
import ComposableArchitecture

struct ColorViewFeature: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        var background: Color = .red
    }
    
    enum Action {
        case delete
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .delete:
                print("## parent에서 제거됨")
                return .none
            }
        }
    }
}

struct ColorView: View {
    let store: StoreOf<ColorViewFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                viewStore.state.background
                
                Button { viewStore.send(.delete) } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }
}

struct ColorView_Previews: PreviewProvider {
    static var previews: some View {
        ColorView(
            store: Store(
                initialState: ColorViewFeature.State(id: .init()),
                reducer: ColorViewFeature()
            )
        )
    }
}
