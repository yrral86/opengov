require 'active_support/core_ext/string/inflections'

module Derailed
  module Util
    # load_dir requires all ruby files in dir
    def self.load_dir(dir)
      ruby_files_in_dir(dir) do |f|
        require "#{dir}/#{f}"
      end
    end

    def self.autoload_dir(mod, dir)
      ruby_files_in_dir(dir) do |fn|
        sym = file_to_symbol(fn)
        mod.autoload sym, "#{dir}/#{fn}"
      end
    end

    def self.file_to_symbol(fn)
      fn.sub(/\.rb/,'').camelize.to_sym
    end

    def self.ruby_files_in_dir(dir)
      in_dir(dir) do
        Dir.glob '**/*.rb' do |fn|
          yield fn if block_given?
        end
      end
    end

    def self.in_dir(dir)
      dir = (dir[0] == '/' ? dir : "#{Config::LibDir}/#{dir}")
      old_dir = Dir.pwd
      Dir.chdir dir
      yield if block_given?
      Dir.chdir old_dir
    end

    # def registers the environment apis on the given object
    # using key, note key is not stored
    def self.environment_apis(object, key)
      {'test' => API::Testing,
        'development' => API::Development}.each_pair do |env, api|
        object.register_api(key, api) if Config::Environment == env
      end
    end
  end
end
