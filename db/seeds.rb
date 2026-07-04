puts "Limpando dados existentes..."
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
  "projects", "programs",
  "custom_fields",
  "dashboard_widgets",
  "organization_memberships",
  "users"
].join(", ")} CASCADE")

puts "Criando usuários..."
users = [
  { name: "Alice Souza", email: "alice@example.com", password: "password123" },
  { name: "Carlos Oliveira", email: "carlos@example.com", password: "password123" },
  { name: "Fernanda Lima", email: "fernanda@example.com", password: "password123" },
  { name: "Rafael Santos", email: "rafael@example.com", password: "password123" },
  { name: "Juliana Costa", email: "juliana@example.com", password: "password123" },
  { name: "Pedro Almeida", email: "pedro@example.com", password: "password123" },
  { name: "Marina Barbosa", email: "marina@example.com", password: "password123" },
  { name: "Thiago Pereira", email: "thiago@example.com", password: "password123" }
].map { |attrs| User.create!(attrs) }

puts "Criando organização..."
org = Organization.create!(name: "TechSolutions Brasil", description: "Empresa de tecnologia focada em transformação digital")

puts "Adicionando membros..."
alice, carlos, fernanda, rafael, juliana, pedro, marina, thiago = users

org.memberships.create!(user: alice, role: :admin)
org.memberships.create!(user: carlos, role: :manager)
org.memberships.create!(user: fernanda, role: :member)
org.memberships.create!(user: rafael, role: :member)
org.memberships.create!(user: juliana, role: :member)
org.memberships.create!(user: pedro, role: :member)
org.memberships.create!(user: marina, role: :member)
org.memberships.create!(user: thiago, role: :member)

puts "Criando campos personalizados..."
cf_text = org.custom_fields.create!(name: "Justificativa de Prioridade", field_type: "text", required: false)
cf_risk = org.custom_fields.create!(name: "Nível de Risco", field_type: "select", options: %w[Baixo Médio Alto Crítico], required: true)

puts "Criando portfólios..."
programas_data = [
  {
    name: "Transformação Digital",
    description: "Iniciativas de modernização e transformação digital da empresa",
    status: :on_track, color: "#6366f1",
    start_date: Date.new(2026, 1, 1), end_date: Date.new(2026, 12, 31),
    budget: 1_500_000
  },
  {
    name: "Inovação em Produtos",
    description: "Novos produtos e funcionalidades para expansão de mercado",
    status: :at_risk, color: "#ef4444",
    start_date: Date.new(2026, 3, 1), end_date: Date.new(2026, 11, 30),
    budget: 2_200_000
  },
  {
    name: "Infraestrutura & Qualidade",
    description: "Melhorias de infraestrutura, segurança e qualidade de software",
    status: :on_track, color: "#10b981",
    start_date: Date.new(2026, 2, 1), end_date: Date.new(2026, 10, 31),
    budget: 800_000
  }
]

programas = programas_data.map { |attrs| org.programs.create!(attrs) }
transformacao, inovacao, infraestrutura = programas

