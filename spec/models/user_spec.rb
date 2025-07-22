require 'rails_helper'

RSpec.describe User, type: :model do
  subject {
    described_class.new(prenom: 'Prenom',
                        nom: 'Nom',
                        email: 'admin@prestation.local',
                        type_profil: :admin,
                        telephone: '221770000000',
                        password: 'Passer123')
  }

  describe 'associations' do
    it { should have_many(:trackings) }
    it { should belong_to(:created_by).optional }
    it { should belong_to(:activated_by).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:prenom) }
    it { should validate_presence_of(:nom) }
    it { should validate_presence_of(:type_profil) }
    it { should validate_presence_of(:telephone) }
    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end
end