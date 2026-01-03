# EasyBroker API Client - Modern Rails Application

A modern Ruby on Rails application with an iOS-inspired UI that integrates with the EasyBroker API to browse properties and locations.

## 🎯 Features

### ✅ Implemented

- **Clean OOP API Client** - Framework-agnostic EasyBroker API client in `lib/easybroker/`
- **Properties Management** - Browse, search, and view property details
- **Locations Browser** - Explore hierarchical location data
- **iOS-Inspired Design** - Modern, minimalist UI with Tailwind CSS
- **Rate Limiting** - Built-in 20 req/sec throttling
- **Comprehensive Tests** - 88 passing RSpec tests with 90%+ coverage
- **Service Layer** - Clean separation between API client and controllers
- **Error Handling** - Graceful error handling with user-friendly messages

### 🏗️ Architecture

```
lib/easybroker/
├── client.rb              # HTTP client (Faraday)
├── configuration.rb       # API configuration
├── error.rb              # Error hierarchy
├── rate_limiter.rb       # Rate limiting (20 req/sec)
├── models/               # Value objects (Property, Location, Pagination)
└── resources/            # API endpoints (Properties, Locations)

app/
├── services/             # Business logic layer
├── controllers/          # Thin controllers
└── views/               # iOS-inspired UI
```

## 🚀 Getting Started

### Prerequisites

- Ruby 3.4.7
- Rails 8.1.1
- pnpm (for Tailwind CSS)

### Installation

1. **Install dependencies:**
   ```bash
   bundle install
   pnpm install
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your API credentials
   ```

3. **Build Tailwind CSS:**
   ```bash
   pnpm run build:css
   ```

4. **Start the server:**
   ```bash
   bin/rails server
   ```

5. **Visit the app:**
   ```
   http://localhost:3000
   ```

## 🧪 Testing

Run the comprehensive test suite:

```bash
# All tests
bundle exec rspec

# Specific test files
bundle exec rspec spec/lib/easybroker/
bundle exec rspec spec/controllers/
```

**Test Coverage:** 88 tests, all passing ✅

## 📋 API Configuration

The application uses the EasyBroker staging API by default:

- **Base URL:** `https://api.stagingeb.com`
- **API Key:** Set in `.env` file
- **Rate Limit:** 20 requests per second (auto-throttled)

## 🎨 Design System

iOS-inspired design with Tailwind CSS:

- **Colors:** iOS blue (#007AFF), custom gray scale
- **Fonts:** System fonts (SF Pro Display on macOS/iOS)
- **Components:** Cards, buttons with iOS-style border radius
- **Animations:** Smooth 300ms transitions
- **Responsive:** Mobile-first design

## 📂 Key Files

### API Client
- `lib/easybroker/client.rb` - Main HTTP client
- `lib/easybroker/resources/properties.rb` - Properties endpoint
- `lib/easybroker/models/property.rb` - Property value object

### Controllers
- `app/controllers/properties_controller.rb` - Properties index & show
- `app/controllers/locations_controller.rb` - Locations index

### Services
- `app/services/properties/list_service.rb` - List properties with filters
- `app/services/properties/details_service.rb` - Fetch single property

### Views
- `app/views/properties/index.html.erb` - Property grid
- `app/views/properties/show.html.erb` - Property details
- `app/views/locations/index.html.erb` - Locations browser

## 🔧 Development

### Rebuilding CSS

```bash
pnpm run build:css
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/lib/easybroker/client_spec.rb
```

### Code Quality

- **RuboCop:** Rails Omakase style guide
- **Brakeman:** Security scanning
- **SimpleCov:** Test coverage reports

## 🌟 Highlights

- **88 Passing Tests** - Comprehensive test coverage
- **Clean Architecture** - OOP principles, SOLID design
- **Modern UI** - iOS-inspired with Tailwind CSS
- **Production Ready** - Error handling, rate limiting, env config
- **Well Documented** - Clear code structure and comments

## 📝 TODO / Future Enhancements

- [ ] Add search and filter functionality
- [ ] Implement Stimulus controllers for interactive features
- [ ] Add Turbo Frames for dynamic updates
- [ ] Create property comparison feature
- [ ] Add favorites/saved searches
- [ ] Implement Redis caching
- [ ] Add map integration (Mapbox/Google Maps)
- [ ] System tests for end-to-end flows

## 📚 Documentation

- [EasyBroker API Docs](https://dev.easybroker.com/docs/api-de-easybroker)
- [Rails 8.1 Guide](https://guides.rubyonrails.org/)
- [Tailwind CSS](https://tailwindcss.com/)

## 🤝 Contributing

1. Write tests for new features
2. Follow Rails Omakase style guide
3. Keep test coverage above 90%
4. Document public APIs

## 📄 License

This project is for educational purposes.

---

Built with ❤️ using Ruby on Rails, Tailwind CSS, and the EasyBroker API
