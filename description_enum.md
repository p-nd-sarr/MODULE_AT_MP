# Le fichier est généré par le code suivant :

```ruby
Rails.application.eager_load!

models = ActiveRecord::Base.descendants.map { |model| [model.name, model.defined_enums] }

for m in models
    unless m.last.empty?
        puts "## #{m.first} (#{eval(m.first+'.table_name')})"
        m.last.each_pair { |enum_name, enum_list|
            puts "### #{enum_name}"
            enum_list.each_pair { |name, val|
                puts "#{val} : #{name}\n\n"
            }
        }
    end
end
```

# Liste des enums

## User (users)
### type_profil
1 : admin

101 : gestionnaire_compte_employeur

102 : gestionnaire_compte_salarie

103 : gestionnaire_compte_allocataire

104 : chef_service_allocation

105 : chef_agence

106 : comptable

107 : chef_service_cotisation

108 : chef_section_instruction

109 : chef_section_liquidation

110 : directeur_prestation

111 : chef_service_contentieux

201 : salarie

202 : allocataire

203 : employeur

204 : agent_accueil

205 : chef_subdivision_atmp

206 : redacteur

207 : dajc

208 : dprp

209 : chef_division_at

210 : directeur_at

211 : medecin_conseil

212 : chef_groupe_caf

213 : chef_subdivision_caf

214 : agent_accueil_direction_at

215 : technicien_at

216 : technicien_direction_at

217 : directeur_general

218 : inspection

219 : consultation

300 : chef_service_prest_ext

301 : controleur_css

302 : auditeur_css

303 : agent_dfc

304 : chef_service_dfc

401 : caissier_ipres

501 : directeur_juridique

502 : chef_service_direction_juridique

503 : agent_direction_juridique

### sexe
1 : homme

2 : femme

## Allocataire (allocataires)
### categorie
1 : retraite

6 : veuve

8 : orphelin

19 : pension_alimentaire

2 : coordination

3 : vtr

4 : allocation_solidarite

5 : fonds_social

7 : remboursement_cotisation

9 : veuve_administration

10 : rente_administration

11 : test_interne

12 : rente_viagere

13 : asj

### etat
0 : inactif

1 : actif

2 : soumis

3 : affecter

4 : suspendus

5 : lever_suspension

6 : rejete

7 : eteint

8 : valider

### regime_mat
1 : monogame

2 : polygame

### sexe
1 : homme

2 : femme

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

### regime
1 : general

2 : cadre

3 : employe_de_maison

### zone
1 : senegal

2 : afrique

3 : europe

## Salarie (salaries)
### etat
1 : deces

### sexe
0 : homme

1 : femme

## Admin::Agence (admin_agences)
### type_agence
81 : ipres

82 : css

## Admin::Bareme (admin_baremes)
### periode
1 : mensuelle

2 : annuelle

## Admin::CafBareme (admin_caf_baremes)
### periode
1 : mensuelle

2 : annuelle

## Admin::ComptaNaturePrestation (admin_compta_nature_prestations)
### entite
1 : ipres

2 : css

### branche
1 : ve

2 : pf

3 : at

## Admin::Gesadm (admin_gesadms)
### sexe
0 : homme

1 : femme

### nation
1 : senegalais

2 : etranger

## Admin::Mandataire (admin_mandataires)
### sexe
1 : homme

2 : femme

## Admin::MontantMensualiteVolet (admin_montant_mensualite_volets)
### num_volet
1 : volet1

2 : volet2

3 : volet3

4 : volet4

5 : volet5

6 : volet6

7 : volet7

8 : volet8

## AllocataireCnav (allocataire_cnavs)
### etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

6 : valide_liquidation

7 : rejete_liquidation

8 : valide_inspection

9 : rejete_inspection

### delta
1 : nouveau

2 : ancien

3 : supprime

### mode_paiement
1 : mandant_postal

2 : virement

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

8 : carte_prepaye

9 : paiement_a_domicile

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

