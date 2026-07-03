puts "Cleaning existing data..."
# Delete in dependency order to avoid FK violations
ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{[
  "webhook_deliveries", "webhooks",
  "notifications", "activity_logs",
  "matrix_cells", "matrix_columns", "matrix_rows", "project_matrices",
  "time_entries", "task_dependencies", "task_tags", "tags",
  "checklist_items", "comments",
  "custom_field_values", "strategic_canvases",
  "key_results", "objectives", "okr_cycles", "kpis",
  "project_members",
  "tasks",
  "projects",
  "custom_fields",
  "dashboard_widgets",
  "organization_memberships",
  "users"
].join(", ")} CASCADE")

puts "Creating users..."
users = [
  { name: "Alice Johnson", email: "alice@example.com", password: "password123" },
  { name: "Bob Smith", email: "bob@example.com", password: "password123" },
  { name: "Carol Williams", email: "carol@example.com", password: "password123" },
  { name: "Dave Brown", email: "dave@example.com", password: "password123" },
  { name: "Eve Davis", email: "eve@example.com", password: "password123" }
].map { |attrs| User.create!(attrs) }

puts "Creating organization..."
org = Organization.create!(name: "Acme Corp", description: "A fictional company for demonstration purposes")

puts "Adding members..."
alice, bob, carol, dave, eve = users

org.memberships.create!(user: alice, role: :admin)
org.memberships.create!(user: bob, role: :manager)
org.memberships.create!(user: carol, role: :member)
org.memberships.create!(user: dave, role: :member)
org.memberships.create!(user: eve, role: :member)

puts "Creating custom fields..."
cf_text = org.custom_fields.create!(name: "Priority Justification", field_type: "text", required: false)
cf_risk = org.custom_fields.create!(name: "Risk Level", field_type: "select", options: %w[Low Medium High Critical], required: true)

puts "Creating projects..."
projects_data = [
  {
    name: "Website Redesign",
    description: "Complete overhaul of the company website with modern design principles",
    priority: :high, status: :on_track, color: "#6366f1", icon: "globe",
    assignee: alice, category: "software", sponsor: bob, manager: carol,
    approval_roles: ["sponsor", "manager"], approval_all_team: false,
    start_date: Date.new(2026, 5, 1), end_date: Date.new(2026, 8, 31),
    proposal_investment_estimated: 50_000, project_investment_estimated: 45_000,
    budget_estimated: 22_000, budget_actual: 10_100,
    return_estimated: 80_000, return_actual: 0
  },
  {
    name: "Mobile App v2",
    description: "Version 2 of the mobile application with new features",
    priority: :urgent, status: :at_risk, color: "#ef4444", icon: "smartphone",
    assignee: bob, category: "software", sponsor: alice, manager: dave,
    approval_roles: ["sponsor", "manager", "responsible"], approval_all_team: false,
    start_date: Date.new(2026, 3, 1), end_date: Date.new(2026, 7, 15),
    proposal_investment_estimated: 120_000, project_investment_estimated: 100_000,
    budget_estimated: 95_000, budget_actual: 78_500,
    return_estimated: 200_000, return_actual: 15_000
  },
  {
    name: "Data Migration",
    description: "Migrate legacy data to new cloud infrastructure",
    priority: :medium, status: :on_track, color: "#f59e0b", icon: "database",
    assignee: carol, category: "infrastructure", sponsor: alice, manager: bob,
    approval_roles: ["manager"], approval_all_team: true,
    start_date: Date.new(2026, 6, 1), end_date: Date.new(2026, 9, 30),
    proposal_investment_estimated: 30_000, project_investment_estimated: 28_000,
    budget_estimated: 28_000, budget_actual: 12_000,
    return_estimated: 50_000, return_actual: 0
  },
  {
    name: "API Integration",
    description: "Third-party API integrations for payment and analytics",
    priority: :high, status: :behind, color: "#10b981", icon: "link",
    assignee: dave, category: "software", sponsor: alice, manager: eve,
    approval_roles: [], approval_all_team: true,
    start_date: Date.new(2026, 4, 15), end_date: Date.new(2026, 7, 1),
    proposal_investment_estimated: 15_000, project_investment_estimated: 15_000,
    budget_estimated: 15_000, budget_actual: 14_200,
    return_estimated: 30_000, return_actual: 5_000
  },
  {
    name: "Internal Tools",
    description: "Build internal tooling for operations team",
    priority: :low, status: :on_hold, color: "#8b5cf6", icon: "wrench",
    assignee: eve, category: "other", sponsor: nil, manager: alice,
    approval_roles: ["responsible"], approval_all_team: false,
    start_date: Date.new(2026, 7, 1), end_date: Date.new(2026, 10, 31),
    proposal_investment_estimated: 0, project_investment_estimated: 0,
    budget_estimated: 0, budget_actual: 0,
    return_estimated: 0, return_actual: 0
  },
  {
    name: "Security Audit",
    description: "Comprehensive security audit and penetration testing",
    priority: :urgent, status: :completed, color: "#06b6d4", icon: "shield",
    assignee: alice, category: "business", sponsor: bob, manager: carol,
    approval_roles: ["sponsor", "manager", "responsible"], approval_all_team: false,
    start_date: Date.new(2026, 1, 10), end_date: Date.new(2026, 3, 20),
    proposal_investment_estimated: 25_000, project_investment_estimated: 22_000,
    budget_estimated: 22_000, budget_actual: 21_500,
    return_estimated: 60_000, return_actual: 60_000
  }
]

