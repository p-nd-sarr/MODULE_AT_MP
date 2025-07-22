class Admin::ComptaTransactionsController < ApplicationController
  def index
    unless params[:q].nil?
      old_numero = params[:q][:ordre_paiement_numero_cont]
      params[:q][:ordre_paiement_numero_cont] = old_numero.gsub(/\s+/, "").strip unless old_numero.empty?
    end
    @q = ComptaTransaction.all.ransack(params[:q])
    @compta_transactions = @q.result.includes(:ordre_paiement).order('id desc').page(params[:page]).per(200)
  end
end
