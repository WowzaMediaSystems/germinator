class %{class_name}Seeder < Germinator::Seed
  

  ##
  # This sets the configuration for the seed to use during execution.
  #
  def configure config
    # Remove this block if you don't need to modify the default configurations.

    # "Stop on error" determines if the germination process should stop when a seed file encounters an error during
    # execution.
    #
    # If the value is FALSE, then the germination process will record the error in the `germinator_migrations` 
    # table and continue on through the list of seed files.
    #
    # If the value is TRUE, then the germination process will stop executing the list of seed files if there is
    # an error during execution.
    
    #config.stop_on_error = false



    # "Valid Models" indentifies which models and/or methods need to be present to properly execute this seed file.
    # Model validation occurs in every seed file before anything is executed.  There are several valid values:
    #
    # true                          -> Returning true disables model validation, and allows the seed file to execute.
    # { :some_model_name => true }  -> Requires that the SomeModelName class exists before executing the seed.
    # { :some_model_name => [ :some_method ] }
    #                               -> Requires that the SomeModelName class exists, and that it has access to a method
    #                                  named "some_method".  some_method can be a static method, an instance method or
    #                                  the name of an ActiveRecord attribute.
    # { :some_model_name => true, some_other_model_name => [ :some_method, :some_other_method ]} 
    #                               -> Requires that the SomeModelName and SomeOtherModelName classes exist, and that 
    #                                  the SomeOtherModelName class has access to a methods named "some_method" and
    #                                  "some_other_method".  some_method and some_other_method can be a static method, 
    #                                  an instance method or the name of an ActiveRecord attribute.
    
    #config.valid_models = true



    # "Stop on bad model" determines if the germination process should stop when a seed file fails the model 
    # validation.
    #
    # If the value is FALSE, then the germination process will record the bad model validation in the
    # `germinator_migrations` table and continue on through the list of seed files.
    #
    # If the value is TRUE, then the germination process will stop executing the list of seed files if the model
    # validation fails.
    
    #config.stop_on_invalid_model = false


    # "Environments" identifies which environments it is safe to execute this seed file in.
    # There are 4 valid values:
    #
    # true                    -> Returning true says that this seed file can be run in any environment.
    # "development"           -> Returning a string with the name of one environment limits it execution 
    #                            to that one environment, in all other environments this file will be ignored.
    # ["development", "test"] -> Returning an array of strings limits the seed files execution to only the
    #                            environments named in the array.
    # false                   -> Return false says that this seed file is disabled and should not be executed.
    
    #config.environments = true

  end


  ##
  # This block of code gets executed during the germinate process (up).
  # 
  def germinate
    # Remove this block if there is nothing to germinate in this seed.
  end


  ##
  # This block of code gets executed during the shrivel process (down).
  # 
  def shrivel
    # Remove this block if there is nothing to shrivel in this seed.
  end

end