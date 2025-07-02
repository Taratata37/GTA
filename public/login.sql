SELECT
    'redirect' AS component,
    'detail.sql?id='|| per.idPersonne || '&pin=' || :pin AS link
FROM personne per 
WHERE  per.pinPersonne = :pin AND per.courrielPersonne = :courriel ;
select 
    'form'            as component,
    'login.sql'       as action;
select 
    'courriel' as name, :courriel as value;
Select 
    'pin' as name, :pin as value;