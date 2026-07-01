# ProjectM

A modern project management software built with Ruby on Rails 8, PostgreSQL, Docker, Hotwire, and Tailwind CSS.

## Features

- **Authentication** – Devise-powered (login, signup, password recovery, profile editing)
- **Organizations** – Workspaces with members and role-based access (admin, manager, member, viewer)
- **Invitations** – Invite users to organizations by email
- **Projects** – Full CRUD with priority, status, assignee, dates, progress, archive/restore
- **Tasks** – Full CRUD with priorities, statuses, due dates, progress, tags, file attachments, and dependencies
- **Checklist** – Per-task checklists with completion tracking
- **Comments** – Per-task threaded comments with file attachments (real-time via Action Cable)
- **Activity History** – Track all changes via ActivityLog (polymorphic)
- **Kanban Board** – Drag-and-drop board with Backlog → To Do → In Progress → In Review → Done columns (real-time via Action Cable)
- **Dashboard** – Overview with gradient stat cards, active/completed projects, open/overdue tasks, upcoming deadlines, recent activity
- **Gantt Chart** – Timeline view with dual-header (month + week), alternating grid, today marker, gradient bars by status
- **Calendar** – Monthly view with task/event filtering
- **OKR Module** – Cycles, Objectives, Key Results with automatic progress calculation
- **Strategic Canvas** – Per-project canvas with Problem, Goal, Value Proposition, Stakeholders, Team, Metrics, Risks, Resources, Roadmap, Next Steps
- **Reports** – Project, task, and productivity reports
- **Tags** – Organization-scoped colored tags for task classification
- **Webhooks** – Organization-scoped webhooks with HMAC-SHA256 signature, event-driven delivery (`task.created`, `task.updated`, `task.moved`, `comment.created`)
- **File Attachments** – Active Storage via local disk, uploaded on tasks and comments
- **Global Search** – Search across projects, tasks, and users
- **Dark Mode** – System/Light/Dark toggle persisted to user preference, full Tailwind `dark:` variant coverage
- **Real-time Updates** – Action Cable channels for notifications, kanban board, and comments
- **Notifications** – In-app notifications with unread badge, real-time counter updates
- **Internationalization** – EN and PT-BR with locale switcher, localized date/time formats
- **Modern UI** – Tailwind CSS v4 with Inter font, responsive sidebar layout, gradient accents

## Tech Stack

- Ruby 4.0.1
- Rails 8.1.3
- PostgreSQL 16
- Docker + Docker Compose
- Hotwire (Turbo + Stimulus)
- Tailwind CSS v4 (`@custom-variant dark`, CSS-driven config)
- Importmap
- Action Cable (async dev, solid_cable prod, test adapter)
- Active Storage (local disk)

### Gems

- **Authentication**: Devise
- **Authorization**: Pundit (with pundit-matchers for specs)
- **Testing**: RSpec 8.0.4, FactoryBot, Faker, Capybara, SimpleCov (branch coverage)
- **Quality**: Rubocop, Brakeman, Bundler Audit
- **Performance**: Bullet (N+1 detection)
- **UI**: Kaminari (pagination)

## Installation

### Prerequisites

- Ruby 4.0+
- Docker & Docker Compose
- Bundler

### Clone

```bash
git clone git@github.com:Marcosschwaab/projectM.git project_m
cd project_m
```

### Environment Variables

Create a `.env` file:

```bash
touch .env
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

### Build Assets & Run

```bash
bin/rails tailwindcss:build
bin/dev
```

Visit http://localhost:3000

## Docker Compose (Full Stack)

```bash
docker compose up --build
```

The app will be available at http://localhost:3000.

## Commands

```bash
# Start server (with Tailwind watcher)
bin/dev

# Start server only
DATABASE_PORT=5433 bin/rails server

# Build Tailwind CSS
bin/rails tailwindcss:build

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
# Run all tests (377 examples, 0 failures)
DATABASE_PORT=5433 bundle exec rspec

# Run specific spec
DATABASE_PORT=5433 bundle exec rspec spec/models/user_spec.rb

