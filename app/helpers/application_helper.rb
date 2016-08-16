# frozen_string_literal: true
module ApplicationHelper
  BOOTSTRAP_FLASH_MSG = {success: 'alert-success', error: 'alert-error',
                         alert: 'alert-block', notice: 'alert-info'}.freeze

  def bootstrap_class_for(flash_type)
    BOOTSTRAP_FLASH_MSG.fetch(flash_type, flash_type.to_s)
  end
end
