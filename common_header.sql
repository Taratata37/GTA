select 
    'shell'                     as component,
    'GTA - Gestion des Tracasseries Administratives' as title,
    'database'                  as icon,
    '/'                         as link,
	JSON('{"title":"Accueil","icon":"home","link":"/"}') as menu_item,
    JSON('{"title":"Gestion","icon":"hexagons","submenu":[{"link":"/gestion/inscription.sql","title":"Inscription","icon":"edit"},{"link":"/gestion/presence.sql","title":"Feuille de présence","icon":"file-text"},{"link":"/gestion/formalites_manquantes.sql","title":"Formalités manquantes","icon":"file-report"},{"link":"/gestion/participants.sql","title":"Participants","icon":"file-text"}]}') as menu_item,
    JSON('{"title":"Administration","icon":"tool","submenu":[{"link":"/admin/formalites.sql","title":"Modifier les formalités","icon":"book"},{"link":"/admin/sacrements.sql","title":"Modifier les sacrements","icon":"list-details"},{"link":"/admin/sections.sql","title":"Modifier les sections","icon":"list-details"},{"link":"/admin/def_mdp.sql","title":"Définir mdp","icon":"key"}]}') as menu_item,
    'boxed'                     as layout,
    'fr-FR'                     as language;
