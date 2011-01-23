require 'rails/generators/migration'

module Heyday
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Create javascript, css, and helpers for a calendar. Also create a model and controller if you would like!"
      include Rails::Generators::Migration
  
      source_root File.expand_path('../templates', __FILE__)

      class_option :model_name,       :type => :string, :optional => true, :default => nil
      class_option :controller_name,  :type => :string, :optional => true, :default => nil

      class_option :use_color, :type => :boolean, :default => false, :desc => "Add an additional 'color' attribute"
      class_option :jquery, :type => :boolean, :default => false, :desc => "Install jQuery"
      class_option :layout, :type => :boolean, :default => false, :desc => "Add a layout for the calendar"
      class_option :create_controller, :type => :boolean, :default => false, :desc => "Create a controller, instead of using an existing one"

      def begin_generate
        @settings = options.dup
        say "Adding a color column", :yellow if @settings[:use_color]
        
        copy_file "fullcalendar.js",  "public/javascripts/heyday/fullcalendar.js"
        copy_file "fullcalendar.css", "public/stylesheets/heyday/fullcalendar.css"
#        copy_file "stylesheets/jquery-ui/jquery-ui.css", "public/stylesheets/jquery-ui/jquery-ui.css"
        directory "stylesheets/jquery-ui/", "public/stylesheets/jquery-ui/"

        if generate_model?
          say "Adding #{model_name} model", :yellow
          template "model.rb.erb", "app/models/#{model_name}.rb"
          migration_template "migration.rb.erb", "db/migrate/create_#{table_name}.rb"
          
          if @settings[:controller_name].blank?
            @settings[:controller_name] = model_name.downcase.underscore.pluralize
          end
        end
      
        @generate_layout = @settings[:layout]
        say "Adding calendar layout", :yellow if @generate_layout
        if @generate_layout
          copy_file "layout.html.erb", "app/views/layouts/calendar.html.erb"
        end
        
        if @settings[:controller_name].present? && @settings[:create_controller]
          say "Adding #{controller_name} controller", :yellow
          template "controller.rb.erb", "app/controllers/#{controller_name}.rb"
          route "match '/#{view_name}(/:year(/:month))' => '#{view_name}#index', :as => :#{named_route_name}, :constraints => {:year => /\\d{4}/, :month => /\\d{1,2}/}"
          route <<-eos
          
  resources :#{view_name} do
    collection do
      get 'get_events'
      post 'move'
      post 'resize'
    end
  end
  
          eos
        end
        
        if @settings[:jquery]
          say "Adding jquery and jquery-ui", :yellow
          copy_file "jquery.js", "public/javascripts/jquery.js"
          copy_file "jquery-ui.js", "public/javascripts/jquery-ui.js"
        end
        copy_file "gcal.js", "public/javascripts/heyday/gcal.js"
    
        empty_directory "app/views/#{view_name}"
        template "calendar.html.erb", File.join("app/views/#{view_name}/index.html.erb")
        template "helper.rb.erb", "app/helpers/#{helper_name}.rb"
    
        views = ["_form.html.erb","create.js.rjs","edit.js.rjs","move.js.rjs","resize.js.rjs"]
        views.each do |view|
          template view, File.join("app/views/#{view_name}/#{view}")
        end
        
        template "javascripts/heyday/fullcalendar_rails.js", "public/javascripts/heyday/fullcalendar_rails.js"
        
        directory "views/calendar/", "app/views/#{view_name}/"
  
      end

      protected

        def generate_model?
          @settings[:model_name].present?
        end
        
        def generate_controller?
          @settings[:controller_name].present?          
        end

        def model_class_name
          if @settings[:model_name]
            return @settings[:model_name].classify
          else
            raise Exception.new("No model_name was provided")
          end
        end

        def model_name
          model_class_name.underscore
        end

        def view_name
          @settings[:controller_name].underscore
        end

        def controller_class_name
          "#{@settings[:controller_name]}_controller".classify
        end

        def controller_name
          controller_class_name.underscore
        end

        def helper_class_name
          "#{@settings[:controller_name]}_helper".classify
        end
  
        def helper_name
          helper_class_name.underscore
        end

        def table_name
          model_name.pluralize
        end

        def named_route_name
          if view_name.include?("/")
            view_name.split("/").join("_")
          else
            view_name
          end
        end

        # FIXME: Should be proxied to ActiveRecord::Generators::Base
        # Implement the required interface for Rails::Generators::Migration.
        def self.next_migration_number(dirname = "db/migrate/") #:nodoc:
          if ActiveRecord::Base.timestamped_migrations
            return Time.now.utc.strftime("%Y%m%d%H%M%S")
          else
            return "%.3d" % (current_migration_number(dirname) + 1)
          end
        end
        
    end
  end
end