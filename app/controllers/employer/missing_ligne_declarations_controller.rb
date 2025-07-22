class Employer::MissingLigneDeclarationsController < Employer::ApplicationController

  def new

  end

  def edit
    #edit
  end

  def update
    @missing_ligne = MissingLigneDeclaration.find(params[:id])
    if @missing_ligne.update(missing_ligne_params)
      flash[:notice] = "Le salarié est modifié."
    else
      flash[:error] = "Erreur sur l'ajout du salarié : #{@missing_ligne.errors.full_messages}"
    end

    redirect_to employer_declaration_ligne_declarations_path(@missing_ligne.missing_declaration)

  end

  def create
    @missing_ligne = MissingLigneDeclaration.new(missing_ligne_params)

    @missing_ligne.missing_declaration
    code_regime = @missing_ligne.missing_declaration.regime == "1" ? "GENERAL" : "CADRE"
    regime = Admin::TypeRegime.find_by_code(code_regime)
    @missing_ligne.type_regime = regime

    @missing_ligne.salaire_soumis = @missing_ligne.salaire_reel

    @missing_ligne.etat = :creation

    if @missing_ligne.motif_sortie.nil?
      @missing_ligne.motif_sortie = :aucun
    end

    @missing_ligne.date_entree = @missing_ligne.date_entree.change(:year => Date.parse("01/01/#{ @missing_ligne.missing_declaration.exercice}").year)
    @missing_ligne.date_sortie = @missing_ligne.date_sortie.change(:year => Date.parse("01/01/#{ @missing_ligne.missing_declaration.exercice}").year)

    if @missing_ligne.save
      flash[:notice] = "Le salarié est ajouté."
    else
      flash[:error] = "Erreur sur l'ajout du salarié : #{@missing_ligne.errors.full_messages}"
    end
    redirect_to employer_declaration_ligne_declarations_path(@missing_ligne.missing_declaration)
  end

  def retirer
    @missing_ligne = MissingLigneDeclaration.find_by(id: params[:missing_ligne_declaration_id])
    unless @missing_ligne.nil?
      missing_declaration = @missing_ligne.missing_declaration
      @missing_ligne.destroy

      flash[:error] = "Salarié retiré avec succès"
      redirect_to employer_declaration_ligne_declarations_path(missing_declaration)
    end
  end

  def destroy
    @missing_ligne = MissingLigneDeclaration.find_by(id: params[:id])
    missing_declaration = @missing_ligne.missing_declaration
    @missing_ligne.destroy

    flash[:notice] = "Salarié retiré avec succès"
    redirect_to employer_declaration_ligne_declarations_path(missing_declaration)
  end

  def import

    declaration_id = params[:missing_declaration_id]

    if params[:file].nil?
      flash[:error] = "Fichier introuvable"
      redirect_to '/employer/declarations/#{declaration_id}/ligne_declarations'
    else
      if MissingLigneDeclaration.my_import(params[:file], declaration_id)
        redirect_to "/employer/declarations/#{declaration_id}/ligne_declarations", notice: "Fichier déclaration salarié importé avec succés"
      else
        flash[:error] = "Erreur sur le traitement. Merci de vérifier les données du fichier"
        redirect_to '/employer/declarations/#{declaration_id}/ligne_declarations'
      end
    end

  end

  private

  def missing_ligne_params
    params.require(:missing_ligne_declaration).permit(:missing_declaration_id, :exercice, :nom, :prenom, :matricule, :sexe, :regime, :date_entree, :lieu_naissance, :nationalite_id, :profession_id, :date_sortie, :date_naissance, :numero_identite, :salaire_reel, :motif_sortie)
  end

end