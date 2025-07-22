class Admin::CarrieresExterieuresController < Admin::ApplicationController
    before_action :set_carrieres_exterieure, only: [:show, :edit, :update, :destroy, :soumettre_carrieres_ext, :valider_carrieres_ext]
  # GET /admin/countries
  # GET /admin/countries.json
  def index
    @carrieres_exterieures = CarrieresExterieure.all
  end

  def show

  end

  def update
    respond_to do |format|
      if @carrieres_exterieure.update(carrieres_exterieure_params)
        format.html { redirect_to @carrieres_exterieure, notice: 'City was successfully updated.' }
        format.json { render :show, status: :ok, location: @carrieres_exterieure }
      else
        format.html { render :edit }
        format.json { render json: @carrieres_exterieure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/carrieres_exterieure/1
  # DELETE /admin/carrieres_exterieure/1.json
  def destroy
    @prestation_ext_france = @carrieres_exterieure.cfs_reversion_veuve
    @carrieres_exterieure.destroy
    respond_to do |format|
        format.html { redirect_to [:admin, @prestation_ext_france], notice: 'carrieres_exterieure was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def valider_carrieres_ext
    if @carrieres_exterieure.en_attente?
      @carrieres_exterieure.etat =:valide
      @carrieres_exterieure.save
    end

  end

  private

  def set_carrieres_exterieure
    @carrieres_exterieure = CarrieresExterieure.find(params[:id] || params[:carrieres_exterieure_id])
  end

  def carrieres_exterieure_params
    params.require(:carrieres_exterieure).permit(:description, :admin_country_id)
  end
end