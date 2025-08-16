**🛍️ Cartly – iOS m-Commerce App (Shopify + Firebase)**

Cartly is a multi-vendor iOS shopping application designed to deliver a seamless online shopping experience. Built with Swift, SwiftUI, and Clean Architecture (MVVM), it integrates Shopify for product and order management and Firebase for authentication, wishlist, and real-time data syncing. The app supports advanced search, dynamic cart, multiple currencies, secure payments, and real-time UI updates.

**📱 Features**

Browse Brands & Categories: Women, Men, Kids, Sale, and product types (T-Shirts, Shoes, etc.)

Advanced Search & Filtering: Search by name, price, rating with smart filters

Dynamic Cart Management: Supports multiple variants and quantities

User Authentication: Email, Google login, or guest mode

Email Verification: Ensures secure account creation

Wishlist Management: Add/remove products and sync in real time

User Profiles: View order history and manage multiple addresses

Multi-Currency Support: View prices in different currencies

Product Reviews: Add, edit, and view product feedback

Promo Code Integration: Apply discounts at checkout

Multiple Payment Options: Apple Pay & cash on delivery

Real-Time Updates: Powered by Combine for reactive UI

Shopify & Firebase Integration: Catalog/orders + auth/wishlist management

**🛠️ Technologies Used**

Language: Swift

UI Frameworks: SwiftUI, UIKit

Architecture: Clean Architecture, MVVM

Reactive Programming: Combine

Networking: Alamofire, URLSession

Backend Services: Shopify Admin API, Firebase SDK (Auth, Firestore, Realtime Database)

Data Handling: Codable for JSON parsing

Design Principles: SOLID, protocol-oriented programming

Version Control: Git + GitHub (feature branches, pull request reviews)

**🏗️ Architecture**

Cartly follows Clean Architecture for separation of concerns:

UI Layer – SwiftUI Views, ViewModels (MVVM)

Domain Layer – Business logic, use cases, entities

Repository Layer – Protocol interfaces for external services

Data Layer – Shopify and Firebase service implementations

**🔄 API Communication**

Unified API layer dispatching requests to Shopify or Firebase via repositories

Combine Publishers for asynchronous events (auth, product fetch, cart updates)

Codable for safe JSON decoding/parsing

**⚙️ Requirements**

iOS 14.0+

Xcode 16.2+

Swift 5.9+

CocoaPods / Swift Package Manager

**📲 Installation**

Clone the repository:

git clone https://github.com/abdelrahmanelshreif/Cartly.git


Navigate to the project folder:

cd Cartly


Install dependencies (if using CocoaPods):

pod install


Open the workspace:

open Cartly.xcworkspace

🤝 Contributing

Contributions are welcome! Feel free to fork this repository, make your changes, and submit a pull request.
