puts "Creating users..."
users = [
  { name: "Alice Johnson", email: "alice@example.com", password: "password123" },
  { name: "Bob Smith", email: "bob@example.com", password: "password123" },
  { name: "Carol Williams", email: "carol@example.com", password: "password123" },
  { name: "Dave Brown", email: "dave@example.com", password: "password123" },
  { name: "Eve Davis", email: "eve@example.com", password: "password123" }
].map { |attrs| User.find_or_create_by!(email: attrs[:email]) { |u| u.assign_attributes(attrs) } }

puts "Creating organization..."
org = Organization.find_or_create_by!(name: "Acme Corp") do |o|
  o.description = "A fictional company for demonstration purposes"
end

puts "Adding members..."
alice, bob, carol, dave, eve = users

org.memberships.find_or_create_by!(user: alice, role: :admin)
org.memberships.find_or_create_by!(user: bob, role: :manager)
org.memberships.find_or_create_by!(user: carol, role: :member)
org.memberships.find_or_create_by!(user: dave, role: :member)
org.memberships.find_or_create_by!(user: eve, role: :member)

puts "Creating projects..."
projects_data = [
  { name: "Website Redesign", description: "Complete overhaul of the company website with modern design principles", priority: :high, status: :on_track, color: "#6366f1", icon: "globe", assignee: alice },
  { name: "Mobile App v2", description: "Version 2 of the mobile application with new features", priority: :urgent, status: :at_risk, color: "#ef4444", icon: "smartphone", assignee: bob },
  { name: "Data Migration", description: "Migrate legacy data to new cloud infrastructure", priority: :medium, status: :on_track, color: "#f59e0b", icon: "database", assignee: carol },
  { name: "API Integration", description: "Third-party API integrations for payment and analytics", priority: :high, status: :behind, color: "#10b981", icon: "link", assignee: dave },
  { name: "Internal Tools", description: "Build internal tooling for operations team", priority: :low, status: :on_hold, color: "#8b5cf6", icon: "wrench", assignee: eve },
  { name: "Security Audit", description: "Comprehensive security audit and penetration testing", priority: :urgent, status: :completed, color: "#06b6d4", icon: "shield", assignee: alice }
]

projects = projects_data.map { |attrs| org.projects.find_or_create_by!(name: attrs[:name]) { |p| p.assign_attributes(attrs) } }

puts "Creating tasks..."
statuses = Task.statuses.keys
priorities = Task.priorities.keys
tasks_data = [
  { title: "Design homepage mockup", project: projects[0], assignee: alice, priority: :high, status: :done },
  { title: "Implement responsive navigation", project: projects[0], assignee: bob, priority: :high, status: :in_progress },
  { title: "Create contact form", project: projects[0], assignee: carol, priority: :medium, status: :todo },
  { title: "Optimize images", project: projects[0], assignee: dave, priority: :low, status: :backlog },
  { title: "Setup CI/CD pipeline", project: projects[1], assignee: alice, priority: :urgent, status: :in_progress },
  { title: "Implement push notifications", project: projects[1], assignee: bob, priority: :high, status: :in_review },
  { title: "Add dark mode support", project: projects[1], assignee: carol, priority: :medium, status: :todo },
  { title: "Performance optimization", project: projects[1], assignee: dave, priority: :high, status: :backlog },
  { title: "Export legacy data", project: projects[2], assignee: carol, priority: :medium, status: :done },
  { title: "Validate data integrity", project: projects[2], assignee: alice, priority: :high, status: :in_progress },
  { title: "Setup Stripe integration", project: projects[3], assignee: dave, priority: :high, status: :in_progress },
  { title: "Configure analytics SDK", project: projects[3], assignee: eve, priority: :medium, status: :backlog },
  { title: "Build deployment dashboard", project: projects[4], assignee: eve, priority: :low, status: :todo },
  { title: "Run vulnerability scan", project: projects[5], assignee: alice, priority: :urgent, status: :done },
  { title: "Review access controls", project: projects[5], assignee: bob, priority: :urgent, status: :done }
]

tasks = tasks_data.map { |attrs| Task.find_or_create_by!(title: attrs[:title]) { |t| t.assign_attributes(attrs) } }

puts "Adding checklist items..."
tasks.each do |task|
  task.checklist_items.find_or_create_by!(content: "Research requirements") { |c| c.completed = true }
  task.checklist_items.find_or_create_by!(content: "Implement solution") { |c| c.completed = [ true, false ].sample }
  task.checklist_items.find_or_create_by!(content: "Review and test") { |c| c.completed = [ true, false ].sample }
  task.checklist_items.find_or_create_by!(content: "Deploy to production") { |c| c.completed = false }
end

puts "Adding comments..."
tasks.each do |task|
  users.sample(2).each do |user|
    task.comments.find_or_create_by!(content: Faker::Lorem.sentence(word_count: 15), user: user)
  end
end

puts "Creating OKR cycle..."
cycle = org.okr_cycles.find_or_create_by!(title: "Q3 2026") do |c|
  c.start_date = Date.new(2026, 7, 1)
  c.end_date = Date.new(2026, 9, 30)
  c.status = :active
end

puts "Creating objectives..."
objectives_data = [
  { title: "Improve product quality", owner: alice },
  { title: "Increase customer satisfaction", owner: bob },
  { title: "Accelerate delivery speed", owner: carol }
]

objectives = objectives_data.map { |attrs| cycle.objectives.find_or_create_by!(title: attrs[:title]) { |o| o.assign_attributes(attrs) } }

