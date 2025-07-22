module Documentable
  extend ActiveSupport::Concern

  included do
    has_many :documents, as: :documentable, dependent: :destroy
  end

  def uploaded?(type_document)
    documents.exists?(type_document: type_document)
  end

  def type_document_obligatoire
    self.class::TYPE_DOCUMENT_OBLIGATOIRE
  end

  def type_documents
    type_document_obligatoire.merge(self.class::TYPE_DOCUMENT)
  end

  def required_document_uploaded?
    type_document_obligatoire.keys.each { |type_document|
      return false unless uploaded?(type_document)
    }
    true
  end
end
