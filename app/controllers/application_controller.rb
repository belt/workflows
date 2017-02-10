# frozen_string_literal: true
# global controller
class ApplicationController < ActionController::Base
  respond_to :html, :json

  include ForgeryProtection
  include HttpHeaderAuthorization
end
