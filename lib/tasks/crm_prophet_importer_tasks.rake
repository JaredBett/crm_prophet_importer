require File.dirname(__FILE__) + "/../crm_prophet_importer/prophet"
require File.dirname(__FILE__) + "/../crm_prophet_importer/import"

namespace :crm do
  namespace :prophet do

    desc "Import prophet data"
    task :import => :environment do
      config = YAML::load(File.open(File.join(Rails.root, 'config', 'prophet.yml')))
      FatFreeCRM::Prophet::Base.establish_connection(config['database'])

      puts "Deleting existing data"
      Account.delete_all
      Contact.delete_all
      Address.delete_all

      puts "Importing companies..."
      FatFreeCRM::Prophet::Import.companies(config['users'])

      puts "Clearing out all activities..."
      Activity.delete_all
    end

  end
end
