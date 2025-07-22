namespace :echeance_css do
  desc "set periode eligibilité enfants a executer tous les mois"
  task set_periode_eligibilite_enfant: :environment do
    date = Date.today.beginning_of_month
    # date = Date.new(2023, 2, 1).beginning_of_month
    date_str = date.strftime('%Y-%m-%d')

    date_veille = date - 1.day
    date_veille_str = date_veille.strftime('%Y-%m-%d')

    sql = <<-SQL
      update enfants a set date_debut_eligibilite_af = '#{date_str}'
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
                AND '#{date_str}' between e.date_naissance + interval '2 years' and e.date_naissance + interval '21 years'
                AND (e.date_deces IS NULL
                  OR (e.date_deces IS NOT NULL)
                         AND (e.date_deces >= '#{date_str}')
                  )
          ) e2 on e.id = e2.id
          where e.date_debut_eligibilite_af is null
      ) b where a.id = b.id;
    SQL

    puts sql

    ActiveRecord::Base.connection.execute(sql)

    puts '----------------------'

    sql = <<-SQL
      update enfants set date_fin_eligibilite_af = '#{date_veille_str}'
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
          AND '#{date_str}' between e.date_naissance + interval '2 years' and e.date_naissance + interval '21 years'
          AND (e.date_deces IS NULL
            OR (e.date_deces IS NOT NULL)
            AND (e.date_deces >= '#{date_str}')
          )
        ) e2 on e.id = e2.id
        where e.date_debut_eligibilite_af is not null
        and e2.id is null
      );
    SQL

    puts sql

    ActiveRecord::Base.connection.execute(sql)

    puts '----------------------'

    sql = <<-SQL
      update enfants e
      set date_fin_eligibilite_af = date_naissance + interval '21 years'
      where date_fin_eligibilite_af is not null and date_fin_eligibilite_af > date_naissance + interval '21 years';
    SQL

    puts sql

    ActiveRecord::Base.connection.execute(sql)

    puts '----------------------'

    sql = <<-SQL
      update enfants e
      set date_debut_eligibilite_af = date_naissance + interval '2 years'
      where date_debut_eligibilite_af is not null and date_debut_eligibilite_af < date_naissance + interval '2 years';
    SQL

    puts sql

    ActiveRecord::Base.connection.execute(sql)

    puts '----------------------'
  end

  desc "générer l'échéance caisse (trimestrielle)"
  task run: :environment do
    trimestre = (Date.today.month / 3.0).ceil
    EcheanceCaisse.create(annee: Date.today.year, trimestre: trimestre)
  end
end
