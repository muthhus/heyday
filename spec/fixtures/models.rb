class CustomEvent < ActiveRecord::Base
  calendar_displayable :start_at_field => 'custom_start_at', :end_at_field => 'custom_end_at'
end

class Event < ActiveRecord::Base
end
