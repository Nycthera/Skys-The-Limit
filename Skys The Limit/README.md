# Skys The Limit

Skys The Limit is an educational iOS app that combines math equation puzzles with constellation-style visualizations. Users solve equations to draw lines between points on a canvas, create and share constellations, and explore math visually.

This repository contains the app source (Swift + SwiftUI) and backend helpers that integrate with Appwrite for persistence.

## Features
- Interactive math equation puzzles and visual feedback
- Custom graph/canvas rendering of constellations
- Save, update, and share constellations via Appwrite
- SwiftUI-based UI with a custom on-screen math keyboard

## Getting Started

These instructions help you build and run the app locally on macOS with Xcode.

### Prerequisites
- macOS with Xcode (recommended: latest stable Xcode)
- Swift toolchain provided by Xcode
- (Optional) Homebrew for installing helper tools

### Build and Run
1. Open `Skys The Limit.xcworkspace` in Xcode.
2. Select a simulator or your device and run the app (Cmd+R).

### Appwrite Configuration
The project contains Appwrite integration under the `Backend/` folder. Before using the Appwrite-backed features, set up an Appwrite project and update the endpoint and project id in `Backend/AppwriteService.swift` if necessary.

Important: Do not commit secrets or private API keys. Use environment variables or secure storage for production keys.

## Development Notes
- Formatting & linting: This repo includes a GitHub workflow for `swiftlint` / `swiftformat`. Please run linters locally before submitting PRs.
- Main files:
  - `Frontend/` — SwiftUI views and UI code
  - `Backend/` — Appwrite helpers and models
  - `Core/` — shared utilities

## Contributing
We welcome contributions! See `CONTRIBUTING.md` for guidelines on reporting issues, creating pull requests, and coding standards.

## License
This project is available under the MIT License. See `LICENSE` for details.

---
If you'd like, I can also help create the GitHub repository and push these changes (I will need your permission and remote access instructions), or help set up CI and release steps.
