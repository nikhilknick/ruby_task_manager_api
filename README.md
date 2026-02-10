# Task Manager API

A Rails API application for managing tasks. This is a RESTful API built with Ruby on Rails that provides endpoints for task management operations.

## Project Overview

This is a task_manager_api project built with Ruby on Rails, designed to handle task management functionality through a clean API interface.

## Technology Stack

- Ruby on Rails (API mode)
- PostgreSQL database
- Solid Queue for background jobs
- Kamal for deployment
- JWT for authentication
- Swagger for API documentation

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

## API Documentation

The API documentation is available via Swagger UI. Once the server is running, you can access the interactive API documentation at:

```
http://localhost:3000/api-docs
```

### Available Endpoints

The API provides RESTful endpoints for task management:

- **Tasks**: CRUD operations for managing tasks
- **Authentication**: User registration and login endpoints
- **Users**: User management endpoints

For detailed information about request/response formats and authentication requirements, please refer to the Swagger documentation.

## Deployment

This project uses Kamal for deployment. See `config/deploy.yml` for deployment configuration.

### Deployment Steps

1. Configure your deployment settings in `config/deploy.yml`
2. Set up required environment variables
3. Run deployment command:
```bash
kamal deploy
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.