projects = projects_data.map do |attrs|
  p = org.projects.create!(attrs)
  # Add team members
  org.members.where.not(id: [p.assignee_id, p.sponsor_id, p.manager_id].compact).sample(2).each do |member|
    p.project_members.create!(user: member)
  end
  # Custom field values
  p.custom_field_values.create!(custom_field: cf_text, value: "Strategic initiative for Q3 growth")
  p.custom_field_values.create!(custom_field: cf_risk, value: "Medium")
  p
end

puts "Creating tasks with estimated hours..."
tasks_data = [
  { title: "Design homepage mockup", project: projects[0], assignee: alice, priority: :high, status: :done, estimated_hours: 16, due_date: Date.new(2026, 5, 15) },
  { title: "Implement responsive navigation", project: projects[0], assignee: bob, priority: :high, status: :in_progress, estimated_hours: 24, due_date: Date.new(2026, 6, 10) },
  { title: "Create contact form", project: projects[0], assignee: carol, priority: :medium, status: :todo, estimated_hours: 8, due_date: Date.new(2026, 7, 1) },
  { title: "Optimize images", project: projects[0], assignee: dave, priority: :low, status: :backlog, estimated_hours: 4, due_date: Date.new(2026, 7, 15) },
  { title: "SEO improvements", project: projects[0], assignee: eve, priority: :medium, status: :backlog, estimated_hours: 12, due_date: Date.new(2026, 9, 1) },

  { title: "Setup CI/CD pipeline", project: projects[1], assignee: alice, priority: :urgent, status: :in_progress, estimated_hours: 20, due_date: Date.new(2026, 6, 20) },
  { title: "Implement push notifications", project: projects[1], assignee: bob, priority: :high, status: :in_review, estimated_hours: 32, due_date: Date.new(2026, 7, 5) },
  { title: "Add dark mode support", project: projects[1], assignee: carol, priority: :medium, status: :todo, estimated_hours: 16, due_date: Date.new(2026, 8, 1) },
  { title: "Performance optimization", project: projects[1], assignee: dave, priority: :high, status: :backlog, estimated_hours: 24, due_date: Date.new(2026, 9, 10) },
  { title: "Offline mode support", project: projects[1], assignee: eve, priority: :medium, status: :backlog, estimated_hours: 40, due_date: Date.new(2026, 10, 1) },

  { title: "Export legacy data", project: projects[2], assignee: carol, priority: :medium, status: :done, estimated_hours: 40, due_date: Date.new(2026, 6, 30) },
  { title: "Validate data integrity", project: projects[2], assignee: alice, priority: :high, status: :in_progress, estimated_hours: 16, due_date: Date.new(2026, 7, 15) },
  { title: "Transform data format", project: projects[2], assignee: bob, priority: :high, status: :todo, estimated_hours: 24, due_date: Date.new(2026, 8, 10) },
  { title: "Load data to cloud", project: projects[2], assignee: dave, priority: :high, status: :backlog, estimated_hours: 32, due_date: Date.new(2026, 9, 5) },
  { title: "Verify migration completeness", project: projects[2], assignee: eve, priority: :medium, status: :backlog, estimated_hours: 8, due_date: Date.new(2026, 10, 1) },

  { title: "Setup Stripe integration", project: projects[3], assignee: dave, priority: :high, status: :in_progress, estimated_hours: 24, due_date: Date.new(2026, 6, 15) },
  { title: "Configure analytics SDK", project: projects[3], assignee: eve, priority: :medium, status: :backlog, estimated_hours: 12, due_date: Date.new(2026, 6, 28) },
  { title: "Test payment webhooks", project: projects[3], assignee: alice, priority: :high, status: :todo, estimated_hours: 8, due_date: Date.new(2026, 7, 5) },
  { title: "Build API documentation", project: projects[3], assignee: bob, priority: :low, status: :backlog, estimated_hours: 6, due_date: Date.new(2026, 7, 20) },

  { title: "Build deployment dashboard", project: projects[4], assignee: eve, priority: :low, status: :todo, estimated_hours: 20, due_date: Date.new(2026, 9, 1) },
  { title: "Create monitoring alerts", project: projects[4], assignee: alice, priority: :low, status: :backlog, estimated_hours: 12, due_date: Date.new(2026, 10, 15) },

  { title: "Run vulnerability scan", project: projects[5], assignee: alice, priority: :urgent, status: :done, estimated_hours: 8, due_date: Date.new(2026, 1, 25) },
  { title: "Review access controls", project: projects[5], assignee: bob, priority: :urgent, status: :done, estimated_hours: 12, due_date: Date.new(2026, 2, 10) },
  { title: "Penetration testing", project: projects[5], assignee: carol, priority: :urgent, status: :done, estimated_hours: 24, due_date: Date.new(2026, 3, 1) },
  { title: "Remediation plan", project: projects[5], assignee: dave, priority: :urgent, status: :done, estimated_hours: 16, due_date: Date.new(2026, 3, 15) }
]

