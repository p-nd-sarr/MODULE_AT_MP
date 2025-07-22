class Admin::TableauBordController < ApplicationController

  def index
    @total_demande = LiquidationRetraite.count + ArretTravail.count + DossierPrestation.count + DossierMaternite.count + MaladieProfessionnelle.count + PrestationExterieure.count
  end
end
