-- ============================================================
--  fiche_print.sql  –  Fiche recommençant – version impression
--  Paramètre attendu : $id  (IdPersonne)
-- ============================================================

-- 1. Sécurité : même garde-fou que la page principale
SELECT 'redirect' AS component, 'index' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides scn
    LEFT JOIN Personne per ON per.IdPersonne = $id
    LEFT JOIN Equipe   equ ON equ.IdEquipe   = per.IdEquipe
    WHERE jeton = sqlpage.cookie('jeton_session')
    AND (
        scn.IdDoyenne IS NULL
        OR equ.IdDoyenne = scn.IdDoyenne
    )
);

-- 2. Injection du CSS print + bouton + déclenchement auto
SELECT 'html' AS component, '
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Fiche recommençant</title>
  <style>
    /* ── Polices ── */
    @import url(''https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,600;1,400&family=DM+Sans:wght@400;500&display=swap'');

    /* ── Variables ── */
    :root {
      --bleu:     #1a3a5c;
      --or:       #b8963e;
      --gris:     #f4f4f0;
      --texte:    #1c1c1c;
      --muted:    #666;
      --border:   #d0cfc8;
    }

    /* ── Reset global ── */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: ''DM Sans'', sans-serif;
      font-size: 10.5pt;
      color: var(--texte);
      background: #fff;
      padding: 0;
    }

    /* ── Bouton d''impression (visible à l''écran, masqué à l''impression) ── */
    #print-bar {
      position: fixed;
      top: 0; left: 0; right: 0;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 10px 24px;
      background: var(--bleu);
      color: #fff;
      z-index: 999;
      gap: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,.25);
    }
    #print-bar span { font-size: .85rem; opacity: .8; }
    #print-bar button {
      background: var(--or);
      color: #fff;
      border: none;
      padding: 8px 20px;
      border-radius: 4px;
      font-size: .9rem;
      font-weight: 500;
      cursor: pointer;
      letter-spacing: .03em;
    }
    #print-bar button:hover { background: #a07830; }

    /* ── Page principale ── */
    .page {
      margin-top: 56px; /* compense la barre fixe */
      padding: 28px 32px 40px;
      max-width: 820px;
      margin-left: auto;
      margin-right: auto;
    }

    /* ── En-tête ── */
    header {
      display: flex;
      align-items: flex-end;
      justify-content: space-between;
      border-bottom: 2.5px solid var(--bleu);
      padding-bottom: 10px;
      margin-bottom: 22px;
    }
    header h1 {
      font-family: ''EB Garamond'', serif;
      font-size: 22pt;
      color: var(--bleu);
      line-height: 1.1;
    }
    header .meta {
      font-size: 8.5pt;
      color: var(--muted);
      text-align: right;
      line-height: 1.6;
    }

    /* ── Sections ── */
    section {
      margin-bottom: 20px;
    }
    section h2 {
      font-family: ''EB Garamond'', serif;
      font-size: 12pt;
      color: var(--bleu);
      border-left: 3px solid var(--or);
      padding-left: 8px;
      margin-bottom: 10px;
      letter-spacing: .02em;
    }

    /* ── Grille de données ── */
    .grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 6px 16px;
    }
    .grid .item label {
      display: block;
      font-size: 7.5pt;
      color: var(--muted);
      text-transform: uppercase;
      letter-spacing: .07em;
      margin-bottom: 1px;
    }
    .grid .item span {
      font-size: 9.5pt;
      font-weight: 500;
    }

    /* ── Sacrements ── */
    .tags { display: flex; flex-wrap: wrap; gap: 6px; }
    .tag {
      background: var(--bleu);
      color: #fff;
      font-size: 8.5pt;
      padding: 3px 10px;
      border-radius: 20px;
      font-weight: 500;
    }
    .tag.absent {
      background: #d9534f;
    }

    /* ── Formalités ── */
    .formalites { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .formalite-item {
      display: flex;
      align-items: center;
      gap: 7px;
      font-size: 9pt;
      padding: 4px 0;
      border-bottom: 1px solid var(--border);
    }
    .formalite-item .dot {
      width: 9px; height: 9px;
      border-radius: 50%;
      flex-shrink: 0;
    }
    .dot.ok  { background: #2a9d5c; }
    .dot.nok {
      width: 0;
      height: 0;
      background: none;
      border-radius: 0;
      border-left: 5px solid transparent;
      border-right: 5px solid transparent;
      border-bottom: 9px solid #d9534f;
    }
    .formalite-item .comment { font-size: 7.5pt; color: var(--muted); margin-left: auto; }

    /* ── Étapes catéchuménat ── */
    .etapes { display: flex; gap: 0; margin-bottom: 4px; }
    .etape {
      flex: 1;
      text-align: center;
      font-size: 8pt;
      padding: 5px 4px;
      background: var(--gris);
      border: 1px solid var(--border);
      border-right: none;
      position: relative;
    }
    .etape:last-child { border-right: 1px solid var(--border); }
    .etape.done { background: var(--bleu); color: #fff; font-weight: 600; }
    .etape.current { background: var(--or); color: #fff; font-weight: 700; }

    /* ── Présences ── */
    .presences { display: flex; flex-wrap: wrap; gap: 5px; }
    .presence-badge {
      font-size: 8pt;
      padding: 3px 9px;
      border: 1px solid var(--border);
      border-radius: 3px;
      background: var(--gris);
    }

    /* ── Alerte statut ── */
    .alerte {
      border-left: 4px solid var(--or);
      background: #fdf8ee;
      padding: 8px 12px;
      border-radius: 3px;
      font-size: 9pt;
      margin-bottom: 16px;
    }
    .alerte strong { display: block; margin-bottom: 2px; }

    /* ── Pied de page ── */
    footer {
      margin-top: 32px;
      border-top: 1px solid var(--border);
      padding-top: 8px;
      font-size: 7.5pt;
      color: var(--muted);
      display: flex;
      justify-content: space-between;
    }

    /* ════════════════════════════════════════
       RÈGLES D''IMPRESSION
    ════════════════════════════════════════ */
    @media print {
      @page {
        size: A4;
        margin: 14mm 16mm 14mm 16mm;
      }
      #print-bar { display: none !important; }
      .page { margin-top: 0; padding: 0; max-width: 100%; }
      body { font-size: 9.5pt; }
      section { break-inside: avoid; }
      .etapes { break-inside: avoid; }
      a { text-decoration: none; color: inherit; }

      .section-coordonnees,
      .section-coordonnees::before {
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
      }
      .dot.ok, .dot.nok {
          -webkit-print-color-adjust: exact !important;
          print-color-adjust: exact !important;
        }
      .tag {
        background: none !important;
        color: var(--bleu) !important;
        border: 1.5px solid var(--bleu) !important;
        font-weight: 700 !important;
      }
    }

    /* ── Guilloche fond coordonnées ── */
.section-coordonnees {
  position: relative;
  padding: 10px 12px 12px;
  border-radius: 4px;
  overflow: hidden;
}
.section-coordonnees::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image:
    repeating-linear-gradient(45deg,  transparent, transparent 7px, rgba(26,58,92,0.055) 7px, rgba(26,58,92,0.055) 8px),
    repeating-linear-gradient(-45deg, transparent, transparent 7px, rgba(184,150,62,0.055) 7px, rgba(184,150,62,0.055) 8px),
    repeating-linear-gradient(0deg,   transparent, transparent 15px, rgba(26,58,92,0.03) 15px, rgba(26,58,92,0.03) 16px),
    repeating-linear-gradient(90deg,  transparent, transparent 15px, rgba(184,150,62,0.03) 15px, rgba(184,150,62,0.03) 16px);
  border: 1px solid rgba(184,150,62,0.25);
  border-radius: 4px;
  pointer-events: none;
}
.section-coordonnees .grid,
.section-coordonnees h2 {
  position: relative;
  z-index: 1;
}
  </style>

</head>
<body>

<!-- Barre impression (écran seulement) -->
<div id="print-bar">
  <span>Aperçu de la fiche pour impression</span>
  <!--<button id="btn-print">🖨️&nbsp; Imprimer / Enregistrer en PDF</button>-->
</div>

<div class="page">
' AS html;


-- 3. En-tête de fiche
SELECT 'html' AS component,
'<header>
  <div>
    <h1>' || PrenomPersonne || ' ' || NomPersonne ||
    CASE WHEN SexePersonne = 'F' AND NomJfPersonne IS NOT NULL
         THEN ' <span style="font-size:13pt;font-weight:400;font-style:italic;">(née ' || NomJfPersonne || ')</span>'
         ELSE '' END ||
    '</h1>
    <div style="color:var(--muted);font-size:9pt;margin-top:4px;">
      Personne inscrite le ' || STRFTIME('%d/%m/%Y', DateInscriptionPersonne) || '
    </div>
  </div>
  <img src="/logo.png"
       alt="Diocèse de Tours"
       style="height:72px;width:auto;object-fit:contain;"
       onerror="this.style.display=''none''"
  >
  <div class="meta">
    Fiche éditée le ' || STRFTIME('%d/%m/%Y', 'now') || '<br>
    Référence : #' || IdPersonne || '
  </div>
</header>' AS html
FROM Personne
WHERE IdPersonne = $id;


-- 4. Alerte statut (si pertinente)
SELECT 'html' AS component,
'<div class="alerte"><strong>' || titre || '</strong>' || description || '</div>' AS html
FROM Status_Personne
WHERE IdPersonne = $id AND length(etat) > 1;


-- 5. Coordonnées
SELECT 'html' AS component,
'<section class="section-coordonnees">
  <h2>Coordonnées</h2>
  <div class="grid">
    <div class="item"><label>Courriel</label><span>' || COALESCE(NULLIF(CourrielPersonne,''),'—') || '</span></div>
    <div class="item"><label>Téléphone</label><span>' || COALESCE(NULLIF(TelephonePersonne,''),'—') || '</span></div>
    <div class="item"><label>Adresse</label><span>' ||
      COALESCE(RuePersonne || ', <br>' || CpPersonne || ' ' || NULLIF(VillePersonne,''), '—') ||
    '</span></div>
    <div class="item"><label>Section</label><span>' || COALESCE(NULLIF(sec.NomSection,''),'—') || '</span></div>
    <div class="item"><label>Promotion</label><span>' || COALESCE(NULLIF(pro.NomPromotion,''),'—') || '</span></div>
    <div class="item"><label>Doyenné</label><span>' || COALESCE(NULLIF(doy.NomDoyenne,''),'—') || '</span></div>
    <div class="item"><label>Équipe</label><span>' || COALESCE(NULLIF(equ.LibelleEquipe,''),'—') || '</span></div>
  </div>
</section>' AS html
FROM Personne per
LEFT JOIN Section   sec ON sec.IdSection   = per.IdSection
LEFT JOIN Promotion pro ON pro.IdPromotion = per.IdPromotion
LEFT JOIN Equipe    equ ON equ.IdEquipe    = per.IdEquipe
LEFT JOIN Doyenne   doy ON doy.IdDoyenne   = equ.IdDoyenne
WHERE per.IdPersonne = $id;


-- 6. Sacrements demandés
SELECT 'html' AS component,
'<section>
  <h2>Accompagnement demandé</h2>
  <div class="tags">' ||
  COALESCE(
    (SELECT GROUP_CONCAT('<span class="tag">' || sac.NomSacrement || '</span>', ' ')
     FROM Sacrement sac
     INNER JOIN Demander dem ON sac.IdSacrement = dem.IdSacrement AND dem.idPersonne = $id),
    '<span class="tag absent">Aucun accompagnement demandé</span>'
  ) ||
  '</div>
</section>' AS html;


-- 7. Étapes du catéchuménat (baptisants uniquement)
SELECT 'html' AS component,
'<section>
  <h2>Parcours catéchuménal</h2>
  <div class="etapes">' ||
  -- Accueil
  CASE WHEN acc.IdPersonne IS NOT NULL THEN '<div class="etape done">Accueil</div>'
       ELSE '<div class="etape">Accueil</div>' END ||
  -- Entrée en Église
  CASE WHEN ent.IdPersonne IS NOT NULL THEN '<div class="etape done">Entrée en Église</div>'
       WHEN acc.IdPersonne IS NOT NULL THEN '<div class="etape current">Entrée en Église</div>'
       ELSE '<div class="etape">Entrée en Église</div>' END ||
  -- Appel décisif
  CASE WHEN apd.IdPersonne IS NOT NULL THEN '<div class="etape done">Appel décisif</div>'
       WHEN ent.IdPersonne IS NOT NULL THEN '<div class="etape current">Appel décisif</div>'
       ELSE '<div class="etape">Appel décisif</div>' END ||
  -- Sacrements
  CASE WHEN scr.IdPersonne IS NOT NULL THEN '<div class="etape done">Sacrements</div>'
       WHEN apd.IdPersonne IS NOT NULL THEN '<div class="etape current">Sacrements</div>'
       ELSE '<div class="etape">Sacrements</div>' END ||
  '</div>
</section>' AS html
FROM Personne per
LEFT JOIN Venir acc ON (acc.IdPersonne = per.IdPersonne AND acc.codeType_evenement = 'ACCUE')
LEFT JOIN Venir ent ON (ent.IdPersonne = per.IdPersonne AND ent.codeType_evenement = 'ENTRE')
LEFT JOIN Venir apd ON (apd.IdPersonne = per.IdPersonne AND apd.codeType_evenement = 'APDEC')
LEFT JOIN Venir scr ON (scr.IdPersonne = per.IdPersonne AND scr.codeType_evenement = 'SCRMT')
WHERE per.IdPersonne = $id
AND EXISTS (
    SELECT 1 FROM Demander dem
    INNER JOIN Sacrement sac ON dem.IdSacrement = sac.IdSacrement
    WHERE dem.IdPersonne = $id AND sac.NomSacrement = 'Baptême'
);


-- 8. Formalités
SELECT 'html' AS component,
'<section>
  <h2>Formalités</h2>
  <div class="formalites">' ||
  GROUP_CONCAT(
    '<div class="formalite-item">'
    || '<span class="dot ' || CASE WHEN Remplir.IdPersonne IS NULL THEN 'nok' ELSE 'ok' END || '"></span>'
    || Formalite.NomFormalite
    || CASE WHEN NULLIF(Remplir.CommentaireFormalite,'') IS NOT NULL
            THEN '<span class="comment">' || Remplir.CommentaireFormalite || '</span>'
            WHEN Remplir.IdPersonne IS NULL THEN '<span class="comment">' ||  '❌ A remplir' || '</span>'
            ELSE '' END
    || '</div>',
    ''
  ) ||
  '</div>
</section>' AS html
FROM Formalite
INNER JOIN Personne ON (Personne.IdSection = Formalite.IdSection AND Personne.IdPersonne = $id)
LEFT JOIN  Remplir  ON (Formalite.IdFormalite = Remplir.IdFormalite AND Remplir.IdPersonne = $id);


-- 9. Présences (ouverture)
SELECT 'html' AS component,
'<section><h2>Présences aux rencontres</h2><div class="presences">' AS html;

-- Une ligne par présence
SELECT 'html' AS component,
    '<span class="presence-badge">'
    || STRFTIME('%d/%m/%Y', ven.date)
    || CASE WHEN te.NomType_evenement IS NOT NULL THEN ' - ' || te.NomType_evenement ELSE '' END
    || '</span>' AS html
FROM Venir ven
LEFT JOIN type_evenement te ON te.codeType_evenement = ven.codeType_evenement
WHERE ven.IdPersonne = $id;

-- Message si aucune présence
SELECT 'html' AS component,
'<em style="color:var(--muted);font-size:9pt;">Aucune présence enregistrée</em>' AS html
WHERE NOT EXISTS (SELECT 1 FROM Venir WHERE IdPersonne = $id);

-- Fermeture
SELECT 'html' AS component, '</div></section>' AS html;


-- 10. Annexe : justificatifs (saut de page avant, une image par formalité)
SELECT 'html' AS component,
'<div style="break-before:page;">
  <h2 style="font-family:''EB Garamond'',serif;font-size:14pt;color:var(--bleu);
             border-left:3px solid var(--or);padding-left:8px;margin-bottom:16px;">
    Annexe – Justificatifs déposés
  </h2>' AS html
WHERE EXISTS (
    SELECT 1 FROM Remplir
    INNER JOIN Formalite ON Formalite.IdFormalite = Remplir.IdFormalite
    INNER JOIN Personne  ON Personne.IdSection = Formalite.IdSection AND Personne.IdPersonne = $id
    WHERE Remplir.IdPersonne = $id AND NULLIF(Remplir.Justificatif,'') IS NOT NULL
);

-- Une image par justificatif
SELECT 'html' AS component,
'<div style="margin-bottom:24px;break-inside:avoid;">
  <div style="font-size:9pt;font-weight:600;color:var(--bleu);margin-bottom:6px;">'
  || Formalite.NomFormalite ||
  CASE WHEN Remplir.CommentaireFormalite IS NOT NULL
       THEN ' <span style="font-weight:400;color:var(--muted);">– ' || Remplir.CommentaireFormalite || '</span>'
       ELSE '' END ||
  '</div>
  <img src="' || Remplir.Justificatif || '"
       style="max-width:100%;max-height:800px;border:1px solid var(--border);border-radius:4px;display:block;"
       alt="Justificatif ' || Formalite.NomFormalite || '"
  >
</div>' AS html
FROM Remplir
INNER JOIN Formalite ON Formalite.IdFormalite = Remplir.IdFormalite
INNER JOIN Personne  ON Personne.IdSection = Formalite.IdSection AND Personne.IdPersonne = $id
WHERE Remplir.IdPersonne = $id AND NULLIF(Remplir.Justificatif,'') IS NOT NULL;

-- Fermeture du div annexe
SELECT 'html' AS component, '</div>' AS html
WHERE EXISTS (
    SELECT 1 FROM Remplir
    INNER JOIN Formalite ON Formalite.IdFormalite = Remplir.IdFormalite
    INNER JOIN Personne  ON Personne.IdSection = Formalite.IdSection AND Personne.IdPersonne = $id
    WHERE Remplir.IdPersonne = $id AND NULLIF(Remplir.Justificatif,'') IS NOT NULL
);

-- 11. Pied de page + fermeture HTML
SELECT 'html' AS component,
'  <footer>
    <span>Document confidentiel – diffusion restreinte </span>
    <span>Généré depuis GTA</span>
  </footer>
</div><!-- .page -->



</body>

</html>' AS html;
