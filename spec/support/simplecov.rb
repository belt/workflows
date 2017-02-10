# frozen_string_literal: true
require 'simplecov'
require 'metric_fu/metrics/rcov/simplecov_formatter'
SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter,
                        SimpleCov::Formatter::MetricFu]
SimpleCov.start do
  add_filter 'spec/'
  add_filter 'vendor/bundle'
end
