# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
  inflect.irregular 'type_contrat_salarie', 'type_contrat_salaries'
  inflect.irregular 'motif_sortie', 'motif_sorties'
  inflect.irregular 'grossesse', 'grossesses'
  inflect.irregular 'veuve', 'veuves'
  inflect.irregular 'paiements_caisse', 'paiements_caisses'
  inflect.irregular 'echeance_caisse', 'echeance_caisses'
  inflect.uncountable %w( pays )
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
