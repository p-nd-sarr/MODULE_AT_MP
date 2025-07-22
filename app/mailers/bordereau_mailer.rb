# app/mailers/bordereau_mailer.rb

class BordereauMailer < ActionMailer::Base
  default from: '"Prestation" <noreply-secusociale@ipres.sn>'

  def new_bordereau_mail(email, employeur, salaries, period)
    @employeur = employeur
    @salaries = salaries
    @period = period

    mail(:to => email, :subject => "Temps de présence collectif") do |format|
      format.pdf do
        attachments['Bordereau.pdf'] = WickedPdf.new.pdf_from_string(
          render_to_string pdf: "TEMPS DE PRÉSENCE COLLECTIF",
                           page_size: 'A4',
                           template: "admin/traitement_collectifs/generated_bordereau.html.erb",
                           layout: "bordereau_mailer.html",
                           orientation: "Landscape",
                           lowquality: true,
                           zoom: 1,
                           pi: 75
        )

      end
    end
  end
end
