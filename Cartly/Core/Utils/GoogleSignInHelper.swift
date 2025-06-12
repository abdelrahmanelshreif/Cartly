//
//  GoogleSignInHelper.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 8/6/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import UIKit

// This helper encapsulates the view-controller-dependent part of Google Sign-In.
// It returns a standard Firebase AuthDataResult, which our FirebaseService will use.

final class GoogleSignInHelper {

    /// Presents the Google Sign-In flow and authenticates with Firebase.
    /// This is an async function because the Google SDK's modern API is async.
    /// - Returns: A Firebase `AuthDataResult`.
    /// - Throws: An `Error` if any step of the process fails.
    func signIn() async throws -> AuthDataResult {
        // 1. Get the top view controller to present the Google Sign-In screen.
        guard let topVC = await UIApplication.shared.topViewController() else {
            throw AppError.couldNotFindTopViewController
        }

        // 2. Start the Google Sign-In flow to get a GIDGoogleUser.
        let gidGoogleUser = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        // 3. Extract the ID token from the Google user.
        guard let idToken = gidGoogleUser.user.idToken?.tokenString else {
            throw AppError.googleIdTokenNotFound
        }

        // 4. Create a Firebase credential.
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: gidGoogleUser.user.accessToken.tokenString)

        // 5. Sign in to Firebase with the credential and return the result.
        return try await Auth.auth().signIn(with: credential)
    }
}



@MainActor
extension UIApplication {
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseController = base ?? connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.rootViewController

        if let nav = baseController as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = baseController as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = baseController?.presentedViewController {
            return topViewController(base: presented)
        }
        return baseController
    }
}
