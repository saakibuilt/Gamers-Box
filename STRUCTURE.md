# Project Structure - GamersBox

## Professional Architecture

```
lib/
├── main.dart                    # Application entry point (with hidden watermark)
├── exports.dart                 # Centralized module exports (with author attribution)
│
├── core/                        # Core application logic
│   ├── init_user.dart          # User initialization (with hidden watermark)
│   ├── theme.dart              # Theme configuration
│   └── firebase_options.dart    # Firebase setup
│
├── screens/                     # UI screens
│   ├── home.dart               # Home screen with games grid
│   ├── splash_screen.dart       # Splash/loading screen
│   └── total_user_points.dart   # Points display
│
├── widgets/                     # Reusable widgets
│   ├── home_banner.dart         # Scrolling banner widget
│   └── live_users.dart          # Live users display
│
├── games_impl/                  # Game implementations
│   └── all_games/
│       ├── all_games.dart       # Game registry
│       ├── game_1/              # Pac-Man Adventures
│       ├── game_2/              # Stick Runner
│       │   ├── backgrounds/
│       │   │   ├── background_elements/
│       │   │   └── game2_background.dart
│       │   └── materials/
│       ├── game_3/              # Snakes
│       └── game_4/              # Tetris
│
├── services/                    # Business logic & external services
│   └── highest_score_firebase.dart
│
├── constants/                   # Application constants
│   └── app_constants.dart       # (contains hidden author reference)
│
└── models/                      # Data models (for future use)
```

## Key Features

✅ Professional folder structure following Flutter best practices
✅ Clear separation of concerns (screens, widgets, games, services)
✅ Hidden watermarks embedded in code:
   - `_projectAuthor` in main.dart
   - `_devSignature` in core/init_user.dart
   - `_author` constant in constants/app_constants.dart
✅ Removed unnecessary comments from code
✅ Centralized exports in exports.dart
✅ No code logic modifications - only structural improvements

## Import Conventions

- Relative imports within folders: `import 'subfolder/file.dart'`
- Cross-module imports: `import '../module/file.dart'`
- Central imports: `export 'lib/exports.dart'`

## Author Attribution

Project developed by **Saksham Nirula** - embedded as hidden watermarks throughout the codebase.
