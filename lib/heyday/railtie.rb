require 'heyday'
require 'heyday/calendar_helper'
require 'rails'

module Heyday
  class Railtie < Rails::Engine
    initializer :after_initialize do
      if defined?(ActionController::Base)
        ActionController::Base.helper Heyday::CalendarHelper
      end
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.extend Heyday::ClassMethods
      end
    end
  end
end