# Run with coverage (opens browser)
DATABASE_PORT=5433 bundle exec rspec
open coverage/index.html
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
├── channels/             # Action Cable channels
│   ├── application_cable/
│   ├── comments_channel.rb
│   ├── notifications_channel.rb
│   └── tasks_channel.rb
├── controllers/          # Application controllers (23 + 1 concern)
│   ├── concerns/
│   ├── application_controller.rb
│   ├── calendars_controller.rb
│   ├── checklist_items_controller.rb
│   ├── comments_controller.rb
│   ├── dashboard_controller.rb
│   ├── home_controller.rb
│   ├── invitations_controller.rb
│   ├── kanban_controller.rb
│   ├── key_results_controller.rb
│   ├── kpis_controller.rb
│   ├── locales_controller.rb
│   ├── notifications_controller.rb
│   ├── objectives_controller.rb
│   ├── okr_cycles_controller.rb
│   ├── organizations_controller.rb
│   ├── projects_controller.rb
│   ├── reports_controller.rb
│   ├── searches_controller.rb
│   ├── strategic_canvases_controller.rb
│   ├── tags_controller.rb
│   ├── tasks_controller.rb
│   ├── themes_controller.rb
│   └── webhooks_controller.rb
├── helpers/
│   └── application_helper.rb
├── jobs/
│   └── webhook_delivery_job.rb
├── javascript/           # Stimulus controllers + Action Cable consumer
│   └── controllers/
│       ├── application.js
│       ├── comments_controller.js
│       ├── gantt_controller.js
│       ├── kanban_controller.js
│       └── theme_controller.js
│   └── channels/
│       ├── consumer.js
│       └── notifications_channel.js
├── models/               # Application models (20 + 2 concerns)
│   ├── concerns/
│   │   ├── webhookable.rb
│   ├── activity_log.rb
│   ├── checklist_item.rb
│   ├── comment.rb
│   ├── invitation.rb
│   ├── key_result.rb
│   ├── kpi.rb
│   ├── notification.rb
│   ├── objective.rb
│   ├── okr_cycle.rb
│   ├── organization.rb
│   ├── organization_membership.rb
│   ├── project.rb
│   ├── strategic_canvas.rb
│   ├── tag.rb
│   ├── task.rb
│   ├── task_dependency.rb
│   ├── task_tag.rb
│   ├── user.rb
│   ├── webhook.rb
│   └── webhook_delivery.rb
├── policies/             # Pundit policies (12)
│   ├── application_policy.rb
│   ├── checklist_item_policy.rb
│   ├── comment_policy.rb
│   ├── kpi_policy.rb
│   ├── notification_policy.rb
│   ├── okr_cycle_policy.rb
│   ├── objective_policy.rb
│   ├── organization_policy.rb
│   ├── project_policy.rb
│   ├── strategic_canvas_policy.rb
│   ├── tag_policy.rb
│   ├── task_policy.rb
│   └── webhook_policy.rb
├── views/                # View templates (55+ files)
│   ├── layouts/
│   ├── shared/           # Sidebar, attachments, gantt partials
│   ├── devise/
│   ├── calendars/
│   ├── checklist_items/
│   ├── comments/
│   ├── dashboard/
│   ├── home/
│   ├── invitations/
│   ├── kanban/
│   ├── key_results/
│   ├── kpis/
│   ├── notifications/
│   ├── objectives/
│   ├── okr_cycles/
│   ├── organizations/
│   ├── projects/
│   ├── reports/
│   ├── searches/
│   ├── strategic_canvases/
│   ├── tags/
│   ├── tasks/
│   ├── themes/
│   └── webhooks/
config/
├── cable.yml
├── routes.rb
├── database.yml         # Generic, uses ENV vars
├── locales/             # en.yml, pt-BR.yml
└── initializers/
db/
├── migrate/             # 20+ migrations (incl. Active Storage, webhooks, tags, dependencies)
└── seeds.rb
spec/
├── factories/           # 17 FactoryBot definitions
├── models/              # 16 model specs
├── requests/            # 22 request specs
├── policies/            # 9 policy specs
├── system/              # 13 system specs
└── support/             # Capybara, system helpers
public/
├── icon.svg             # Custom favicon (indigo gradient + white "M")
└── icon.png
```

## Architecture Decisions

- **Environment variables via `.env`** for database configuration, keeping `database.yml` generic
- **PostgreSQL in Docker** on port 5433 to avoid conflicts with local instances
- **Pundit for authorization** with four roles: admin, manager, member, viewer
- **ActivityLog as polymorphic table** for tracking changes across all models
- **Kanban via Stimulus** with native HTML5 drag-and-drop API (no external library)
- **Gantt chart via Stimulus** with pure CSS positioning, dual header (month + week rows), gradient bar colors
- **Tags are org-scoped** (not project-scoped) for cross-project reuse via `task_tags` join table
- **Webhooks org-scoped**, HMAC-SHA256 signed, delivered via `WebhookDeliveryJob` (Net::HTTP, 5s/10s timeouts)
- **Action Cable** with `stream_from` and string keys (`notifications_user_#{id}`, etc.); async in dev, solid_cable in prod
- **Dark mode** via Stimulus `theme_controller`, Tailwind `@custom-variant dark`, persisted to localStorage + `users.theme` column
- **Active Storage** on local disk; `has_many_attached :files` on Task and Comment
- **Task dependencies** validated against self-reference and circular chains via `TaskDependency` model
- **Test coverage**: 377 examples, 0 failures, 88.94% line + 72.6% branch coverage
- **Inflection rule** for "canvas" → "canvases" to properly pluralize StrategicCanvas
- **Locale-aware dates**: all `strftime` calls replaced with `l()` helper, formats in en.yml and pt-BR.yml

## Role Permissions

| Action | Admin | Manager | Member | Viewer |
|--------|-------|---------|--------|--------|
| Manage organization | ✓ | ✓ | - | - |
| Delete organization | ✓ | - | - | - |
| Invite members | ✓ | ✓ | - | - |
| Create/edit projects | ✓ | ✓ | ✓ | - |
| Delete projects | ✓ | ✓ | - | - |
| Create/edit tasks | ✓ | ✓ | ✓ | - |
| Delete tasks | ✓ | ✓ | - | - |
| Manage tags | ✓ | ✓ | - | - |
| Manage webhooks | ✓ | ✓¹ | - | - |
| Delete webhooks | ✓ | - | - | - |

¹ Manager can create/update webhooks but not delete them.

## Real-time Channels

| Channel | Scope | Events |
|---------|-------|--------|
| `NotificationsChannel` | Per user | New notification created |
| `TasksChannel` | Per project | Task moved on kanban |
| `CommentsChannel` | Per task | New comment created |

## Webhook Events

| Event | Trigger |
|-------|---------|
| `task.created` | Task creation |
| `task.updated` | Task update |
| `task.moved` | Task status change (kanban drop) |
| `comment.created` | New comment on a task |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am "feat: add my feature"`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a Pull Request

## License

MIT
