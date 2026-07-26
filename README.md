# Vitabu

A multi-language ebook reading platform with a Flutter frontend and Laravel admin panel.

**Vitabu** (Swahili for "books") lets users browse, read, and purchase ebooks and magazines across multiple languages with a seamless reading experience.

## Architecture

```
vitabu/
├── yourappname/          # Flutter app (mobile + web)
│   ├── lib/              # Dart source code
│   ├── assets/           # Locales, images, fonts
│   └── build/            # Build output (gitignored)
├── admin_panel/          # Laravel admin backend
│   ├── app/              # PHP application code
│   ├── resources/        # Views, lang files
│   └── routes/           # API & web routes
└── .gitignore
```

## Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter (Dart) |
| **Backend** | Laravel (PHP) |
| **Database** | MySQL / MariaDB |
| **Auth** | Firebase Auth, Google Sign-In, Apple Sign-In |
| **Payments** | Stripe, Razorpay, Paystack, Flutterwave, Paytm |
| **Ads** | Google Mobile Ads |

## Features

- 📚 Browse ebooks & magazines by category/language
- 🌐 Multi-language support (English, Hindi, Arabic)
- 📖 Built-in PDF & EPUB reader
- 🔖 Bookmarks, highlights, notes
- 🎵 Audio courses & audiobooks
- 💳 In-app purchases & subscriptions
- 👤 User profiles & author registration
- ⚙️ Admin panel for content management

## Getting Started

### Prerequisites

- Flutter SDK >= 3.2.0
- PHP >= 8.1
- Composer
- MySQL / MariaDB
- Node.js & NPM (for Laravel Mix)

### Frontend (yourappname)

```bash
cd yourappname
flutter pub get
flutter run
```

### Backend (admin_panel)

```bash
cd admin_panel
cp .env.example .env        # Configure your database & API keys
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

## Localization

Translations are in `yourappname/assets/locales/`:
- `en.json` — English
- `hi.json` — Hindi
- `ar.json` — Arabic

## License

All rights reserved.