tasks = tasks_data.map { |attrs| Task.create!(attrs) }

puts "Updating task progress based on status..."
tasks.each do |task|
  case task.status
  when "done" then task.update_column(:progress, 100)
  when "in_progress" then task.update_column(:progress, rand(30..70))
  when "in_review" then task.update_column(:progress, rand(70..95))
  when "todo" then task.update_column(:progress, 10)
  else task.update_column(:progress, 0)
  end
end

puts "Setting task dependencies..."
# Website Redesign: contact form depends on navigation
tasks[2].dependencies << tasks[1]
# Mobile App: dark mode depends on CI/CD; offline depends on performance
tasks[7].dependencies << tasks[5]
tasks[9].dependencies << tasks[8]
# Data Migration: transform depends on export; load depends on transform; verify depends on load
tasks[12].dependencies << tasks[10]
tasks[13].dependencies << tasks[12]
tasks[14].dependencies << tasks[13]
# API: webhooks depend on stripe; docs depend on webhooks
tasks[17].dependencies << tasks[15]
tasks[18].dependencies << tasks[17]
# Security: penetration depends on vuln scan; remediation depends on penetration
tasks[22].dependencies << tasks[20]
tasks[23].dependencies << tasks[22]

puts "Adding time entries (for IDC/IDP calculation)..."
TimeEntry.create!(task: tasks[0], user: alice, duration: 14, started_at: 2.days.ago.change(hour: 9), description: "Homepage layout design")
TimeEntry.create!(task: tasks[0], user: alice, duration: 120, started_at: 1.day.ago.change(hour: 10), description: "Homepage mockup refinement")
TimeEntry.create!(task: tasks[1], user: bob, duration: 480, started_at: 3.days.ago.change(hour: 8), description: "Navigation implementation")
TimeEntry.create!(task: tasks[5], user: alice, duration: 360, started_at: 5.days.ago.change(hour: 9), description: "CI/CD pipeline setup")
TimeEntry.create!(task: tasks[6], user: bob, duration: 240, started_at: 4.days.ago.change(hour: 14), description: "Push notification service")
TimeEntry.create!(task: tasks[10], user: carol, duration: 600, started_at: 7.days.ago.change(hour: 8), description: "Legacy data export scripts")
TimeEntry.create!(task: tasks[11], user: alice, duration: 120, started_at: 1.day.ago.change(hour: 13), description: "Data validation queries")
TimeEntry.create!(task: tasks[15], user: dave, duration: 360, started_at: 2.days.ago.change(hour: 9), description: "Stripe API setup")

puts "Creating matrices (EAP diagram alternative)..."
matrix = projects[0].project_matrices.create!(name: "RACI Matrix")
cols = ["Engenharia", "Design", "Produto", "Marketing"]
rows = ["HTML/CSS", "Componentes JS", "Testes", "Deploy", "SEO"]

