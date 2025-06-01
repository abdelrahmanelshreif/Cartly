import SwiftUI

struct HomeToolbar: View {
    let cartState: ResultState<Int>

    var body: some View {
        HStack {
            UserInfoView()
                .layoutPriority(1)

            Spacer()

            HStack(spacing: 16) {
                SearchButton()
                CartButton(cartState: cartState)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
