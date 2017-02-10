SimpleCov.start :rails do
  root Rails.root.to_s
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
end
