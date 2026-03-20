SELECT 
    'shell'                     AS component,
    'GTA - Gestion des Tracasseries Administratives' AS title,
    'database'                  AS icon,
    '/'                         AS link,
    JSON('{"title":"Accueil","icon":"home","link":"/"}') AS menu_item,
    JSON('{"title":"Gestion","icon":"hexagons","submenu":[{"link":"/gestion/inscription.sql","title":"Inscription","icon":"edit"},{"link":"/gestion/presence.sql","title":"Feuille de présence","icon":"file-text"},{"link":"/gestion/formalites_manquantes.sql","title":"Formalités manquantes","icon":"file-report"},{"link":"/gestion/participants.sql","title":"Participants","icon":"file-text"},{"link":"/gestion/equipes.sql","title":"Équipes","icon":"users-group"}]}') AS menu_item,
    CASE WHEN scn.IdDoyenne IS NULL THEN
        JSON('{"title":"Administration","icon":"tool","submenu":[{"link":"/admin/formalites.sql","title":"Modifier les formalités","icon":"book"},{"link":"/admin/sacrements.sql","title":"Modifier les sacrements","icon":"list-details"},{"link":"/admin/sections.sql","title":"Modifier les sections","icon":"list-details"},{"link":"/admin/gestion_promotions.sql","title":"Gérer les promotions","icon":"school"},{"link":"/admin/def_mdp.sql","title":"Définir mdp","icon":"key"},{"link":"/admin/rgpd.sql","title":"Purge RGPD","icon":"user-off"}]}')
    END                         AS menu_item,
    'boxed'                     AS layout,
    'fr-FR'                     AS language
FROM v_sessions_valides scn
WHERE scn.jeton = sqlpage.cookie('jeton_session');
