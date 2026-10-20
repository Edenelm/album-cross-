# תוספת: אלבומים קצרים — טובים לאורך כל האלבום, לא בסוף (2026-10-18)

המשך של claude/album-length-end-arpdau-2026-10-18.md. אוכלוסייה: כל מי שקיבל את האלבום, ימים פעילים, בלי יום הסגירה, החרגות.
שאלת עדן: אלבומים קצרים (למשל דיסני 13, 21 יום) "היו טובים" — למה לא רואים את זה בגידול בסוף?

## דיסני 13 מול השכנים (מאותן תוצאות)
| אלבום | אורך | ARPDAU אלבום | שחקנים פעילים ביום (ממוצע) | הכנסה ליום (כל האלבום) | הכנסה ליום ב־4 האחרונים | גידול בסוף |
|---|---|---|---|---|---|---|
| 11 | 35 | 1.12 | 1.47M | 1.64M$ | 1.66M$ | +3% |
| 12 | 42 | 0.97 | 1.44M | 1.40M$ | 1.42M$ | +3% |
| 13 | 21 | 1.01 | 1.38M | 1.40M$ | 1.42M$ | +3% |
| 14 | 42 | 0.91 | 1.32M | 1.19M$ | 1.12M$ | −1% |
| 15 | 42 | 0.91 | 1.15M | 1.05M$ | 1.10M$ | +9% |
ARPDAU כל האלבום מול ממוצע השכנים: דיסני 11 +7%, 13 +8% (הגבוהים בתקופה; אחרים −9% עד +3%). דייס — הקצרים +4 / −1 / 0 / +3%, בתוך הטווח (−8% עד +6%).

## עקומה לפי חלק מזמן האלבום — דיסני 9–15 (הורץ באישור, 49GB)
שאילתה: בסוף הקובץ. מדד = ARPDAU בפרוסה של 10% מזמן האלבום ÷ ARPDAU של כל האלבום.
| אלבום (אורך) | 0–10 | 10–20 | 20–30 | 30–40 | 40–50 | 50–60 | 60–70 | 70–80 | 80–90 | 90–100 |
|---|---|---|---|---|---|---|---|---|---|---|
| 9 (41) | 0.80 | 0.90 | 0.96 | 0.88 | 1.05 | 0.88 | 1.15 | 1.07 | 1.12 | 1.07 |
| 10 (49) | 0.85 | 0.96 | 1.15 | 1.01 | 0.95 | 1.04 | 1.01 | 0.94 | 1.01 | 1.08 |
| 11 (35) | 0.91 | 1.15 | 0.88 | 0.96 | 0.91 | 1.05 | 0.98 | 1.32 | 0.92 | 1.07 |
| 12 (42) | 0.99 | 1.07 | 1.01 | 0.94 | 1.06 | 0.98 | 0.96 | 1.05 | 0.93 | 1.03 |
| 13 (21) | 0.75 | 1.06 | 1.19 | 0.90 | 1.07 | 1.25 | 1.05 | 0.80 | 0.94 | 1.11 |
| 14 (42) | 0.94 | 1.08 | 0.97 | 0.97 | 1.15 | 0.95 | 1.05 | 0.98 | 0.97 | 0.99 |
| 15 (42) | 0.88 | 1.14 | 0.95 | 0.98 | 0.95 | 0.95 | 1.11 | 1.06 | 0.93 | 1.08 |
ARPDAU מוחלט באלבום 13: 0.76 / 1.08 / 1.21 / 0.91 / 1.09 / 1.27 / 1.06 / 0.81 / 0.95 / 1.12$. אלבומים 12 ו־14 נעים בין 0.85 ל־1.04$.

## קריאה (תצפיתי)
- ההשערה "באלבום קצר אין שקע באמצע" לא נתמכת: גם באלבומים הארוכים בדיסני אין שקע באמצע (המדד סביב 1.0, בהתאם לממצא מ־2026-10-08 שדיסני שטוח באמצע).
- אלבום 13 גבוה בגלל שתי קפיצות: פרוסה 20–30% (27–28.6, סוף שבוע) ופרוסה 50–60% (3–4.7, **סוף שבוע של 4 ביולי**). באלבום של 21 יום כל פרוסה היא יומיים, אז סוף שבוע או חג מזיזים את כל האלבום.
- אלבום 11 — קפיצה אחת בפרוסה 70–80% (1.32); לא נבדק מה היה שם.
- מסקנה: האלבומים הקצרים בדיסני היו טובים בגלל ימים חזקים מסוימים (לוח שנה ואירועים), לא בגלל מבנה אחר לאורך האלבום. באלבום קצר כמה ימים חזקים משפיעים על הממוצע יותר.
- הצעד הבא האפשרי: לוח האירועים וההצעות של דיסני 13 (27–28.6, 3–4.7) ושל דיסני 11 (פרוסה 70–80%) — שאלה לצוות דיסני.

## שאילתה
```sql
-- Disney albums 9-15: ARPDAU by 10% slice of album time (players who received the album, active days, close day excluded)
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-01-01' AND DATE '2026-10-18' AND album_id BETWEEN 9 AND 15
  GROUP BY 1
),
excl AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-18' AND exclude_reason IS NOT NULL
),
d AS (
  SELECT x.album_id, DATE_DIFF(a.a_end, a.a_start, DAY) AS span,
    LEAST(9, CAST(FLOOR(DATE_DIFF(x.date_dim, a.a_start, DAY) / DATE_DIFF(a.a_end, a.a_start, DAY) * 10) AS INT64)) AS slice10,
    IFNULL(x.album_spent_today, 0) AS rev
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  JOIN alb a ON a.album_id = x.album_id
  LEFT JOIN excl e ON e.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-01-01' AND DATE '2026-10-18'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND x.special_user_flag = FALSE AND e.user_id IS NULL
),
s AS (
  SELECT album_id, ANY_VALUE(span) AS span, slice10, COUNT(*) AS act_days, SUM(rev) AS rev
  FROM d GROUP BY album_id, slice10
)
SELECT album_id, span, slice10, act_days, ROUND(rev) AS rev,
  ROUND(rev / act_days, 3) AS arpdau,
  ROUND(SAFE_DIVIDE(rev / act_days, SUM(rev) OVER (PARTITION BY album_id) / SUM(act_days) OVER (PARTITION BY album_id)), 3) AS index_vs_album
FROM s
ORDER BY album_id, slice10
```
