namespace :allocation_familiale_doc_valid do
  desc "Set allocation familiale document invalid"
  task set_allocation_familiale_invalid: :environment do
    AllocationFamiliale.creation.each do |allocation|
      documents = Document.where(documentable: allocation.enfant)

      if allocation.enfant.migrated_document_exp_date?
        next if allocation.enfant.migrated_document_exp_date > Date.today
      end
      unless documents.where("date_expiration > ?", Date.today).exists?
        allocation.document_valid = false
        allocation.save
      end
    end
  end
end
