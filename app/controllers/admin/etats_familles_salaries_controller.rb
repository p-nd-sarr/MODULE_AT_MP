class Admin::EtatsFamillesSalariesController < Admin::ApplicationController
  before_action :set_participant, only: %i[show generate_etat]

  def index
    @q = Psrm::Participant.all.ransack(params[:q])
    @participants = @q.result.page(params[:page]).per(100)
  end

  def show
    @conjoints = Conjoint.all.where(numero_affiliation: @matricule)
    @enfants = Enfant.all.where(numero_affiliation: @matricule)
  end

  def set_participant
    @matricule = params[:id] || params[:etats_familles_salary_id]
    @participant = Psrm::Participant.find_by(matric: @matricule)

  end


  def generate_etat
    @conjoints = Conjoint.all.where(numero_affiliation: @matricule)
    @enfants = Enfant.all.where(numero_affiliation: @matricule)

    respond_to do |format|
      format.html
      format.pdf do
        generated_pdf = render_to_string pdf: "Récépissé salarié",
                                         page_size: 'A4',
                                         template: "admin/etats_familles_salaries/generated_etat.html.erb",
                                         layout: "pdf.html",
                                         orientation: "Landscape",
                                         lowquality: true,
                                         zoom: 1,
                                         pi: 75
        pdf = CombinePDF.new
        pdf << CombinePDF.parse(generated_pdf)
        pdf_first_page = pdf.pages[0]
        mediabox = pdf_first_page[:CropBox] || pdf_first_page[:MediaBox]
        @conjoints.each do |conjoint|
          title_page = CombinePDF.create_page mediabox
          full_name = 'Les pieces jointes du conjoint ' + conjoint.prenom + ' ' + conjoint.nom
          title_page.textbox full_name, font_color: [0.8, 0, 0], font_size: :fit_text, box_color: [1, 0.8, 0.8], opacity: 1
          pdf << title_page

          if conjoint.certificat_mariage.attached?
            cm = conjoint.certificat_mariage.download
            pdf << CombinePDF.parse(cm)
          end

          if conjoint.extrait_naissance.attached?
            ext = conjoint.extrait_naissance.download
            pdf << CombinePDF.parse(ext)
          end
        end
        @enfants.each do |enfant|
          title_page = CombinePDF.create_page mediabox
          full_name = "Les pieces jointes de l'enfant " + enfant.prenom + ' ' + enfant.nom
          title_page.textbox full_name, font_color: [0.8, 0, 0], font_size: :fit_text, box_color: [1, 0.8, 0.8], opacity: 1
          pdf << title_page

          if enfant.extrait_naissance.attached?
            ext = enfant.extrait_naissance.download
            pdf << CombinePDF.parse(ext)
          end

        end

        send_data pdf.to_pdf, filename: "etat_famille.pdf", type: "application/pdf"
      end
    end
  end

end

