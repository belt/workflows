# frozen_string_literal: true
# forgery protection
module ForgeryProtection
  extend ActiveSupport::Concern

  def self.included(klass)

    # Prevent CSRF attacks by raising an exception
    # For APIs, use :null_session instead
    klass.protect_from_forgery with: :exception
  end
end
