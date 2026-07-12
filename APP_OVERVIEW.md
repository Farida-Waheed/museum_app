# Museum App Overview

## What this app does
This project is a Flutter-based museum experience application for visitors. It combines ticket handling, exhibit discovery, guided tours, multilingual support, and interactive museum features into a single mobile app.

## Main purpose
The app helps users:
- Explore museum exhibits and collections
- Learn about exhibits through detailed screens and content
- Use tickets and QR scanning for entry or robot pairing
- Follow guided or live tours
- Receive notifications and reminders
- Interact with a support/chat assistant
- Customize their experience with settings and accessibility options

## Key features
### Visitor experience
- Onboarding and intro screens
- Home screen with museum navigation
- Exhibit list and exhibit detail pages
- Interactive map and search experience
- Tour planner and progress tracking
- Live tour flow and visit summaries

### Tickets and access
- Ticket purchasing and viewing
- My tickets management
- QR code scanning for museum entry
- Robot pairing flow for Horus-Bot tours

### Engagement and support
- Chat assistant for museum questions
- Quiz feature for exhibits
- Feedback submission
- Support inbox and conversation screens
- Events and achievements
- Profile and memories sections

### Personalization
- English and Arabic localization
- Accessibility settings
- Theme and font preferences
- Notification preferences

## Technology stack
- Flutter + Dart
- Provider for state management
- Firebase for authentication, Firestore, Storage, and initialization
- MQTT for robot communication
- Mobile scanner and permission handling for QR flows
- Local notifications and shared preferences
- Internationalization with intl and flutter_localizations

## Project structure
- lib/main.dart: app entry point
- lib/app/: app-wide configuration, routing, and theme
- lib/screens/: all UI screens grouped by feature
- lib/models/: providers, session state, and data models
- lib/services/: external services and app logic integrations
- lib/widgets/: reusable UI components
- lib/core/: shared constants, styles, and notification infrastructure
- lib/l10n/: localization resources

## Navigation highlights
The app includes routes for:
- Intro and onboarding
- Home and entry mode
- Exhibits, map, search, and quiz
- Tour progress, live tour, and summaries
- Tickets, QR scanning, and robot pairing
- Settings, accessibility, notifications, and feedback
- Profile, memories, planner, events, and achievements

## Notes for developers
The app is organized around feature-based screens and provider-driven state. The main application bootstraps Firebase, initializes localization and notifications, then wires all providers before launching the UI.
