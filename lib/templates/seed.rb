class %{class_name}Seeder < Germinator::Seed

  #
  # Set the configuration for the seed to use during execution.
  #
  def configure config
    # stop_on_error determines if the germination process should stop when a
    # seed file encounters an error during execution. FALSE = Germinator records
    # the error and continues.  TRUE = Germinator stops at the error and halts
    # all future germinator execution.

        config.stop_on_error = false                                            # Default: Continue on all errors.
        # config.stop_on_error = true                                           # Stop on any error.


    # valid_models identifies which models and/or methods need to be present to
    # properly execute this seed file.

        config.valid_models = true                                              # Default: Don't engage model validation.
        # config.valid_models = { model1: true, model2: true }                  # Validate that model1 and model2 exist before executing.
        # config.valid_models = { model1: [ :field1, :field2 ]}                 # Validate that model1 exists and that it has field1 and field2 accessible.


    # stop_on_bad_model determines if the germination process should stop when a
    # seed file fails the model validation.

        config.stop_on_invalid_model = false                                    # Default: Continue on to the next germinator if the models fail the validation.
        # config.stop_on_invalid_model = false                                  # Stop the germinators if the models fail the validation.


    # environments identifies which environments it is safe to execute this seed
    # file in.

        config.environments = true                                              # Default: Execute this seed in all evnironments.
        # config.environments = false                                           # Disable this seed file and prevent it from executing.
        # config.environments = "development"                                   # Only execute this seed file in the development environment.
        # config.environments = ["development", "production"]                   # Only execute this seed file in the development and production environments.
        # config.environments = "test"                                          # Only execute this seed file in the test environment.

  end


  # Code to execute during the germinate process (up).
  #
  def germinate
  end


  ##
  # Code to execute during the shrivel process (down).
  #
  # def shrivel
  # end

end
