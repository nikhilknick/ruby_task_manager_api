# Task Manager API

A Rails API application for managing tasks. This is a RESTful API built with Ruby on Rails that provides endpoints for task management operations.

## Project Overview

This is a task_manager_api project built with Ruby on Rails, designed to handle task management functionality through a clean API interface.

## Technology Stack

- Ruby on Rails (API mode)
- PostgreSQL database
- Solid Queue for background jobs
- Kamal for deployment

## Getting Started

### Prerequisites

- Ruby (see `.ruby-version` for the required version)
- PostgreSQL
- Bundler

### Installation

1. Clone the repository:
```bash
git clone https://github.com/nikhilknick/ruby_task_manager_api.git
cd ruby_task_manager_api
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create
rails db:migrate
```

4. Start the server:
```bash
rails server
```

## Configuration

- Database configuration: `config/database.yml`
- Environment variables: Use `.env` files (not committed to git)
- Rails credentials: `config/credentials.yml.enc` (encrypted)

## Development

Run the test suite:
```bash
rails test
```

Run code quality checks:
```bash
bin/rubocop
bin/brakeman
```

## Deployment

This project uses Kamal for deployment. See `config/deploy.yml` for deployment configuration.

## License

[Add your license here]
