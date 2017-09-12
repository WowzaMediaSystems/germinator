require 'germinator/base'
require 'germinator/seed_config'
require 'germinator/errors'

module Germinator
  ##
  # A base class for the seed files
  #
  class Seed < Germinator::Base


    attr_reader :config, :response, :message

    def initialize
      @response = "Success"
      @config = SeedConfig.new
      configure @config
    end

    ##
    # An overridable method that allows you to modify this seed's configuration
    #
    def configure c
      # Set the environments configuration to the response from the
      # environments method so that the file will be backward compatible.
      c.environments = self.environments
    end

    ##
    # Specifies the commands to execute during a germinate process.
    #
    def germinate
      # Do nothing for now.
    end


    ##
    # Specifies the commands to execute during a shrivel process.
    #
    def shrivel
      # Do nothing for now.
    end

    ##
    # Either germinates or shrivles the database based on the direction specified.
    #
    # ==== Parameters:
    #
    # *direction* => The direction to execute. :up = germinate. :down = shrivel.
    #
    def migrate direction=:up
      if is_valid_environment?
        if models_are_valid?
          begin
            germinate if direction === :up
            shrivel if direction === :down
          rescue Exception => e
            if config.stop_on_error
              raise e
            else
              puts_error e
              class_name = e.class.name
              @response = class_name
              @message = e.message
              puts "Moving on..."
            end
          end
        else
          error = Germinator::Errors::InvalidSeedModel.new
          @response = error.class.name.to_s.gsub(/Germinator\:\:Errors\:\:/,"")
          @message = error.message
          raise error
        end
      else
        error = Germinator::Errors::InvalidSeedEnvironment.new
        @response = error.class.name.to_s.gsub(/Germinator\:\:Errors\:\:/,"")
        @message = error.message
        raise error
      end
    end


    ##
    # Specifies which environments the Seed instance is allowed to execute in.
    #
    # *DEPRECATED:* Please use the Seed#configure method to set the environments configuration.
    #
    def environments
      return true
    end


    ##
    # Specifies the commands to execute during a plant process.
    #
    # *DEPRECATED:* Create a rake task to handle repeatable data manipulations.
    #
    def plant
    end


    private
    ##
    # Determines if the current environment is an acceptable environment to execute this
    # seed in.
    #
    def is_valid_environment?
      envs = config.environments
      return envs if !!envs == envs
      return false unless envs.kind_of?(String) || envs.kind_of?(Array)

      envs = [ envs ] if envs.kind_of?(String)
      envs = envs.map{ |e| e.downcase }

      envs.include?(Rails.env.downcase)
    end


    def models_are_valid?
      valid_models = config.valid_models
      return valid_models if !!valid_models == valid_models
      return false unless valid_models.kind_of?(Hash)

      puts "Validating models..."

      valid_models.default = true

      valid_models.each do |name, methods|
        begin
          model = Module.const_get(name.to_s.camelize)
          return false unless model.is_a?(Class)

          model.connection.schema_cache.clear!
          model.reset_column_information

          next if !!methods == methods
          return false unless methods.kind_of?(Array)

          methods.each do |method|
            unless (model.column_names.include?(method.to_s) || model.instance_methods.include?(method.to_sym) || model.metaclass.instance_methods.include?(method.to_sym))
              puts "Method #{method} does not exist for model #{name.to_s.camelize}", 6
              return false
            end
          end
        rescue NameError => e
          puts "Model #{name.to_s.camelize} does not exist!", 6
          puts_error(e)
          return false
        rescue Exception => e
          puts ""
          puts_error e
          puts ""
          return false
        end
      end

      return true
    end

    private def ellipsisize(str, minimum_length=4,edge_length=3)
      return self if str.length < minimum_length or str.length <= edge_length*2
      edge = '.'*edge_length
      mid_length = str.length - edge_length*2
      str.gsub(/(#{edge}).{#{mid_length},}(#{edge})/, '\1...\2')
    end

  end
end
