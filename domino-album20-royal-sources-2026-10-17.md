# דומינו אלבום 20 — מאיפה מגיעים רויאלים חדשים, לפי רבע (2026-10-17)

שאלה (עדן): מה היה מקור הרויאלים בסוף האלבום באלבום 20 — החלפת כפולים, או גם טרייל?
אוכלוסייה: משלמים, לא באלבום הראשון, יחס התחברות בשורה האחרונה 0.5 ומעלה, יום הסגירה מוחרג, בלי שחקנים מיוחדים וחשודים ברמאות. נספר רק רויאל חדש (קבלה ראשונה של אותו רויאל). רבע = חלק מזמן האלבום.
טבלאות: domino-dreams-dbt — prod_40_mart.user_daily_album, prod_40_mart.user_daily_metrics, prod_30_intermediate.int_user_album_stickers (10 GB). מיפוי קטגוריות כמו 5ד (topic5_rare_sources_queries.sql).

## לפי קטגוריה (חלק מהרויאלים החדשים ברבע)
| קטגוריה | רבע 1 | רבע 2 | רבע 3 | רבע 4 |
|---|---|---|---|---|
| החלפת כפולים | 0% | 0% | 8% | 37% |
| טרייל (כולל פרס גדול) | 3% | 24% | 20% | 7% |
| מומנטום | 6% | 8% | 19% | 3% |
| יומי | 22% | 8% | 3% | 2% |
| הצעות בתשלום (ג'וקר, משימות, 1+X) | 0% | 0% | 2% | 4% |
| לא ידוע (מקור ריק) | 23% | 8% | 1% | 0% |
| אירועים אחרים | 46% | 52% | 47% | 47% |

## אירועים בולטים בתוך "אירועים אחרים"
- רבע 1: AdventureWheel 12%, Puzzle 11%, Merge 8%, Kiosk 5%, RoadToGlory 4%.
- רבע 2: Twister 36%, Puzzle 10%.
- רבע 3: Album 17%, AdventureWheel 9%, Blast 6%, MovieTwister 4%, Pinata 3%.
- רבע 4: level end 11%, MovieTwister 8%, Kiosk 7%, Puzzle 4%, "Missions,Album" 4%, Merge 3%.

## מה מאחורי "לא ידוע" (עדן, 2026-10-17)
מקור ריק אבל שם קמפיין קיים. מתוך כל הרויאלים במקור ריק באלבום 20 (כ־37 אלף):
- כ־62% — EV_Royal_Card_Popup_Since_250310
- כ־32% — BasketBonanza|d_260916
- השאר — GoldenPuzzle / PetGlowUp
השערה (לא נבדק): היחסים מתאימים לפיזור לפי רבע — ברבע 1 כ־23 אלף במקור ריק (≈ 62%), ברבע 2 כ־12 אלף (≈ 32%). כלומר ייתכן שרבע 1 = חלון הקופץ של כרטיס הרויאל, ורבע 2 = BasketBonanza.
שיוך לקטגוריה: ממתין להחלטת עדן (חלון הקופץ — הצעה בתשלום או אירוע?). BasketBonanza / GoldenPuzzle / PetGlowUp — אירועים אחרים.

## קריאה
- ידוע: ברבע האחרון של אלבום 20 החלפת כפולים היא המקור המרכזי לרויאל חדש (37%), יותר מאשר ב־17/19 (23–30%).
- ידוע: טרייל הוא מקור משמעותי באמצע האלבום (24% ברבע השני, 20% בשלישי), אבל ברבע האחרון רק 7%. לכן בסוף הוא לא המקור המרכזי.
- חסר: הטבלה לא מראה מאיפה הגיעו הכפולים שהוחלפו. אם רבים מהם הגיעו מהטרייל, הטרייל תורם לסוף בעקיפין — לא נמדד.
- דורש אימות: מקורות לא ממופים — "Album" (17% ברבע 3), "level end" (11% ברבע 4), "Missions,Album", ומקור ריק (23% ברבע 1). לשאול את צוות דומינו.

## שאילתה
```sql
WITH excluded AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-16' AND suspected_cheater_flag),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start, a.album_close_date AS a_end,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-16' AND a.album_id = 20
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND MIN(user_album_count) > 1
    AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
st AS (
  SELECT p.user_id, IFNULL(NULLIF(s.new_sticker_source, ''), '(null)') AS src,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_min_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) + 1 AS quarter
  FROM pop p JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
    ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-01' AND DATE '2026-10-16' AND s.album_id = 20
    AND LOWER(s.sticker_type) = 'royal' AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= p.a_start AND s.sticker_collected_min_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
lab AS (
  SELECT quarter, src, CASE
    WHEN src = 'pixie_reward' THEN 'Long feature'
    WHEN LOWER(src) LIKE '%momentum%' THEN 'Momentum'
    WHEN LOWER(src) LIKE '%trail%' AND LOWER(src) NOT LIKE '%tournament%' THEN 'Trail'
    WHEN src = 'days_milestone' THEN 'Daily'
    WHEN src = 'duplicates' THEN 'Dup exchange'
    WHEN src = 'Market' THEN 'Market'
    WHEN src IN ('joker','progress_offer','Missions','BuyThemAll','SeasonPass','OfferLuckyTwister','Box','mtx','1po') OR src LIKE '1+%' THEN 'Paid offer'
    WHEN src = '(null)' THEN 'Unknown' ELSE 'Other events' END AS cat
  FROM st)
SELECT quarter, cat, src, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY quarter), 3) AS share_in_quarter
FROM lab GROUP BY quarter, cat, src ORDER BY quarter, n DESC;
```

