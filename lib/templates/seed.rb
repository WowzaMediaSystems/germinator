class %{class_name}Seeder < Germinator::Seed
  
  ##
  # Determines which environments this seed should be allowed to execute in.
  #
  # ==== Valid values:
  # *true*                    => All environments (default)
  # *"development"*           => Only the "development" environment
  # *["development","test"]*  => Only the "development" and "test" environments.
  # *false*                   => No environments (disables this seed)
  #
  def environments
    # This block can be removed if this code should execute in all environments 
    true
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
  

  ##
  # This block of code gets executed when a plant request is made, and this seed name is identified.
  # 
  # ==== Example:
  #
  # $ rake db:plant %{name}
  #
  def plant
    # Remove this block if there is nothing to plant in this seed.
  end

end