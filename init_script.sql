CREATE
    OR REPLACE FUNCTION update_arrondi_allocataire_trigger_fnc()
    RETURNS trigger AS
$$
DECLARE
    arrondi float;
    montant_total float;
BEGIN
    IF NEW.est_repris or NEW.echeance_paiement_id IS NULL or NEW.code_operation <> 'I_EAC' THEN
        RETURN NEW;
    end if;
    BEGIN
        SELECT arrondi_en_cours
        INTO STRICT arrondi
        FROM allocataires
        WHERE allocataires.numero_allocataire = NEW.numero_allocataire;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NEW;
        WHEN TOO_MANY_ROWS THEN
            RETURN NEW;
    END;

    SELECT SUM(montant) INTO STRICT montant_total
    FROM compta_transactions WHERE ordre_paiement_id = NEW.ordre_paiement_id;

    UPDATE compta_transactions
    set montant = NEW.montant - (montant_total - floor((montant_total + arrondi) / 500) * 500)  -- floor((NEW.montant + arrondi) / 500) * 500
    WHERE id = NEW.id;

    UPDATE allocataires
    SET old_arrondi_en_cours = arrondi_en_cours,
        arrondi_en_cours = montant_total + arrondi - floor((montant_total + arrondi) / 500) * 500
    WHERE allocataires.numero_allocataire = NEW.numero_allocataire;

    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';


CREATE TRIGGER compta_transactions_insert_trigger
    AFTER INSERT
    ON compta_transactions
    FOR EACH ROW
EXECUTE PROCEDURE update_arrondi_allocataire_trigger_fnc();

---------------------

create or replace function set_points_psrm_carrieres_fnc() returns trigger
    language plpgsql
as
$$
DECLARE
    v_points_rc float;
    v_points_rg float;
    v_plafond_salaire float;
    v_coefficient float;
    v_salaire float;
    v_taux_contractuel float;
    v_salaire_reference float;
BEGIN
    v_points_rc = 0;
    v_points_rg = 0;

    -- cadre
    v_salaire = NEW.total_sal_ipres_rcc_1 + NEW.total_sal_ipres_rcc_2 + NEW.total_sal_ipres_rcc_3;

    IF v_salaire <> 0 THEN
        BEGIN
            SELECT plafond_salaire, taux_contractuel, salaire_reference INTO STRICT v_plafond_salaire, v_taux_contractuel, v_salaire_reference
            FROM admin_baremes b
                     INNER JOIN admin_type_regimes atr on b.admin_type_regime_id = atr.id and atr.code = 'CADRE'
            WHERE b.date_debut_validite <= NEW.date_debut_periode_cotisation and b.date_fin_validite >= NEW.date_debut_periode_cotisation;

            v_coefficient = 1.0 * (v_taux_contractuel / 100.0) / v_salaire_reference;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_coefficient = 0;
                v_plafond_salaire = 0;
            WHEN TOO_MANY_ROWS THEN
                v_coefficient = 0;
                v_plafond_salaire = 0;
        END;

        v_points_rc = round(least(v_salaire, v_plafond_salaire) * v_coefficient);
    END IF;

    -- général
    v_salaire = NEW.total_sal_ipres_rg_1 + NEW.total_sal_ipres_rg_2 + NEW.total_sal_ipres_rg_3;

    IF v_salaire <> 0 THEN
        BEGIN
            SELECT plafond_salaire, taux_contractuel, salaire_reference INTO STRICT v_plafond_salaire, v_taux_contractuel, v_salaire_reference
            FROM admin_baremes b
                     INNER JOIN admin_type_regimes atr on b.admin_type_regime_id = atr.id and atr.code = 'GENERAL'
            WHERE b.date_debut_validite <= NEW.date_debut_periode_cotisation and b.date_fin_validite >= NEW.date_debut_periode_cotisation;

            v_coefficient = 1.0 * (v_taux_contractuel / 100.0) / v_salaire_reference;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_coefficient = 0;
                v_plafond_salaire = 0;
            WHEN TOO_MANY_ROWS THEN
                v_coefficient = 0;
                v_plafond_salaire = 0;
        END;

        v_points_rg = round(least(v_salaire, v_plafond_salaire) * v_coefficient);
    END IF;

    --

    NEW.points_rc = v_points_rc;
    NEW.points_rg = v_points_rg;

    RETURN NEW;
END;
$$;


create trigger set_points_psrm_carrieres_trigger
    before insert
    on psrm_carrieres
    for each row
execute procedure set_points_psrm_carrieres_fnc();


create trigger set_points_declaration_carrieres_trigger
    before insert
    on declaration_carrieres
    for each row
execute procedure set_points_psrm_carrieres_fnc();
