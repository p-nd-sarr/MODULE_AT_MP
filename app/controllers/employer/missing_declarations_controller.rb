class Employer::MissingDeclarationsController < Employer::ApplicationController

  def new

  end

  def create

  end

  def valider
    @declaration = MissingDeclaration.find(params[:missing_declaration_id])

    @ligne_declarations = @declaration.missing_ligne_declarations

    @ligne_declarations.each do |ligne_declaraiton|
      ligne_declaraiton.etat= :valide
      ligne_declaraiton.date_validation = DateTime.now
      ligne_declaraiton.save
    end

    @declaration.etat = :valide
    @declaration.save

    flash[:notice] = "Déclaration validée avec succées"
    redirect_to employer_declaration_ligne_declarations_path(@declaration)

  end

  def delete_document
    @declaration = MissingDeclaration.find(params[:missing_declaration_id])

    @declaration.document.purge
    @declaration.save

    flash[:notice] = "Document supprimer"
    redirect_to employer_declaration_ligne_declarations_path(@declaration)

  end

  def soumettre
    @declaration = MissingDeclaration.find(params[:id] || params[:missing_declaration_id])

    if @declaration.update(declaration_commentaire_params)
      @declaration.soumis_le = DateTime.now
      @declaration.soumis_par = current_user
      @declaration.save
      flash[:notice] = "La demande de déclaration est soumise"
      redirect_to employer_declaration_ligne_declarations_path(@declaration)
    end
  end

  def download_csv
    send_file(
        "#{Rails.root}/public/declaration_salaries.csv",
        filename: "declaration_salaries.csv",
        type: "application/csv"
    )
  end


  private

  def declaration_commentaire_params
    params.require(:missing_declaration).permit(:commentaire, :document)
  end

  def missing_ligne_params
    params.require(:missing_ligne_declaration).permit(:missing_declaration_id, :exercice, :nom, :prenom, :matricule, :date_entree, :lieu_naissance, :nationalite_id, :profession_id, :date_sortie,:date_naissance, :numero_identite, :salaire_reel, :salaire_soumis, :motif_sortie )

  end

end