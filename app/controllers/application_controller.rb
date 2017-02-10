# frozen_string_literal: true
# global controller
class ApplicationController < ActionController::Base
  respond_to :html, :json

  include ForgeryProtection

  def http_auth_token
    @http_auth_token ||= Settings.project.http_auth_token
  end
end
