class Setting < ActiveRecord::Base
  serialize :value, JSON
end
