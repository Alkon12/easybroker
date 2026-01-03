# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails 8.1 application with an iOS-inspired UI that integrates with the EasyBroker API to browse properties and locations. The codebase emphasizes clean OOP architecture with a framework-agnostic API client library in `lib/easybroker/`.

## Commands

### Development

```bash
# Install dependencies
bundle install
pnpm install

# Start server
bin/rails server

# Build Tailwind CSS (required after CSS changes)
pnpm run build:css

# Rails console
bin/rails console
```

### Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test directory
bundle exec rspec spec/lib/easybroker/
bundle exec rspec spec/controllers/

# Run single test file
bundle exec rspec spec/lib/easybroker/client_spec.rb

# Run with documentation format
bundle exec rspec --format documentation
```

### Code Quality

```bash
# RuboCop (Rails Omakase style guide)
bundle exec rubocop

# Brakeman security scanning
bundle exec brakeman

# Bundler audit
bundle exec bundler-audit
```

## Architecture

### API Client Library (`lib/easybroker/`)

Framework-agnostic Ruby client for EasyBroker API. This is NOT part of the Rails autoload path.

**Core Components:**
- `client.rb` - Main HTTP client using Faraday, handles all HTTP methods
- `configuration.rb` - API configuration (base_url, api_key) loaded from ENV
- `rate_limiter.rb` - Thread-safe rate limiting (20 req/sec) using token bucket algorithm
- `error.rb` - Error hierarchy (ClientError, ServerError, Unauthorized, NotFound, etc.)

**Resources Pattern:**
- `resources/base.rb` - Base class for all resource endpoints
- `resources/properties.rb` - Properties endpoint (`all`, `find`)
- `resources/locations.rb` - Locations endpoint (`all`)
- Resources accessed via `client.properties.all` or `client.locations.all`

**Models (Value Objects):**
- `models/property.rb` - Property data object
- `models/location.rb` - Location data object
- `models/pagination.rb` - Pagination metadata
- `models/paginated_response.rb` - Wrapper combining data + pagination

**Key Design Decisions:**
- Client is framework-agnostic (no Rails dependencies in `lib/easybroker/`)
- Module name is `EasyBroker` (CamelCase) to differentiate from Rails module `Easybroker`
- Rate limiter uses thread-safe token bucket to enforce 20 req/sec limit
- All API responses return model instances, not raw hashes

### Rails Application Layer

**Service Layer (`app/services/`):**
- `properties/list_service.rb` - Lists properties with pagination/filtering
- `properties/details_service.rb` - Fetches single property details
- `locations/list_service.rb` - Lists locations
- Services instantiate and use the EasyBroker::Client
- Services transform API client responses for controllers

**Controllers (`app/controllers/`):**
- Thin controllers delegate to service layer
- `properties_controller.rb` - Index (list) and show (details)
- `locations_controller.rb` - Index (list)
- Error handling with rescue_from for EasyBroker errors

**Views:**
- iOS-inspired design with Tailwind CSS
- System fonts (SF Pro Display on macOS/iOS)
- iOS blue (#007AFF), custom gray scale
- Card-based layouts with iOS-style border radius

### Data Flow

```
Controller → Service → EasyBroker::Client → API
                ↓
           Transform
                ↓
          View Models
```

### Configuration

Environment variables in `.env`:
- `EASYBROKER_API_KEY` - API authentication key
- `EASYBROKER_BASE_URL` - API base URL including version (defaults to https://api.stagingeb.com/v1)

Configuration loaded via:
```ruby
EasyBroker::Client.new(
  api_key: ENV['EASYBROKER_API_KEY'],
  base_url: ENV['EASYBROKER_BASE_URL']
)
```

### Testing

**Test Stack:**
- RSpec for all tests
- WebMock for HTTP request stubbing
- VCR for recording/replaying API responses (cassettes in `spec/fixtures/vcr_cassettes/`)
- FactoryBot for test data
- SimpleCov for coverage reports

**Test Organization:**
- `spec/lib/easybroker/` - API client library tests (unit tests, no Rails)
- `spec/controllers/` - Controller request specs
- `spec/services/` - Service layer tests
- `spec/support/` - Shared contexts, helpers, and configuration

**Important Testing Notes:**
- Use VCR cassettes for API tests to avoid hitting live API
- Maintain 90%+ test coverage
- Write request specs for controllers, not controller specs

### Key Files

- `lib/easybroker.rb` - Entry point, requires all client components in correct order
- `config/application.rb` - Rails app config, note `config.autoload_lib(ignore: %w[assets tasks])`
- `config/routes.rb` - Root is properties#index, resources for properties and locations
- `Gemfile` - Faraday for HTTP, dotenv-rails for env vars, RSpec/WebMock for testing

## Rails-specific Notes

- Ruby version: 3.4.7
- Rails version: 8.1.1
- Database: SQLite3
- Asset pipeline: Propshaft
- CSS: Tailwind CSS (build with pnpm)
- JS: Importmap, Turbo, Stimulus

## Important Patterns

**Using the API Client:**
```ruby
client = EasyBroker::Client.new
response = client.properties.all(page: 1, limit: 20)
# Returns PaginatedResponse with .data and .pagination
```

**Service Pattern:**
```ruby
service = Properties::ListService.new
result = service.call(page: params[:page])
# Returns hash with :properties and :pagination
```

**Error Handling:**
All EasyBroker errors inherit from `EasyBroker::Error`. Common exceptions:
- `EasyBroker::Unauthorized` (401)
- `EasyBroker::NotFound` (404)
- `EasyBroker::RateLimitExceeded` (429)
- `EasyBroker::ServerError` (500-599)
