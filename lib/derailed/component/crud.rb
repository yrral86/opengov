module Derailed
  module Component
    # = Derailed::Component::Crud
    # This module ptovides functions to handle basic CRUD funtionality for the
    # various models provided by the component.  All that is required besides
    # the model is three templates in the component's view directory:
    # 1. modelname.html.erb: displays the record (passed in the variable called
    #    object)
    # 2. modelnamelist.html.erb: displays a list of records (passed as
    #    'objects')
    # 3. modelnameform.html.erb: displays a form to create/edit a record
    #    ('object')... also needs a hidden input named _method with value
    #    <%= method =>
    module Crud
      private

      # crud handles determining which model we are working with and then
      # handing control off the the appropriate function based on what we
      # are trying to do with that model
      def crud(env)
        model_name = path(2)
        id = path(3)

        model = @component.model_by_url(model_name)

        if model
          if request.post?
            case request.params['_method']
            when 'put' # UPDATE
              update(model,request)
            when 'delete' # DELETE
              delete(model,id)
            else # CREATE
              create(model,request)
            end
          elsif request.get? # READ
            if id == 'edit'
              if path(4)
                update(model,request)
              else
                create(model,request)
              end
            else
              read(model,id)
            end
          elsif request.delete? # IN CASE WE EVER USE THE ACTUAL METHODS
            delete(model,id) # INSTEAD OF TUNNELING OVER POST
          elsif request.put?
            update(model,request)
          else
            method_not_allowed
          end
        else
          unless model_name
            model_name = 'Nil'
          end
          not_found "Model #{model_name} not found " +
            "in component #{@component.name}"
        end
      end

      # clean_params removes any paramaters that are not attributes of the model
      def clean_params(model, params)
        new_params = {}
        attributes = model.new.attributes.keys - model.protected_attributes.to_a
        attributes.each do |a|
          if params[a]
            new_params[a] = params[a]
          end
        end
        new_params
      end

      # create creates a new record for the given model with the given params
      def create(model, request)
        params = clean_params(model, request.params)
        if params.empty?
          render_form(model, nil, 'post')
        else
          object = model.new(params)
          if object.save
            redirect "/#{@component.name.downcase}/#{model.name.downcase}/" +
              object[:id].to_s
          else
            render_form(model, object, 'post')
          end
        end
      end

      # read displays modelname.html.erb for the given record
      def read(model, id)
        object = model.find_by_id(id)
        if object
          render(model.name.downcase, binding)
        elsif id
          not_found "Record  ##{id} not found for model " +
            "#{model.name} in component #{@component.name}"
        else
          objects = model.find :all
          render(model.name.downcase + 'list', binding)
        end
      end

      # render_form renders the form for creation/update
      def render_form(model,object,method)
        object = model.new unless object
        render(model.name.downcase + 'form', binding)
      end

      # update updated the given record
      def update(model, request)
        if request.get?
          id = path(4)
        else
          id = path(3)
        end
        object = model.find_by_id(id)
        if object
          params = clean_params(model, request.params)
          if params.empty?
            render_form(model, object, 'put')
          else
            if object.update_attributes(params)
              redirect "/#{@component.name.downcase}/" +
                "#{model.name.downcase}/#{id}"
            else
              render_form(model, object, 'put')
            end
          end
        else
          not_found "'Record ##{id.to_s} not found for model #{model.name} " +
            "in component #{@component.name}"
        end
      end

      # delete deletes the given record
      def delete(model, id)
        object = model.find_by_id(id)
        if object
          object.delete
          redirect "/#{@component.name.downcase}/#{model.name.downcase}"
        else
          not_found "Record ##{id} not found for model #{model.name} " +
            "in component #{@component.name}"
        end
      end

      def delete_override
        if (request.post? && params['_method'] == 'delete') ||
          request.delete?
          yield path(3)
        else
          method_missing(path(2).to_sym)
        end
      end
    end
  end
end