puts "Criando projetos..."
projects_data = [
  {
    name: "Redesign do Site Institucional",
    description: "Modernização completa do site da empresa com design system próprio",
    priority: :high, status: :on_track, color: "#6366f1", icon: "globe",
    assignee: alice, category: "software", sponsor: carlos, manager: fernanda,
    program: transformacao,
    approval_roles: ["sponsor", "manager"], approval_all_team: false,
    start_date: Date.new(2026, 5, 1), end_date: Date.new(2026, 8, 31),
    proposal_investment_estimated: 50_000, project_investment_estimated: 45_000,
    budget_estimated: 22_000, budget_actual: 10_100,
    return_estimated: 80_000, return_actual: 0
  },
  {
    name: "Aplicativo Mobile v2",
    description: "Nova versão do aplicativo com funcionalidades offline e modo escuro",
    priority: :urgent, status: :at_risk, color: "#ef4444", icon: "smartphone",
    assignee: carlos, category: "software", sponsor: alice, manager: rafael,
    program: inovacao,
    approval_roles: ["sponsor", "manager", "responsible"], approval_all_team: false,
    start_date: Date.new(2026, 3, 1), end_date: Date.new(2026, 7, 15),
    proposal_investment_estimated: 120_000, project_investment_estimated: 100_000,
    budget_estimated: 95_000, budget_actual: 78_500,
    return_estimated: 200_000, return_actual: 15_000
  },
  {
    name: "Migração para Nuvem",
    description: "Migração de dados legados para infraestrutura cloud-native",
    priority: :medium, status: :on_track, color: "#f59e0b", icon: "database",
    assignee: fernanda, category: "infrastructure", sponsor: alice, manager: carlos,
    program: infraestrutura,
    approval_roles: ["manager"], approval_all_team: true,
    start_date: Date.new(2026, 6, 1), end_date: Date.new(2026, 9, 30),
    proposal_investment_estimated: 30_000, project_investment_estimated: 28_000,
    budget_estimated: 28_000, budget_actual: 12_000,
    return_estimated: 50_000, return_actual: 0
  },
  {
    name: "Integração com APIs",
    description: "Integrações com gateways de pagamento e plataformas de analytics",
    priority: :high, status: :behind, color: "#10b981", icon: "link",
    assignee: rafael, category: "software", sponsor: alice, manager: juliana,
    program: inovacao,
    approval_roles: [], approval_all_team: true,
    start_date: Date.new(2026, 4, 15), end_date: Date.new(2026, 7, 1),
    proposal_investment_estimated: 15_000, project_investment_estimated: 15_000,
    budget_estimated: 15_000, budget_actual: 14_200,
    return_estimated: 30_000, return_actual: 5_000
  },
  {
    name: "Ferramentas Internas",
    description: "Desenvolvimento de ferramentas para a equipe de operações",
    priority: :low, status: :on_hold, color: "#8b5cf6", icon: "wrench",
    assignee: juliana, category: "other", sponsor: nil, manager: alice,
    program: transformacao,
    approval_roles: ["responsible"], approval_all_team: false,
    start_date: Date.new(2026, 7, 1), end_date: Date.new(2026, 10, 31),
    proposal_investment_estimated: 0, project_investment_estimated: 0,
    budget_estimated: 0, budget_actual: 0,
    return_estimated: 0, return_actual: 0
  },
  {
    name: "Auditoria de Segurança",
    description: "Auditoria completa de segurança e testes de penetração",
    priority: :urgent, status: :completed, color: "#06b6d4", icon: "shield",
    assignee: alice, category: "business", sponsor: carlos, manager: fernanda,
    program: infraestrutura,
    approval_roles: ["sponsor", "manager", "responsible"], approval_all_team: false,
    start_date: Date.new(2026, 1, 10), end_date: Date.new(2026, 3, 20),
    proposal_investment_estimated: 25_000, project_investment_estimated: 22_000,
    budget_estimated: 22_000, budget_actual: 21_500,
    return_estimated: 60_000, return_actual: 60_000
  },
  {
    name: "Plataforma de E-commerce",
    description: "Nova plataforma de e-commerce B2B com catálogo dinâmico",
    priority: :high, status: :on_track, color: "#f97316", icon: "shopping-cart",
    assignee: pedro, category: "software", sponsor: alice, manager: carlos,
    program: inovacao,
    approval_roles: ["sponsor", "responsible"], approval_all_team: false,
    start_date: Date.new(2026, 4, 1), end_date: Date.new(2026, 9, 30),
    proposal_investment_estimated: 200_000, project_investment_estimated: 180_000,
    budget_estimated: 180_000, budget_actual: 95_000,
    return_estimated: 350_000, return_actual: 20_000
  },
  {
    name: "Monitoramento & Observabilidade",
    description: "Implementação de stack de monitoramento com dashboards em tempo real",
    priority: :medium, status: :behind, color: "#14b8a6", icon: "activity",
    assignee: marina, category: "infrastructure", sponsor: carlos, manager: rafael,
    program: infraestrutura,
    approval_roles: ["manager", "responsible"], approval_all_team: false,
    start_date: Date.new(2026, 5, 15), end_date: Date.new(2026, 8, 15),
    proposal_investment_estimated: 40_000, project_investment_estimated: 35_000,
    budget_estimated: 35_000, budget_actual: 8_000,
    return_estimated: 60_000, return_actual: 0
  },
  {
    name: "Treinamento & Documentação",
    description: "Criação de trilhas de aprendizado e documentação técnica",
    priority: :low, status: :on_hold, color: "#a855f7", icon: "book",
    assignee: thiago, category: "business", sponsor: alice, manager: juliana,
    program: transformacao,
    approval_roles: ["manager"], approval_all_team: true,
    start_date: Date.new(2026, 8, 1), end_date: Date.new(2026, 11, 30),
    proposal_investment_estimated: 10_000, project_investment_estimated: 10_000,
    budget_estimated: 10_000, budget_actual: 0,
    return_estimated: 15_000, return_actual: 0
  }
]

