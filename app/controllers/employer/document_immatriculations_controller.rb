class Employer::DocumentImmatriculationsController < Employer::ApplicationController

  def index
    @documents = current_user.document_immatriculations
  end

  def new

  end

  def show
    #show
  end


  def create
    @document_immatriculation = DocumentImmatriculation.new(document_immatriculation_params)
    @document_immatriculation.user = current_user
    if @document_immatriculation.save
      redirect_to [:employer,'immatriculations'] , notice: "document créée avec succès."
    else
      puts @document_immatriculation.errors.full_messages
      flash[:error] = @document_immatriculation.errors.full_messages
      redirect_to [:employer,'immatriculations'] , notice: ""
    end
  end

  def edit
    #edit
  end

  def destroy
    @document_immatriculation = DocumentImmatriculation.find(params[:id])
    @document_immatriculation.destroy
    redirect_to [:employer,'immatriculations'] , notice: "Document supprimé."
  end

  def update
    @document_immatriculation = DocumentImmatriculation.find(params[:id])
    if @document_immatriculation.update(representant_params)

      immatriculation = current_user.immatriculation

      immatriculation.documents_valide!(false)
      redirect_to [:employer,'immatriculations'], notice: "document was successfully updated."
    else
      puts @document_immatriculation.errors.full_messages
      flash[:error] = @document_immatriculation.errors.full_messages
      render 'employer/immatriculations'
    end
  end

  private

  def document_immatriculation_params
    params.require(:document_immatriculation).permit(:type_document, :document, :commentaire, :document_immatriculation)
  end


end