## AllocatairePf (allocataire_pfs)
### regime_matrimoniale
1 : monogame

2 : polygame

### sexe
1 : homme

2 : femme

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

## AllocationFamiliale (allocation_familiales)
### etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

6 : suspendu

7 : echu

### trimestre
1 : trimestre1

2 : trimestre2

3 : trimestre3

4 : trimestre4

### motif_rejet
1 : motif1

2 : motif2

3 : motif3

## AllocationPostnatale (allocation_postnatales)
### etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

### volet
4 : volet4

5 : volet5

6 : volet6

7 : volet7

8 : volet8

## AllocationPrenatale (allocation_prenatales)
### etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

### volet
1 : volet1

2 : volet2

3 : volet3

## ArretTravail (arret_travails)
### etat
1 : instruction

2 : accepte

3 : rejete

4 : gueris

5 : rechute

6 : decede

### situation_matrimoniale_salarie
1 : marie

2 : divorce

3 : celibataire

4 : veuf

### nationalite_salarie
1 : senegalais

2 : etranger

### type_de_contrat_travail_salarie
1 : permanent

2 : journalier

3 : saisonier

4 : autres_cdd

### qualification_professionnelle_salarie
1 : cadre

2 : technicien

3 : agent_de_maitrise

4 : employes

5 : apprentis

6 : manoeuvres

7 : ouvriers_specialises

8 : ouvrier_qualifie

9 : divers

### agent_materiel
1 : accident_de_plein_pied

2 : chute_dun_niveau

3 : objets_en_cours_de_manutention_manuelle

4 : objets_ou_masse_en_mouvement

5 : particules_ou_petits_elements_de_matieres

6 : appareils_de_levage_amarrage_prehension

7 : vehicule

8 : machine_productrice_transformation_energie

9 : organe_transmission

10 : machine_transmission

11 : machine_a_broyer_concasser_pulveriser_diviser

12 : machine_a_malaxer_melanger

13 : machine_a_cribler_tamiser_separer

14 : presses_mecaniques_pilons

15 : machine_a_presser_mouler_injecter

### nature_accident
1 : nouveau_accident

### sexe
1 : homme

2 : femme

### type_de_piece
1 : cni

2 : carte_cedeao

3 : carte_consulaire

4 : passeport

5 : extrait_de_naissance

### type_declaration
1 : accident_travail

2 : accident_trajet

### consequence_accident_travail
1 : arret_travail

2 : deces

3 : sans_arret_travail

### incapacite_permanente
1 : partielle

2 : totale

### declarant
1 : ayant_droit

2 : employeur

3 : salarie

## AscendantsSalarie (ascendants_salaries)
### type_piece_pere
1 : extrait_naissance_p

2 : cni_p

### type_piece_mere
1 : extrait_naissance_m

2 : cni_m

## AtAvi (at_avis)
### avis
1 : favorable

2 : defavorable

3 : complement_information

## AtDecompte (at_decomptes)
### etat
1 : creation

2 : liquide

3 : valide

4 : validation_medecin

5 : validation_comptable

6 : rejete

## AtDocument (at_documents)
### type_document
15 : certificat_guerison

53 : bulletin_de_salaire

## AtDossierReversionRente (at_dossier_reversion_rentes)
### etat
0 : creation

1 : soumis

2 : valide

3 : rejete

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

### type_ayant_droit
1 : veuve

2 : orphelin

3 : pere

4 : mere

## AtFraisEngage (at_frais_engages)
### etat
1 : creation

2 : liquide

3 : valide

4 : validation_comptable

5 : validation_medecin

6 : rejete

### type_frais
1 : medecin

2 : hopitaux

3 : pharmacien

4 : autre_fournisseurs

5 : divers

6 : soins_medicaux

7 : hospitalisation

8 : frais_phamaceutiques

9 : frais_de_transport

10 : prothese

11 : frais_funeraire

12 : autres

### rembourse_a_qui
1 : victime

