  update enfants a set date_debut_eligibilite_af = '2024-10-01'
  from (
      select e.id from enfants e
                           inner join (
          select e.id
          from enfants e
                   inner join psrm_participants pp on pp.matric = e.numero_affiliation
                   left join conjoints c on c.numero_affiliation = e.numero_affiliation and c.etat_conjoint = 1
          where (e.origine_enfant = 3 -- naturel
                     AND (
                             pp.genre = 'FEMME'
                         OR
                             pp.genre = 'HOMME'
                                 AND c.numero_affiliation is not null
                     )
              OR e.origine_enfant IN (1, 2) -- mariage ou adulterin
              )
            AND '2024-10-01' between e.date_naissance + interval '2 years' and e.date_naissance + interval '21 years'
            AND (e.date_deces IS NULL
              OR (e.date_deces IS NOT NULL)
                     AND (e.date_deces >= '2024-10-01')
              )
      ) e2 on e.id = e2.id
      where e.date_debut_eligibilite_af is null
  ) b where a.id = b.id;
----------------------
  update enfants set date_fin_eligibilite_af = '2024-09-30'
  where id in (
    select e.id from enfants e
    left join (
      select e.id
      from enfants e
      inner join psrm_participants pp on pp.matric = e.numero_affiliation
      left join conjoints c on c.numero_affiliation = e.numero_affiliation and c.etat_conjoint = 1
      where (e.origine_enfant = 3 -- naturel
        AND (
          pp.genre = 'FEMME'
        OR
          pp.genre = 'HOMME'
          AND c.numero_affiliation is not null
        )
        OR e.origine_enfant IN (1, 2) -- mariage ou adulterin
      )
      AND '2024-10-01' between e.date_naissance + interval '2 years' and e.date_naissance + interval '21 years'
      AND (e.date_deces IS NULL
        OR (e.date_deces IS NOT NULL)
        AND (e.date_deces >= '2024-10-01')
      )
    ) e2 on e.id = e2.id
    where e.date_debut_eligibilite_af is not null
    and e2.id is null
  );
----------------------
  update enfants e
  set date_fin_eligibilite_af = date_naissance + interval '21 years'
  where date_fin_eligibilite_af is not null and date_fin_eligibilite_af > date_naissance + interval '21 years';
----------------------
  update enfants e
  set date_debut_eligibilite_af = date_naissance + interval '2 years'
  where date_debut_eligibilite_af is not null and date_debut_eligibilite_af < date_naissance + interval '2 years';
----------------------
  update enfants a set date_debut_eligibilite_af = '2024-11-01'
  from (
      select e.id from enfants e
                           inner join (
          select e.id
          from enfants e
                   inner join psrm_participants pp on pp.matric = e.numero_affiliation
                   left join conjoints c on c.numero_affiliation = e.numero_affiliation and c.etat_conjoint = 1
          where (e.origine_enfant = 3 -- naturel
                     AND (
                             pp.genre = 'FEMME'
                         OR
                             pp.genre = 'HOMME'
                                 AND c.numero_affiliation is not null
                     )
              OR e.origine_enfant IN (1, 2) -- mariage ou adulterin
              )
            AND '2024-11-01' between e.date_naissance + interval '2 years' and e.date_naissance + interval '21 years'
            AND (e.date_deces IS NULL
              OR (e.date_deces IS NOT NULL)
                     AND (e.date_deces >= '2024-11-01')
              )
      ) e2 on e.id = e2.id
      where e.date_debut_eligibilite_af is null
  ) b where a.id = b.id;
----------------------
  update enfants set date_fin_eligibilite_af = '2024-10-31'
  where id in (
    select e.id from enfants e
    left join (
      select e.id
      from enfants e
      inner join psrm_participants pp on pp.matric = e.numero_affiliation
      left join conjoints c on c.numero_affiliation = e.numero_affiliation and c.etat_conjoint = 1
      where (e.origine_enfant = 3 -- naturel
        AND (
          pp.genre = 'FEMME'
        OR
          pp.genre = 'HOMME'
          AND c.numero_affiliation is not null
        )
        OR e.origine_enfant IN (1, 2) -- mariage ou adulterin
      )
      AND '2024-11-01' between e.date_naissance + interval '2 years' and e.date_naissance + interval '21 years'
      AND (e.date_deces IS NULL
        OR (e.date_deces IS NOT NULL)
        AND (e.date_deces >= '2024-11-01')
      )
    ) e2 on e.id = e2.id
    where e.date_debut_eligibilite_af is not null
    and e2.id is null
  );
----------------------
  update enfants e
  set date_fin_eligibilite_af = date_naissance + interval '21 years'
  where date_fin_eligibilite_af is not null and date_fin_eligibilite_af > date_naissance + interval '21 years';
----------------------
  update enfants e
  set date_debut_eligibilite_af = date_naissance + interval '2 years'
  where date_debut_eligibilite_af is not null and date_debut_eligibilite_af < date_naissance + interval '2 years';
----------------------
  update enfants a set date_debut_eligibilite_af = '2024-12-01'
  from (
      select e.id from enfants e
                           inner join (
          select e.id
          from enfants e
                   inner join psrm_participants pp on pp.matric = e.numero_affiliation
                   left join conjoints c on c.numero_affiliation = e.numero_affiliation and c.etat_conjoint = 1
          where (e.origine_enfant = 3 -- naturel
                     AND (
                             pp.genre = 'FEMME'
                         OR
                             pp.genre = 'HOMME'
                                 AND c.numero_affiliation is not null
                     )
              OR e.origine_enfant IN (1, 2) -- mariage ou adulterin
              )
            AND '2024-12-01' between e.date_naissance + interval '2 years' and e.date_naissance + interval '21 years'
            AND (e.date_deces IS NULL
              OR (e.date_deces IS NOT NULL)
                     AND (e.date_deces >= '2024-12-01')
              )
      ) e2 on e.id = e2.id
      where e.date_debut_eligibilite_af is null
  ) b where a.id = b.id;
----------------------
  update enfants set date_fin_eligibilite_af = '2024-11-30'
  where id in (
    select e.id from enfants e
    left join (
      select e.id
      from enfants e
      inner join psrm_participants pp on pp.matric = e.numero_affiliation
      left join conjoints c on c.numero_affiliation = e.numero_affiliation and c.etat_conjoint = 1
      where (e.origine_enfant = 3 -- naturel
        AND (
          pp.genre = 'FEMME'
        OR
          pp.genre = 'HOMME'
          AND c.numero_affiliation is not null
        )
        OR e.origine_enfant IN (1, 2) -- mariage ou adulterin
      )
      AND '2024-12-01' between e.date_naissance + interval '2 years' and e.date_naissance + interval '21 years'
      AND (e.date_deces IS NULL
        OR (e.date_deces IS NOT NULL)
        AND (e.date_deces >= '2024-12-01')
      )
    ) e2 on e.id = e2.id
    where e.date_debut_eligibilite_af is not null
    and e2.id is null
  );
----------------------
  update enfants e
  set date_fin_eligibilite_af = date_naissance + interval '21 years'
  where date_fin_eligibilite_af is not null and date_fin_eligibilite_af > date_naissance + interval '21 years';
----------------------
  update enfants e
  set date_debut_eligibilite_af = date_naissance + interval '2 years'
  where date_debut_eligibilite_af is not null and date_debut_eligibilite_af < date_naissance + interval '2 years';
----------------------
