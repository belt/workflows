# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Workflow, type: :model do
  context 'when validated' do
    it {should have_valid(:flow_group).when('workflow group')}
    # it {should_not have_valid(:flow_group).when(nil, '', "Test \x0 data")}
    it {should_not have_valid(:flow_group).when(nil, '')}

    it {should have_valid(:name).when('workflow name')}
    # it {should_not have_valid(:name).when(nil, '', "Test \x0 data")}
    it {should_not have_valid(:name).when(nil, '')}

    it {should have_valid(:app_route).when('http://foo')}
    # it {should_not have_valid(:app_route).when(nil, '', "Test \x0 data")}
    it {should_not have_valid(:app_route).when(nil, '')}
  end
end
