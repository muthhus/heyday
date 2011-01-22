require 'rails/generators/migration'

module Heyday
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Create javascript, css, and helpers for a calendar. Also create a model and controller if you would like!"
      include Rails::Generators::Migration
  
      source_root File.expand_path('../templates', __FILE__)

      class_option :model,       :type => :string, :optional => true, :default => nil
      class_option :controller,  :type => :string, :optional => true, :default => nil

      class_option :use_color, :type => :boolean, :default => false, :desc => "Add an additional 'color' attribute"

      def begin_generate
        say "Adding a color column", :yellow if options[:use_color]

        copy_file "fullcalendar.js",  "public/javascripts/heyday/fullcalendar.js"
        copy_file "fullcalendar.css", "public/stylesheets/heyday/fullcalendar.css"

        if model_name
          template "model.rb.erb", "app/models/#{model_name}.rb"
          migration_template "migration.rb.erb", "db/migrate/#{next_migration_number}_create_#{table_name}.rb"
        end
    
        if controller_name
          template "controller.rb.erb", "app/controllers/#{controller_name}.rb"
          route "match '/#{view_name}(/:year(/:month))' => '#{view_name}#index', :as => :#{named_route_name}, :constraints => {:year => /\\d{4}/, :month => /\\d{1,2}/}"
          route <<-eos
            resources :#{view_name} do
              collection do
                get 'get_events'
              end
            end
          eos
        end
    
        empty_directory "app/views/#{view_name}"
        template "calendar.html.erb", File.join("app/views/#{view_name}/index.html.erb")
        template "helper.rb.erb", "app/helpers/#{helper_name}.rb"
    
        views = ["_form.html.erb","create.js.rjs","edit.js.rjs","move.js.rjs","new.js.rjs","resize.js.rjs"]
        views.each do |view|
          template view, File.join("app/views/#{view_name}/#{view}.erb")
        end
  
      end

      def model_class_name
        @model_name.classify
      end

      def model_name
        model_class_name.underscore
      end

      def view_name
        @controller_name.underscore
      end

      def controller_class_name
        "#{@controller_name}_controller".classify
      end

      def controller_name
        controller_class_name.underscore
      end

      def helper_class_name
        "#{@controller_name}_helper".classify
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