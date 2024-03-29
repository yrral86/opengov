module Derailed
  module Manager
    # = Derailed::Manager::Mux
    # This module provides functions for gathering data from the components and
    # scattering data to the components
    module Mux
      private
      # gather gathers data from each component into an array
      def gather
        array = []
        @components.each_value do |c|
          array.concat(yield(c.proxy).map do |n|
                         "#{c.proxy.name}::#{n}"
                       end) if c.registered?
        end
        array
      end
    end
  end
end
