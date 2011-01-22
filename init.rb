ActiveRecord::Base.send :include, Heyday
ActionView::Base.send   :include, Heyday::CalendarHelper
