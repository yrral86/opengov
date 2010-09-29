module Derailed
  module Util
    # load_dir requires all ruby files in dir
    def self.load_dir(dir)
      old_dir = Dir.pwd
      Dir.chdir(dir[0] == '/' ? dir : "#{Config::LibDir}/#{dir}")
      Dir.glob '**/*.rb' do |f|
        require "#{dir}/#{f}"
      end
      Dir.chdir old_dir
    end
  end
end
