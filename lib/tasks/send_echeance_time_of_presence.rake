namespace :send_echeance_time_of_presence do
  desc "Send Time of presence document to employer on every deadline"
  task send_time_of_presence: :environment do
    require 'active_support/concern'
    include SetDate

    @employeurs = Psrm::Employeur.when_eligible
    @annee = Date.today.year
    @trimestre = find_quarter(Date.today.month)
    @period = set_period_for_allocation_f(@trimestre, @annee)

    @employeurs.each do |employeur|
      mandataire = Admin::Mandataire.where(numero_employeur: employeur.fhnum).last

      unless mandataire.nil?
        @salaries = Psrm::Participant.requiert_carrieres_dp(@trimestre, @annee, employeur.fhnum).select { |m| m.is_eligible(@period) }

        next if @salaries.length == 0
        email = mandataire.email
        unless email.nil? or email.empty?
          if email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
            BordereauMailer.new_bordereau_mail(email, employeur, @salaries, @period).deliver
          end
        end
      end
    end
  end
end