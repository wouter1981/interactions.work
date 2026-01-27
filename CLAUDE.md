# CLAUDE.md - AI Assistant Guidelines

This document provides guidance for AI assistants working with the interactions.work codebase.

## Project Overview

**interactions.work** is a monorepo containing .NET microservices architecture. The repository serves as a master entry point that orchestrates multiple services as Git submodules.

### Architecture

- **Frontend Service** (`frontend/`) - ASP.NET Core web application
- **Profile Service** (`profile.service/`) - Backend microservice
- **Test Projects** (`frontend.tests/`) - xUnit test suites

## Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | .NET 5.0 / ASP.NET Core |
| Language | C# |
| Testing | xUnit 2.4.1 |
| Coverage | Coverlet |
| IDE | Visual Studio 2016+ / VS Code |
| Build | dotnet CLI |

## Repository Structure

```
interactions.work/
├── .vscode/
│   ├── launch.json           # Debug configurations
│   └── tasks.json            # Build tasks
├── .gitmodules               # Submodule definitions
├── .gitignore                # Git ignore patterns
├── README.md                 # Project documentation
├── interactions.work.sln     # Visual Studio solution
├── frontend/                 # Frontend service (submodule)
│   └── src/
│       └── frontend.csproj
├── frontend.tests/           # Frontend tests
│   └── frontend.tests.csproj
└── profile.service/          # Profile service (submodule)
    └── src/
        └── profile.service.csproj
```

## Development Commands

### Building

```bash
# Build entire solution
dotnet build interactions.work.sln

# Build individual services
dotnet build frontend/src/frontend.csproj
dotnet build profile.service/src/profile.service.csproj
```

### Testing

```bash
# Run all tests
dotnet test

# Run with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run specific test project
dotnet test frontend.tests/frontend.tests.csproj
```

### Running Services

```bash
# Run frontend (development mode)
dotnet run --project frontend/src/frontend.csproj

# Run profile service
dotnet run --project profile.service/src/profile.service.csproj
```

## Git Submodule Workflow

This repository uses Git submodules for service isolation.

### Initial Setup

```bash
# Clone with submodules
git clone --recurse-submodules <repo-url>

# Configure submodule behavior
git config submodule.recurse 1
git config push.recurseSubmodules on-demand
```

### Updating Submodules

```bash
# Fetch latest from all submodules
git submodule update --remote

# Initialize submodules after clone
git submodule update --init --recursive
```

### Working with Submodules

```bash
# Check submodule status
git submodule status

# Enter submodule to make changes
cd frontend
git checkout main
git pull origin main
```

## Code Conventions

### Naming

- **Projects**: lowercase with dots (e.g., `frontend`, `profile.service`)
- **Namespaces**: Match project name (e.g., `namespace frontend.tests`)
- **Classes**: PascalCase
- **Methods**: PascalCase
- **Variables**: camelCase
- **Constants**: UPPER_SNAKE_CASE or PascalCase

### Project Structure

- Source code goes in `src/` subdirectory
- Tests in separate project with `.tests` suffix
- Each service is a separate submodule

### Testing Guidelines

- Use xUnit `[Fact]` for single-case tests
- Use `[Theory]` with `[InlineData]` for parameterized tests
- Test class names should match the class being tested
- One assertion per test when practical

## VS Code Configuration

### Debug Configurations

Available launch configurations in `.vscode/launch.json`:
- **Frontend (web)** - Debug the frontend ASP.NET Core app
- **Profile Service (web)** - Debug the profile service
- **.NET Core Attach** - Attach to running process

### Build Tasks

Available tasks in `.vscode/tasks.json`:
- `build-frontend` - Build the frontend project
- `build-profile.service` - Build the profile service

## AI Assistant Guidelines

### When Making Changes

1. **Read before modifying** - Always read existing code before making changes
2. **Respect conventions** - Follow the established naming and structure patterns
3. **Keep changes focused** - Make minimal, targeted modifications
4. **Test changes** - Run relevant tests after modifications

### Project-Specific Notes

- This is a .NET monorepo with Git submodules
- Build commands use `dotnet` CLI
- Development environment uses ASPNETCORE_ENVIRONMENT=Development
- Projects target .NET 5.0

### Common Patterns

- Services are isolated in their own directories
- Shared code should be extracted to a common library
- Configuration follows ASP.NET Core conventions (appsettings.json)
- Use dependency injection for service registration

### Things to Avoid

- Don't commit directly to submodule main branches
- Don't add binaries to source control (check .gitignore)
- Don't modify solution configuration platforms unnecessarily
- Don't introduce dependencies without discussion

## Quick Reference

| Task | Command |
|------|---------|
| Build all | `dotnet build` |
| Test all | `dotnet test` |
| Run frontend | `dotnet run --project frontend/src/frontend.csproj` |
| Run profile service | `dotnet run --project profile.service/src/profile.service.csproj` |
| Update submodules | `git submodule update --remote` |
| Check status | `git submodule status` |
