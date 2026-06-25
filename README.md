# ProjectM

A modern project management software built with Ruby on Rails 8, PostgreSQL, Docker, Hotwire, and Tailwind CSS.

## Features

- **Authentication** - Devise-powered (login, signup, password recovery, profile editing)
- **Organizations** - Workspaces with members and role-based access (admin, manager, member)
- **Invitations** - Invite users to organizations by email
- **Projects** - Full CRUD with priority, status, assignee, dates, progress, archive
- **Tasks** - Full CRUD with priorities, statuses, due dates, and progress tracking
- **Checklist** - Per-task checklists with completion tracking
- **Comments** - Per-task threaded comments
- **Activity History** - Track all changes via ActivityLog (polymorphic)
- **Kanban Board** - Drag-and-drop board with Backlog → To Do → In Progress → In Review → Done columns
- **Dashboard** - Overview with active/completed projects, open/overdue tasks, upcoming deadlines, recent activity
- **OKR Module** - Cycles, Objectives, Key Results with automatic progress calculation
- **Strategic Canvas** - Per-project canvas with Problem, Goal, Value Proposition, Stakeholders, Team, Metrics, Risks, Resources, Roadmap, Next Steps
- **Reports** - Project, task, and productivity reports
- **Global Search** - Search across projects, tasks, and users
- **Modern UI** - Tailwind CSS with Inter font, sidebar layout, responsive design

## Tech Stack

- Ruby 4.0.1
- Rails 8.1.3
- PostgreSQL 16
- Docker + Docker Compose
- Hotwire (Turbo + Stimulus)
- Tailwind CSS 4
- Importmap

### Gems

- **Authentication**: Devise
- **Authorization**: Pundit
- **Testing**: RSpec, FactoryBot, Faker, Capybara, SimpleCov
- **Quality**: Rubocop, Brakeman, Bundler Audit
- **Performance**: Bullet (N+1 detection)
- **UI**: ViewComponent (available), Kaminari (pagination)

## Installation

### Prerequisites

- Ruby 4.0+
- Docker & Docker Compose
- Bundler

### Clone

```bash
git clone <repo-url> project_m
cd project_m
```

### Environment Variables

Copy the example env file:

```bash
cp .env.example .env
```

Configure as needed:

```
DATABASE_HOST=localhost
DATABASE_PORT=5433
DATABASE_NAME=project_m_development
DATABASE_USERNAME=project_m
DATABASE_PASSWORD=project_m_password
RAILS_ENV=development
SECRET_KEY_BASE=
```

Generate a secret key:

```bash
rails secret
```

### Docker (PostgreSQL)

Start PostgreSQL:

```bash
docker compose up -d postgres
```

The PostgreSQL container runs on port `5433` (configurable via `DATABASE_PORT`).

### Install Dependencies

```bash
bundle install
```

### Database Setup

```bash
bin/rails db:create
bin/rails db:migrate
```

### Seed Data

```bash
bin/rails db:seed
```

Login credentials:

```
Email: alice@example.com
Password: password123
```

### Run the Server

```bash
bin/dev
```

Or without Tailwind watcher:

```bash
DATABASE_PORT=5433 bin/rails server
```

Visit http://localhost:3000

## Docker Compose (Full Stack)

To run both the app and PostgreSQL in Docker:

```bash
docker compose up --build
```

The app will be available at http://localhost:3000.

## Commands

```bash
# Start server
DATABASE_PORT=5433 bin/rails server

# Start with Tailwind watcher
bin/dev

# Console
DATABASE_PORT=5433 bin/rails console

# Migrations
DATABASE_PORT=5433 bin/rails db:migrate

# Seed
DATABASE_PORT=5433 bin/rails db:seed

# Rollback
DATABASE_PORT=5433 bin/rails db:rollback

# Routes
DATABASE_PORT=5433 bin/rails routes
```

## Tests

```bash
# Run all tests
DATABASE_PORT=5433 bundle exec rspec

# Run specific test
DATABASE_PORT=5433 bundle exec rspec spec/models/user_spec.rb

# Run with coverage
DATABASE_PORT=5433 bundle exec rspec
# Open coverage/index.html in browser
```

