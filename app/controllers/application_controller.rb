# frozen_string_literal: true
# global controller
class ApplicationController < ActionController::Base
  respond_to :html, :json

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def http_auth_token
    @http_auth_token ||= Settings.project.http_auth_token
  end
end
