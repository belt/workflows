Rails.application.config.generators do |g|
  g.view_specs          false
  g.helper_specs        false
  g.test_framework      :rspec
  g.fixture_replacement :factory_girl
  g.orm                 :sequel
  g.template_engine     :haml
  g.stylesheet_engine   :scss
end