cols.each_with_index { |name, i| matrix.matrix_columns.create!(name: name, position: i) }
rows.each_with_index { |name, i| matrix.matrix_rows.create!(name: name, position: i) }

# Populate cells
matrix.matrix_rows.each do |row|
  matrix.matrix_columns.each do |col|
    MatrixCell.create!(matrix_column: col, matrix_row: row, value: %w[R A C I].sample)
  end
end

matrix2 = projects[1].project_matrices.create!(name: "Feature Priority Matrix")
cols2 = ["Impacto", "Esforço", "Risco", "Prioridade"]
rows2 = ["Push Notifications", "Dark Mode", "Offline Mode", "CI/CD", "Performance"]

cols2.each_with_index { |name, i| matrix2.matrix_columns.create!(name: name, position: i) }
rows2.each_with_index { |name, i| matrix2.matrix_rows.create!(name: name, position: i) }

matrix2.matrix_rows.each do |row|
  matrix2.matrix_columns.each do |col|
    value = case col.name
            when "Impacto" then %w[Alto Médio Baixo].sample
            when "Esforço" then %w[Grande Médio Pequeno].sample
            when "Risco" then %w[Alto Médio Baixo].sample
            when "Prioridade" then %w[P0 P1 P2 P3].sample
            end
    MatrixCell.create!(matrix_column: col, matrix_row: row, value: value)
  end
end

puts "Creating tags..."
tags = %w[frontend backend infrastructure security documentation].map do |name|
  org.tags.create!(name: name, color: "##{SecureRandom.hex(3)}")
end

puts "Tagging tasks..."
tasks.sample(10).each do |task|
  task.tags << tags.sample(rand(1..3))
end

puts "Adding checklist items and comments..."
tasks.each do |task|
  3.times do |i|
    task.checklist_items.create!(content: ["Research requirements", "Implement solution", "Review and test", "Deploy to production"][i], completed: [true, false].sample)
  end
  users.sample(2).each do |user|
    task.comments.create!(content: "Comment about #{task.title} from #{user.name}", user: user)
  end
end

puts "Creating OKR cycle..."
cycle = org.okr_cycles.create!(title: "Q3 2026", start_date: Date.new(2026, 7, 1), end_date: Date.new(2026, 9, 30), status: :active)

puts "Creating objectives..."
objectives = [
  cycle.objectives.create!(title: "Improve product quality", owner: alice, project: projects[0]),
  cycle.objectives.create!(title: "Increase customer satisfaction", owner: bob, project: projects[3]),
  cycle.objectives.create!(title: "Accelerate delivery speed", owner: carol, project: projects[1])
]

puts "Creating key results..."
key_results_data = [
  { objective: objectives[0], title: "Reduce bug rate by 50%", target_value: 50, current_value: 35, unit: "%" },
  { objective: objectives[0], title: "Achieve 95% test coverage", target_value: 95, current_value: 82, unit: "%" },
  { objective: objectives[1], title: "Increase NPS score to 60", target_value: 60, current_value: 45, unit: "points" },
  { objective: objectives[1], title: "Reduce support tickets by 30%", target_value: 30, current_value: 20, unit: "%" },
  { objective: objectives[2], title: "Deploy weekly releases", target_value: 12, current_value: 8, unit: "releases" },
  { objective: objectives[2], title: "Reduce cycle time to 2 weeks", target_value: 14, current_value: 18, unit: "days" }
]

key_results_data.each { |attrs| KeyResult.create!(attrs) }

puts "Creating strategic canvas..."
projects.each do |project|
  StrategicCanvas.create!(
    project: project,
    problem: "Need to improve #{project.name.downcase} to meet evolving market demands",
    goal: "Successfully deliver #{project.name} with high quality standards",
    value_proposition: "Streamlined processes and better user experience",
    stakeholders: "Engineering, Design, Product, Marketing teams",
    team: "#{project.assignee&.name || 'TBD'} (lead), cross-functional team",
    metrics: "Completion rate, user satisfaction, performance benchmarks",
    risks: "Resource constraints, timeline pressure, technical debt",
    resources: "Engineering time, design tools, cloud infrastructure",
    roadmap: "Phase 1: Planning, Phase 2: Development, Phase 3: Testing, Phase 4: Launch",
    next_steps: "Kick-off meeting, assign tasks, set up project board"
  )
end

