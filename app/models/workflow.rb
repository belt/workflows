# frozen_string_literal: true
# supported workflows
class Workflow < Sequel::Model
  def validate
    super
    validate_flow_group
    validate_name
    validate_app_route
  end

  def validate_flow_group
    validates_presence :flow_group, allow_blank: false
  end

  def validate_name
    validates_presence :name, allow_blank: false
    validates_unique [:flow_group, :name]
  end

  def validate_app_route
    validates_presence :app_route, allow_blank: false
    validates_unique [:flow_group, :name, :app_route]
  end

  def self.all_alphabetical
    order(:flow_group).order_append(:name)
  end
end
