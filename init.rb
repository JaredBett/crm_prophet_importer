require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_prophet_importer, initializer) do
         name "Prophet Data Importer"
      authors "Jared Betteridge"
      version "0.1"
  description "Imports data from Prophet to Fat Free CRM"
end
