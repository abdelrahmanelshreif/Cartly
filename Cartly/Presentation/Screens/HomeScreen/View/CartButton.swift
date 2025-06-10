import SwiftUI

struct CartButton: View {
    let cartState: ResultState<Int>
    @EnvironmentObject var router: AppRouter
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                // Handle cart tap
                router.push(Route.Cart)
            }) {
                Image(systemName: "cart.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.primary)
            }

            switch cartState {
            case .loading:
                ProgressView()
                    .scaleEffect(0.4)
                    .offset(x: 10, y: -10)

            case .success(let count) where count > 0:
                Text("\(count)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 10, y: -10)

            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .offset(x: 10, y: -10)

            default:
                EmptyView()
            }
        }
    }
}
