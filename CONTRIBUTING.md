# Contributing to interactions.work

Thank you for your interest in contributing to interactions.work! This document provides guidelines and information for contributors.

## Code of Conduct

This project focuses on improving human interactions and collaboration. We expect all contributors to embody these values:

- Be respectful and inclusive
- Focus on constructive feedback
- Value soft skills and human connection
- Maintain privacy and trust

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Set up the development environment (see README.md)
4. Create a feature branch from `develop`

## Development Workflow

### Branching Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable releases (protected) |
| `develop` | Integration branch |
| `feature/*` | New features |
| `fix/*` | Bug fixes |
| `chore/*` | Maintenance tasks |

### Git Workflow

1. Create a feature branch from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the code style guidelines

3. Write tests for new functionality

4. Commit your changes using conventional commits

5. Push to your fork and open a Pull Request against `develop`

## Code Style

### Rust

- Follow Rust 2021 edition idioms
- Run `cargo fmt` before committing
- Run `cargo clippy` and address warnings
- Aim for zero warnings

```bash
cargo fmt
cargo clippy
cargo test
```

### Flutter/Dart

- Follow the official Dart style guide
- Run `dart format` before committing
- Run `dart analyze` and address issues

```bash
dart format .
dart analyze
flutter test
```

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <description>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat: add pulse notification system
fix: correct encryption key derivation
docs: update README with installation steps
chore: update dependencies
```

## Testing

### Requirements

- Unit tests required for core logic
- Integration tests for git operations
- Widget tests for Flutter UI components
- Aim for 80%+ coverage on core library

### Running Tests

```bash
# Rust tests
cargo test --workspace

# Flutter tests
flutter test
flutter test --coverage
```

## Pull Request Guidelines

### Before Submitting

- [ ] Code follows the style guidelines
- [ ] Tests pass locally
- [ ] New functionality includes tests
- [ ] Documentation is updated if needed
- [ ] Commit messages follow conventional commits

### PR Description

Include:
- Summary of changes
- Related issue numbers (if any)
- Testing performed
- Screenshots for UI changes

### Review Process

1. Automated checks run on PR submission
2. Maintainers review the code
3. Address feedback and update PR
4. Maintainers merge after approval

## Project-Specific Guidelines

### Privacy First

- Never expose private data patterns to shared spaces
- Always use encryption for sensitive data
- Test encryption/decryption thoroughly

### Domain Focus

- This is about human interactions, not task management
- Keep the focus on soft skills and relationships
- Avoid adding hard metric tracking

### Simplicity

- Don't over-engineer solutions
- Keep code readable and maintainable
- Focus on human connection, not complexity

## Reporting Issues

### Bug Reports

Include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, versions)

### Feature Requests

Include:
- Clear description of the feature
- Use case and motivation
- Potential implementation approach (optional)

## Questions?

- Check existing issues and discussions
- Open a new issue for questions
- Be patient and respectful

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
