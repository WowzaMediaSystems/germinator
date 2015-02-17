class InstallGerminatorGenerator < Rails::Generators::Base
  source_root File.expand_path('../../..', __FILE__)

  def add_germinator_version_table
    puts "Installing Germinator..."
    # Make sure we don't already have a table in the database
    unless ActiveRecord::Base.connection.table_exists? Germinator::VERSION_TABLE_NAME
      puts "  Creating Germinator table: #{Germinator::VERSION_TABLE_NAME}"
      ActiveRecord::Base.establish_connection
      ActiveRecord::Base.connection.execute("CREATE TABLE `#{Germinator::VERSION_TABLE_NAME}` (`version` VARCHAR(20) NOT NULL)")      
    else
      puts "  Germinator table exists: #{Germinator::VERSION_TABLE_NAME}" 
    end
  end

  def add_germinator_file_directory
    file_directory = "#{Rails.root}/#{Germinator::SEED_PATH}"
    puts "Building directory structure..."
    unless File.directory?(file_directory)
      empty_directory(file_directory)
      puts "  Added: #{file_directory}"
    else
      puts "  Directory already exists: #{file_directory}"
    end
  end

end