2 : employeur

## AtIncapacite (at_incapacites)
### etat
1 : creation

2 : liquidation

3 : validation

4 : validation_compatable

5 : validation_medecin

## AtLesion (at_lesions)
### nature_lesion
1 : non_precise

2 : fracture

3 : brulure

4 : gelure

5 : amputation

6 : plaie

7 : inflamation

8 : contusion

9 : entorse

10 : luxation

11 : asphyxie

12 : commotion

13 : corps_etranger

14 : fibrillation_coeur

15 : hernies

16 : lumbago

17 : paralyse

18 : noyade

19 : ecrasement_partie_corps

20 : poly_traumatisme

21 : cecite

22 : perte_partille_vision

23 : lombalgies_residuelles

24 : traumatismes

25 : dermatose_professionnelle

26 : raideur

27 : douleurs

28 : electrocution

29 : congestions

30 : hemoragie

31 : crush_syndrome

32 : tetanos

33 : surdite

34 : hepatite_virale

### siege_lesion
1 : non_precise

2 : tete

3 : yeux

4 : membres_superieurs

5 : membres_inferieurs

6 : main

7 : tronc

8 : pieds

9 : localisations_multiples

10 : sieges_internes

11 : systeme_nerveux

12 : bras_droit

13 : bras_gauche

14 : maxillaire

15 : visceres

16 : oreille

## AtRechute (at_rechutes)
### avis
favorable : favorable

défavorable : defavorable

## AtRenteFamille (at_rente_familles)
### type_ayant_droit
1 : veuve

2 : orphelin

3 : ascendant

## AtSalaire (at_salaires)
### mois
1 : JANVIER

2 : FEVRIER

3 : MARS

4 : AVRIL

5 : MAI

6 : JUIN

7 : JUILLET

8 : AOUT

9 : SEPTEMBRE

10 : OCTOBRE

11 : NOVEMBRE

12 : DECEMBRE

## Attestation (attestations)
### etat
1 : creation

2 : soumis

3 : valide

## AvisTier (avis_tiers)
### etat
1 : creation

2 : validation

3 : validation_directeur

4 : rejeter

5 : suspendu

### type_operation
1 : revision_base_veuve

2 : revision_pension_impaye

3 : avance_tabaski

4 : avance_korite

5 : pret_bancaire

6 : autre

## AvocatsHuissier (avocats_huissiers)
### type_intervenant
0 : avocat

1 : huissier

## BaseReversionSalary (base_reversion_salaries)
### sexe
1 : homme

2 : femme

### motif_not_completed
1 : en_attente_numerisation

2 : ouvert_en_cip

3 : en_attente_documents_obligatoires

4 : declarations_manquantes

## BordereauCollectif (bordereau_collectifs)
### bordereau_type
1 : normal

0 : complementaire

## CafConjoint (caf_conjoints)
### etat_couple
1 : marie

2 : divorce

3 : decede

### sexe
1 : homme

2 : femme

### type_piece
1 : cni

2 : carte_consulaire

3 : passeport

## CafEnfant (caf_enfants)
### lien_parente
1 : mariage

2 : adulterin

3 : naturel

4 : adoption

### type_piece
1 : cni

2 : extrait_naisance

## Caisse::Paiement (caisse_paiements)
### etat
1 : attente_paiement

2 : paye

3 : decede

### source
1 : prestation

2 : cnav

3 : retour_impaye_poste

100 : autre

### periode
1 : mensuelle

2 : bimestrielle

3 : trimestrielle

4 : immediate

5 : annuelle

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

## Carriere (carrieres)
### etat
0 : en_attente

1 : valide

2 : rejete

3 : a_rembourse

## CarriereDossierMaternite (carriere_dossier_maternites)
### trimestre
1 : trimestre1

2 : trimestre2

3 : trimestre3

4 : trimestre4

## CarriereDossierPrestation (carriere_dossier_prestations)
### allocation_etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

6 : suspendu