projects = projects_data.map do |attrs|
  p = org.projects.create!(attrs)

  # Criar project members com roles variados
  all_members = org.members.where.not(id: [p.assignee_id, p.sponsor_id, p.manager_id].compact)
  eligible_managers = all_members.to_a.sample(rand(1..2))
  eligible_members = (all_members - eligible_managers).sample(rand(1..3))

  eligible_managers.each { |m| p.project_members.create!(user: m, role: :manager) }
  eligible_members.each { |m| p.project_members.create!(user: m, role: :member) }

  p.custom_field_values.create!(custom_field: cf_text, value: "Iniciativa estratégica para #{p.program&.name&.downcase || 'crescimento'}")
  p.custom_field_values.create!(custom_field: cf_risk, value: %w[Baixo Médio Alto Crítico].sample)
  p
end

puts "Criando tarefas..."
tasks_data = [
  { title: "Criar mockup da homepage", project: projects[0], assignee: alice, priority: :high, status: :done, estimated_hours: 16, due_date: Date.new(2026, 5, 15) },
  { title: "Implementar navegação responsiva", project: projects[0], assignee: carlos, priority: :high, status: :in_progress, estimated_hours: 24, due_date: Date.new(2026, 6, 10) },
  { title: "Criar formulário de contato", project: projects[0], assignee: fernanda, priority: :medium, status: :todo, estimated_hours: 8, due_date: Date.new(2026, 7, 1) },
  { title: "Otimizar imagens", project: projects[0], assignee: rafael, priority: :low, status: :backlog, estimated_hours: 4, due_date: Date.new(2026, 7, 15) },
  { title: "Melhorias de SEO", project: projects[0], assignee: juliana, priority: :medium, status: :backlog, estimated_hours: 12, due_date: Date.new(2026, 9, 1) },

  { title: "Configurar pipeline CI/CD", project: projects[1], assignee: alice, priority: :urgent, status: :in_progress, estimated_hours: 20, due_date: Date.new(2026, 6, 20) },
  { title: "Implementar notificações push", project: projects[1], assignee: carlos, priority: :high, status: :in_review, estimated_hours: 32, due_date: Date.new(2026, 7, 5) },
  { title: "Adicionar suporte a modo escuro", project: projects[1], assignee: fernanda, priority: :medium, status: :todo, estimated_hours: 16, due_date: Date.new(2026, 8, 1) },
  { title: "Otimização de performance", project: projects[1], assignee: rafael, priority: :high, status: :backlog, estimated_hours: 24, due_date: Date.new(2026, 9, 10) },
  { title: "Suporte offline", project: projects[1], assignee: juliana, priority: :medium, status: :backlog, estimated_hours: 40, due_date: Date.new(2026, 10, 1) },

  { title: "Exportar dados legados", project: projects[2], assignee: fernanda, priority: :medium, status: :done, estimated_hours: 40, due_date: Date.new(2026, 6, 30) },
  { title: "Validar integridade dos dados", project: projects[2], assignee: alice, priority: :high, status: :in_progress, estimated_hours: 16, due_date: Date.new(2026, 7, 15) },
  { title: "Transformar formato dos dados", project: projects[2], assignee: carlos, priority: :high, status: :todo, estimated_hours: 24, due_date: Date.new(2026, 8, 10) },
  { title: "Carregar dados na nuvem", project: projects[2], assignee: rafael, priority: :high, status: :backlog, estimated_hours: 32, due_date: Date.new(2026, 9, 5) },
  { title: "Verificar completude da migração", project: projects[2], assignee: juliana, priority: :medium, status: :backlog, estimated_hours: 8, due_date: Date.new(2026, 10, 1) },

  { title: "Configurar integração Stripe", project: projects[3], assignee: rafael, priority: :high, status: :in_progress, estimated_hours: 24, due_date: Date.new(2026, 6, 15) },
  { title: "Configurar SDK de analytics", project: projects[3], assignee: juliana, priority: :medium, status: :backlog, estimated_hours: 12, due_date: Date.new(2026, 6, 28) },
  { title: "Testar webhooks de pagamento", project: projects[3], assignee: alice, priority: :high, status: :todo, estimated_hours: 8, due_date: Date.new(2026, 7, 5) },
  { title: "Documentar APIs", project: projects[3], assignee: carlos, priority: :low, status: :backlog, estimated_hours: 6, due_date: Date.new(2026, 7, 20) },

  { title: "Criar dashboard de deploys", project: projects[4], assignee: juliana, priority: :low, status: :todo, estimated_hours: 20, due_date: Date.new(2026, 9, 1) },
  { title: "Configurar alertas de monitoramento", project: projects[4], assignee: alice, priority: :low, status: :backlog, estimated_hours: 12, due_date: Date.new(2026, 10, 15) },

  { title: "Executar varredura de vulnerabilidades", project: projects[5], assignee: alice, priority: :urgent, status: :done, estimated_hours: 8, due_date: Date.new(2026, 1, 25) },
  { title: "Revisar controles de acesso", project: projects[5], assignee: carlos, priority: :urgent, status: :done, estimated_hours: 12, due_date: Date.new(2026, 2, 10) },
  { title: "Testes de penetração", project: projects[5], assignee: fernanda, priority: :urgent, status: :done, estimated_hours: 24, due_date: Date.new(2026, 3, 1) },
  { title: "Plano de remediação", project: projects[5], assignee: rafael, priority: :urgent, status: :done, estimated_hours: 16, due_date: Date.new(2026, 3, 15) },

  { title: "Modelar catálogo de produtos", project: projects[6], assignee: pedro, priority: :high, status: :done, estimated_hours: 32, due_date: Date.new(2026, 5, 15) },
  { title: "Implementar carrinho de compras", project: projects[6], assignee: marina, priority: :high, status: :in_progress, estimated_hours: 40, due_date: Date.new(2026, 6, 30) },
  { title: "Integrar gateway de pagamento", project: projects[6], assignee: thiago, priority: :urgent, status: :in_progress, estimated_hours: 24, due_date: Date.new(2026, 7, 15) },
  { title: "Desenvolver painel do vendedor", project: projects[6], assignee: alice, priority: :medium, status: :todo, estimated_hours: 30, due_date: Date.new(2026, 8, 15) },

  { title: "Configurar Prometheus + Grafana", project: projects[7], assignee: marina, priority: :high, status: :in_progress, estimated_hours: 24, due_date: Date.new(2026, 6, 20) },
  { title: "Criar dashboards operacionais", project: projects[7], assignee: thiago, priority: :medium, status: :todo, estimated_hours: 16, due_date: Date.new(2026, 7, 10) },
  { title: "Configurar alertas automáticos", project: projects[7], assignee: pedro, priority: :high, status: :backlog, estimated_hours: 12, due_date: Date.new(2026, 7, 30) },

  { title: "Criar trilha de onboarding", project: projects[8], assignee: thiago, priority: :medium, status: :todo, estimated_hours: 20, due_date: Date.new(2026, 9, 1) },
  { title: "Documentar arquitetura do sistema", project: projects[8], assignee: juliana, priority: :low, status: :backlog, estimated_hours: 16, due_date: Date.new(2026, 10, 15) },
  { title: "Gravar video-tutoriais", project: projects[8], assignee: pedro, priority: :low, status: :backlog, estimated_hours: 24, due_date: Date.new(2026, 11, 1) }
]