puts "Creating key results..."
key_results_data = [
  { objective: objectives[0], title: "Reduce bug rate by 50%", target_value: 50, current_value: 35, unit: "%" },
  { objective: objectives[0], title: "Achieve 95% test coverage", target_value: 95, current_value: 82, unit: "%" },
  { objective: objectives[1], title: "Increase NPS score to 60", target_value: 60, current_value: 45, unit: "points" },
  { objective: objectives[1], title: "Reduce support tickets by 30%", target_value: 30, current_value: 20, unit: "%" },
  { objective: objectives[2], title: "Deploy weekly releases", target_value: 12, current_value: 8, unit: "releases" },
  { objective: objectives[2], title: "Reduce cycle time to 2 weeks", target_value: 14, current_value: 18, unit: "days" }
]

key_results_data.each { |attrs| KeyResult.find_or_create_by!(title: attrs[:title]) { |kr| kr.assign_attributes(attrs) } }

puts "Creating strategic canvas..."
projects.each do |project|
  StrategicCanvas.find_or_create_by!(project: project) do |c|
    c.problem = "Need to improve #{project.name.downcase} to meet evolving market demands"
    c.goal = "Successfully deliver #{project.name} with high quality standards"
    c.value_proposition = "Streamlined processes and better user experience"
    c.stakeholders = "Engineering, Design, Product, Marketing teams"
    c.team = "#{project.assignee&.name || 'TBD'} (lead), cross-functional team"
    c.metrics = "Completion rate, user satisfaction, performance benchmarks"
    c.risks = "Resource constraints, timeline pressure, technical debt"
    c.resources = "Engineering time, design tools, cloud infrastructure"
    c.roadmap = "Phase 1: Planning, Phase 2: Development, Phase 3: Testing, Phase 4: Launch"
    c.next_steps = "Kick-off meeting, assign tasks, set up project board"
  end
end

puts "Linking objectives to projects..."
objectives[0].update(project: projects[0])
objectives[1].update(project: projects[3])
objectives[2].update(project: projects[1])

puts "Creating KPIs..."
kpi_data = [
  { name: "Customer NPS", description: "Net Promoter Score from customer surveys", category: :strategic, frequency: :monthly, target_value: 70, current_value: 52, unit: "points", owner: bob },
  { name: "Release Cadence", description: "Number of production releases per month", category: :operational, frequency: :monthly, target_value: 8, current_value: 5, unit: "releases", owner: carol },
  { name: "Bug Fix Rate", description: "Percentage of reported bugs resolved within SLA", category: :quality, frequency: :weekly, target_value: 95, current_value: 87, unit: "%", owner: alice, project: projects[0] },
  { name: "Test Coverage", description: "Code test coverage percentage", category: :quality, frequency: :monthly, target_value: 90, current_value: 78, unit: "%", owner: alice, project: projects[0] },
  { name: "Mobile Crash Rate", description: "App crash rate per 1000 sessions", category: :quality, frequency: :weekly, target_value: 0.1, current_value: 0.3, unit: "%", owner: bob, project: projects[1] },
  { name: "Data Migration Progress", description: "Percentage of records migrated", category: :project, frequency: :weekly, target_value: 100, current_value: 65, unit: "%", owner: carol, project: projects[2] },
  { name: "Monthly Recurring Revenue", description: "Track MRR growth", category: :financial, frequency: :monthly, target_value: 150000, current_value: 120000, unit: "$", owner: alice }
]

kpi_data.each do |attrs|
  proj = attrs.delete(:project)
  owner = attrs.delete(:owner)
  org.kpis.find_or_create_by!(name: attrs[:name]) do |k|
    k.assign_attributes(attrs)
    k.project = proj
    k.owner = owner
  end
end

puts "Creating sample notifications..."
sample_tasks = Task.all.to_a
alice.notifications.find_or_create_by!(action: "task_assigned", notifiable: sample_tasks[0]) do |n|
  n.actor = bob; n.organization = org; n.created_at = 1.hour.ago
end
alice.notifications.find_or_create_by!(action: "task_commented", notifiable: sample_tasks[1]) do |n|
  n.actor = carol; n.organization = org; n.created_at = 3.hours.ago
end
bob.notifications.find_or_create_by!(action: "task_moved", notifiable: sample_tasks[4]) do |n|
  n.actor = alice; n.organization = org; n.created_at = 6.hours.ago
end
carol.notifications.find_or_create_by!(action: "task_assigned", notifiable: sample_tasks[2]) do |n|
  n.actor = alice; n.organization = org; n.created_at = 1.day.ago
end
alice.notifications.find_or_create_by!(action: "task_assigned", notifiable: sample_tasks[3]) do |n|
  n.actor = dave; n.organization = org; n.created_at = 2.days.ago; n.read = true; n.read_at = 1.day.ago
end
alice.notifications.find_or_create_by!(action: "task_commented", notifiable: sample_tasks[0]) do |n|
  n.actor = eve; n.organization = org; n.created_at = 3.days.ago; n.read = true; n.read_at = 2.days.ago
end

puts "Adding activity logs..."
projects.each do |project|
  ActivityLog.find_or_create_by!(
    action: "created project #{project.name}",
    trackable: project,
    trackable_type: "Project",
    user: project.assignee || alice,
    organization: org,
    project: project
  )
end

puts "Seed completed!"
puts ""
puts "Login credentials:"
puts "  Email: alice@example.com"
puts "  Password: password123"
