module Germinator
  require 'germinator/railtie' if defined?(Rails)

  # Default table name in the database.
  VERSION_TABLE_NAME = "germinator_migrations"

  # Default seed path for the germinate files.
  SEED_PATH = "db/germinate"

  ##
  # A class to manage the seeding process.
  #
  class Seeder

    ##
    # Germinates the database by finding unseeded files in the germinate/
    # directory and attempting to execute their germinate method.
    #
    # ==== Parameters:
    #
    # *step:* => A maximum number of seeds to germinate.  nil or 0 will execute all unseeded files in the germinate directory. (default: nil)
    #
    def germinate p={}
      confirm_database_table
      include_seeds
      step = p.has_key?(:step) ? p[:step].to_i : nil
      step = nil if step==0

      i = 0
      _seeds = unseeded

      _seeds.keys.sort.each do |key|
        seed = _seeds[key]

        begin
          puts "== #{seed}: GERMINATE ==========", 0
          seed_object = get_seed_object seed
          seed_object.migrate :up
          puts "== #{seed}: END       ==========", 0
          
          add_seeded_version seed.version
        rescue Exception => e
          puts ""
          puts "-"*80
          puts e
          if e.backtrace and e.backtrace.size > 0
            e.backtrace.each do |trace|
              puts "#{trace}"
            end
          end
          puts "-"*80
          puts ""
          puts "There was an error while executing the seeds.  Germination stopped!", 0
          puts ""
          return
        end

        i += 1
        break if step and i >= step
      end
    end

    ##
    # Shrivels the database by finding seeded files in the germinate/
    # directory and attempting to execute their shrivel method.
    #
    # ==== Parameters:
    #
    # *step:* => A maximum number of seeds to shrivel.  nil or 0 will execute all unseeded files in the germinate directory. (default: 1)
    #    
    def shrivel p={}
      confirm_database_table
      include_seeds
      step = p.has_key?(:step) ? p[:step].to_i : 1
      step = nil if step==0

      i = 0
      _seeds = seeded

      _seeds.keys.sort.reverse.each do |key|
        seed = _seeds[key]

        begin
          puts "== #{seed}: SHRIVEL ==========", 0
          seed_object = get_seed_object seed
          seed_object.migrate :down
          puts "== #{seed}: END     ==========", 0
          
          remove_seeded_version seed.version
        rescue Exception => e
          puts ""
          puts "-"*80
          puts e
          puts "-"*80
          puts ""
          puts "There was an error while executing the seeds.  Shrivel stopped!", 0
          puts ""
          return
        end
        
        i += 1
        break if step and i >= step
      end      
    end



    ##
    # Shrivels and then germinates the database by finding seeded files in the germinate/
    # directory and attempting to execute their shrivel and germinate methods.  The germinate
    # methods get called in order after all of the shrivel methods have been call.
    #
    # ==== Parameters:
    #
    # *step:* => A maximum number of seeds to reseed.  nil or 0 will execute all unseeded files in the germinate directory. (default: nil)
    #    
    def reseed p={}
      step = p.has_key?(:step) ? p[:step].to_i : 1
      step = nil if step==0

      puts "Reseeding the database...", 0
      puts ""

      shrivel step: step
      germinate step: step
    end


    ##
    # Plants the database by finding the specified seed file (by name only) and then attempts to
    # execute the plant method.  This is useful for code that needs to be executed more than once
    # in an environment.
    #
    # ==== Parameters
    #
    # *germinator_name* => The snake case name of the germinator file, minus the time stamp. Example: 20150201120001_some_germinator_file becomes some_germinator_file.
    #
    def plant seed_name
      confirm_database_table
      include_seeds

      _seeds = seeds.select{ |key, seed| seed.name === seed_name }

      if _seeds and (_seeds.keys.length > 0)
        puts "Seeds: #{_seeds}"

        key, seed = _seeds.first

        begin

          puts "== #{seed.name}: PLANT ==========", 0
          seed_object = get_seed_object seed
          seed_object.plant
          puts "== #{seed.name}: END   ==========", 0
          
          add_seeded_version seed.version
        rescue Exception => e
          puts ""
          puts "-"*80
          puts e
          puts "-"*80
          puts ""
          puts "There was an error while executing the seeds.  Plant stopped!", 0
          puts ""
          return
        end
      else
        puts ""
        puts "-"*80
        puts "Seed #{seed_name} does not exist.  Canceling plant request."
        puts "-"*80
        puts ""
      end

    end

    private
    ##
    # A helper method to include the seed classes into the code so they can be instantiated.
    #
    def include_seeds
      Dir["#{Rails.root}/#{Germinator::SEED_PATH}/*.rb"].each {|file| require file.gsub(/\.rb/, "") }
    end


    private
    ##
    # A helper method to instantiate a seed object by class name.
    #
    def get_seed_object seed
      seed_class = "#{seed.class_name}Seeder".constantize
      seed_object = seed_class.new
      return seed_object
    end


    private
    ##
    # Returns a hash of all germinator files as SeedFile objects keyed by seed name.
    #
    def seeds
      hash = {}

      germinate_directory = "#{Rails.root}/#{SEED_PATH}/*.rb"
      files = Dir[germinate_directory]

      files.each do |file|
        seed_file = SeedFile.new(file)
        hash[seed_file.seed_name] = seed_file 
      end

      hash
    end


    private
    ##
    # Returns a hash of seeded germinator files as SeedFile objects keyed by seed name.
    #
    def seeded
      versions = seeded_versions
      seeds.select{ |key, seed| versions.include?(seed.version.to_s) } 
    end


    private
    ##
    # Returns a hash of unseeded germinator files as SeedFile objects keyed by seed name.
    def unseeded
      versions = seeded_versions
      seeds.select{ |key, seed| !versions.include?(seed.version.to_s) } 
    end


    private
    ##
    # Requests a list of all of the seeded versions from the database. Returns an array of the
    # verison numbers.
    #
    def seeded_versions
      #ActiveRecord::Base.establish_connection
      version_records = ActiveRecord::Base.connection.execute("SELECT * FROM `#{Germinator::VERSION_TABLE_NAME}` ORDER BY `version`")

      version_records.map do |version_record| 
        key, value = version_record.first
        value
      end
    end


    private
    ##
    # Inserts a seeded version number into the database.
    #
    def add_seeded_version version
      return unless version and (version.to_i > 0)
      ActiveRecord::Base.connection.execute("INSERT INTO `#{Germinator::VERSION_TABLE_NAME}` (version) VALUES ('#{version.to_s}')")
    end


    private
    ##
    # Deletes a seeded version number from the database
    #
    def remove_seeded_version version
      return unless version and (version.to_i > 0)
      ActiveRecord::Base.connection.execute("DELETE FROM `#{Germinator::VERSION_TABLE_NAME}` WHERE `version`='#{version.to_s}'")
    end


    protected
    ##
    # Override the puts method to add the ability to indent content in the output.  This is a way of making it prettier for the
    # console.  
    #
    def puts content, indent=3
      STDOUT.puts "#{(" "*indent)}#{content}"
    end


    private
    def confirm_database_table
      ActiveRecord::Base.establish_connection
      unless ActiveRecord::Base.connection.table_exists? Germinator::VERSION_TABLE_NAME
        ActiveRecord::Base.connection.execute("CREATE TABLE `#{Germinator::VERSION_TABLE_NAME}` (`version` VARCHAR(20) NOT NULL)")      
      end
    end
  end


  ##
  # A base class for the seed files
  #
  class Seed

    ##
    # Specifies which environments the Seed instance is allowed to execute in.
    #
    def environments
      return true
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
    # Specifies the commands to execute during a plant process.
    def plant
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
      if is_valid_environment
        germinate if direction === :up
        shrivel if direction === :down
      else
        puts "  !! The current environment (#{Rails.env}) is not permitted to execute this seed."
      end
    end


    private
    ##
    # Determines if the current environment is an acceptable environment to execute this
    # seed in.
    #
    def is_valid_environment
      envs = environments
      return envs if !!envs == envs
      return false unless envs.kind_of?(String) || envs.kind_of?(Array)
      
      envs = [ envs ] if envs.kind_of?(String)
      envs = envs.map{ |e| e.downcase }

      envs.include?(Rails.env.downcase)
    end


    protected
    ##
    # Override the puts method to add the ability to indent content in the output.  This is a way of making it prettier for the
    # console.  
    #
    def puts content, indent=3
      STDOUT.puts "#{(" "*indent)}#{content}"
    end

  end


  ##
  # A helper class to parse a seed file name and return the appropriate
  # values
  #
  class SeedFile
    require 'pathname'

    attr_reader :path

    ##
    # Inititalize the class instance.
    #
    # ==== Parameters:
    #
    # *path* => The full path of the seed file being parsed.
    #
    def initialize path
      @path = path
    end


    ##
    # Returns the base file name of the seed file.
    #
    def basename
      Pathname.new(@path).basename.to_s
    end


    ##
    # Returns the version portion of the seed file.
    #
    def version
      parts = basename.split('_', 2)
      return "" if parts.length === 0
      return parts[0]
    end


    ##
    # Returns the name portion of the seed file.
    #
    def name
      parts = basename.split('_', 2)
      return "" if parts.length <= 1
      return parts[1].gsub(/\.rb/, "").to_s
    end


    ##
    # Returns the full seed name of the seed file (no path or extension).
    def seed_name
      "#{version}_#{name}"
    end


    ##
    # Returns the name of the class for the seed file.
    #
    def class_name
      name.camelize
    end


    ##
    # Override the to_s method to make it more readable.
    #
    def to_s
      "[#{version}] #{class_name}"
    end
  end
end
