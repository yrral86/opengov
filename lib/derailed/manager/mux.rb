module Derailed
  module Manager
    module Mux
      def gather
        array = []
        @components.each_value do |c|
          array.concat(yield(c).collect {|n| "#{c.name}::#{n}"})
        end
        array
      end
    end
  end
end
