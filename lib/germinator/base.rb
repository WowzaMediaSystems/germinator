module Germinator
  class Base
    protected
    ##
    # Override the puts method to add the ability to indent content in the output.  This is a way of making it prettier for the
    # console.  
    #
    def puts content, indent=3
      STDOUT.puts "#{(" "*indent)}#{content}"
    end

    ##
    # Helper to standardize the output for an error.
    #
    def puts_error e
      puts "-"*80
      puts e.message
      e.backtrace.each do |trace|
        puts trace
      end
      puts "-"*80
    end

    ##
    # Displays the configuration object values in the terminal.
    #
    def output_config seed
      puts "Configuration:"
      seed.config.instance_variables.each do |ivar| 
        puts "- #{ivar.to_s.gsub(/\@/, "")} -> #{seed.config.instance_variable_get ivar}", 6
      end
    end

    ##
    #
    def self.confirm_database_table
      ActiveRecord::Base.establish_connection
      unless ActiveRecord::Base.connection.table_exists? Germinator::VERSION_TABLE_NAME
        ActiveRecord::Base.connection.execute("CREATE TABLE `#{Germinator::VERSION_TABLE_NAME}` (`version` VARCHAR(20) NOT NULL, `name` VARCHAR(300) NOT NULL, `response` VARCHAR(40) NOT NULL, `message` VARCHAR(300))")      
      end
    end

  end
end