7 : echu

### trimestre
1 : trimestre1

2 : trimestre2

3 : trimestre3

4 : trimestre4

## CarrieresExterieure (carrieres_exterieures)
### etat
0 : en_attente

1 : valide

2 : rejete

3 : a_rembourse

## CarrieresPrestExterieure (carrieres_prest_exterieures)
### etat
0 : en_attente

1 : valide

2 : rejete

3 : a_rembourse

## ComptaTransaction (compta_transactions)
### statut
-1 : en_attente_validation

0 : en_cours

1 : paye

2 : marque_impaye

3 : impaye

4 : regularise

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

### zone
1 : senegal

2 : afrique

3 : europe

## Conjoint (conjoints)
### etat
1 : creation

2 : valide

3 : rejete

4 : deces

5 : divorce

6 : soumis

### etat_civil
0 : marie

1 : celibataire

### sex
0 : homme

1 : femme

### type_piece
1 : cni

2 : carte_consulaire

3 : passeport

4 : extrait_naissance

5 : autre

### etat_conjoint
1 : union

2 : divorcer

3 : deceder

### regime_matrimoniale
1 : monogame

2 : polygame

### rang_conjoint
1 : premiere

2 : deuxieme

3 : troisieme

4 : quatrieme

## DecesEnfant (deces_enfants)
### type_piece
1 : certificat_deces

## Declaration (declarations)
### statut
1 : creation

2 : soumis

3 : manquante

4 : valide

## DeclarationChargement (declaration_chargements)
### statut
0 : creation

1 : fichier_invalide

2 : fichier_valide

3 : valide

4 : rejete

### regime
1 : general

2 : cadre

3 : employe_de_maison

## DeclarationDivorceOuDecesConjoint (declaration_divorce_ou_deces_conjoints)
### type_piece
1 : certificat_divorce

2 : certificat_deces

### status_with_conjoint
1 : divorcer

2 : deceder

## DeclarationSalaireManquante (declaration_salaire_manquantes)
### statut
0 : manquante

1 : en_cours

2 : chargee

### regime
1 : general

2 : cadre

3 : employe_de_maison

## DemandeRemboursementCotisation (demande_remboursement_cotisations)
### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

### motif_remboursement
1 : surplus_cotisations_encaissees

2 : quitter_definitivement_pays

3 : cotisation_au_dela_60_ans

4 : cotisation_au_dela_55_ans

## DemandeurReversion (demandeur_reversions)
### etat
0 : en_attente

1 : soumis

2 : valide

3 : rejete

### type_ayant_droit
1 : veuve

2 : orphelin

## Document (documents)
### type_document
1 : cni

2 : extrait_naissance

3 : attestation_travail

4 : certificat_mariage

5 : certificat_divorce

6 : cni_epouse

7 : extrait_naissance_epouse

8 : passeport

9 : carte_consulaire

10 : rib

11 : certificat_deces

12 : certificat_travail

13 : certificat_emploi_salaire

14 : certificat_non_divorce

15 : certificat_non_remariage

16 : extrait_naissance_defunt

17 : copie_cni_legalise

18 : attestation_non_engagement

19 : certificat_medical

20 : declaration_sur_honneur

21 : copie_cni

22 : acte_etat_civil_jug_supp_veuve

23 : jug_here_cert_non_opp_non_app

24 : carte_identite_tuteur

25 : certificat_tutelle

26 : autorisation_sortir_pays

27 : certif_empl_sal

28 : demande_conges

29 : certificat_medicale_gross

30 : attestation_susp_act

31 : last_bul_salaire

32 : attestation_cess_paie

33 : attestation_salaire

34 : attestation_maintien_salaire

35 : certif_conges_maternite

36 : certificat_scolarite

37 : cni_attributaire

38 : passeport_attributaire

39 : carte_consulaire_attributaire

40 : type_piece_attributaire

41 : type_piece_demandeur

42 : certificat_medical_consolidation

43 : rapport_evaluation_medecin

