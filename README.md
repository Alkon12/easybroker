<div align="center">

# EasyBroker Properties Browser

**Modern Ruby on Rails application with iOS-inspired UI for browsing real estate properties**

[![Ruby](https://img.shields.io/badge/Ruby-3.4.7-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1.1-red.svg)](https://rubyonrails.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-4.1.18-38B2AC.svg)](https://tailwindcss.com/)
[![RSpec](https://img.shields.io/badge/RSpec-Tested-green.svg)](https://rspec.info/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[Features](#features) • [Architecture](#architecture) • [Quick Start](#quick-start) • [Documentation](#documentation)

</div>

---

## Overview

A production-ready Rails 8.1 application that integrates seamlessly with the EasyBroker API to provide an elegant property browsing experience. Built with clean architecture principles, featuring a **framework-agnostic API client library**, comprehensive test coverage, and an iOS-inspired design system.

### Why This Project?

- **Clean Architecture**: Framework-agnostic API client library in `lib/easybroker/` following SOLID principles
- **Modern Rails**: Built on Rails 8.1 with Hotwire, Turbo, and Stimulus
- **iOS-Inspired UI**: Apple's design language with SF Pro Display fonts and iOS blue (#007AFF)
- **Production Ready**: Thread-safe rate limiting, comprehensive error handling, Docker support
- **Well Tested**: 90%+ test coverage with RSpec, VCR, and WebMock

---

## Features

### Core Functionality

- **Property Browsing**: Paginated property listings with responsive card layouts
- **Property Details**: Comprehensive property information with image galleries
- **Location Explorer**: Interactive map with property markers using Leaflet.js
- **Smart Caching**: Redis-backed caching for optimal performance

### Technical Highlights

- **Rate Limiting**: Thread-safe token bucket algorithm (20 req/sec limit)
- **Error Handling**: Comprehensive error hierarchy with graceful degradation
- **API Abstraction**: Clean resource pattern (`client.properties.all`, `client.locations.all`)
- **Value Objects**: Immutable models for Property, Location, Pagination
- **Service Layer**: Thin controllers delegating to service objects

---

## Tech Stack

### Backend
- **Ruby** 3.4.7
- **Rails** 8.1.1
- **Faraday** - HTTP client with retry middleware
- **SQLite3** - Database (production-ready with Solid Cache/Queue/Cable)

### Frontend
- **Tailwind CSS** 4.1.18 - Utility-first CSS framework
- **Hotwire** - Turbo & Stimulus for SPA-like experience
- **Leaflet.js** - Interactive maps
- **Importmap** - Native ES modules

### Testing
- **RSpec** - BDD testing framework
- **WebMock** - HTTP request stubbing
- **VCR** - Record and replay API interactions
- **SimpleCov** - Code coverage reporting
- **FactoryBot** - Test data generation

### DevOps
- **Docker** - Containerization with multi-stage builds
- **Kamal** - Zero-downtime deployments
- **Thruster** - HTTP asset caching and compression
- **GitHub Actions** - CI/CD pipeline

---

## Architecture

### Project Structure

```
easybroker/
├── app/
│   ├── controllers/          # Thin controllers with error handling
│   ├── services/             # Business logic layer
│   │   ├── properties/       # Property-related services
│   │   └── locations/        # Location-related services
│   ├── views/                # iOS-inspired ERB templates
│   └── javascript/           # Stimulus controllers
├── lib/
│   └── easybroker/           # Framework-agnostic API client
│       ├── client.rb         # Main HTTP client (Faraday)
│       ├── configuration.rb  # API configuration
│       ├── rate_limiter.rb   # Thread-safe rate limiting
│       ├── error.rb          # Error hierarchy
│       ├── resources/        # API resource endpoints
│       │   ├── base.rb
│       │   ├── properties.rb
│       │   └── locations.rb
│       └── models/           # Value objects
│           ├── property.rb
│           ├── location.rb
│           ├── pagination.rb
│           └── paginated_response.rb
└── spec/                     # Comprehensive test suite
    ├── lib/easybroker/       # API client tests
    ├── services/             # Service layer tests
    └── controllers/          # Request specs
```

### Data Flow

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────┐     ┌─────────┐
│ Controller  │────▶│   Service    │────▶│ EasyBroker::     │────▶│   API   │
│             │     │              │     │ Client           │     │         │
└─────────────┘     └──────────────┘     └──────────────────┘     └─────────┘
       │                   │                      │
       │                   ▼                      │
       │            Transform to                  │
       │            View Models                   │
       │                   │                      │
       ▼                   ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                         View Layer                              │
│            (iOS-inspired cards, maps, pagination)               │
└─────────────────────────────────────────────────────────────────┘
```

### API Client Design

The `lib/easybroker/` library is **framework-agnostic** and can be used in any Ruby project:

```ruby
# Initialize client
client = EasyBroker::Client.new(
  api_key: ENV['EASYBROKER_API_KEY'],
  base_url: ENV['EASYBROKER_BASE_URL']
)

# Fetch properties
response = client.properties.all(page: 1, limit: 20)
# => #<EasyBroker::PaginatedResponse>

response.data         # Array of Property objects
response.pagination   # Pagination metadata

# Fetch single property
property = client.properties.find('property123')
# => #<EasyBroker::Property>

# Fetch locations
locations = client.locations.all
# => Array of Location objects
```

**Error Handling:**

```ruby
begin
  client.properties.all
rescue EasyBroker::Unauthorized
  # Handle 401 - invalid API key
rescue EasyBroker::NotFound
  # Handle 404 - resource not found
rescue EasyBroker::RateLimitExceeded
  # Handle 429 - too many requests
rescue EasyBroker::ServerError
  # Handle 500+ - server errors
rescue EasyBroker::Error => e
  # Catch-all for any API error
end
```

---

## Quick Start

### Prerequisites

- Ruby 3.4.7 (use `rbenv` or `asdf`)
- Node.js 18+ (for pnpm)
- pnpm 10.25.0+
- SQLite3

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/easybroker.git
   cd easybroker
   ```

2. **Install dependencies**
   ```bash
   bundle install
   pnpm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and add your EasyBroker API credentials:
   ```env
   EASYBROKER_API_KEY=your_api_key_here
   EASYBROKER_BASE_URL=https://api.stagingeb.com/v1
   ```

4. **Set up the database**
   ```bash
   bin/rails db:setup
   ```

5. **Build Tailwind CSS**
   ```bash
   pnpm run build:css
   ```

6. **Start the development server**
   ```bash
   bin/dev
   ```

7. **Visit the application**
   Open [http://localhost:3000](http://localhost:3000) in your browser

---

## Development

### Running the Application

```bash
# Start Rails server
bin/rails server

# Start with all services (Rails + CSS watcher)
bin/dev

# Rails console
bin/rails console

# Build CSS after changes
pnpm run build:css
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test directory
bundle exec rspec spec/lib/easybroker/
bundle exec rspec spec/controllers/

# Run with documentation format
bundle exec rspec --format documentation

# Run with coverage report
COVERAGE=true bundle exec rspec
```

### Code Quality

```bash
# Run RuboCop (Rails Omakase style guide)
bundle exec rubocop

# Auto-correct RuboCop offenses
bundle exec rubocop -A

# Security scanning with Brakeman
bundle exec brakeman

# Dependency vulnerability scanning
bundle exec bundler-audit
```

### CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`) runs:
- RuboCop linting
- RSpec test suite
- Brakeman security scan
- Bundler audit

---

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `EASYBROKER_API_KEY` | EasyBroker API authentication key | Required |
| `EASYBROKER_BASE_URL` | API base URL including version | `https://api.stagingeb.com/v1` |
| `RAILS_ENV` | Rails environment | `development` |
| `RAILS_MAX_THREADS` | Puma thread pool size | `5` |

### Rate Limiting

The API client implements thread-safe rate limiting using a token bucket algorithm:
- **Rate**: 20 requests per second
- **Implementation**: `lib/easybroker/rate_limiter.rb`
- **Thread-safe**: Uses Mutex for concurrent request handling

### Caching Strategy

- **Solid Cache** for Rails.cache (database-backed)
- **VCR cassettes** for test suite API responses
- Custom service-level caching for expensive operations

---

## Testing Strategy

### Test Coverage

- **90%+ coverage** across all layers
- Unit tests for API client library
- Service layer tests
- Request specs for controllers
- Integration tests with VCR cassettes

### Testing Tools

```ruby
# spec/spec_helper.rb
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

# VCR for API recording/replay
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end
```

### Example Test

```ruby
# spec/lib/easybroker/client_spec.rb
RSpec.describe EasyBroker::Client do
  let(:client) { described_class.new(api_key: 'test_key') }

  describe '#properties' do
    it 'returns a Properties resource' do
      expect(client.properties).to be_a(EasyBroker::Resources::Properties)
    end
  end
end
```

---

## Deployment

### Docker

Build and run with Docker:

```bash
# Build image
docker build -t easybroker .

# Run container
docker run -p 3000:3000 \
  -e EASYBROKER_API_KEY=your_key \
  -e RAILS_ENV=production \
  easybroker
```

### Kamal Deployment

Deploy with zero downtime using Kamal:

```bash
# Initial setup
kamal setup

# Deploy
kamal deploy

# Rollback
kamal rollback
```

---

## API Documentation

### EasyBroker API Client

#### Client Initialization

```ruby
client = EasyBroker::Client.new(
  api_key: 'your_api_key',
  base_url: 'https://api.stagingeb.com/v1' # optional
)
```

#### Properties

```ruby
# List all properties
response = client.properties.all(page: 1, limit: 20)
response.data         # => [#<EasyBroker::Property>, ...]
response.pagination   # => #<EasyBroker::Pagination>

# Find property by ID
property = client.properties.find('property_id')
property.title        # => "Beautiful House"
property.bedrooms     # => 3
property.price        # => 500000
```

#### Locations

```ruby
# List all locations
locations = client.locations.all
locations.first.name  # => "Polanco"
locations.first.slug  # => "polanco"
```

#### Models

**Property**
```ruby
property.public_id
property.title
property.property_type
property.bedrooms
property.bathrooms
property.location
property.operations    # ["sale", "rental"]
property.price
```

**Location**
```ruby
location.id
location.name
location.slug
```

**Pagination**
```ruby
pagination.page
pagination.limit
pagination.total
pagination.next_page
```

---

## Service Layer

### Properties::ListService

```ruby
service = Properties::ListService.new
result = service.call(page: 1)

result[:properties]   # => Array of Property objects
result[:pagination]   # => Pagination metadata
result[:total]        # => Total count
```

### Properties::DetailsService

```ruby
service = Properties::DetailsService.new
property = service.call(property_id: 'abc123')
```

### Locations::ListService

```ruby
service = Locations::ListService.new
locations = service.call
```

---

## UI/UX Design

### iOS Design System

- **Typography**: SF Pro Display (system font on macOS/iOS)
- **Colors**:
  - iOS Blue: `#007AFF`
  - Gray Scale: Custom iOS-inspired grays
- **Components**:
  - Card layouts with iOS border radius
  - Native-feeling animations
  - Touch-optimized interactions

### Responsive Design

- Mobile-first approach
- Breakpoints: `sm`, `md`, `lg`, `xl`
- Grid system: 1-column (mobile) → 3-column (desktop)

---

## Project Conventions

### Naming Conventions

- **API Client Module**: `EasyBroker` (CamelCase) - differentiates from Rails `Easybroker`
- **Service Classes**: `Verb + Noun + Service` (e.g., `ListService`, `DetailsService`)
- **Resource Classes**: Singular nouns (e.g., `Properties`, `Locations`)

### Code Style

- **Ruby**: Rails Omakase style guide (enforced by RuboCop)
- **JavaScript**: StandardJS style
- **CSS**: Tailwind utility-first approach

### Git Workflow

- `main` branch for production
- Feature branches: `feature/description`
- Commit messages: Conventional Commits format

---

## Troubleshooting

### Common Issues

**API Key not working**
```bash
# Verify environment variables are loaded
bin/rails console
> ENV['EASYBROKER_API_KEY']
```

**Tailwind CSS not updating**
```bash
# Rebuild CSS
pnpm run build:css

# Or use watch mode
pnpm run build:css -- --watch
```

**Rate limit exceeded**
```ruby
# Rate limiter enforces 20 req/sec
# Adjust in lib/easybroker/rate_limiter.rb if needed
```

**VCR cassette errors in tests**
```bash
# Delete cassettes to re-record
rm -rf spec/fixtures/vcr_cassettes/
bundle exec rspec
```

---

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for new functionality
4. Ensure all tests pass (`bundle exec rspec`)
5. Run RuboCop (`bundle exec rubocop`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Development Setup

See [Quick Start](#quick-start) for development environment setup.

### Code Review Process

- All PRs require passing CI checks
- Maintain 90%+ test coverage
- Follow Rails Omakase style guide
- Security scans must pass (Brakeman, Bundler Audit)

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [EasyBroker](https://easybroker.com) for providing the property API
- [Rails](https://rubyonrails.org/) for the amazing framework
- [Tailwind CSS](https://tailwindcss.com/) for the utility-first CSS framework
- Apple for design inspiration

---

## Contact & Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/easybroker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/easybroker/discussions)

---

<div align="center">

**Built with ❤️ using Ruby on Rails**

[⬆ Back to Top](#easybroker-properties-browser)

</div>
