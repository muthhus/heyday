require 'heyday/railtie'

module Heyday

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # def heyday(*args, &block)
    #   options = {}
    #   options.merge!(args.pop) if args.last.kind_of?(Hash)
    #   args.each do |arg|
    #   end
    # end
    
    def calendar_displayable(options = {})
      defaults = {
        :start_at_field => :start_at,
        :end_at_field => :end_at
      }
      options = defaults.merge(options)
      cattr_accessor :start_at_field, :end_at_field, :repeat_options
      self.start_at_field = options[:start_at_field].to_s
      self.end_at_field   = options[:end_at_field].to_s
      alias_attribute :start_at, start_at_field unless start_at_field == 'start_at'
      alias_attribute :end_at,   end_at_field   unless end_at_field   == 'end_at'
      #before_save :adjust_all_day_dates
      send :include, InstanceMethods
      self.repeat_options = [
        "Does not repeat",
        "Daily"          ,
        "Weekly"         ,
        "Monthly"        ,
        "Yearly"         
      ]
    end
  end
  
  # Instance Methods
  # Override in your model as needed
  module InstanceMethods
    
    def update_events(events, event)
      events.each do |e|
        begin 
          st, et = e.starttime, e.endtime
          e.attributes = event
          if event_series.period.downcase == 'monthly' or event_series.period.downcase == 'yearly'
            nst = DateTime.parse("#{e.starttime.hour}:#{e.starttime.min}:#{e.starttime.sec}, #{e.starttime.day}-#{st.month}-#{st.year}")  
            net = DateTime.parse("#{e.endtime.hour}:#{e.endtime.min}:#{e.endtime.sec}, #{e.endtime.day}-#{et.month}-#{et.year}")
          else
            nst = DateTime.parse("#{e.starttime.hour}:#{e.starttime.min}:#{e.starttime.sec}, #{st.day}-#{st.month}-#{st.year}")  
            net = DateTime.parse("#{e.endtime.hour}:#{e.endtime.min}:#{e.endtime.sec}, #{et.day}-#{et.month}-#{et.year}")
          end

        rescue
          nst = net = nil
        end
        if nst and net
          e.starttime, e.endtime = nst, net
          e.save
        end
      end

      event_series.attributes = event
      event_series.save
    end
    
  end
  
end