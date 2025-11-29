# WeRun 2.0 🏃‍♂️

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-DD2C00?style=for-the-badge&logo=firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**A personal learning project exploring Flutter, Firebase, and Clean Architecture**

[Features](#-features) • [Setup](#-setup) • [Tech Stack](#-tech-stack) • [Structure](#-project-structure) • [Learning Notes](#-what-i-learned)

</div>

---

## 📖 About

This is a personal project I built to practice mobile development with Flutter. It's a running tracker app that implements GPS tracking, real-time maps, social features, and AI-powered route suggestions. The main goal was to learn Clean Architecture, BLoC pattern, and Firebase integration in a real-world scenario.

## ✨ Features

### 🏃 Core Tracking
- Real-time GPS tracking with distance, pace, and route recording
- Activity history with detailed statistics
- Visual analytics with charts and graphs
- Run sessions saved to Firestore

### 🤖 Smart Features
- AI-powered route suggestions (practice implementation)
- Basic weather integration
- Performance analytics

### 🗺️ Maps & Navigation
- MapLibre integration for route visualization
- Custom route planning
- Location marker system

### 👥 Social Components
- Friend system with friend requests
- Community leaderboard
- Basic chat functionality
- User profiles

### 🔐 Authentication
- Firebase Auth implementation
- Email/password and social login
- User session management

## 🚀 Setup

### Prerequisites

- Flutter SDK: `>=3.0.0`
- Dart SDK: `>=3.0.0`
- Android Studio or VS Code
- Xcode (for iOS development)
- Firebase account

### Installation Steps

1. **Clone the repository**
```bash
git clone https://github.com/MinhDeepZaiZLer/WeRun_2.0.git
cd WeRun_2.0
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
```bash
# Add google-services.json to android/app/
# Add GoogleService-Info.plist to ios/Runner/
# Update firebase_options.dart with your config
```

4. **Run the app**
```bash
flutter run
```

### Building

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🛠 Tech Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **BLoC Pattern**: State management with flutter_bloc
- **GetIt**: Dependency injection
- **MapLibre**: Map rendering

### Backend & Services
- **Firebase Auth**: User authentication
- **Cloud Firestore**: NoSQL real-time database
- **Firebase Storage**: File storage (planned)
- **Location Services**: GPS tracking

### Architecture
- **Clean Architecture**: Separation of concerns
- **Repository Pattern**: Data abstraction layer
- **Use Cases**: Business logic encapsulation

## 📁 Project Structure

```
│   main.dart
│
├───ai
├───core
│   ├───constants
│   ├───di
│   │       injection.config.dart
│   │       injection.dart
│   │
│   └───utils
├───data
│   ├───models
│   │       run_activity_model.dart
│   │
│   ├───repositories
│   │       ai_repository_impl.dart
│   │       auth_repository_impl.dart
│   │       chat_repository_impl.dart
│   │       leaderboard_repository_impl.dart
│   │       run_repository_impl.dart
│   │       user_repository_impl.dart
│   │       weather_repository_impl.dart
│   │
│   └───services
│           firebase_auth_service.dart
│           firestore_service.dart
│           gps_service.dart
│           weather_service.dart
│
├───domain
│   ├───entities
│   │       chat_message.dart
│   │       friend_request.dart
│   │       leaderboard_entry.dart
│   │       location_point.dart
│   │       run_activity.dart
│   │       suggested_route.dart
│   │       user.dart
│   │
│   ├───repositories
│   │       ai_repository.dart
│   │       auth_repository.dart
│   │       chat_repository.dart
│   │       home_repository.dart
│   │       leaderboard_repository.dart
│   │       run_repository.dart
│   │       user_repository.dart
│   │       weather_repository.dart
│   │
│   ├───usecases
│   │       get_current_user_usecase.dart
│   │       get_leaderboard_usecase.dart
│   │       get_run_history_usecase.dart
│   │       get_run_stats_usecase.dart
│   │       get_suggested_route_usecase.dart
│   │       login_usecase.dart
│   │       logout_usecase.dart
│   │       register_usecase.dart
│   │       save_run_usecase.dart
│   │
│   └───utils
│           distance_calculator.dart
│
├───p2p
└───presentation
    ├───components
    │       navigation_drawer_content.dart
    │
    ├───navigation
    │       app_router.dart
    │
    ├───screens
    │   │   placeholder_screen.dart
    │   │
    │   ├───auth
    │   │   │   auth_welcome_screen.dart
    │   │   │   login_screen.dart
    │   │   │   sign_up_screen.dart
    │   │   │
    │   │   └───bloc
    │   │           auth_bloc.dart
    │   │           auth_event.dart
    │   │           auth_state.dart
    │   │
    │   ├───chat
    │   │   │   chat_screen.dart
    │   │   │
    │   │   └───bloc
    │   │           chat_bloc.dart
    │   │           chat_event.dart
    │   │           chat_state.dart
    │   │
    │   ├───friends
    │   │   │   community_screen.dart
    │   │   │   friends_screen.dart
    │   │   │   other_user_profile_screen.dart
    │   │   │
    │   │   ├───bloc
    │   │   │       community_bloc.dart
    │   │   │       community_event.dart
    │   │   │       community_state.dart
    │   │   │
    │   │   └───friends_bloc
    │   │           friends_bloc.dart
    │   │
    │   ├───history
    │   │   │   history_screen.dart
    │   │   │
    │   │   └───bloc
    │   │           history_bloc.dart
    │   │           history_event.dart
    │   │           history_state.dart
    │   │
    │   ├───home
    │   │       home_bloc.dart
    │   │       home_event.dart
    │   │       home_screen.dart
    │   │       home_state.dart
    │   │
    │   ├───profile
    │   │       profile_screen.dart
    │   │
    │   ├───run
    │   │   │   map_screen.dart
    │   │   │   run_screen.dart
    │   │   │
    │   │   ├───bloc
    │   │   │       run_bloc.dart
    │   │   │       run_event.dart
    │   │   │       run_state.dart
    │   │   │
    │   │   └───widgets
    │   │           run_components.dart
    │   │
    │   └───statistics
    │       │   statistics_screen.dart
    │       │
    │       └───bloc
    │               leaderboard_bloc.dart
    │
    └───theme
            app_colors.dart
            app_theme.dart
```

## 💡 What I Learned

Building this project helped me understand:

### Architecture & Patterns
- Implementing Clean Architecture in a real Flutter app
- Managing complex state with BLoC pattern
- Dependency injection with GetIt
- Repository pattern for data abstraction

### Firebase Integration
- Setting up Firebase services (Auth, Firestore)
- Real-time data synchronization
- User authentication flows
- NoSQL database design

### Flutter Development
- Building responsive UIs
- Navigation and routing
- Custom widgets and components
- Platform-specific code (Android/iOS)

### Mapping & Location
- GPS tracking and location services
- MapLibre integration
- Drawing routes on maps
- Handling location permissions

## 🔧 Challenges & Solutions

**Challenge**: Managing complex state across multiple screens  
**Solution**: Implemented BLoC pattern with clear separation of concerns

**Challenge**: Real-time GPS tracking performance  
**Solution**: Optimized location updates and map rendering

**Challenge**: Firebase data structure design  
**Solution**: Researched NoSQL best practices and normalized data appropriately

## 🚧 Known Issues & Future Improvements

- [ ] Data layer implementation (currently using repositories directly)
- [ ] Unit and integration tests
- [ ] Offline mode support
- [ ] Better error handling
- [ ] Code documentation
- [ ] Performance optimization for large datasets
- [ ] UI/UX improvements

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Platforms

- ✅ Android
- ✅ iOS
- ⚠️ Web (Limited support)
- ⚠️ Desktop (Experimental)

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! Để contribute:

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request


## 📞 Liên hệ

Có câu hỏi? Tạo issue hoặc liên hệ qua GitHub!

---

<div align="center">

**Made with ❤️ and Flutter**

⭐ Star repo nếu bạn thấy hữu ích!

</div>
