require 'rails_helper'

RSpec.describe Carriere, type: :model do
  describe 'associations' do
    it { should belong_to(:type_regime) }
  end
end
