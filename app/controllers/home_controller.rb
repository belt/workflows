# frozen_string_literal: true
# enumerates supported workflows
class HomeController < ApplicationController
  def index
    @page_header = view_context.link_to 'Workflows', workflows_path
    @workflows = Workflow.all_alphabetical
    respond_with @workflows
  rescue => error
    flash[:danger] = error.message
  end
end
