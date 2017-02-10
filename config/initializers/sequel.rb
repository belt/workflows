# integrate draper into sequel.gem
class Sequel::Model
  include Draper::Decoratable
end