puts "Creating KPIs..."
kpi_data = [
  { name: "Customer NPS", description: "Net Promoter Score from customer surveys", category: :strategic, frequency: :monthly, target_value: 70, current_value: 52, unit: "points", owner: bob },
  { name: "Release Cadence", description: "Number of production releases per month", category: :operational, frequency: :monthly, target_value: 8, current_value: 5, unit: "releases", owner: carol },
  { name: "Bug Fix Rate", description: "Percentage of reported bugs resolved within SLA", category: :quality, frequency: :weekly, target_value: 95, current_value: 87, unit: "%", owner: alice, project: projects[0] },
  { name: "Test Coverage", description: "Code test coverage percentage", category: :quality, frequency: :monthly, target_value: 90, current_value: 78, unit: "%", owner: alice, project: projects[0] },
  { name: "Mobile Crash Rate", description: "App crash rate per 1000 sessions", category: :quality, frequency: :weekly, target_value: 0.1, current_value: 0.3, unit: "%", owner: bob, project: projects[1] },
  { name: "Data Migration Progress", description: "Percentage of records migrated", category: :project, frequency: :weekly, target_value: 100, current_value: 65, unit: "%", owner: carol, project: projects[2] },
  { name: "Monthly Recurring Revenue", description: "Track MRR growth", category: :financial, frequency: :monthly, target_value: 150_000, current_value: 120_000, unit: "$", owner: alice }
]

kpi_data.each do |attrs|
  org.kpis.create!(attrs)
end

puts "Creating webhooks..."
webhook = org.webhooks.create!(
  name: "Slack Notifier",
  url: "https://hooks.slack.com/services/T00/B00/example",
  events: ["task.created", "task.updated", "comment.created"],
  active: true
)
webhook.deliveries.create!(status: "success", response: "200 OK")
webhook.deliveries.create!(status: "success", response: "200 OK")
webhook.deliveries.create!(status: "failed", response: "500 Internal Server Error", error: "Connection timeout")

puts "Creating sample notifications..."
alice.notifications.create!(action: "task_assigned", notifiable: tasks[0], actor: bob, organization: org, created_at: 1.hour.ago)
alice.notifications.create!(action: "task_commented", notifiable: tasks[1], actor: carol, organization: org, created_at: 3.hours.ago)
bob.notifications.create!(action: "task_moved", notifiable: tasks[4], actor: alice, organization: org, created_at: 6.hours.ago)
carol.notifications.create!(action: "task_assigned", notifiable: tasks[2], actor: alice, organization: org, created_at: 1.day.ago)
alice.notifications.create!(action: "task_assigned", notifiable: tasks[3], actor: dave, organization: org, created_at: 2.days.ago, read: true, read_at: 1.day.ago)
alice.notifications.create!(action: "task_commented", notifiable: tasks[0], actor: eve, organization: org, created_at: 3.days.ago, read: true, read_at: 2.days.ago)

puts "Adding activity logs..."
projects.each do |project|
  ActivityLog.create!(
    action: "created project #{project.name}",
    trackable: project, trackable_type: "Project",
    user: project.assignee || alice,
    organization: org, project: project
  )
end

tasks.sample(10).each do |task|
  ActivityLog.create!(
    action: "created task #{task.title}",
    trackable: task, trackable_type: "Task",
    user: task.assignee || alice,
    organization: org, project: task.project
  )
end

puts ""
puts "=== Seed completed! ==="
puts ""
puts "Login credentials:"
puts "  Email: alice@example.com"
puts "  Password: password123"
puts ""
puts "Projects: #{Project.count}"
puts "Tasks: #{Task.count}"
puts "Task dependencies: #{TaskDependency.count}"
puts "Time entries: #{TimeEntry.count}"
puts "Project matrices: #{ProjectMatrix.count}"
puts "Matrix cells: #{MatrixCell.count}"
puts "Tags: #{Tag.count}"
puts "Custom fields: #{CustomField.count}"
puts "Custom field values: #{CustomFieldValue.count}"
puts "Team members (project): #{ProjectMember.count}"
puts "Comments: #{Comment.count}"
puts "Checklist items: #{ChecklistItem.count}"
puts "OKR cycles: #{OkrCycle.count}"
puts "Objectives: #{Objective.count}"
puts "Key results: #{KeyResult.count}"
puts "KPIs: #{Kpi.count}"
puts "Strategic canvases: #{StrategicCanvas.count}"
puts "Webhooks: #{Webhook.count}"
puts "Notifications: #{Notification.count}"
puts "Activity logs: #{ActivityLog.count}"
