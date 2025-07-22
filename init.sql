CREATE USER ipres WITH PASSWORD 'passer';
ALTER USER ipres WITH SUPERUSER;
CREATE DATABASE prestation_docker_test;
GRANT ALL PRIVILEGES ON DATABASE prestation_docker_test TO ipres;


----


BEGIN;

DROP TRIGGER compta_transactions_insert_trigger ON compta_transactions;

alter table compta_transactions rename to compta_transactions_legacy;

alter index compta_transactions_numero_allocataire_idx rename to compta_transactions_numero_allocataire_idx_legacy;
alter index compta_transactions_send_to_compta_idx rename to compta_transactions_send_to_compta_idx_legacy;
alter index index_compta_transactions_on_admin_agence_id rename to index_compta_transactions_on_admin_agence_id_legacy;
alter index index_compta_transactions_on_admin_region_id rename to index_compta_transactions_on_admin_region_id_legacy;
alter index index_compta_transactions_on_dr_type_and_dr_id rename to index_compta_transactions_on_dr_type_and_dr_id_legacy;
alter index index_compta_transactions_on_echeance_paiement_id rename to index_compta_transactions_on_echeance_paiement_id_legacy;
alter index index_compta_transactions_on_id_reprise rename to index_compta_transactions_on_id_reprise_legacy;
alter index index_compta_transactions_on_ordre_paiement_id rename to index_compta_transactions_on_ordre_paiement_id_legacy;

CREATE TABLE compta_transactions (
                                     id bigserial NOT NULL,
                                     dossier_type varchar NULL,
                                     dossier_id int8 NULL,
                                     code_operation varchar NOT NULL,
                                     code_classe_evenement varchar NOT NULL DEFAULT 'LIQUIDATION'::character varying,
                                     code_agence_liquidation varchar NULL,
                                     numero_allocataire varchar NOT NULL,
                                     nom varchar NULL,
                                     prenom varchar NULL,
                                     adresse varchar NULL,
                                     code_banque_allocataire varchar NULL,
                                     numero_compte_allocataire varchar NULL,
                                     date_debut_periode date NULL,
                                     date_fin_periode date NULL,
                                     montant float8 NOT NULL,
                                     code_devise varchar(3) NOT NULL DEFAULT 'XOF'::character varying,
                                     statut int4 NOT NULL DEFAULT 0,
                                     created_at timestamp NOT NULL,
                                     updated_at timestamp NOT NULL,
                                     mode_paiement int4 NULL,
                                     send_to_compta bool NOT NULL DEFAULT false,
                                     bank_id varchar NULL,
                                     bank_branch_id varchar NULL,
                                     ordre_paiement_id int8 NULL,
                                     description varchar NULL,
                                     can_send_to_compta bool NOT NULL DEFAULT true,
                                     send_to_compta_at timestamp NULL,
                                     echeance_paiement_id int8 NULL,
                                     "zone" int4 NULL,
                                     admin_region_id int8 NULL,
                                     admin_agence_id int8 NULL,
                                     nin_allocataire varchar NULL,
                                     telephone_allocataire varchar NULL,
                                     mail_allocataire varchar NULL,
                                     date_comptable timestamp NULL,
                                     en_tete bool NOT NULL DEFAULT true,
                                     est_repris bool NOT NULL DEFAULT false,
                                     id_reprise int4 NULL,
                                     infos_paiement_id_bhs varchar(30) NULL,
                                     infos_paiement_id_ccp varchar(30) NULL,
                                     infos_paiement_libelle_ccp varchar(30) NULL,
                                     infos_paiement_succursale_cncas varchar(30) NULL,
                                     est_attributaire bool NOT NULL DEFAULT false,
                                     par_subrogation bool NOT NULL DEFAULT false,
                                     id_reel_allocataire varchar NULL,
                                     nom_reel_allocataire varchar NULL,
                                     prenom_reel_allocataire varchar NULL,
                                     CONSTRAINT compta_transactions_pkey1 PRIMARY KEY (id, date_comptable),
                                     CONSTRAINT fk_rails_426635d195 FOREIGN KEY (admin_region_id) REFERENCES public.admin_regions(id),
                                     CONSTRAINT fk_rails_abc2b53895 FOREIGN KEY (admin_agence_id) REFERENCES public.admin_agences(id),
                                     CONSTRAINT fk_rails_d464791343 FOREIGN KEY (echeance_paiement_id) REFERENCES public.echeance_paiements(id)
) partition by range(date_comptable);

CREATE INDEX compta_transactions_numero_allocataire_idx ON compta_transactions USING btree (numero_allocataire);
CREATE INDEX compta_transactions_send_to_compta_idx ON compta_transactions USING btree (send_to_compta);
CREATE INDEX index_compta_transactions_on_admin_agence_id ON compta_transactions USING btree (admin_agence_id);
CREATE INDEX index_compta_transactions_on_admin_region_id ON compta_transactions USING btree (admin_region_id);
CREATE INDEX index_compta_transactions_on_dr_type_and_dr_id ON compta_transactions USING btree (dossier_type, dossier_id);
CREATE INDEX index_compta_transactions_on_echeance_paiement_id ON compta_transactions USING btree (echeance_paiement_id);
CREATE INDEX index_compta_transactions_on_id_reprise ON compta_transactions USING btree (id_reprise);
CREATE INDEX index_compta_transactions_on_ordre_paiement_id ON compta_transactions USING btree (ordre_paiement_id);

