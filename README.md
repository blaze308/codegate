# CodeGate 🎫

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?logo=firebase)](https://firebase.google.com)
[![Style: Material 3](https://img.shields.io/badge/Style-Material%203-757575?logo=material-design)](https://m3.material.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

CodeGate is a modern event management and QR code-based ticketing system built with Flutter and Firebase. It provides a seamless experience for event hosts to create and manage events, and for guests to access events through secure QR codes.

## ✨ Features

- **Event Creation & Management**

  - Create events with detailed information (title, date, venue, description)
  - Set event segments and schedules
  - Manage venue details and dress codes
  - Add vendor/partner information

- **QR Code Integration**

  - Generate secure QR codes for event access
  - Real-time QR code scanning and validation
  - Support for multiple scanning devices

- **Firebase Integration**

  - Real-time data synchronization
  - Secure authentication system
  - Cloud storage for event assets
  - Scalable database architecture

- **Modern UI/UX**
  - Material 3 design system
  - Dark mode support
  - Responsive layout
  - Custom theme with deep purple accent

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.7.0)
- Firebase account and project setup
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository

```bash
git clone https://github.com/blaze308/codegate.git
cd codegate
```

2. Install dependencies

```bash
flutter pub get
```

3. Configure Firebase

- Create a new Firebase project
- Download `google-services.json` for Android
- Download `GoogleService-Info.plist` for iOS
- Generate the Firebase configuration file using FlutterFire CLI
- Place the configuration files in their respective platform directories

4. Run the app

```bash
flutter run
```

## 📱 Supported Platforms

- Android
- iOS
- Web
- macOS
- Linux
- Windows

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - UI framework
- [Firebase](https://firebase.google.com/) - Backend and authentication
- [QR Flutter](https://pub.dev/packages/qr_flutter) - QR code generation
- [Mobile Scanner](https://pub.dev/packages/mobile_scanner) - QR code scanning
- [Cloud Firestore](https://firebase.google.com/products/firestore) - Database
- [Firebase Auth](https://firebase.google.com/products/auth) - Authentication
- [Firebase Storage](https://firebase.google.com/products/storage) - File storage

## 📦 Key Dependencies

- `firebase_core`: ^3.14.0
- `cloud_firestore`: ^5.6.9
- `firebase_auth`: ^5.6.0
- `mobile_scanner`: ^7.0.1
- `qr_flutter`: ^4.1.0
- `intl`: ^0.20.2
- `gallery_saver`: ^2.3.2
- `image_picker`: ^1.0.7

## 🔒 Environment Setup

Make sure to set up your Firebase configuration properly:

1. Create a Firebase project in the Firebase Console
2. Enable Authentication, Firestore, and Storage services
3. Configure your app's Firebase options
4. Keep the Firebase configuration file (`firebase_options.dart`) secure and never commit it to version control

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Known Issues

- Check the [Issues](https://github.com/blaze308/codegate/issues) page for known issues and feature requests
- Feel free to create new issues if you find any bugs

## 📞 Contact

Your Name - [@blaze308](https://twitter.com/blaze308)

Project Link: [https://github.com/blaze308/codegate](https://github.com/blaze308/codegate)

---

<p align="center">Made with ❤️ using Flutter and Firebase</p>
