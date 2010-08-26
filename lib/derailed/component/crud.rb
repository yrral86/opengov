module Derailed
  module Component
    module Crud
      def crud(env)
        model_name = next_path
        id = next_path
        r = controller.request

        model = @models[model_name]

        if model then
          if r.post? then
            case r.params['_method']
            when 'put' # UPDATE
              update(model,r)
            when 'delete' # DELETE
              delete(model,id)
            else # CREATE
              create(model,r)
            end
          elsif r.get? then # READ
            if id == 'edit' then
              render_form(model,next_path)
            else
              read(model,id)
            end
          elsif r.delete? then # IN CASE WE EVER USE THE ACTUAL METHODS
            delete(model,id) # INSTEAD OF TUNNELING OVER POST
          elsif r.put? then
            update(model,r)
          else
            View.method_not_allowed
          end
        else
          unless model_name then
            model_name = 'Nil'
          end
          View.not_found('Model ' +
                                model_name +
                                ' not found in component ' +
                                @name)
        end
      end

      def clean_params(model, params)
        new_params = {}
        attributes = model.new.attributes.keys - model.protected_attributes.to_a
        attributes.each do |a|
          if params[a] then
            new_params[a] = params[a]
          end
        end
        new_params
      end

      def create(model, request)
        params = clean_params(model, request.params)
        object = model.new(params)
        # MODEL NEEDS VALIDATION OF SOME SORT OTHERWISE WE
        # WILL FALL THROUGH AND CREATE A NULL FILLED RECORD
        # INSTEAD OF DISPLAYING THE FORM
        if object.save then
          View.redirect('/' + @name.downcase +
                               '/' + model.name.downcase +
                               '/' + object.id.to_s)
        else
          render_form(model, nil)
        end
      end

      def read(model, id)
        object = model.find_by_id(id)
        if object then
          View.render_erb_from_file(view_file(model.name.downcase),binding)
        elsif id then
          View.not_found('Record  #' + id + ' not found for model ' +
                                model.name + ' in component ' + @name)
        else
          objects = model.find :all
          View.render_erb_from_file(view_file(model.name.downcase + 'list'),
                                           binding)
        end
      end

      def render_form(model,id)
        if id then
          object = model.find_by_id(id)
          method = 'put'
        else
          object = model.new
          method = 'post'
        end
        View.render_erb_from_file(view_file(model.name.downcase + 'form'),
                                         binding)
      end

      def update(model, request)
        id = request.path.split("/")[3]
        object = model.find_by_id(id)
        if object
          params = clean_params(model, request.params)
          if object.update_attributes(params) then
            View.redirect('/' + @name.downcase +
                                 '/' + model.name.downcase +
                                 '/' + id)
          else
            render_form(model, id)
          end
        else
          View.not_found('Record # ' +
                                id.to_s +
                                ' not found for model ' +
                                model.name +
                                'in component ' +
                                @name)
        end
      end

      def delete(model, id)
        object = model.find_by_id(id)
        if object then
          object.delete
          View.redirect('/' + @name.downcase +
                               '/' + model.name.downcase)
        else
          View.not_found('Record # ' +
                                id +
                                ' not found for model ' +
                                model.name +
                                'in component ' +
                                @name)
        end
      end

      def view_file(name)
        Config::RootDir + '/' +
          'components' + '/' +
          @name.downcase + '/' +
          'v' + '/' +
          name + '.html.erb'
      end

      def render(name, binding)
        View.render_erb_from_file_to_string(view_file('_' + name), binding)
      end

      def error_box(record)
        string = "<ul>"
        record.errors.full_messages.each do |m|
          string += "<li>#{m}</li>"
        end
        string += "</ul>"
      end
    end
  end
end
