class OpenGovDataComponent
  # model: The active record class
  def initialize(model)
    @model = model
  end

  def model_name
    @model.class
  end
end
