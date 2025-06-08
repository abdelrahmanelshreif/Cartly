import SwiftUI

struct SearchToolbar: View {
    let cartState: ResultState<Int>

    var body: some View {
        HStack(spacing: 16) {
            CartButton(cartState: cartState)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
