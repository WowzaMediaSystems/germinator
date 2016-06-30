require 'germinator/version'

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
      puts "Configuration: #{seed.config.to_hash}"
    end

    ##
    #
    def self.confirm_database_table
      ActiveRecord::Base.establish_connection
      unless ActiveRecord::Base.connection.table_exists? Germinator::VERSION_2_TABLE_NAME

        # Create the germinator_seeds table because it doesn't exist.
        ActiveRecord::Base.connection.execute("CREATE TABLE `#{Germinator::VERSION_2_TABLE_NAME}` (`version` VARCHAR(20) NOT NULL, `name` VARCHAR(300) NOT NULL, `response` VARCHAR(40) NOT NULL, `message` VARCHAR(300))")

        # Migrate the Version 1 Table to Version 2.
        if ActiveRecord::Base.connection.table_exists? Germinator::VERSION_1_TABLE_NAME
          # If the Version 1 germinator_migrations table still exists, copy its contents to the germinator_seeds table to keep the seeds in sync.
          ActiveRecord::Base.connection.execute("INSERT INTO `#{Germinator::VERSION_2_TABLE_NAME}` (`version`, `name`, `response`, `message`) (SELECT version, '', 'Success', 'This entry was upgraded from Version 1' FROM `#{Germinator::VERSION_1_TABLE_NAME}` ORDER BY `version`)")

          # Drop the old Version 1 table since it will no longer be used.
          ActiveRecord::Base.connection.execute("DROP TABLE `#{Germinator::VERSION_1_TABLE_NAME}`")
        end
      end

      unless ActiveRecord::Base.connection.column_exists?(Germinator::VERSION_2_TABLE_NAME.to_sym, :configuration)
        ActiveRecord::Base.connection.execute("ALTER TABLE `#{Germinator::VERSION_2_TABLE_NAME}` ADD `configuration` TEXT")
      end
    end

  end
end
