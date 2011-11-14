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
      has_many :opportunities, :foreign_key => :CompanyID
      has_many :categories, :foreign_key => :ItemID
    end

    class Contact < Base
      set_table_name :tblContact
      set_primary_key :ContactID

      belongs_to :company, :foreign_key => :MainCompanyID
      has_one :notes, :class_name => "ContactNote", :foreign_key => :ContactID
      has_many :categories, :foreign_key => :ItemID
    end

    class ContactNote < Base
      set_table_name :tblContactNotes
      set_primary_key :ContactID

      belongs_to :contact, :foreign_key => :ContactID
    end

    class User < Base
      set_table_name :tblUser
      set_primary_key :UserID
    end

    class Opportunity < Base
      set_table_name :tblIncident
      set_primary_key :IncidentID

      has_many :notes, :class_name => "OpportunityNote", :foreign_key => :IncidentID
    end

    class OpportunityNote < Base
      set_table_name :tblIncidentNote
      set_primary_key :NoteID
    end

    class Category < Base
      set_table_name :tblContCompCategory
      set_primary_keys :ItemID, :CategoryID
      def name; attributes['Unused1']; end
    end

  end
end
