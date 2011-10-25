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

      #puts "Importing people..."
      #people, contacts = FatFreeCRM::prophet::Import.people
      #puts "  Importing related notes..."
      #FatFreeCRM::prophet::Import.notes(people, contacts)
      #puts "  Importing related tasks..."
      #FatFreeCRM::prophet::Import.related_tasks(people, contacts)

      #puts "Importing companies..."
      #companies, accounts = FatFreeCRM::prophet::Import.companies
      #puts "  Importing related notes..."
      #FatFreeCRM::prophet::Import.notes(companies, contacts)
      #puts "  Importing related tasks..."
      #FatFreeCRM::prophet::Import.related_tasks(companies, accounts)

      #puts "Importing tasks..."
      #FatFreeCRM::prophet::Import.standalone_tasks

      puts "Clearing out all activities..."
      Activity.delete_all
    end

  end
end
