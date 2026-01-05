# Contributing to EasyBroker Properties Browser

First off, thank you for considering contributing to EasyBroker Properties Browser! It's people like you that make this project better.

## Code of Conduct

This project and everyone participating in it is governed by respect and professionalism. Please be kind and constructive in your interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (code snippets, screenshots, etc.)
- **Describe the behavior you observed** and what you expected
- **Include your environment details** (Ruby version, Rails version, OS, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **List some examples** of how it would work

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding style** - Rails Omakase for Ruby
3. **Write tests** - Maintain 90%+ code coverage
4. **Update documentation** - README, code comments, etc.
5. **Run the test suite** - `bundle exec rspec`
6. **Run linters** - `bundle exec rubocop`
7. **Run security scans** - `bundle exec brakeman`

## Development Setup

### Prerequisites

- Ruby 3.4.7
- Node.js 18+ with pnpm
- SQLite3

### Setup Steps

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/easybroker.git
cd easybroker

# Install dependencies
bundle install
pnpm install

# Set up environment
cp .env.example .env
# Edit .env with your API key

# Set up database
bin/rails db:setup

# Build CSS
pnpm run build:css

# Run tests
bundle exec rspec
```

## Code Style Guidelines

### Ruby Style

We follow the [Rails Omakase](https://github.com/rails/rubocop-rails-omakase) style guide:

```bash
# Check your code
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -A
```

### Testing Guidelines

- Write RSpec tests for all new features
- Use VCR for API interactions
- Mock external dependencies
- Aim for 90%+ coverage

Example test structure:

```ruby
RSpec.describe MyClass do
  describe '#my_method' do
    context 'when condition is true' do
      it 'returns expected result' do
        # Test implementation
      end
    end

    context 'when condition is false' do
      it 'handles error gracefully' do
        # Test implementation
      end
    end
  end
end
```

### Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat: add property search functionality

fix: resolve pagination error on last page

docs: update API client usage examples
```

## Project Structure

### API Client Library (`lib/easybroker/`)

Framework-agnostic Ruby client:

- Keep it free of Rails dependencies
- Follow resource pattern for endpoints
- Use value objects for data models
- Implement comprehensive error handling

### Rails Application Layer

- **Controllers**: Keep thin, delegate to services
- **Services**: Contain business logic
- **Views**: iOS-inspired design with Tailwind
- **Tests**: Request specs for controllers, unit tests for services

## Testing Your Changes

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/lib/easybroker/client_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec

# Run linters
bundle exec rubocop

# Run security scans
bundle exec brakeman
bundle exec bundler-audit
```

## Pull Request Process

1. **Update the README** if you're adding features
2. **Update CLAUDE.md** if changing architecture
3. **Ensure all tests pass** and coverage is maintained
4. **Run all linters and security scans**
5. **Update the CHANGELOG** (if applicable)
6. **Get at least one code review** before merging

### PR Checklist

- [ ] Tests pass (`bundle exec rspec`)
- [ ] Linter passes (`bundle exec rubocop`)
- [ ] Security scans pass (`bundle exec brakeman`)
- [ ] Coverage maintained at 90%+
- [ ] Documentation updated
- [ ] Commits follow conventional format

## Getting Help

- Read the [README](README.md)
- Check existing [Issues](https://github.com/yourusername/easybroker/issues)
- Start a [Discussion](https://github.com/yourusername/easybroker/discussions)

## Recognition

Contributors will be recognized in the project README and release notes.

Thank you for contributing!
