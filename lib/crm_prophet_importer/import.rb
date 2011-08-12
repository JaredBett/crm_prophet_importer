module FatFreeCRM
  module Prophet
    class Import

      class << self

        def companies
          Company.limit(20).where("CompName != ''").each do |c|
            puts "Importing Company #{c.CompName}"

            trunc_name = c.CompName[0..63]

            if ::Account.find_by_name(trunc_name)
              puts "Company already exists with name #{trunc_name}"
            end
           
            account = ::Account.create!(
              :user_id          => 1,
              :assigned_to      => 1,
              :name             => trunc_name,
              :access           => "Public",
              :website          => c.CompWebsite,
              :phone            => c.CompPhone,
              :fax              => c.CompFax,
              :created_at       => c.CreatedDate
            )

            if c.CompNotes.present?
              puts "Adding note to company #{trunc_name}"
              ::Comment.create!(
                :user_id          => 1,
                :commentable_id   => account.id,
                :commentable_type => 'Account',
                :private          => false,
                :title            => "",
                :comment          => c.CompNotes[0..254],
                :created_at       => c.CreatedDate
              )
            end

            #if company.contact_data.addresses.present?
              #highrise_address = company.contact_data.addresses.first
              #account.billing_address = ::Address.new(:full_address => extract(company.contact_data, :address))
              #account.shipping_address = ::Address.new(:full_address => extract(company.contact_data, :address))
              #account.save!
            #end
            #import_email(company, account)
            # puts account.inspect
          end
        end

      end
    end
  end
end
