module Dashboard
  class WidgetsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_widget, only: %i[update destroy]

    def index
      @widgets = policy_scope(DashboardWidget).ordered
      render json: @widgets.map { |w| widget_json(w) }
    end

    def create
      @widget = current_user.dashboard_widgets.build(widget_params)
      @widget.position = current_user.dashboard_widgets.maximum(:position).to_i + 1
      authorize @widget

      if @widget.save
        render json: widget_json(@widget), status: :created
      else
        render json: { errors: @widget.errors.full_messages }, status: :unprocessable_content
      end
    end

    def update
      authorize @widget
      if @widget.update(widget_params)
        render json: widget_json(@widget)
      else
        render json: { errors: @widget.errors.full_messages }, status: :unprocessable_content
      end
    end

    def destroy
      authorize @widget
      @widget.destroy!
      head :no_content
    end

    def reorder
      ActiveRecord::Base.transaction do
        current_user.dashboard_widgets.update_all("position = -(position + 1000)")
        params[:ordered_ids].each_with_index do |id, index|
          current_user.dashboard_widgets.where(id: id).update_all(position: index)
        end
      end
      head :ok
    end

    private

    def set_widget
      @widget = current_user.dashboard_widgets.find(params[:id])
    end

    def widget_params
      params.require(:dashboard_widget).permit(:widget_type, :position, :width, :visible, settings: {})
    end

    def widget_json(widget)
      {
        id: widget.id,
        widget_type: widget.widget_type,
        position: widget.position,
        width: widget.width,
        visible: widget.visible,
        settings: widget.settings
      }
    end
  end
end