tasks = tasks_data.map { |attrs| Task.create!(attrs) }

puts "Atualizando progresso das tarefas..."
tasks.each do |task|
  case task.status
  when "done" then task.update_column(:progress, 100)
  when "in_progress" then task.update_column(:progress, rand(30..70))
  when "in_review" then task.update_column(:progress, rand(70..95))
  when "todo" then task.update_column(:progress, 10)
  else task.update_column(:progress, 0)
  end
end

puts "Criando dependências entre tarefas..."
tasks[2].dependencies << tasks[1]
tasks[7].dependencies << tasks[5]
tasks[9].dependencies << tasks[8]
tasks[12].dependencies << tasks[10]
tasks[13].dependencies << tasks[12]
tasks[14].dependencies << tasks[13]
tasks[17].dependencies << tasks[15]
tasks[18].dependencies << tasks[17]
tasks[22].dependencies << tasks[20]
tasks[23].dependencies << tasks[22]
tasks[26].dependencies << tasks[25]
tasks[27].dependencies << tasks[26]

puts "Criando apontamentos de horas..."
TimeEntry.create!(task: tasks[0], user: alice, duration: 14, started_at: 2.days.ago.change(hour: 9), description: "Layout da homepage")
TimeEntry.create!(task: tasks[0], user: alice, duration: 120, started_at: 1.day.ago.change(hour: 10), description: "Refinamento do mockup")
TimeEntry.create!(task: tasks[1], user: carlos, duration: 480, started_at: 3.days.ago.change(hour: 8), description: "Implementação da navegação")
TimeEntry.create!(task: tasks[5], user: alice, duration: 360, started_at: 5.days.ago.change(hour: 9), description: "Setup do CI/CD")
TimeEntry.create!(task: tasks[6], user: carlos, duration: 240, started_at: 4.days.ago.change(hour: 14), description: "Serviço de notificações push")
TimeEntry.create!(task: tasks[10], user: fernanda, duration: 600, started_at: 7.days.ago.change(hour: 8), description: "Scripts de exportação")
TimeEntry.create!(task: tasks[11], user: alice, duration: 120, started_at: 1.day.ago.change(hour: 13), description: "Validação de dados")
TimeEntry.create!(task: tasks[15], user: rafael, duration: 360, started_at: 2.days.ago.change(hour: 9), description: "Setup Stripe")
TimeEntry.create!(task: tasks[25], user: pedro, duration: 480, started_at: 3.days.ago.change(hour: 8), description: "Modelagem do catálogo")
TimeEntry.create!(task: tasks[26], user: marina, duration: 300, started_at: 1.day.ago.change(hour: 10), description: "Implementação do carrinho")
TimeEntry.create!(task: tasks[27], user: thiago, duration: 180, started_at: 12.hours.ago.change(hour: 14), description: "Integração com gateway")

