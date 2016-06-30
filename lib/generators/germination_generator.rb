class GerminationGenerator < Rails::Generators::Base
  source_root File.expand_path('../../templates', __FILE__)
  argument :seed_name, :type => :string, :default => nil

  def build_seed_file
    if seed_name.nil?
      puts "You must provide a germinator seed name."
      return
    end

    puts "Seed name: #{seed_name.underscore}"
    name = seed_name.underscore

    if Dir["#{Rails.root}/#{Germinator::SEED_PATH}/*_#{name}.rb"].length > 0
      puts "The germinator seed name provided already exists. Please select another name."
      return
    end

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    source_seed_file = "seed.rb"
    destination_seed_file = "#{Rails.root}/#{Germinator::SEED_PATH}/#{timestamp}_#{name}.rb"

    copy_file source_seed_file, destination_seed_file do |content|
      content.gsub('%{class_name}', seed_name)
    end
  end

end
