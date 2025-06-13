//
//  GoogleSignInHelper.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 8/6/25.
//

import FirebaseAuth
import Foundation
import GoogleSignIn
import UIKit

// This helper encapsulates the view-controller-dependent part of Google Sign-In.
// It returns a standard Firebase AuthDataResult, which our FirebaseService will use.

final class GoogleSignInHelper {

    /// Presents the Google Sign-In flow and authenticates with Firebase.
    /// This is an async function because the Google SDK's modern API is async.
    /// - Returns: A Firebase `AuthDataResult`.
    /// - Throws: An `Error` if any step of the process fails.
    @MainActor
    func signIn() async throws -> AuthDataResult {
        // No need for 'await' on topViewController() since we're already on MainActor
        guard let topVC = UIApplication.shared.topViewController() else {
            throw AppError.couldNotFindTopViewController
        }

        let gidGoogleUser = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: topVC)

        guard let idToken = gidGoogleUser.user.idToken?.tokenString else {
            throw AppError.googleIdTokenNotFound
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: gidGoogleUser.user.accessToken.tokenString
        )

        return try await Auth.auth().signIn(with: credential)
    }

}

@MainActor
extension UIApplication {
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseController =
            base
            ?? connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.rootViewController

        if let nav = baseController as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = baseController as? UITabBarController,
            let selected = tab.selectedViewController
        {
            return topViewController(base: selected)
        }
        if let presented = baseController?.presentedViewController {
            return topViewController(base: presented)
        }
        return baseController
    }
}
