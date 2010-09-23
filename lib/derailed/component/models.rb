module Derailed
  module Component
    module Models
      # add_models adds the models passed to it to the component's list of
      # available models, indexed by the model name
      def add_models(models)
        models.each do |m|
          m.extend(DRbUndumped)
          @models[m.name] = m
        end
      end

      # model_names returns the list of available model names
      def model_names
        @models.keys
      end

      # model_types returns the list of available model types
      def model_types
        types = []
        @models.each_value do |m|
          if m.respond_to?(:abstract_type) && m.abstract_type
            types << m.abstract_type
          end
        end
        types
      end

      # has_type? returns true if the component provides the given type,
      # false otherwise
      def has_type?(type)
        model_types.include?(type)
      end

      # model returns the requested model
      def model(name)
        @models[name]
      end

      # model_by_url returns the requested model
      def model_by_url(model_url)
        @models.keys.each do |k|
          if k.downcase == model_url
            return @models[k]
          end
        end
      end

      # model_by_type returns the model of the requested type
      def model_by_type(type)
        @models.values.each do |m|
          return m if m.respond_to?(:abstract_type) &&
            m.abstract_type == type
        end
        nil
      end

      # def clear_models destroys all records if we are
      # in the test environment
      def clear_models
        if Config::Environment == 'test'
          @models.values.each do |m|
            unless @name == 'Authenticator' && m.name == 'UserSession'
              m.destroy_all
            end
          end
        else
          throw "clear_models called in non-test environment"
        end
      end
    end
  end
end
