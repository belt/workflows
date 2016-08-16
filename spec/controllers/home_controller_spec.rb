# frozen_string_literal: true
require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  context 'basic JSON request' do
    render_views

    context 'with no data' do
      it 'yields HTTP 200' do
        get :index, format: :json
        expect(response.status).to eq 200
      end

      it 'yields JSON' do
        get :index, format: :json
        expect(JSON.parse(response.body)).to eq []
      end
    end

    context 'with data' do
      let!(:workflow_attrs) {{flow_group: 'foo', name: 'a', app_route: '/'}}
      before :each do
        Workflow.create workflow_attrs
        get :index, format: :json
      end

      it 'yields HTTP 200' do
        expect(response.status).to eq 200
      end

      it 'yields JSON' do
        resp = JSON.parse(response.body).map(&:with_indifferent_access)
        expect(resp.first.symbolize_keys).to include workflow_attrs
      end
    end
  end

  context 'basic HTML request' do
    context 'with no data' do
      it 'yields HTTP 200' do
        get :index
        expect(response.status).to eq 200
      end
    end

    context 'with data' do
      before :each do
        Workflow.create flow_group: 'foo', name: 'a', app_route: '/'
        get :index
      end

      it 'yields HTTP 200' do
        expect(response.status).to eq 200
      end

      it 'yields JSON' do
        expect(JSON.parse(response.body)).to eq nil
      end
    end
  end
end
