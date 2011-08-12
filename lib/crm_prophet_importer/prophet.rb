module FatFreeCRM
  module Prophet

    class Base < ActiveRecord::Base
      self.abstract_class = true
    end

    class Company < Base
      set_table_name :tblCompany
      set_primary_key :CompanyID

      has_many :contacts, :foreign_key => :MainCompanyID
    end

    class Contact < Base
      set_table_name :tblContact
      set_primary_key :ContactID

      belongs_to :company, :foreign_key => :MainCompanyID
    end

    class User < Base
      set_table_name :tblUser
      set_primary_key :UserID
    end

  end
end