create trigger compta_transactions_insert_trigger after
    insert
    on
        compta_transactions for each row execute function update_arrondi_allocataire_trigger_fnc();

create table compta_transactions_2022 partition of compta_transactions for values from ('2022-01-01') to ('2023-01-01');
create table compta_transactions_2021 partition of compta_transactions for values from ('2021-01-01') to ('2022-01-01');
create table compta_transactions_2020 partition of compta_transactions for values from ('2020-01-01') to ('2021-01-01');
create table compta_transactions_2019 partition of compta_transactions for values from ('2019-01-01') to ('2020-01-01');
create table compta_transactions_2018 partition of compta_transactions for values from ('2018-01-01') to ('2019-01-01');
create table compta_transactions_2017 partition of compta_transactions for values from ('2017-01-01') to ('2018-01-01');
create table compta_transactions_2016 partition of compta_transactions for values from ('2016-01-01') to ('2017-01-01');
create table compta_transactions_2015 partition of compta_transactions for values from ('2015-01-01') to ('2016-01-01');

COMMIT;

---------------

BEGIN;

DROP TRIGGER compta_transactions_insert_trigger ON compta_transactions;

-- with rows as (
--     delete from compta_transactions_legacy d
--     where (date_comptable >= '2022-01-01' and date_comptable < '2023-01-01')
--     returning d.*)
insert into compta_transactions (select * from compta_transactions_legacy);

create trigger compta_transactions_insert_trigger after
    insert
    on
        compta_transactions for each row execute function update_arrondi_allocataire_trigger_fnc();

ALTER SEQUENCE compta_transactions_id_seq1
    RESTART 11915029;

COMMIT;


---------------

create table if not exists xxipres_css_op_det
(
    legal_entity_id           integer,
    entity_id                 integer,
    event_id                  integer,
    code_type_ligne_operation varchar(100),
    desc_ligne_paiement       varchar(200),
    montant_ligne             integer,
    attribute1                varchar(150),
    attribute2                varchar(150),
    attribute3                varchar(150),
    attribute4                varchar(150),
    attribute5                varchar(150),
    attribute6                varchar(150),
    attribute7                varchar(150),
    attribute8                varchar(150),
    attribute9                varchar(150),
    attribute10               varchar(150),
    attribute11               varchar(150),
    attribute12               varchar(150),
    attribute13               varchar(150),
    attribute14               varchar(150),
    attribute15               varchar(150),
    creation_date             date,
    created_by                integer,
    last_update_date          varchar(100),
    last_updated_by           integer,
    last_update_login         integer
    );

alter table xxipres_css_op_det
    owner to postgres;

create unique index if not exists xxdetl170
    on xxipres_css_op_det (event_id);

create table if not exists xxipres_css_op_ent
(
    legal_entity_id            integer,
    entity_id                  integer,
    code_type_evenement        varchar(100),
    date_evenement             date,
    security_id_int_1          varchar(100),
    ledger_id                  integer,
    id_allocataire             varchar(100),
    nom_allocataire            varchar(200),
    pnom_allocataire           varchar(200),
    adresse_allocataire        varchar(200),
    adresse_rue                varchar(200),
    adrese_ville               varchar(200),
    pays                       varchar(100),
    region                     varchar(100),
    montant_op                 double precision,
    mode_de_paiement           varchar(100),
    code_banque                varchar(100),
    code_agence                varchar(100),
    numero_compte_alloc        varchar(100),
    zone_de_paiement           varchar(100),
    code_agence_paiement       varchar(100),
    code_caisse_paiement       varchar(100),
    numero_ordre_paiement      varchar(100),
    desc_ord_paiement          varchar(100),
    nin                        varchar(100),
    num_tel                    varchar(100),
    email                      varchar(100),
    categ_allocataire          varchar(100),
    num_echeance               varchar(100),
    code_statut_transaction    varchar(100),
    code_processus_transaction varchar(100),
    branche_liq                varchar(100),
    attribute1                 varchar(150),
    attribute2                 varchar(150),
    attribute3                 varchar(150),
    attribute4                 varchar(150),
    attribute5                 varchar(150),
    attribute6                 varchar(150),
    attribute7                 varchar(150),
    attribute8                 varchar(150),
    attribute9                 varchar(150),
    attribute10                varchar(150),
    attribute11                varchar(150),
    attribute12                varchar(150),
    attribute13                varchar(150),
    attribute14                varchar(150),
    attribute15                varchar(150),
    creation_date              date,
    created_by                 integer,
    last_update_date           date,
    last_updated_by            integer,
    last_update_login          integer
    );

alter table xxipres_css_op_ent
    owner to postgres;

create index if not exists iopcss
    on xxipres_css_op_ent (legal_entity_id, creation_date, security_id_int_1);

create unique index if not exists xxentl150
    on xxipres_css_op_ent (legal_entity_id, entity_id);

create unique index if not exists xxentl160
    on xxipres_css_op_ent (entity_id);

create unique index if not exists xxentl170
    on xxipres_css_op_ent (numero_ordre_paiement);

----------------

