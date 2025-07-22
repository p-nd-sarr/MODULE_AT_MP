class Employer::MoratoiresController < Employer::ApplicationController
  before_action :peut_acceder!

  def index

    @moratoires= Moratoire.where(user_id: current_user.id).page(params[:page]).per(10)

    @moratoire = Moratoire.where(user_id: current_user.id).last

    # @moratoire = @immatriculation.moratoires.last

  end

  def new
    @moratoire = Moratoire.new

    @factures = Facture.where("statut = 0").order("created_at DESC")
  end

  def show
    #show
  end

  def create

    #@immatriculation = Immatriculation.find(params[:immatriculation_id  ])

    @moratoire = Moratoire.new(moratoire_params)

    @moratoire.date_fin = @moratoire.date_debut + @moratoire.nombre_echeance.month

    @moratoire.user = current_user

    #declaration = Declaration.find(1)

    montant_total = 0;

    factures = []
    @moratoire.references.each do |f|
      facture = Facture.find_by(reference_facture: f)

      if facture != nil
        montant_total += facture.montant

        factures << facture
      end
    end

    @moratoire.montant = montant_total

    @moratoire.dernier_montant = (montant_total - @moratoire.premier_montant) / (@moratoire.nombre_echeance-1)

    if @moratoire.save

=begin
      factures.each do |f|
        f.update_attribute(:solde, 0)
        f.update_attribute(:statut, 1)
        f.update_attribute(:moratoire_id, @moratoire)
      end


      create_first_facture(declaration)

      i = 1
      (@moratoire.nombre_echeance-1).times do
        #create_last_facture(i, declaration)
        #i +=1
      end
=end
      redirect_to [:employer, 'moratoires'], notice: 'La demande de moratoire est créée. En cours de validation'
    else
      flash[:error] = "Une erreur est survenue lors de la création de la demande de moratoire."
      render :show
    end
  end

  def generate_reference(declaration)
    letters =  (0..9).to_a + ('A'..'Z').to_a
    declaration.id.to_s + letters.sample(10).join
  end

  def valider_moratoire

    @moratoire = Moratoire.find(params[:immatriculation_id])
    if @moratoire.nil?
      redirect_to [:employer, 'moratoires']
    else
      @moratoire.update_attribute(:statut, 1)
      redirect_to [:employer, @moratoire]
    end

  end

  private

  def create_first_facture(declaration)

    facture = Facture.new
    facture.montant = @moratoire.premier_montant.round(-1)
    facture.solde = @moratoire.premier_montant.round(-1)
    facture.date_facture = @moratoire.date_debut
    facture.echeance = @moratoire.date_debut
    facture.periode = @moratoire.date_debut
    facture.moratoire = @moratoire
    facture.declaration = declaration
    facture.reference_facture = generate_reference(declaration)
    facture.save!
  end

  def create_last_facture(i, declaration)
    facture = Facture.new
    facture.montant = @moratoire.dernier_montant.round(-1)
    facture.solde = @moratoire.dernier_montant.round(-1)
    facture.date_facture = @moratoire.date_debut + i.month
    facture.echeance = facture.date_facture
    facture.periode = facture.date_facture
    facture.moratoire  = @moratoire
    facture.declaration = declaration
    facture.reference_facture = generate_reference(declaration)
    facture.save!
  end

  def moratoire_params
    params.require(:moratoire).permit(:premier_montant, :dernier_montant, :nombre_echeance, :date_debut, :date_fin,  :commentaire, references:[])
  end

  def peut_acceder!
    @immatriculation = current_user.immatriculation
    if @immatriculation == nil or @immatriculation.statut_demande != nil
      flash[:info] = "Immatriculation pas encore valide. Veillez faire la demande!"
      redirect_to [:employer, 'immatriculations']
    end
  end
end