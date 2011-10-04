module FatFreeCRM
  module Prophet

    class Base < ActiveRecord::Base
      self.abstract_class = true
    end

    class CompanyAddress < Base
      set_table_name :tblCompanyAddr
      set_primary_keys :CompanyID, :AddrType

      #belongs_to :company, :foreign_key => 'CompanyID'
    end

    class Company < Base
      set_table_name :tblCompany
      set_primary_key :CompanyID

      has_many :contacts, :foreign_key => :MainCompanyID
      has_many :addresses, :class_name => "CompanyAddress", :foreign_key => :CompanyID
    end

    class Contact < Base
      set_table_name :tblContact
      set_primary_key :ContactID

      belongs_to :company, :foreign_key => :MainCompanyID
      has_one :notes, :class_name => "ContactNotes", :foreign_key => :ContactID
    end

    class ContactNotes < Base
      set_table_name :tblContactNotes
      set_primary_key :ContactID

      belongs_to :contact, :foreign_key => :ContactID
    end

    class User < Base
      set_table_name :tblUser
      set_primary_key :UserID
    end

  end
end
