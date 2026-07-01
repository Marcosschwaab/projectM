class ThemesController < ApplicationController
  def update
    if current_user.update(theme: params[:theme])
      redirect_back(fallback_location: root_path, notice: t("flash.theme_updated"))
    else
      redirect_back(fallback_location: root_path, alert: t("flash.invalid_theme"))
    end
  end
end
