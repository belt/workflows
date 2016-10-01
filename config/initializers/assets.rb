# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

if ENV['COMPILE_CONTROLLERS_ASSETS']
  Rails.application.eager_load!

  # be lazy and force a rake assets:precompile, based on what's on the disk
  css_files = Dir.glob Rails.root.join('app/assets/stylesheets/**.s[ac]ss')
  css_files += Dir.glob Rails.root.join('app/assets/stylesheets/**.css')
  css_files.map!{|path| path.sub /\.(?:sa|sc|c)ss/, '.css'}
  coffee_files = Dir.glob Rails.root.join('app/assets/javascripts/**.coffee')

  app_controllers = (ActionController::Base.descendants - [ApplicationController]).map(&:to_s)
  app_controllers.map(&:underscore).map{|obj| obj.sub!(/_controller/,"")}
  app_controllers.each do |controller|
    path = Rails.root.join('app/assets/stylesheets', "#{controller}.css")
    found_files = css_files & [path]
    Rails.application.config.assets.precompile += found_files if found_files

    path = Rails.root.join('app/assets/javascripts', "#{controller}.js.coffee")
    found_files = coffee_files & [path]
    Rails.application.config.assets.precompile += found_files
  end
end
