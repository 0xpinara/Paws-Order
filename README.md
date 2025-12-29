# Pet Society Mobile

A clean, bug-free remake of the classic Pet Society game built with Godot 4.

## Project Structure

```
PetSocietyMobile/
├── assets/
│   ├── sprites/      # Pet and item sprites
│   ├── ui/           # UI elements and icons
│   ├── audio/        # Sound effects and music
│   └── fonts/        # Custom fonts
├── scenes/
│   ├── screens/      # Main game screens (menu, home, shop, etc.)
│   ├── components/   # Reusable UI components
│   └── pets/         # Pet-related scenes
├── scripts/
│   ├── autoload/     # Global singletons (GameManager, SaveManager, etc.)
│   ├── resources/    # Custom Resource classes (PetData, ItemData, etc.)
│   ├── screens/      # Screen logic scripts
│   └── utils/        # Helper utilities
├── data/             # Game data files (item definitions, etc.)
└── project.godot     # Godot project file
```

## Requirements

- Godot 4.2 or higher
- For iOS export: macOS with Xcode installed

## Getting Started

1. Download and install [Godot 4.2+](https://godotengine.org/download)
2. Open Godot and click "Import"
3. Navigate to this folder and select `project.godot`
4. Click "Import & Edit"

## Running the Game

- Press F5 or click the Play button to run in the editor
- The game starts at the Main Menu

## Core Features

### Implemented ✅
- [x] Project structure and autoloads
- [x] Main menu with save/load detection
- [x] Pet creator with color selection
- [x] Home screen with pet display
- [x] Pet stats (health, happiness, hygiene)
- [x] Basic pet care (feed, wash, play)
- [x] Shop system with categories
- [x] Coin economy
- [x] Save/Load system (JSON-based)
- [x] Audio manager framework

### In Progress 🚧
- [ ] Asset extraction from original game
- [ ] Proper pet sprites and animations
- [ ] Furniture placement system
- [ ] Room decoration
- [ ] Inventory management

### Planned 📋
- [ ] Multiple rooms
- [ ] Mini-games (ball, frisbee, jump rope)
- [ ] Pet clothing/accessories
- [ ] Achievements
- [ ] Sound effects and music

## iOS Export

1. Open Project > Export
2. Add iOS preset
3. Configure:
   - Bundle Identifier: com.yourname.petsociety
   - App Store Team ID
   - Signing certificate
4. Export to Xcode project
5. Build and archive in Xcode
6. Submit to App Store Connect

## Architecture

### Autoloads (Singletons)

- **GameManager**: Central game state, pet data, coins, inventory
- **SaveManager**: JSON-based save/load system
- **AudioManager**: Music and sound effects
- **ItemDatabase**: Item definitions and lookups

### Resources

- **PetData**: Pet name, colors, stats, equipment
- **ItemData**: Item properties (price, category, effects)
- **RoomData**: Room layout and placed furniture
- **PlacedItemData**: Individual furniture placement

### Scene Flow

```
MainMenu
    ├── (New Game) → PetCreator → HomeScreen
    └── (Play) → HomeScreen
                    ├── Shop → HomeScreen
                    ├── Inventory (TODO)
                    └── Settings (TODO)
```

## Code Style

- GDScript with static typing
- PascalCase for classes and nodes
- snake_case for variables and functions
- Prefix private functions with underscore
- Use signals for decoupling

## Performance Notes

- Uses Godot's mobile renderer
- Optimized for 60fps on mobile
- Sprites loaded on-demand
- Object pooling for frequently spawned items

## License

This is a fan project for educational purposes.
Original Pet Society was developed by Playfish/EA.

