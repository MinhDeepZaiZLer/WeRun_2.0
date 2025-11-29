# WeRun 2.0 🏃‍♂️💬

**WeRun 2.0** is a modern, smart running app that combines powerful activity tracking with exciting social networking features. Challenge your friends, discover AI-powered running routes, chat in real-time, climb the leaderboard, and stay motivated like never before!

Built with **Flutter** (mobile frontend) and **FastAPI** (backend), this full-stack project is perfect for developers, fitness enthusiasts, or anyone looking to explore a feature-rich fitness-social app.

![Running together]  
*Turn every run into a social adventure!*

## 🚀 Key Features

### Mobile App (Flutter)
- **Secure Authentication** – Sign up, log in, log out with Firebase
- **Real-time Running Tracker**  
  - Interactive route maps (Google Maps)  
  - Auto-save run history  
  - Track distance, pace, time, and calories burned  
- **Social Hub**  
  - Friends list & global community  
  - Instant chat and messaging  
  - Send/receive friend requests  
- **Global Leaderboard** – See who’s on top by weekly/monthly distance!  
- **AI Route Suggestions** – Smart recommendations based on weather, location, and your habits  
- **Weather Integration** – Know the conditions before you step out  
- **Personal Profile** – Edit avatar, stats, goals, and privacy settings  

### Backend (FastAPI)
- Full user management & secure JWT authentication  
- Real-time chat API  
- AI service integration for route suggestions  
- Leaderboard engine with live ranking  
- Robust statistics and analytics  
- Flexible database support (PostgreSQL or SQLite)  

## 🏗️ Project Structure

### Frontend (Flutter)
```
.
├── firebase_options.dart
├── main.dart
├── ai/                  # AI route logic
├── core/
│   ├── constants/
│   ├── di/              # Dependency injection
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│   └── utils/
├── p2p/                 # Peer-to-peer features (future)
└── presentation/
    ├── components/
    ├── navigation/
    ├── screens/
    │   ├── auth/
    │   ├── chat/
    │   ├── friends/
    │   ├── history/
    │   ├── home/
    │   ├── profile/
    │   ├── run/
    │   └── statistics/
    └── theme/
```

### Backend (FastAPI)
```
.
├── main.py
├── database.py
├── models/
├── routers/
├── services/
└── __pycache__/
```

## ⚡ Tech Stack

**Frontend**  
- Flutter & Dart  
- Firebase Authentication & Firestore  
- Bloc (state management)  
- Google Maps, Geolocator, Weather API  

**Backend**  
- Python 3.10+  
- FastAPI (high performance)  
- SQLAlchemy & Pydantic  
- PostgreSQL or SQLite  
- JWT for secure authentication  

**Tools**  
- Git & GitHub  
- Postman (API testing)  
- Flutter DevTools  

## 📦 Installation & Quick Start

### 1. Frontend (Mobile)
```bash
git clone <your-frontend-repo-url>
cd <frontend-folder>
flutter pub get
flutter run
```

### 2. Backend (API)
```bash
git clone <your-backend-repo-url>
cd <backend-folder>

# Create virtual environment
python -m venv venv
source venv/bin/activate        # Linux/macOS
# or
venv\Scripts\activate           # Windows

pip install -r requirements.txt
uvicorn main:app --reload
```

Open `http://127.0.0.1:8000/docs` in your browser to explore the interactive API documentation (Swagger UI).

## 🌟 What’s New in 2.0?
- AI-powered route suggestions  
- Real-time chat with friends  
- Sleek, modern UI with dark mode  
- Global leaderboard with weekly resets  
- Weather-aware planning  

## 🔐 Security Best Practices
- Never commit `firebase_options.dart` or API keys to public repos.  
- Store all secrets in `.env` files (use `python-dotenv`).  
- Token-based authentication keeps your data safe.  

## 🤝 Contributing
We welcome contributions!  
1. Fork the repo  
2. Create a feature branch (`git checkout -b feature/amazing-idea`)  
3. Commit your changes (`git commit -m 'Add amazing idea'`)  
4. Push and open a Pull Request  

## 📄 License
WeRun 2.0 is intended for **internal development and learning purposes**. Commercial use or redistribution requires explicit permission from the author.

---

**Ready to run with the community?**  
Star ⭐ this repo, clone it, and start building your own fitness social network today!

*Let’s make running fun again!* 🏆

Questions? Open an issue or reach out – happy coding! 💻✨