44 : pv_enquete

45 : bulletin_salaire_precedent_accident

46 : bulletin_de_salaire_journalier

48 : contrat_travail

49 : rapport_de_mer

50 : demande_extension_garantie

51 : relation_ecrite_temoin

53 : bulletin_de_salaire

54 : ordre_de_mission

56 : pv_police_gendarmerie

57 : rapport_sortie_sapeurs_pompiers

58 : pv_huissiers

59 : certificat_genre_de_mort

60 : certificat_guerison

62 : certificat_vie_individuelle

63 : demande_reversion_orphelin

64 : demande_reversion_veuve

65 : extraits_naissance_enfant

66 : certificat_infirmite

67 : certificat_apprentissage

68 : formulaire_convention_france_senegal_CFS

69 : certificat_de_domile

70 : certificat_de_residence

71 : certificat_medical_genre_de_mort

72 : cni_extrait

73 : formulaire_declaration_at

74 : relation_ecrite_premiere_avisee

75 : questionnaire_trajet

76 : acte_naissance_enf_moins_21

77 : certificat_vie_collective_enf_moins_21

78 : formulaire_demande_pension

79 : certificat_medicale

80 : protocole_accord_branche

81 : certificat_vie_collectif

82 : certificat_charge_entretien

83 : attestation_administrative

84 : decision_engagement

85 : decision_radiation

86 : cni_extrait_enfant

87 : cni_extrait_ascendant

88 : accord_sur_ipp

88 : releve_navigation

89 : tableau_indicatif_marin

90 : formulaire_demande

91 : carte_identite_defunt

92 : justificatif_reversion

93 : actes_deces_coepouse

94 : certificat_travail_prolongation

95 : certificat_travail_rechute

96 : contre_expertise

97 : procuration_legalisee

98 : bulletin_salaire_precedent_rechute

99 : dmt

100 : formulaire_demande_pf

101 : certificat_jugement_heredite

1000 : autres

## DocumentAllocatFamiliale (document_allocat_familiales)
### type_document
1 : certificat_medicale

2 : certificat_scolarite

3 : certificat_infirmite

4 : certificat_apprentissage

## DocumentDossierMaternite (document_dossier_maternites)
### type_document
1 : cni

2 : demande_conges

3 : attestation_travail

4 : attestation_susp_act

5 : certificat_medicale_gross

6 : last_bul_salaire

## DocumentDossierPrestation (document_dossier_prestations)
### type_document
1 : cni

2 : extrait_naissance

3 : certificat_mariage

4 : certificat_divorce

5 : cni_epouse

6 : extrait_naissance_epouse

## DocumentGrappePrestation (document_grappe_prestations)
### type_document
1 : certificat_deces

2 : certificat_divorce

## DocumentImmatriculation (document_immatriculations)
### type_document
1 : declaration_etablissement

2 : avis_immatriculation

3 : registre_commerce

4 : copie_cin_employeur

5 : contrats_travail

6 : copie_piece_employe

## DocumentLiquidationRetraite (document_liquidation_retraites)
### type_document
1 : cni

2 : attestation_travail

3 : certificat_mariage

4 : certificat_medical

7 : passeport

8 : carte_consulaire

9 : rib

10 : certif_empl_sal

11 : procuration_depot_dossier

12 : protocole_accord_branche

## DocumentPrestationExterieure (document_prestation_exterieures)
### type_document
1 : piece

2 : attestation_travail

## DossierCnav (dossier_cnavs)
### etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

6 : suspendu

7 : cloture

8 : valide_liquidation

9 : rejete_liquidation

10 : valide_inspection

11 : rejete_inspection

### mois
1 : janvier

2 : fevrier

3 : mars

4 : avril

5 : mai

6 : juin

7 : juillet

8 : aout

9 : septembre

10 : octobre

11 : novembre

12 : decembre

## DossierJuridiqueActe (dossier_juridique_actes)
### type_act
0 : audience

