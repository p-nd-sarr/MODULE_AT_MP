class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :periode, ->(date_debut, date_fin) { where("created_at > ? AND created_at < ?", date_debut, date_fin) }

  def self.human_enum_name(enum_name, enum_value)
    I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}")
  end

  def self.enum_select_human(enum_name)
    defined_enums[enum_name.to_s].keys.collect do |enum| [
        I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum}"),
        enum
    ]
    end
  end

  # define enum_name_human to display the human value
  def method_missing(m, *args)
    if m.to_s[/(.+)_human$/]
      enum_name = $1
      if self.class.defined_enums.has_key?(enum_name)
        enum_value = args.empty? ? self.send(enum_name) : args.first
        return nil if enum_value.nil?
        return I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}")
      end
    end
    super
  end

  def respond_to?(method_name, include_private = false)
    if method_name.to_s[/(.+)_human$/]
      enum_name = $1
      return self.class.defined_enums.has_key?(enum_name) || super
    end
    super
  end
end
