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
        :end_at_field => :end_at,
        :title_field => :title,
        :description_field => :description
      }
      options = defaults.merge(options)
      cattr_accessor :start_at_field, :end_at_field, :title_field, :description_field, :repeat_options
      self.start_at_field = options[:start_at_field].to_s
      self.end_at_field   = options[:end_at_field].to_s
      self.title_field = options[:title_field].to_s
      self.description_field   = options[:description_field].to_s
      alias_attribute :start_at, start_at_field unless start_at_field == 'start_at'
      alias_attribute :end_at,   end_at_field   unless end_at_field   == 'end_at'
      alias_attribute :title, title_field unless title_field == 'title' || title_field.nil?
      alias_attribute :description, description_field unless description_field == 'description' || description_field.nil?
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
          st, et = e.start_at, e.end_at
          e.attributes = event
          if event_series.period.downcase == 'monthly' or event_series.period.downcase == 'yearly'
            nst = DateTime.parse("#{e.start_at.hour}:#{e.start_at.min}:#{e.start_at.sec}, #{e.start_at.day}-#{st.month}-#{st.year}")  
            net = DateTime.parse("#{e.end_at.hour}:#{e.end_at.min}:#{e.end_at.sec}, #{e.end_at.day}-#{et.month}-#{et.year}")
          else
            nst = DateTime.parse("#{e.start_at.hour}:#{e.start_at.min}:#{e.start_at.sec}, #{st.day}-#{st.month}-#{st.year}")  
            net = DateTime.parse("#{e.end_at.hour}:#{e.end_at.min}:#{e.end_at.sec}, #{et.day}-#{et.month}-#{et.year}")
          end

        rescue
          nst = net = nil
        end
        if nst and net
          e.start_at, e.end_at = nst, net
          e.save
        end
      end

      event_series.attributes = event
      event_series.save
    end
    
  end
  
end