1 : seance

## DossierJuridiqueHonoraire (dossier_juridique_honoraires)
### type_intervenant
0 : avocat

1 : huissier

## DossierMaternite (dossier_maternites)
### etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

6 : suspendu

7 : cloture

### sexe_salarie
1 : masculin

2 : feminin

### type_piece
1 : cni_tp

2 : passport

3 : cc

### nombre_part_impot
1 : un

2 : un_cinq

3 : deux

4 : deux_cinq

5 : trois

6 : trois_cinq

7 : quatre

8 : quatre_cinq

9 : cinq

### part_trimf
1 : un_trimf

2 : deux_trimf

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

## DossierPrestation (dossier_prestations)
### nationalite
1 : senegalais

2 : etranger

### sexe_salarie
1 : masculin

2 : feminin

## DossierReversionSalary (dossier_reversion_salaries)
### etat
0 : creation

1 : complete

2 : soumis

3 : recap_soumis

4 : recap_valide

5 : valide

6 : rejete

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

### type_ayant_droit
1 : veuve

2 : orphelin

## EcheancePaiement (echeance_paiements)
### periode
1 : mensuelle

2 : bimestrielle

3 : trimestrielle

4 : immediate

## Enfant (enfants)
### etat
1 : creation

2 : valide

3 : rejete

4 : deces

5 : soumis

### sexe
1 : masculin

2 : feminin

### origine_enfant
1 : mariage

3 : naturel

4 : adoption

2 : adulterin

### type_piece
1 : extrait_naissance

2 : cni

3 : autre

## ExtinctionAllocataire (extinction_allocataires)
### etat
1 : creation

2 : soumis

3 : affecte

4 : valide

5 : rejete

## Facture (factures)
### statut
0 : ouverte

1 : fermee

## Grossesse (grossesses)
### etat
1 : valide

2 : avortement

3 : fausse_couche

## Historique (historiques)
### etat
1 : valide

2 : soumis

3 : suspendus

4 : lever_suspension

5 : affecte

6 : rejete

7 : regularise

## IcmModifierInfoPersonnelle (icm_modifier_info_personnelles)
### etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

### sexe_salarie
1 : masculin

2 : feminin

### type_piece
1 : cni_tp

2 : passport

3 : cc

## Immatriculation (immatriculation_societes)
### type_etablissement
1 : hdqt

2 : brnc

3 : cnst

### type_immatriculation
1 : bvoln

2 : cmpl

### etat
1 : creation

2 : soumis

3 : valide

### type_pieces
1 : cdao

2 : nin

3 : pass

4 : conc

### statut_demande
1 : adm

2 : acfie

3 : acfis

4 : avfie

5 : aviecacss

6 : avfiecaipres

7 : iesv

8 : pending

9 : autre

## ImmatriculationSocietePrive (immatriculation_societe_prives)
### type_etablissement
1 : hdqt

2 : brnc

3 : cnst

### type_immatriculation
1 : bvoln

2 : cmpl

### etat
1 : creation

2 : soumis

### type_pieces
1 : cdao

2 : nin

3 : pass

4 : conc

## IndemniteCongesMaternite (indemnite_conges_maternites)
### etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

### tranche_paiement
1 : avant_acouchement

2 : apres_acouchement

3 : apres_reprise

4 : tranche_prolongation

### lieu_accouchement
1 : senegal

2 : hors_senegal

## LiquidationRetraite (liquidation_retraites)
### type_retraite
1 : retraite_normale

2 : retraite_anticipee_valide

3 : retraite_anticipee_invalide

5 : accords_branche_55

6 : accords_branche_56

7 : accords_branche_57

8 : accords_branche_58

9 : accords_branche_59

10 : regime_employes_maison

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

### zone
1 : senegal

2 : afrique

3 : europe

### motif_not_completed
1 : en_attente_numerisation

2 : ouvert_en_cip

3 : en_attente_documents_obligatoires

4 : declarations_manquantes

