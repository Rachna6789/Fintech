# Fintech App

A real-time **Fintech Portfolio Management Dashboard** built with Flutter and Dart. The application allows users to manually track stock and cryptocurrency portfolios, monitor price movements, and receive real-time alerts.

## 🚀 Features

* 📊 **Portfolio Dashboard**

  * Track stocks and cryptocurrencies in one place.
  * View portfolio holdings and overall performance.

* 📈 **Stock & Cryptocurrency Tracking**

  * Add and manage assets.
  * Track asset quantities and values.
  * Monitor price changes.

* ⚡ **Real-Time Price Updates**

  * Real-time communication using Socket.IO.
  * Backend built with Node.js and Express.js.

* 🔔 **Price Alerts**

  * Receive notifications when asset prices reach configured thresholds.
  * Firebase Cloud Messaging (FCM) is used for push notifications.

* 🔐 **Authentication & Security**

  * Firebase Authentication.
  * Biometric authentication support.
  * Firestore Security Rules for data protection.

* ☁️ **Cloud Backend**

  * Firebase Firestore for storing portfolio-related data.
  * Firebase Cloud Functions for backend-triggered operations.

* 🎨 **Cross-Platform UI**

  * Built with Flutter and Dart.
  * Responsive interface for Android, iOS, and other supported platforms.

## 🛠️ Tech Stack

### Frontend

* **Flutter**
* **Dart**
* **Riverpod**

### Backend

* **Node.js**
* **Express.js**
* **Socket.IO**

### Firebase

* **Firebase Authentication**
* **Cloud Firestore**
* **Firebase Cloud Functions**
* **Firebase Cloud Messaging (FCM)**
* **Firestore Security Rules**

## 🏗️ System Architecture

```text
                   ┌──────────────────────┐
                   │      Flutter App     │
                   │   Dart + Riverpod    │
                   └──────────┬───────────┘
                              │
                    HTTP / Socket.IO
                              │
                              ▼
                   ┌──────────────────────┐
                   │   Node.js Backend    │
                   │      Express.js      │
                   └──────────┬───────────┘
                              │
                         Socket.IO
                              │
                              ▼
                   ┌──────────────────────┐
                   │ Real-Time Price Data │
                   └──────────────────────┘

                   ┌──────────────────────┐
                   │       Firebase       │
                   │                      │
                   │ Authentication       │
                   │ Firestore            │
                   │ Cloud Functions      │
                   │ FCM                  │
                   └──────────────────────┘
```

## 📱 Application Workflow

1. User signs in using Firebase Authentication.
2. The user accesses the portfolio dashboard.
3. Stocks and cryptocurrencies can be added to the portfolio.
4. Portfolio information is stored in Firestore.
5. The Node.js/Express.js backend manages real-time communication.
6. Socket.IO delivers real-time price updates.
7. Cloud Functions process relevant backend operations.
8. FCM sends price alerts and notifications to the user.

## 📂 Project Structure

```text
Fintech/
│
├── lib/
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── main.dart
│
├── backend/
│   ├── controllers/
│   ├── routes/
│   ├── services/
│   ├── socket/
│   └── server.js
│
├── android/
├── ios/
├── web/
├── assets/
├── pubspec.yaml
└── README.md
```

> The exact folder structure may vary depending on the current implementation.

## ⚙️ Installation & Setup

### Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Node.js
* npm
* Git
* Android Studio or Xcode
* Firebase project

### 1. Clone the Repository

```bash
git clone https://github.com/Rachna6789/Fintech.git
cd Fintech
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Create a Firebase project and configure Firebase for the required platforms.

Enable:

* Firebase Authentication
* Cloud Firestore
* Firebase Cloud Messaging
* Cloud Functions

Add the required Firebase configuration files to the appropriate platform directories.

### 4. Configure Backend

Navigate to the backend directory:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

Create a `.env` file and add the required environment variables:

```env
PORT=5000
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_CLIENT_EMAIL=your_client_email
FIREBASE_PRIVATE_KEY=your_private_key
```

**Do not commit `.env` or Firebase private credentials to GitHub.**

### 5. Start the Backend

```bash
npm start
```

### 6. Run the Flutter Application

From the project root:

```bash
flutter run
```

## 🔐 Security

The project uses multiple security mechanisms:

* Firebase Authentication for user authentication.
* Firestore Security Rules for database access control.
* Biometric authentication for additional device-level protection.
* Environment variables for sensitive backend configuration.
* Firebase credentials and API keys should not be committed to the repository.

Add sensitive files to `.gitignore`:

```gitignore
.env
google-services.json
GoogleService-Info.plist
*.jks
*.keystore
```

> Configure your Firebase project according to the requirements of your deployment environment.

## 🔔 Notifications

Firebase Cloud Messaging is used to deliver notifications such as:

* Price threshold alerts
* Portfolio-related notifications
* Important market updates

## 🔄 Real-Time Communication

Socket.IO provides persistent, bidirectional communication between the Flutter application and Node.js backend.

```text
Flutter Client
      │
      │ Socket.IO Connection
      ▼
Node.js + Express
      │
      ▼
Real-Time Price Updates
      │
      ▼
Flutter Dashboard
```

This allows the dashboard to update relevant information without requiring continuous manual refreshes.

## 📊 State Management

**Riverpod** is used for application state management.

It helps manage:

* Portfolio state
* Authentication state
* Asset information
* Real-time updates
* API/service dependencies

## 🔮 Future Improvements

* Integration with production-grade stock market APIs.
* Integration with cryptocurrency market APIs.
* Advanced portfolio analytics.
* Historical price charts.
* Profit/loss analysis.
* Automated portfolio rebalancing.
* Advanced notification preferences.
* Unit, widget, and integration testing.
* Redis/Pub/Sub for scalable real-time communication.
* Logging and monitoring.
* Cloud deployment of the backend.
* Improved observability and performance monitoring.

## 🎯 Learning Outcomes

Through this project, the following technologies and concepts were implemented:

* Flutter application development
* Dart programming
* Riverpod state management
* REST API integration
* Node.js backend development
* Express.js
* Socket.IO real-time communication
* Firebase Authentication
* Cloud Firestore
* Firebase Cloud Functions
* Firebase Cloud Messaging
* Authentication and authorization
* Real-time application architecture

## 👩‍💻 Author

**Rachna Galipelli**

GitHub:
https://github.com/Rachna6789

## 📄 License

This project is intended for educational and portfolio purposes.
