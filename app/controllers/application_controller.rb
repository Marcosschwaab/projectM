class ApplicationController < ActionController::Base
  include ApplicationHelper
  allow_browser versions: :modern
  stale_when_importmap_changes

  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :locale, :theme ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :locale, :theme ])
  end

  private

  def set_locale
    locale = current_user&.locale.presence || params[:locale] || I18n.default_locale
    if I18n.available_locales.map(&:to_s).include?(locale.to_s)
      I18n.locale = locale
    else
      I18n.locale = I18n.default_locale
    end
  end

  def user_not_authorized
    flash[:alert] = t("flash.unauthorized")
    redirect_back(fallback_location: root_path)
  end
end