### sexe
1 : homme

2 : femme

## MaintienPrestation (maintien_prestations)
### etat
1 : actif

0 : inactif

### type_maintien
1 : chomage

2 : deces

## MaladieProfessionnelle (maladie_professionnelles)
### etat
1 : a_soumettre

2 : en_instruction

3 : accepte

4 : rejete

5 : en_attente_information

### situation_matrimoniale_salarie
1 : marie

2 : divorce

3 : celibataire

4 : veuf

### nationalite_salarie
1 : senegalais

2 : etranger

### type_de_contrat_travail_salarie
1 : permanent

2 : journalier

3 : saisonier

4 : autres_cdd

### qualification_professionnelle_salarie
1 : cadre

2 : technicien

3 : agent_de_maitrise

4 : employes

5 : apprentis

6 : manoeuvres

7 : ouvriers_specialises

8 : ouvrier_qualifie

9 : divers

## MissingDeclaration (missing_declarations)
### etat
1 : creation

2 : soumis

3 : manquante

4 : valide

## MissingLigneDeclaration (missing_ligne_declarations)
### etat
1 : creation

2 : soumis

3 : rejeter

4 : valide

### motif_sortie
0 : aucun

1 : deces

3 : licenciement_demission

4 : retraite

8 : mutation

### sexe
1 : homme

2 : femme

## ModifierAdresse (modifier_adresses)
### etat
1 : creation

2 : soumis

3 : affecte

4 : valide

5 : rejete

## ModifierModePaiement (modifier_mode_paiements)
### etat
1 : creation

2 : soumis

3 : affecte

4 : valide

5 : rejete

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

### motif_virement
1 : mise_en_place_virement

2 : changement_de_banque

3 : changement_de_compte

### attachment
1 : cni

10 : rib

18 : attestation_non_engagement

19 : certificat_medical

90 : formulaire_demande

## Moratoire (moratoires)
### statut
0 : soumise

1 : validee

2 : annulee

## MpDocument (mp_documents)
### type_document
1 : certificat_medical

2 : cni

3 : contrat_travail

## OrdrePaiement (ordre_paiements)
### statut
-1 : en_attente_validation

0 : en_cours

1 : paye

2 : impaye

3 : regularise

4 : marque_impaye

## Paiement (paiements)
### mode_paiement
1 : om

2 : wari

3 : espece

4 : cheque

5 : virement

6 : prelevement

## PaiementAllocataire (paiement_allocataires)
### etat
0 : en_attente_paiement

1 : paye

2 : rejete

3 : retourne

10 : en_attente_validation_instruction

### periode
1 : mensuelle

2 : bimestrielle

3 : trimestrielle

4 : immediate

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

### categorie
1 : retraite

6 : veuve

8 : orphelin

19 : pension_alimentaire

2 : coordination

3 : vtr

4 : allocation_solidarite

5 : fonds_social

7 : remboursement_cotisation

9 : veuve_administration

10 : rente_administration

11 : test_interne

12 : rente_viagere

13 : asj

### type_paiement
## PensionAlimentaire (pension_alimentaires)
### etat
1 : creation

2 : validation_chef_service

3 : validation_directeur

4 : rejeter

## PrestationExtFrance (prestation_ext_frances)
### type_retraite
1 : retraite_normale

2 : retraite_anticipee_valide

3 : retraite_anticipee_invalide

### sexe_salarie
1 : masculin

2 : feminin

### nature
1 : retraite

2 : reversion

### sens_convention
1 : resident_sn

2 : resident_fr

### situation_familiale
1 : celibataire

2 : marie

3 : veuf

4 : divorce

5 : remarie

6 : separe_de_corps

7 : separe_de_fait

### type_piece
1 : cni

2 : carte_consulaire

3 : passeport

4 : extrait_naissance

### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

## PrestationExterieure (prestation_exterieures)
### etat
1 : creation

2 : valide

### state
initialisation : init

soumission_etat_chef_grp : soumis