## Lint

```bash
# Rubocop
bundle exec rubocop

# Rubocop auto-fix
bundle exec rubocop -a

# Brakeman security scan
bundle exec brakeman

# Bundler audit
bundle exec bundler-audit
```

## Project Structure

```
app/
├── controllers/       # Application controllers
│   ├── concerns/      # Shared controller concerns
│   ├── application_controller.rb
│   ├── home_controller.rb
│   ├── organizations_controller.rb
│   ├── invitations_controller.rb
│   ├── projects_controller.rb
│   ├── tasks_controller.rb
│   ├── comments_controller.rb
│   ├── checklist_items_controller.rb
│   ├── kanban_controller.rb
│   ├── dashboard_controller.rb
│   ├── okr_cycles_controller.rb
│   ├── strategic_canvases_controller.rb
│   ├── reports_controller.rb
│   └── searches_controller.rb
├── models/            # Application models
│   ├── concerns/      # Shared model concerns
│   ├── user.rb
│   ├── organization.rb
│   ├── organization_membership.rb
│   ├── invitation.rb
│   ├── project.rb
│   ├── task.rb
│   ├── checklist_item.rb
│   ├── comment.rb
│   ├── activity_log.rb
│   ├── okr_cycle.rb
│   ├── objective.rb
│   ├── key_result.rb
│   └── strategic_canvas.rb
├── policies/          # Pundit authorization policies
│   ├── application_policy.rb
│   ├── organization_policy.rb
│   ├── project_policy.rb
│   ├── task_policy.rb
│   ├── comment_policy.rb
│   ├── checklist_item_policy.rb
│   ├── okr_cycle_policy.rb
│   └── strategic_canvas_policy.rb
├── views/             # View templates
│   ├── layouts/
│   ├── shared/        # Sidebar, topbar partials
│   ├── devise/        # Devise views (auth)
│   ├── home/
│   ├── organizations/
│   ├── invitations/
│   ├── projects/
│   ├── tasks/
│   ├── kanban/
│   ├── dashboard/
│   ├── okr_cycles/
│   ├── strategic_canvases/
│   ├── reports/
│   └── searches/
├── javascript/        # Stimulus controllers
│   └── controllers/
│       ├── application.js
│       ├── hello_controller.js
│       └── kanban_controller.js
├── helpers/           # Helper modules
└── assets/
    └── tailwind/      # Tailwind CSS entry point
config/
├── routes.rb          # Route definitions
├── database.yml       # Database configuration
└── initializers/      # Initializers (Devise, inflections, etc.)
db/
├── migrate/           # Database migrations
└── seeds.rb           # Demo seed data
spec/
├── factories/         # FactoryBot definitions
├── models/            # Model specs
├── requests/          # Request specs
├── policies/          # Policy specs
├── system/            # System specs
└── support/           # Test support files
```

## Architecture Decisions

- **Environment variables via `.env`** for database configuration, keeping `database.yml` generic
- **PostgreSQL in Docker** on port 5433 to avoid conflicts with local PostgreSQL instances
- **Pundit for authorization** with three roles: admin, manager, member
- **ActivityLog as polymorphic table** for tracking changes across all models
- **Kanban via Stimulus** with native HTML5 drag-and-drop API (no external library)
- **Tasks grouped by status** for the Kanban board (backlog, todo, in_progress, in_review, done)
- **Inflection rule** for "canvas" → "canvases" to properly pluralize StrategicCanvas

## Role Permissions

| Action | Admin | Manager | Member |
|--------|-------|---------|--------|
| Manage organization | ✓ | ✓ | - |
| Delete organization | ✓ | - | - |
| Invite members | ✓ | ✓ | - |
| Create/edit projects | ✓ | ✓ | ✓ |
| Delete projects | ✓ | ✓ | - |
| Create/edit tasks | ✓ | ✓ | ✓ |
| Delete tasks | ✓ | ✓ | - |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am "feat: add my feature"`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a Pull Request

## License

MIT
