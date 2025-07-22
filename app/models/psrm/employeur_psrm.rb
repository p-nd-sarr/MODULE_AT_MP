class Psrm::EmployeurPsrm < Psrm::DbBase
  self.table_name = 'CISADM.CM_EMPLOYEUR_VIEW'

=begin
  Nom                 NULL ?   Type
  ------------------- -------- -------------
  FHNUM               NOT NULL CHAR(10)
  ANCIEN_NUM_IPRES             VARCHAR2(16)
  ANCIEN_NUM_CSS               VARCHAR2(16)
  FHRSOC              NOT NULL VARCHAR2(254)
  ACTIVITE_PRINICIPAL          VARCHAR2(200)
  FHBP                         CHAR(12)
  FHADR                        VARCHAR2(254)
  FHTEL                        VARCHAR2(24)
  FHEFFA                       DATE
  TAUX_AT                      VARCHAR2(254)
  SOLDE_PF                     NUMBER
  SOLDE_AT                     NUMBER
  SOLDE_VE                     NUMBER
  SOLDE_TOTAL                  NUMBER
  STATUT                       VARCHAR2(254)
  ANCIEN_STATUT_IPRES          VARCHAR2(254)
  ANCIEN_STATUT_CSS            VARCHAR2(254)
=end
end