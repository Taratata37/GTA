select 
    'shell'                     as component,
    'GTA - Gestion des Tracasseries Administratives' as title,
    'database'                  as icon,
    '/'                         as link,
	JSON('{"title":"Accueil","icon":"home","link":"/"}') as menu_item,
    JSON('{"title":"Gestion","icon":"hexagons","submenu":[{"link":"/inscription.sql","title":"Inscription","icon":"edit"},{"link":"/presence.sql","title":"Feuille de présence","icon":"file-text"},{"link":"/formalites_manquantes.sql","title":"Formalités manquantes","icon":"file-report"}]}') as menu_item,
    JSON('{"title":"Administration","icon":"tool","submenu":[{"link":"/formalites.sql","title":"Modifier les formalités","icon":"book"},{"link":"/sacrements.sql","title":"Modifier les sacrements","icon":"list-details"},{"link":"/sections.sql","title":"Modifier les sections","icon":"list-details"}]}') as menu_item,
    'boxed'                     as layout,
    'fr-FR'                     as language;