puts "Criando matrizes..."
matrix = projects[0].project_matrices.create!(name: "Matriz RACI")
cols = ["Engenharia", "Design", "Produto", "Marketing"]
rows = ["HTML/CSS", "Componentes JS", "Testes", "Deploy", "SEO"]

cols.each_with_index { |name, i| matrix.matrix_columns.create!(name: name, position: i) }
rows.each_with_index { |name, i| matrix.matrix_rows.create!(name: name, position: i) }

matrix.matrix_rows.each do |row|
  matrix.matrix_columns.each do |col|
    MatrixCell.create!(matrix_column: col, matrix_row: row, value: %w[R A C I].sample)
  end
end

matrix2 = projects[1].project_matrices.create!(name: "Matriz de Prioridades")
cols2 = ["Impacto", "Esforço", "Risco", "Prioridade"]
rows2 = ["Notificações Push", "Modo Escuro", "Modo Offline", "CI/CD", "Performance"]

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

puts "Criando tags..."
tags = %w[frontend backend infraestrutura seguranca documentacao mobile ux performance].map do |name|
  org.tags.create!(name: name, color: "##{SecureRandom.hex(3)}")
end

puts "Adicionando tags às tarefas..."
tasks.sample(15).each do |task|
  task.tags << tags.sample(rand(1..3))
end

puts "Criando checklists e comentários..."
tasks.each do |task|
  3.times do |i|
    task.checklist_items.create!(content: ["Pesquisar requisitos", "Implementar solução", "Revisar e testar", "Fazer deploy"][i], completed: [true, false].sample)
  end
  users.sample(2).each do |user|
    task.comments.create!(content: "Comentário sobre #{task.title} por #{user.name}", user: user)
  end
end

