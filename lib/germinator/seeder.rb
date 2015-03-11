require 'germinator/version'
require 'germinator/base'
require 'germinator/errors'

module Germinator
  ##
  # A class to manage the seeding process.
  #
  class Seeder < Germinator::Base

    ##
    # Germinates the database by finding unseeded files in the germinate/
    # directory and attempting to execute their germinate method.
    #
    # ==== Parameters:
    #
    # *step:* => A maximum number of seeds to germinate.  nil or 0 will execute all unseeded files in the germinate directory. (default: nil)
    #
    def germinate p={}
      step = p.has_key?(:step) ? p[:step].to_i : nil
      step = nil if step==0

      i = 0
      _seeds = unseeded

      _seeds.keys.sort.each do |seed_name|
        germinate_by_seed_name seed_name
        i += 1
        break if step and i >= step
      end
    end

    ##
    # Executes a seed file's germinate method using the name of the seed file.
    # The germinate method is only executed if it has not been executed previously.
    #
    def germinate_by_name name
      Base::confirm_database_table
      include_seeds      
      _seeds = seeds.select{ |seed_name, seed| seed.name == name }
      return if _seeds.size == 0
      seed_name, seed = _seeds.first
      germinate_by_seed_name seed_name
    end

    ##
    # Executes a seed file's germinate method using the version of the seed file.
    # The germinate method is only executed if it has not been executed previously.
    #
    def germinate_by_version version
      _seeds = seeds.select{ |seed_name, seed| seed.version == version }
      return if _seeds.size == 0
      seed_name, seed = _seeds.first
      germinate_by_seed_name seed_name
    end


    ##
    # Executes a seed file's germinate method using the seed_name (version_name) of 
    # the seed file. The germinate method is only executed if it has not been executed 
    # previously.
    #
    def germinate_by_seed_name seed_name
      Base::confirm_database_table
      include_seeds      
      _seeds = unseeded
      return unless _seeds.has_key?(seed_name)
      
      seed = _seeds[seed_name]

      puts "== #{seed}: GERMINATE ==========", 0
      begin
        
        seed_object = get_seed_object seed
        output_config seed_object
        seed_object.migrate :up
        
        add_seeded_version seed.version, seed.name, seed_object.response, seed_object.message
      rescue Germinator::Errors::InvalidSeedEnvironment => e
        puts e.message
        add_seeded_version seed.version, seed.name, seed_object.response, seed_object.message
      rescue Germinator::Errors::InvalidSeedModel => e
        puts e.message
        return if seed_object.config.stop_on_invalid_model
        add_seeded_version seed.version, seed.name, seed_object.response, seed_object.message
        puts "Moving on..."
      rescue Exception => e
        puts ""
        puts_error e
        puts ""
        puts "There was an error while executing the seeds.  Germination stopped!", 0
        puts ""
        raise e if !seed_object || seed_object.config.stop_on_error
        add_seeded_version seed.version, seed.name, seed_object.response, seed_object.message
      ensure
        puts "== #{seed}: END       ==========", 0
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
      Base::confirm_database_table
      include_seeds
      step = p.has_key?(:step) ? p[:step].to_i : 1
      step = nil if step==0

      i = 0
      _seeds = seeded

      _seeds.keys.sort.reverse.each do |seed_name|
        shrivel_by_seed_name seed_name
        i += 1
        break if step and i >= step
      end      
    end


    ##
    # Executes a seed file's germinate method using the name of the seed file.
    # The germinate method is only executed if it has not been executed previously.
    #
    def shrivel_by_name name
      _seeds = seeds.select{ |seed_name, seed| seed.name == name }
      return if _seeds.size == 0
      seed_name, seed = _seeds.first
      shrivel_by_seed_name seed_name
    end


    ##
    # Executes a seed file's germinate method using the version of the seed file.
    # The germinate method is only executed if it has not been executed previously.
    #
    def shrivel_by_version version
      _seeds = seeds.select{ |seed_name, seed| seed.version == version }
      return if _seeds.size == 0
      seed_name, seed = _seeds.first
      shrivel_by_seed_name seed_name
    end


    ##
    # Executes a seed file's germinate method using the seed_name (version_name) of 
    # the seed file. The germinate method is only executed if it has not been executed 
    # previously.
    #
    def shrivel_by_seed_name seed_name
      Base::confirm_database_table
      include_seeds      

      _seeds = seeded
      return unless _seeds.has_key?(seed_name)
      
      seed = _seeds[seed_name]

      begin
        puts "== #{seed}: SHRIVEL ==========", 0
        seed_object = get_seed_object seed
        output_config seed_object
        seed_object.migrate :down
        puts "== #{seed}: END     ==========", 0
        
        remove_seeded_version seed.version
      rescue Germinator::Errors::InvalidSeedEnvironment => e
        puts e.message
        remove_seeded_version seed.version
      rescue Germinator::Errors::InvalidSeedModel => e
        puts e.message
        return if seed_object && seed_object.config.stop_on_invalid_model
        remove_seeded_version seed.version
        puts "Moving on..."          
      rescue Exception => e
        puts ""
        puts_error e
        puts ""
        puts "There was an error while executing the seeds.", 0
        puts ""
        raise e if !seed_object || seed_object.config.stop_on_error
        puts "Moving on..."
        remove_seeded_version seed.version
      ensure
        puts "== #{seed}: END       ==========", 0
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
      version_records = ActiveRecord::Base.connection.execute("SELECT * FROM `#{Germinator::VERSION_2_TABLE_NAME}` ORDER BY `version`")

      versions = version_records.map do |version_record| 
        key, value = version_record.first
        value
      end

      versions.sort
    end


    private
    ##
    # Inserts a seeded version number into the database.
    #
    def add_seeded_version version, name, response, message
      return unless version and (version.to_i > 0)
      ActiveRecord::Base.connection.execute("INSERT INTO `#{Germinator::VERSION_2_TABLE_NAME}` (version, name, response, message) VALUES ('#{version.to_s}', '#{name.to_s}', '#{response.to_s}', '#{message.to_s}')")
    end


    ##
    # Deletes a seeded version number from the database
    #
    def remove_seeded_version version
      return unless version and (version.to_i > 0)
      ActiveRecord::Base.connection.execute("DELETE FROM `#{Germinator::VERSION_2_TABLE_NAME}` WHERE `version`='#{version.to_s}'")
    end
  end
end  