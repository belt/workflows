# frozen_string_literal: true
# HTTP Header Authorization
module HttpHeaderAuthorization
  extend ActiveSupport::Concern

  # rfc_2616 section 14.8
  # rfc_7234 section 14.2
  def http_auth_token
    @http_auth_token ||= Settings.project.http_auth_token
  end
end