dossier_valide : validation

dossier_rejete : rejet

dossier_suspendu : suspension

### situation_matrimoniale_salarie
1 : marie

2 : divorce

3 : celibataire

4 : veuf

### nationalite_salarie
1 : senegalais

2 : etranger

### sexe_salarie
1 : homme

2 : femme

### type_piece
1 : cni

2 : carte_consulaire

3 : passeport

### type_retraite
1 : retraite_normale

2 : retraite_anticipee_valide

3 : retraite_anticipee_invalide

## PretAllocataire (pret_allocataires)
### etat
1 : creation

2 : valider

3 : rejeter

4 : traite

### type_pret
1 : avance_tabaski

## PretAllocataireLigne (pret_allocataire_lignes)
### regime
1 : general

2 : cadre

3 : employe_de_maison

## RegularisationImpaye (regularisation_impayes)
### periode
1 : mensuelle

2 : bimestrielle

3 : trimestrielle

4 : immediate

### etat
0 : en_attente

1 : rejete

2 : valide

4 : regularise

## RegularisationPension (regularisation_pensions)
### motif_regularisation_pension
1 : annulation_de_suspension

2 : reordonnancement_de_pension

3 : regularisation_pour_les_majorants

4 : annulation_de_suspension_avec_rappel

5 : autre_motif

6 : pension_heredite

### etat
1 : creation

2 : soumis

3 : affecte

4 : valide

5 : regularise

6 : rejete

7 : annuler

## RemboursementCotisation (remboursement_cotisations)
### etat
0 : en_attente

1 : soumis

2 : valide

3 : rejete

## Rentier (rentiers)
### etat
0 : inactif

1 : en_attente_activation

2 : actif

3 : suspendus

4 : rejete

5 : eteint

### sexe
1 : homme

2 : femme

## RepresentantLegal (representant_legals)
### type_of_identity
0 : cdao

1 : nin

2 : pass

3 : conc

4 : autre

## RevaloriserPension (revaloriser_pensions)
### type
1 : a_ajouter

2 : a_enlever

### type_revalorisation
1 : pret

2 : retenu

3 : remboursement

4 : avis_tiers

5 : pension_alimentaire

## ReversionVeuve (reversion_veuves)
### mode_paiement
1 : mandant_postal

2 : virement

3 : wari

4 : caisse_ipres

5 : post_finance

6 : mise_a_disposition_bancaire

7 : paiement_departemental

8 : carte_prepaye

9 : paiement_a_domicile

10 : cheque

11 : caisse_css

12 : orange_money

13 : wave

14 : paiement_hors_convention

100 : autres

### type_ayant_droit
1 : veuve

2 : orphelin

## RevisionPension (revision_pensions)
### type_motif
1 : justification_carriere

2 : integration_carriere

3 : justification_integration

## SalarieImmatriculation (salarie_immatriculations)
### etat
1 : actif

2 : retrait

### temps_travail
1 : tps_plein

2 : tps_partiel

### sexe
1 : homme

2 : femme

### type_piece
1 : cdao

2 : nin

3 : pass

### etat_civil
0 : cel

1 : div

2 : mar

3 : veu

### nature_contrat
0 : spe

1 : sta

2 : cdd

3 : cdi

4 : jou

## SuspensionAllocataire (suspension_allocataires)
### etat
1 : creation

2 : soumis

3 : affecte

4 : valide

5 : rejete

## TraitementCollectif (traitement_collectifs)
### allocation_etat
1 : creation

2 : soumis

3 : traitement_en_cours

4 : valide

5 : rejete

6 : suspendu

7 : echu

## UpdateGrappeFamiliale (update_grappe_familiales)
### etat
2 : soumis

3 : affecte

4 : valide

5 : rejete

### type_demande
1 : deces

2 : divorce

## Psrm::Reglement (XX_REGLEMENT_NAP)
### CODE_TYPE_REGLEMENT
0 : versement

1 : avance

2 : solde