# The Mind - Flutter Implementation

A Flutter implementation of **The Mind** (더 마인드), a cooperative card game designed by Wolfgang Warsch.

## 📱 Overview

The Mind is a cooperative card game where players must play cards in ascending order without communicating directly with each other. This project brings the game to mobile and web platforms using Flutter.

## 🛠 Tech Stack

- **Flutter 3.x** - Cross-platform UI framework
- **Dart 3.x** - Programming language with null safety
- **Riverpod 2.x** - State management solution
- **Supabase** - Backend as a Service (BaaS)
- **GoRouter** - Navigation and routing
- **Freezed** - Code generation for models
- **JSON Serializable** - JSON serialization/deserialization

## 📁 Project Structure

```
lib/
├── core/                 # Core utilities and configuration
│   ├── constants/       # App constants
│   ├── router/          # GoRouter setup
│   └── theme/           # Theme configuration
├── features/            # Feature modules (feature-first architecture)
│   ├── home/           # Home/splash screen
│   ├── lobby/          # Game lobby and room selection
│   ├── game/           # Main game logic and UI
│   └── result/         # Game results/score screen
├── shared/             # Shared components
│   ├── models/         # Shared data models
│   ├── providers/      # Shared state providers
│   └── widgets/        # Reusable UI widgets
└── utils/              # Utility functions
```

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart 3.x (included with Flutter)
- A Supabase account ([Create free account](https://supabase.com))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/wotjs020708/TheMind.git
   cd TheMind/the_mind
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (Freezed, JSON Serializable)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Development

### Running Tests
```bash
flutter test
```

### Building for Release
```bash
# iOS
flutter build ios

# Android
flutter build apk

# Web
flutter build web
```

### Code Generation
When modifying Freezed models or JSON serializable classes:
```bash
flutter pub run build_runner watch
```

## 🎮 Game Rules

For complete game rules and strategy guide, see [The_Mind_Rule.md](../The_Mind_Rule.md)

## 👥 Contributing

This project is a collaborative implementation of The Mind card game.

## 📄 License

This project respects the original game design by Wolfgang Warsch and NSV.

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [The Mind - Board Game Geek](https://boardgamegeek.com/boardgame/244992/mind)
