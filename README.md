# Shopping-Cart-Simulator
This project is a simple shopping cart simulator built using Swift and UIKit with the MVVM architecture.

## Project Overview
This project is a simple shopping cart simulator built using Swift and UIKit with the MVVM architecture. The main functionality of the app is to allow users to add items to a shopping cart and display the total sum of item prices. Available items and prices are fetched from a REST API and displayed in a list.

## Implemented Features:

- Fetches available items with prices from a REST API once on application start.
- Allows adding and removing items from the shopping cart dynamically.
- Updates the total price and item count every time an item is added or removed.
- Uses NSDiffableDataSource for efficient UI updates.
- Implements LoadingState to manage and display loading states during API calls.
- Implements PurchaseState to handle purchase status updates.
-  Simulates API calls using Alamofire.
- Uses SnapKit for easy and flexible UI layout.
- REST API Endpoints
    * Get all products GET request /getAllProducts
    * Purchase products POST request: /purchaseProducts
## Technologies Used:
- Swift
- UIKit
- MVVM Architecture
- NSDiffableDataSource
- Alamofire (for API calls)
- SnapKit (for UI layout)
- REST API Integration

