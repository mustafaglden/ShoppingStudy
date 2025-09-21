# ShoppingStudy

A modern, feature-rich e-commerce iOS application built with SwiftUI, demonstrating professional iOS development practices including MVVM architecture, multi-language support, and comprehensive user management.

## Features

### Core Functionality
- **User Authentication**: Register and login system with local user persistence
- **Product Catalog**: Browse products fetched from Fake Store API
- **Shopping Cart**: Add, remove, and modify quantities of products
- **Favorites**: Mark products as favorites for quick access
- **Gift System**: Send products as gifts to other users
- **Purchase History**: Track all past purchases and orders
- **User Profiles**: Manage personal information and view statistics

### Technical Features
- **Multi-Language Support**: Full localization for English and Turkish
- **Multi-Currency Support**: USD, EUR, and TRY with real-time exchange rates
- **Offline Persistence**: Local data storage using UserDefaults
- **Modern Architecture**: MVVM pattern with dependency injection
- **Async/Await**: Modern Swift concurrency for all network operations
- **SwiftUI**: 100% SwiftUI implementation with iOS 16+ features

##  Architecture

### Design Pattern: MVVM
```
View (SwiftUI) ←→ ViewModel (ObservableObject) ←→ Model/Service Layer
```

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0 or later
- Swift 5.9

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/ShoppingStudy.git
```

2. Open the project in Xcode:
```bash
cd ShoppingStudy
open ShoppingStudy.xcodeproj
```

3. Build and run the project (⌘+R)

### Configuration

The app uses the following APIs:
- **Products API**: https://fakestoreapi.com
- **Exchange Rate API**: https://v6.exchangerate-api.com

No additional API key configuration is required as the keys are included.

## App Screens

### 1. Authentication
- **Login Screen**: User login with language selection
- **Register Screen**: New user registration

### 2. Main Features
- **Product List**: Browse and search products with filtering options
- **Product Detail**: View detailed product information
- **Shopping Cart**: Manage cart items and proceed to checkout
- **Favorites**: Quick access to favorite products
- **Profile**: View statistics and manage settings

### 3. Additional Features
- **Gift Selection**: Choose recipients for gift purchases
- **Checkout**: Simulated payment processing
- **Settings**: Language and currency preferences
- **Purchase History**: View past orders

## Limitations

Even though the Fake Store API returns a success response when registering a new user, the registration is not actually persisted. Users can only log in with the pre-defined accounts available in the API’s login dataset. This is a limitation of the Fake Store API, not the application.

## Localization

The app supports two languages:
- English (en)
- Turkish (tr)

## Currency Support

Supported currencies:
- USD ($) - US Dollar
- EUR (€) - Euro
- TRY (₺) - Turkish Lira

Exchange rates are fetched in real-time and cached for performance.

## Testing

### Running Tests
```bash
# Run all tests
⌘+U in Xcode

# Run specific test suite
Select test file → ⌘+U
```

### Test Coverage
- Unit tests for core business logic
- ViewModel tests with mock services
- Persistence layer tests
- Currency conversion tests

## Dependencies

This project has **zero external dependencies**. All functionality is implemented using native iOS frameworks:
- SwiftUI for UI
- Combine for reactive programming
- URLSession for networking
- UserDefaults for local storage

## Data Persistence

User data is stored locally using UserDefaults with Codable models:
- User profiles
- Shopping cart items
- Favorites
- Purchase history
- App preferences

## Code Style

The project follows Swift best practices:
- SwiftUI declarative syntax
- Async/await for asynchronous operations
- Protocol-oriented programming
- Dependency injection
- SOLID principles

## Acknowledgments

- [Fake Store API](https://fakestoreapi.com) for providing the product data
- [Exchange Rate API](https://exchangerate-api.com) for currency conversion rates
