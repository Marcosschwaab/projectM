class LocalesController < ApplicationController
  def switch
    if I18n.available_locales.map(&:to_s).include?(params[:locale])
      if user_signed_in?
        current_user.update!(locale: params[:locale])
      end
      redirect_back(fallback_location: root_path)
    else
      redirect_back(fallback_location: root_path, alert: t("flash.invalid_locale"))
    end
  end
end