puts "Criando ciclo OKR..."
cycle = org.okr_cycles.create!(title: "Q3 2026", start_date: Date.new(2026, 7, 1), end_date: Date.new(2026, 9, 30), status: :active)

puts "Criando objetivos..."
objectives = [
  cycle.objectives.create!(title: "Melhorar qualidade do produto", owner: alice, project: projects[0]),
  cycle.objectives.create!(title: "Aumentar satisfação do cliente", owner: carlos, project: projects[3]),
  cycle.objectives.create!(title: "Acelerar velocidade de entrega", owner: fernanda, project: projects[1]),
  cycle.objectives.create!(title: "Expandir presença digital", owner: pedro, project: projects[6])
]

puts "Criando key results..."
key_results_data = [
  { objective: objectives[0], title: "Reduzir taxa de bugs em 50%", target_value: 50, current_value: 35, unit: "%" },
  { objective: objectives[0], title: "Atingir 95% de cobertura de testes", target_value: 95, current_value: 82, unit: "%" },
  { objective: objectives[1], title: "Aumentar NPS para 60", target_value: 60, current_value: 45, unit: "pontos" },
  { objective: objectives[1], title: "Reduzir tickets de suporte em 30%", target_value: 30, current_value: 20, unit: "%" },
  { objective: objectives[2], title: "Entregar releases semanais", target_value: 12, current_value: 8, unit: "releases" },
  { objective: objectives[2], title: "Reduzir tempo de ciclo para 2 semanas", target_value: 14, current_value: 18, unit: "dias" },
  { objective: objectives[3], title: "Lançar em 3 novos estados", target_value: 3, current_value: 1, unit: "estados" },
  { objective: objectives[3], title: "Atingir 10k pedidos no primeiro mês", target_value: 10_000, current_value: 0, unit: "pedidos" }
]

key_results_data.each { |attrs| KeyResult.create!(attrs) }

puts "Criando strategic canvas..."
projects.each do |project|
  StrategicCanvas.create!(
    project: project,
    problem: "Necessidade de melhorar #{project.name.downcase} para atender às demandas do mercado",
    goal: "Entregar #{project.name} com excelência e alto padrão de qualidade",
    value_proposition: "Processos otimizados e melhor experiência do usuário",
    stakeholders: "Times de Engenharia, Design, Produto e Marketing",
    team: "#{project.assignee&.name || 'A definir'} (líder), equipe multifuncional",
    metrics: "Taxa de conclusão, satisfação do usuário, benchmarks de performance",
    risks: "Restrições de recursos, pressão de prazos, dívida técnica",
    resources: "Tempo de engenharia, ferramentas de design, infraestrutura cloud",
    roadmap: "Fase 1: Planejamento, Fase 2: Desenvolvimento, Fase 3: Testes, Fase 4: Lançamento",
    next_steps: "Reunião de kick-off, distribuir tarefas, configurar quadro do projeto"
  )
end

puts "Criando KPIs..."
kpi_data = [
  { name: "NPS do Cliente", description: "Net Promoter Score das pesquisas de satisfação", category: :strategic, frequency: :monthly, target_value: 70, current_value: 52, unit: "pontos", owner: carlos },
  { name: "Cadência de Releases", description: "Número de releases em produção por mês", category: :operational, frequency: :monthly, target_value: 8, current_value: 5, unit: "releases", owner: fernanda },
  { name: "Taxa de Correção de Bugs", description: "Percentual de bugs corrigidos dentro do SLA", category: :quality, frequency: :weekly, target_value: 95, current_value: 87, unit: "%", owner: alice, project: projects[0] },
  { name: "Cobertura de Testes", description: "Percentual de cobertura de código por testes", category: :quality, frequency: :monthly, target_value: 90, current_value: 78, unit: "%", owner: alice, project: projects[0] },
  { name: "Taxa de Crash Mobile", description: "Taxa de crash do app a cada 1000 sessões", category: :quality, frequency: :weekly, target_value: 0.1, current_value: 0.3, unit: "%", owner: carlos, project: projects[1] },
  { name: "Progresso da Migração", description: "Percentual de registros migrados para a nuvem", category: :project, frequency: :weekly, target_value: 100, current_value: 65, unit: "%", owner: fernanda, project: projects[2] },
  { name: "Receita Recorrente Mensal", description: "Acompanhamento do MRR", category: :financial, frequency: :monthly, target_value: 150_000, current_value: 120_000, unit: "R$", owner: alice },
  { name: "Conversão de Vendas", description: "Taxa de conversão do e-commerce", category: :strategic, frequency: :weekly, target_value: 5, current_value: 2.8, unit: "%", owner: pedro, project: projects[6] }
]

