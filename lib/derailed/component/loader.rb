module Derailed
  module Component
    module Loader
      def require_libraries
        dir = Config::RootDir + "/components-enabled/#{@name.downcase}"
        original = class_list
        require_dir(dir)
        new = class_list
        new_modules = new - original
        new_models = new_modules.select do |m|
          subclass?(m, Derailed::Component::Model) ||
          subclass?(m, Authlogic::Session::Base)
        end
        controller_array = new_modules.select do |m|
          subclass?(m, Derailed::Component::Controller)
        end
        [new_models,controller_array[0]] # we should only have one controller
      end

      def subclass?(m,klass)
        m.ancestors.include?(klass)
      end

      def class_list
        array = []
        ObjectSpace.each_object(Class) {|m| array << m }
        array
      end

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
