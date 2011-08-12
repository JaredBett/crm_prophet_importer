
module FatFreeCRM
  module Prophet
    class Import

      DEFAULT_USER_ID = 2

      class << self

        def companies(username_map)

          user_ids = {}
          username_map.each do |prophet_user, ff_user|
            prophet_user_id = User.where(["DisplayName = ?", prophet_user]).first.UserID
            ff_user_id = ::User.where(["username = ?", ff_user]).first.id
            user_ids[prophet_user_id] = ff_user_id
          end

          Company.limit(100).where("CompName != ''").each do |c|
            puts "Importing Company #{c.CompName}"

            trunc_name = c.CompName[0..63]
            user_id = user_ids[c.UserID] || DEFAULT_USER_ID

            if ::Account.find_by_name(trunc_name)
              puts "Company already exists with name #{trunc_name}, skipping"
              next
            end

            account = ::Account.create!(
              :user_id          => user_id,
              :assigned_to      => user_id,
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
                :user_id          => user_id,
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
