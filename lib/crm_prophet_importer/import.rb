
module FatFreeCRM
  module Prophet
    class Import

      DEFAULT_USER_ID = 2

      class << self

        def companies(config)
          username_map = config['users']
          tag_map = config['tags']

          user_ids = {}
          username_map.each do |prophet_user, ff_user|
            prophet_user_id = User.where(["DisplayName = ?", prophet_user]).first.UserID
            ff_user_id = ::User.where(["username = ?", ff_user]).first.id
            user_ids[prophet_user_id] = ff_user_id
          end

          #Company.limit(100).where("CompName = 'Jupit.net'").each do |c|
          Company.where("CompName != ''").each do |c|
            puts "Importing Company #{c.CompName}"

            trunc_name = c.CompName[0..63]
            user_id = user_ids[c.UserID] || DEFAULT_USER_ID

            if ::Account.find_by_name(trunc_name)
              puts "Company already exists with name #{trunc_name}, skipping"
              next
            end

            ### create account
            account = ::Account.create(
              :prophet_company_id => c.CompanyID,
              :user_id          => user_id,
              :assigned_to      => user_id,
              :name             => trunc_name,
              :access           => "Public",
              :website          => c.CompWebsite,
              :phone            => c.CompPhone,
              :fax              => c.CompFax,
              :email            => c.email,
              :created_at       => c.CreatedDate,
              :updated_at       => c.UpdatedDate
            )

            ### create account notes
            if c.CompNotes.present?
              puts "Adding note to company #{trunc_name}"
              ::Comment.create(
                :user_id          => user_id,
                :commentable_id   => account.id,
                :commentable_type => 'Account',
                :private          => false,
                :title            => "",
                :comment          => c.CompNotes[0..254],
                :created_at       => c.CreatedDate,
                :updated_at       => c.UpdatedDate
              )
            end

            ### create account addresses
            c.addresses.each do |a|
              type = a.AddrType == 1 ? 'Shipping' : 'Billing'
              newAddr = ::Address.create(
                :address_type     => type,
                :street1          => a.CompAddr,
                :city             => a.CompCity,
                :state            => a.CompState,
                :zipcode          => a.CompZip,
                :country          => a.CompCountry,
                :created_at       => c.CreatedDate,
                :updated_at       => c.UpdatedDate
              )
              if type == 'Billing'
                account.billing_address = newAddr
              else 
                account.shipping_address = newAddr
              end
            end


            ### create account tags
            tags = []
            c.categories.each do |category|
                tags << tag_map[category.name] if tag_map.include? category.name
            end
            if tags.any?
              puts "Adding tags to company #{c.CompName}: #{tags.join(',')}"
              account.tag_list = tags.join(',')
              account.save
            end


            ### create contacts
            c.contacts.each do |contact|
              puts "Importing Contact #{contact.ContactName}"
              ### create contact
              ff_contact = account.contacts.create(
                :prophet_contact_id => contact.ContactID,
                :user_id => user_id,
                :first_name => contact.FirstName,
                :last_name => contact.LastName,
                :title => contact.JobTitle,
                :department => contact.Department,
                :email => contact.Email1,
                :alt_email => contact.Email2,
                :phone => contact.BusiPhone || contact.HomePhone,
                :mobile => contact.CellPhone,
                :fax => contact.Fax,
                :blog => contact.Website,
                :created_at => contact.CreatedDate,
                :updated_at => contact.UpdatedDate
              )
              notes = contact.notes
              ### create contact notes
              if notes && notes.Notes.present?
                puts "Adding note to contact #{contact.ContactName}"
                ::Comment.create(
                  :user_id          => user_id,
                  :commentable_id   => ff_contact.id,
                  :commentable_type => 'Contact',
                  :private          => false,
                  :title            => "",
                  :comment          => notes.Notes[0..254],
                  :created_at       => contact.CreatedDate,
                  :updated_at       => contact.UpdatedDate
                )
              end

              ### create contact tags
              tags = []
              contact.categories.each do |category|
                  tags << tag_map[category.name] if tag_map.include? category.name
              end
              if tags.any?
                puts "Adding tags to contact #{contact.ContactName}: #{tags.join(',')}"
                ff_contact.tag_list = tags.join(',')
                ff_contact.save
              end
            end

            ### create additional account notes from opportunity notes
            c.opportunities.each do |opp|
              puts "Adding opportunity note to company #{trunc_name}"
              opp_user_id = user_ids[opp.UserID] || DEFAULT_USER_ID
              opp.notes.each do |opp_note|
                ::Comment.create(
                  :user_id          => opp_user_id,
                  :commentable_id   => account.id,
                  :commentable_type => 'Account',
                  :private          => false,
                  :title            => "",
                  :comment          => opp_note.Note[0..254],
                  :created_at       => opp_note.CreatedDate,
                  :updated_at       => opp.UpdatedDate
                )
              end
            end

          end
        end
      end
    end
  end
end
