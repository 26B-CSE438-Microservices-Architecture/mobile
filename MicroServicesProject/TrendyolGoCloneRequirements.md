# Trendyol Go Clone - iOS Real-Time Quick Commerce App

A modern iOS application inspired by Trendyol Go, built with SwiftUI and integrated with LiveKit to facilitate real-time communication between customers and delivery partners within a microservices ecosystem.

## Key Features
* **Instant Delivery Tracking:** Real-time map updates and order status synchronization.
* **Courier-Customer Communication:** High-performance voice/video calling using WebRTC via LiveKit.
* **Modern UI:** A fluid, native experience built entirely with SwiftUI 6.0.
* **Microservices Ready:** Designed to consume data from a distributed backend architecture.

## Requirements

### Functional
* **User Authentication:** Secure login and session management.
* **Real-Time Call:** Direct sub-second latency communication with the delivery courier.
* **Order Flow:** Seamless transition from cart to on-the-way status.

### Technical
* **Swift 6.0 / iOS 17+**
* **LiveKit Swift SDK:** Real-time media layer.
* **CoreLocation:** For precise delivery tracking.

## Planned Interfaces

| Screen | Description | Components |
| :--- | :--- | :--- |
| Login | Secure entry point | TextField, SecureField, AuthButton |
| Active Order | Real-time tracking and map | MapView, StatusTimeline, CallCourierButton |
| Profile | User and Wallet management | List, NavigationLink, SettingsToggle |

## Project Structure (SwiftUI)
* **Views/:** UI components and main navigation flows.
* **ViewModels/:** State management and business logic for API interactions.
* **Services/:** Network layer for Auth and Gateway communication.

## Microservices Integration and Data Requirements

As the Mobile Team, we require the following data structures from the Auth Service and API Gateway for session-based connectivity.

### Expected JSON Data Structure (Auth and Session)
```json
{
  "status": "success",
  "data": {
    "auth_token": "bearer_eyJhbGciOiJIUzI1Ni...",
    "user_info": {
      "user_id": "98765",
      "full_name": "Melih Atalay",
      "email": "melihatalay08@gmail.com",
      "role": "customer"
    },
    "active_session": {
      "session_id": "order_550e8400",
      "gateway_url": "https://api-gateway.your-system.com/v1",
      "livekit_token": "optional_token_for_instant_call_access"
    }
  }
}
```

### Requirements from Backend Teams
* **Auth Service:** Provide a secure JWT containing user roles (Customer/Courier) and standard profile data.
* **API Gateway:** A single entry point to route requests to specific microservices (Order, Tracking, Communication). It must handle header-based authentication.
* **Connectivity:** All endpoints must support HTTPS with standard RESTful methods.
