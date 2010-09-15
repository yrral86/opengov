module Derailed
  module Component
    # = Derailed::Component::Loader
    # This module provides the require_libraries function to require the models
    # and controller for the component.
    module Loader
      private
      # require_libraries pulls in all the ruby files in the component's
      # directory and keeps track of the classes that are added.  These
      # classes are the models and the controller class.
      def require_libraries
        original = class_list
        require_dir Config::ComponentDir + "/#{@name.downcase}"
        new = class_list

        new_modules = new - original
        new_models = new_modules.select do |m|
          subclass?(m, Derailed::Component::Model) ||
          subclass?(m, Authlogic::Session::Base)
        end

        controller_array = new_modules.select do |m|
          subclass?(m, Derailed::Component::Controller)
        end

        new_models.each do |m|
          if subclass?(m, Derailed::Component::Model)
            m.full_model_name = "#{name}::#{m.name}"
          end
        end

        [new_models,controller_array[0]] # we should only have one controller
      end

      # subclass returns true if klass is an ancestor of m
      def subclass?(m,klass)
        m.ancestors.include?(klass)
      end

      # class_list returns a list of currently defined classes
      def class_list
        array = []
        ObjectSpace.each_object(Class) {|m| array << m }
        array
      end

      # require_dir requires all ruby files in the specified directory
      def require_dir(dir)
        old_dir = Dir.pwd
        Dir.chdir dir
        Dir.glob '**/*.rb' do |f|
          require "#{dir}/#{f}" unless f == 'init.rb'
        end
        Dir.chdir old_dir
      end
    end
  end
end
