module Germinator


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