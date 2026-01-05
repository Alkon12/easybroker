# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive README with detailed documentation
- GitHub issue templates for bugs and feature requests
- Pull request template with checklist
- Contributing guidelines
- MIT License
- Environment variable examples

## [1.0.0] - 2026-01-04

### Added
- Initial release of EasyBroker Properties Browser
- Framework-agnostic API client library (`lib/easybroker/`)
- Property browsing with pagination
- Property details view with image galleries
- Location explorer with interactive map
- iOS-inspired UI design with Tailwind CSS
- Thread-safe rate limiting (20 req/sec)
- Comprehensive error handling
- Service layer architecture
- 90%+ test coverage with RSpec
- VCR cassettes for API testing
- Docker support with multi-stage builds
- Kamal deployment configuration
- GitHub Actions CI/CD pipeline
- Security scanning (Brakeman, Bundler Audit)
- Code quality enforcement (RuboCop)

### Features

#### API Client
- `EasyBroker::Client` - Main HTTP client using Faraday
- `EasyBroker::Resources::Properties` - Properties endpoint
- `EasyBroker::Resources::Locations` - Locations endpoint
- `EasyBroker::RateLimiter` - Thread-safe token bucket rate limiting
- Value objects: Property, Location, Pagination, PaginatedResponse
- Comprehensive error hierarchy

#### Web Application
- Properties listing with responsive card layout
- Property details with image carousel
- Location map with property markers (Leaflet.js)
- Pagination controls
- iOS-style navigation
- Responsive design (mobile-first)

#### Testing
- RSpec test suite with 90%+ coverage
- WebMock for HTTP stubbing
- VCR for API recording/replay
- FactoryBot for test data
- SimpleCov for coverage reporting

#### DevOps
- Docker containerization
- Kamal deployment setup
- GitHub Actions workflow
- Automated security scanning
- Code quality checks

### Technical Highlights
- Ruby 3.4.7
- Rails 8.1.1
- Tailwind CSS 4.1.18
- Hotwire (Turbo + Stimulus)
- SQLite3 with Solid Cache/Queue/Cable
- Faraday HTTP client
- Leaflet.js for maps

[unreleased]: https://github.com/yourusername/easybroker/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/easybroker/releases/tag/v1.0.0
