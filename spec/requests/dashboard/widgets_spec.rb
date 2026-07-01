require "rails_helper"

RSpec.describe "Dashboard::Widgets", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /dashboard/widgets" do
    it "returns user's widgets as JSON" do
      create(:dashboard_widget, user: user, widget_type: "stats")
      get dashboard_widgets_path
      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body).to be_an(Array)
      expect(body.first["widget_type"]).to eq("stats")
    end
  end

  describe "POST /dashboard/widgets" do
    it "creates a widget" do
      expect {
        post dashboard_widgets_path, params: { dashboard_widget: { widget_type: "overdue_tasks" } }, as: :json
      }.to change(DashboardWidget, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns errors for invalid widget" do
      post dashboard_widgets_path, params: { dashboard_widget: { widget_type: "invalid" } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /dashboard/widgets/:id" do
    it "updates a widget" do
      widget = create(:dashboard_widget, user: user, widget_type: "stats")
      patch dashboard_widget_path(widget), params: { dashboard_widget: { width: 2 } }, as: :json
      expect(response).to have_http_status(:success)
      expect(widget.reload.width).to eq(2)
    end
  end

  describe "DELETE /dashboard/widgets/:id" do
    it "removes a widget" do
      widget = create(:dashboard_widget, user: user, widget_type: "stats")
      expect {
        delete dashboard_widget_path(widget)
      }.to change(DashboardWidget, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "PATCH /dashboard/widgets/reorder" do
    it "updates positions" do
      w1 = create(:dashboard_widget, user: user, widget_type: "stats", position: 0)
      w2 = create(:dashboard_widget, user: user, widget_type: "timeline", position: 1)
      patch reorder_dashboard_widgets_path, params: { ordered_ids: [w2.id, w1.id] }, as: :json
      expect(response).to have_http_status(:success)
      expect(w1.reload.position).to eq(1)
      expect(w2.reload.position).to eq(0)
    end
  end
end
