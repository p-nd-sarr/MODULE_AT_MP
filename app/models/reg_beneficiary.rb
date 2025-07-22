class RegBeneficiary < ApplicationRecord

  belongs_to :regularisation_pension, foreign_key: :regularisation_pensions_id
end