kpi_data.each { |attrs| org.kpis.create!(attrs) }

puts "Criando webhooks..."
webhook = org.webhooks.create!(
  name: "Notificador Slack",
  url: "https://hooks.slack.com/services/T00/B00/exemplo",
  events: ["task.created", "task.updated", "comment.created"],
  active: true
)
webhook.deliveries.create!(status: "success", response: "200 OK")
webhook.deliveries.create!(status: "success", response: "200 OK")
webhook.deliveries.create!(status: "failed", response: "500 Erro Interno", error: "Timeout de conexão")

puts "Criando notificações..."
alice.notifications.create!(action: "task_assigned", notifiable: tasks[0], actor: carlos, organization: org, created_at: 1.hour.ago)
alice.notifications.create!(action: "task_commented", notifiable: tasks[1], actor: fernanda, organization: org, created_at: 3.hours.ago)
carlos.notifications.create!(action: "task_moved", notifiable: tasks[4], actor: alice, organization: org, created_at: 6.hours.ago)
fernanda.notifications.create!(action: "task_assigned", notifiable: tasks[2], actor: alice, organization: org, created_at: 1.day.ago)
alice.notifications.create!(action: "task_assigned", notifiable: tasks[3], actor: rafael, organization: org, created_at: 2.days.ago, read: true, read_at: 1.day.ago)
alice.notifications.create!(action: "task_commented", notifiable: tasks[0], actor: juliana, organization: org, created_at: 3.days.ago, read: true, read_at: 2.days.ago)
pedro.notifications.create!(action: "task_assigned", notifiable: tasks[25], actor: alice, organization: org, created_at: 30.minutes.ago)
marina.notifications.create!(action: "task_assigned", notifiable: tasks[26], actor: alice, organization: org, created_at: 1.hour.ago)

puts "Criando logs de atividade..."
projects.each do |project|
  ActivityLog.create!(
    action: "criou o projeto #{project.name}",
    trackable: project, trackable_type: "Project",
    user: project.assignee || alice,
    organization: org, project: project
  )
end

programas.each do |program|
  ActivityLog.create!(
    action: "criou o portfólio #{program.name}",
    trackable: program, trackable_type: "Program",
    user: alice,
    organization: org, project: nil
  )
end

tasks.sample(15).each do |task|
  ActivityLog.create!(
    action: "criou a tarefa #{task.title}",
    trackable: task, trackable_type: "Task",
    user: task.assignee || alice,
    organization: org, project: task.project
  )
end

puts ""
puts "=== Seed concluído! ==="
puts ""
puts "Credenciais de acesso:"
puts "  Email: alice@example.com"
puts "  Senha: password123"
puts ""
puts "Resumo:"
puts "  Programas: #{Program.count}"
puts "  Projetos: #{Project.count}"
puts "  Tarefas: #{Task.count}"
puts "  Dependências: #{TaskDependency.count}"
puts "  Apontamentos: #{TimeEntry.count}"
puts "  Matrizes: #{ProjectMatrix.count}"
puts "  Células: #{MatrixCell.count}"
puts "  Tags: #{Tag.count}"
puts "  Campos personalizados: #{CustomField.count}"
puts "  Valores de campos: #{CustomFieldValue.count}"
puts "  Membros de projeto: #{ProjectMember.count}"
puts "  Comentários: #{Comment.count}"
puts "  Itens de checklist: #{ChecklistItem.count}"
puts "  Ciclos OKR: #{OkrCycle.count}"
puts "  Objetivos: #{Objective.count}"
puts "  Key Results: #{KeyResult.count}"
puts "  KPIs: #{Kpi.count}"
puts "  Strategic Canvas: #{StrategicCanvas.count}"
puts "  Webhooks: #{Webhook.count}"
puts "  Notificações: #{Notification.count}"
puts "  Logs de atividade: #{ActivityLog.count}"
