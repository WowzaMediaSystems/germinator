module Germinator
  class SeedConfig

    attr_accessor :stop_on_error, :stop_on_invalid_model, :environments, :valid_models

    def initialize
      @stop_on_error = false
      @stop_on_invalid_model = false
      @environments = true
      @valid_models = true
    end

    def to_hash
      {
        stop_on_error: @stop_on_error,
        stop_on_invalid_model: @stop_on_invalid_model,
        environments: @environments,
        valid_models: @valid_models
      }
    end
  end
end
