-- ============================================================
--  detail_print_enveloppe.sql  –  Impression enveloppe DL
--  Paramètre attendu : $id  (IdPersonne)
-- ============================================================

-- 1. Sécurité
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

-- 2. HTML + CSS
SELECT 'html' AS component, '
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Enveloppe</title>
  <style>
    @import url(''https://fonts.googleapis.com/css2?family=EB+Garamond:wght@400;600&family=DM+Sans:wght@400;500&display=swap'');

    :root {
      --bleu: #1a3a5c;
      --or:   #b8963e;
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      background: #e8e8e8;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      font-family: ''DM Sans'', sans-serif;
      gap: 20px;
    }

    /* ── Barre impression ── */
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
    }
    #print-bar button:hover { background: #a07830; }

    /* ── Enveloppe DL : 220mm x 110mm ── */
    .enveloppe {
      width: 220mm;
      height: 110mm;
      background: #fff;
      position: relative;
      overflow: hidden;
      box-shadow: 0 4px 24px rgba(0,0,0,.18);
      margin-top: 60px;
    }

    /* Filet décoratif haut */
    .enveloppe::before {
          content: "";
          position: absolute;
          top: 0; left: 0; right: 0;
          height: 20mm;
          background-image:
            repeating-linear-gradient(45deg,  transparent, transparent 7px, rgba(26,58,92,0.055) 7px, rgba(26,58,92,0.055) 8px),
            repeating-linear-gradient(-45deg, transparent, transparent 7px, rgba(184,150,62,0.055) 7px, rgba(184,150,62,0.055) 8px);
          border-bottom: 1.5px solid var(--or);
          -webkit-print-color-adjust: exact !important;
          print-color-adjust: exact !important;
        }
    /* Bloc destinataire — centré verticalement, aligné à gauche au 2/5 */
    .destinataire {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      text-align: center;
    }

    .destinataire .nom {
      font-family: ''EB Garamond'', serif;
      font-size: 18pt;
      color: var(--bleu);
      font-weight: 600;
      line-height: 1.15;
      white-space: nowrap;
    }

    .destinataire .details {
      margin-top: 6px;
      font-size: 12pt;
      color: #555;
      line-height: 1.7;
      letter-spacing: .02em;
    }

    .destinataire .separateur {
      display: inline-block;
      margin: 0 6px;
      color: var(--or);
      font-weight: 700;
    }

    /* Logo discret en bas à droite */
    .logo {
      position: absolute;
      top: 4mm;
      right: 6mm;
      height: 16mm;
      width: auto;
      opacity: 0.7;
    }

    /* ══ IMPRESSION ══ */
    @media print {
      @page {
        size: 220mm 110mm;
        margin: 0;
      }
      body {
        background: none;
        display: block;
        min-height: unset;
      }
      #print-bar { display: none !important; }
      .enveloppe {
        width: 220mm;
        height: 110mm;
        margin: 0;
        box-shadow: none;
        page-break-after: avoid;
      }
      .enveloppe::before {
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
      }
    }
  </style>
</head>
<body>

<div id="print-bar">
  <span>Aperçu enveloppe DL — 220 × 110 mm</span>
  <!--<button onclick="window.print()">🖨️&nbsp; Imprimer</button>-->
</div>
' AS html;


-- 3. Contenu de l'enveloppe
SELECT 'html' AS component,
'<div class="enveloppe">

  <div class="destinataire">
    <div class="nom">' || PrenomPersonne || ' ' || NomPersonne || '</div>
    <div class="details">' ||
      COALESCE(sec.NomSection, '') ||
      CASE WHEN equ.LibelleEquipe IS NOT NULL
           THEN '<span class="separateur">·</span>' || equ.LibelleEquipe
           ELSE '' END ||
      CASE WHEN pro.NomPromotion IS NOT NULL
           THEN '<span class="separateur">·</span>' || pro.NomPromotion
           ELSE '' END ||
    '</div>
  </div>

  <img class="logo"
       src="/logo.png"
       alt="logo"
       onerror="this.style.display=''none''"
  >

</div>

</body>
</html>' AS html
FROM Personne per
LEFT JOIN Section   sec ON sec.IdSection   = per.IdSection
LEFT JOIN Equipe    equ ON equ.IdEquipe    = per.IdEquipe
LEFT JOIN Promotion pro ON pro.IdPromotion = per.IdPromotion
WHERE per.IdPersonne = $id;
