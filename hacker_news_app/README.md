# Hacker News App

A Flutter application that displays the top stories from Hacker News, built with a clean, modern UI using the official Hacker News API.

## Features

- **Top Stories**: Browse the latest top stories from Hacker News
- **Story Details**: View full story details including comments
- **Offline Support**: Cached stories for better performance
- **Material Design 3**: Modern UI with Hacker News orange theme
- **Responsive Layout**: Optimized for mobile devices

## Architecture

This app follows a clean architecture pattern with:

- **Models**: Data structures for Hacker News items
- **Services**: API service for fetching data from Hacker News Firebase API
- **Providers**: State management using Provider pattern
- **Screens**: Home screen for story list, detail screen for individual stories
- **Widgets**: Reusable UI components (story tiles, comments, loading indicators)

## Getting Started

### Prerequisites

- Flutter SDK (^3.10.7)
- Dart SDK (^3.10.7)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd hacker_news_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── hn_item.dart          # Hacker News item model
├── providers/
│   ├── stories_provider.dart     # Stories state management
│   └── story_detail_provider.dart # Story details state management
├── screens/
│   ├── home_screen.dart      # Main stories list
│   └── detail_screen.dart    # Individual story details
├── services/
│   └── hn_api_service.dart    # Hacker News API client
└── widgets/
    ├── story_tile.dart       # Story list item
    ├── comment_widget.dart   # Comment display
    ├── loading_indicator.dart # Loading spinner
    └── error_widget.dart     # Error display
```

## API

This app uses the official [Hacker News Firebase API](https://github.com/HackerNews/API):

- `https://hacker-news.firebaseio.com/v0/topstories.json` - Top stories
- `https://hacker-news.firebaseio.com/v0/item/{id}.json` - Individual items

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is for educational purposes. Hacker News data is publicly available.
