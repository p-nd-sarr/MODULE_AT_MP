class UserMailer < ActionMailer::Base
  default from: '"Prestation" <noreply-secusociale@ipres.sn>'

  # @param [User] user
  # @param [String] password
  def new_account(user, password)
    @user = user
    @password = password

    mail(to: "#{@user.full_name} <#{@user.email}>", subject: 'Nouveau compte sur la plateforme de Prestation créé')
  end

  def email_updated(user, previous_email)
    @user = user
    @previous_email = previous_email

    mail(to: "#{@user.full_name} <#{@user.email}>", subject: 'Adresse email du compte de la plateforme Prestation modifiée')
  end
end
