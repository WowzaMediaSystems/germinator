
module Germinator
  module Errors
    
    class Standard < StandardError; end

    class InvalidSeedEnvironment < Standard
      def message
        "The current environment (#{Rails.env}) is not permitted to execute this seed."
      end
    end

    class InvalidSeedModel < Standard
      def message
        "The models designated in the seed configuration are not valid."
      end
    end
  end
end