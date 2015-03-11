require 'germinator/base'

class InstallGerminatorGenerator < Rails::Generators::Base
  source_root File.expand_path('../../..', __FILE__)

  def add_germinator_version_table
    Germinator::Base.confirm_database_table
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