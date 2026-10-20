# לוח סיפור מוצע: מצגת האלבומים בין הסטודיואים (טיוטה לאישור)

מצגת: https://claude.ai/artifact/6UUb91x2vHULkaM4g73uQr (נקראה כפי שהיא עכשיו: 68 שקופיות ב-order ועוד 7 קבצים מחוץ ל-order, שמוצגים בסוף. סה"כ 75). לא שיניתי בה כלום.

**מקרא:** ✅ נשאר (כותרת חדשה) · 🔀 מיזוג / בנייה מחדש מנתון קיים · 📎 לנספח · ❌ יוצא · ⚠️ צריך החלטה

---

## הסיפור (במילים שלך)
1. **הבעיה:** לאחרונה אין עלייה בסוף האלבום. שלושת המשחקים, האלבומים האחרונים, מה שטוח ומה טוב.
2. **למה 1:** ההשלמה נדחסת ל-3 הימים האחרונים.
3. **למה 2:** רויאלס וגולדנס משתחררים מאוחר מדי / לא מגיעים ליעד (גם בדומינו).
4. **התוצאה:** שיעור מסיימים נמוך ונתח הכנסות מסיימים נמוך.
5. **איפה השחקנים עומדים:** כמה הכנסות רחוקות 4+ מדבקות, 3–4 ימים לפני הסגירה.
6. **יעדים לפי אוכלוסייה:** דייס כדוגמה. החיזוי הכי טוב הוא הוצאה יומית בתוך האלבום. יעד לכל קבוצה מהעבר. המלצה לדייס: רק הוצאה בתוך האלבום, רבעון אחרון, לפי הוצאה יומית. ולמה שקלול לפי הכנסות.

אחר כך: החלטות / טסטים → נספח → "שאלות שהנתונים דחו".

---

## חלק ראשי (29 שקופיות)

| # | כותרת = המסר | הגרף / המספר שמוכיח | מקור |
|---|---|---|---|
| 1 | The Album in Three Games | שלושת הלוגואים | ✅ `cover` |
| 2 | Six Steps: From a Flat End to Targets per Group | 6 שורות, מספר אחד לכל צעד | 🔀 `map` + המספרים מ-`learned` (הנוכחי לא תואם לסיפור) |
| **צעד 1: הבעיה** ||||
| 3 | Is the Album End Still Lifting Revenue? | שקופית שאלה עם סרט | ✅ `q-today` |
| 4 | The End Lift Is Fading: Dice Below Its Best, Domino Uneven, Disney Flat ⚠️ | ×3: עלייה ב-4 הימים האחרונים מול כל האלבום, לפי אלבום. Dice: 53/57 +31/+33 → 59–63 +15–20. Domino: +6 עד +32 (16 שטוח, 19–20 ‎+16/+18). Disney: −1 עד +3 באלבומים 11–14, ‎+8 ב-15 | 🔀 `end-growth` (מקוצר לאלבומים האחרונים, שטוח <+5% מסומן באדום) |
| 5 | Current Snapshot + Recommendation | ‎+18% Dice היום מול +30% בשיא · Domino תלוי אלבום · Disney ~0 | 🔀 `snap-today` |
| **צעד 2: למה 1, 3 ימים אחרונים** ||||
| 6 | Why 1: The Finish Comes Only in the Last 3 Days | שאלה | ✅ `q-ch3` |
| 7 | Almost Every Finisher Finishes in the Last 3 Days | ×3: נתח מסיימים משלמים ב-3 הימים האחרונים: Dice 84–88%, Domino 63% / 93% / 85% (17/19/20), Disney 99% | ✅ `last3days` (+ Domino 20 מ-`domino-weeks`) |
| 8 | The Closing Tool Opens a Week Earlier in Dice Than in Disney | ×3: שחקנים ביום עם Wild/Joker, קנוי מול משחק. Dice מוכר מ-7 ימים, Domino 5–7, Disney 2–3 | ✅ `closing-week` (שורת התזמון מ-`closing-tools`) |
| 9 | Current Snapshot + Recommendation | 84–99% בשלושת הימים האחרונים · 7 מול 2 ימים | 🔀 `snap-ch3` (המלצה חוצת משחקים) |
| **צעד 3: למה 2, רויאלס וגולדנס** ||||
| 10 | Why 2: Royals and Goldens Stop Coming Before the End ⚠️ | שאלה | 🔀 `q-ch1` (היום כתוב "Run Dry Too Early", ב-map "too early or not at all") |
| 11 | Far Payers Get Their Last New Royal 10 Days Before Close (Dice: 5) | ×3 ציר זמן: הרייר החדש האחרון מול פתיחת השער ל-Wild/Joker. ימים בלי שום דבר שמזיז את השער: 0 / ~1 / ~7 | ✅ `royal-dip` |
| 12 | Domino and Disney End 2–3 Royals and 4–5 Goldens Short | ×3: נתח הנאסף בסוף. רייר 76% / 64% / 65%, גולדנס 94% / 83% / 83% | 🔀 מיזוג `royals` + `goldens` (או `progression-type` שמחוץ ל-order) |
| 13 | Current Snapshot + Recommendation | 10 מול 5 ימים · 4–5 גולדנס חסרים | ✅ `snap-ch1` |
| **צעד 4: התוצאה** ||||
| 14 | The Result: Few Finishers, Little Finisher Revenue | שאלה + יעד: ~10% מסיימים, ≥30% הכנסות | ✅ `q-ch2` |
| 15 | No Game Reaches the Target | ×3 עמודות מול קו יעד, ממוצעים: מסיימים 9.3% / 5.1% / 4.0% · נתח הכנסות 26% / 26% / 18% | 🔀 `target` עם הממוצעים מ-`disney-finishers` (טווחים להערות) |
| 16 | Current Snapshot + Recommendation | | 🔀 `rec-ch4` (היום המלצה רק לדיסני) |
| **צעד 5: איפה השחקנים עומדים** ||||
| 17 | Where Do Our Players Stand 3 Days Before Close? | שאלה | ✅ `q-stand` |
| 18 | 3 Days Before Close, Half of Revenue Is Still 4+ Stickers Away | ×3 לפי קבוצת $ ליום: 41% / 47% / 53% (ב-4 ימים: 55/57/56%). יום אחד מזיז Dice 14 נק', Domino 10, Disney 3 | ✅ `stand` |
| 19 | Current Snapshot + Recommendation | | ✅ `snap-ch5` |
| **צעד 6: יעדים לפי אוכלוסייה (דייס כדוגמה)** ||||
| 20 | How Should We Set Targets? | שאלה | ✅ `q-ch8` |
| 21 | In Dice, Stronger Payers Finish More: 6% to 27% ⚠️ | Dice: % מסיימים לפי $ ליום ($0 / ≤2 / 2–5 / 5–20 / 20+). דומינו ודיסני קטנים בצד או בהערות | 🔀 `groups` (היום מקובץ לפי האלבום הקודם, בסתירה להמלצה) |
| 22 | Spend in This Album Predicts the End Better Than the Last Album | Dice: האלבום הקודם 58% שטוח · הוצאה עד עכשיו 63% ב-25%, 86% ב-75%. אותו דבר בשלושת המשחקים | ✅ `predictor` (Dice במרכז) |
| 23 | Targets Count Revenue, Not Players | ‎$5+ ליום = 14% מהמשלמים, 58% מההכנסות | ✅ `weighting` (+ "האג'נדה" בהערות) |
| 24 | One Multiplier Lifts Every Group to the 10% Target ⚠️ | יעד לכל קבוצה = העבר שלה × מכפיל אחד | 🔀 `multiplier` (×1.19 לא מתיישב עם 9.3%) |
| 25 | Current Snapshot + Recommendation for Dice | רק הוצאה בתוך האלבום · רבעון אחרון · 5 קבוצות לפי $ ליום · שקלול לפי הכנסות | 🔀 `snap-ch8` |
| **סיום** ||||
| 26 | Decide Now: No Test Needed | 6 החלטות | ✅ `decisions` (ליישר למספור הצעדים) |
| 27 | Test Next, in This Order | טבלת טסטים | ✅ `tests` (ליישר) |
| 28 | Built the Same, Ending Differently | המסר אחד ליציאה מהחדר | 🔀 `closing` (היום ממוקד דיסני) |

## נספח A: מעניין אבל לא מרכזי (מסודר לפי צעדים)

| כותרת | מקור |
|---|---|
| Appendix divider | 🔀 `q-more` |
| (1) Last-4-day revenue level: Dice rising, Disney falling ⚠️ | 📎 `album-trend` |
| (1) Last 10% vs average day | 📎 `album-shape` |
| (1) 7+ players lift the same: not a new-player effect | 📎 `endlift-7` |
| (1) Who plays the album (tenure) | 📎 `tenure` |
| (2) Domino 17 finished through the week | 📎 `domino-weeks` |
| (2) Closing tools table | 📎 `closing-tools` |
| (2) With / without a Wild/Joker: ×1.5–2.0 vs ×0.4–0.6 | 📎 `routes` |
| (2) Disney Royal 131 gate | 📎 `tangled` |
| (3) Same album, different rares and gate | 📎 `template` |
| (3) Dice Golden sale 7 days before close | 📎 `goldens-week` |
| (3) New stickers per day, last third | 📎 `progression` |
| (3) Dice gives rares sooner and more often | 📎 `rares-pace` |
| (3) The Super is Dice's gate by design | 📎 `dice-gate` |
| (4) Disney finishers pay like Dice finishers | 📎 `disney-finishers` |
| (4) Same starting point, Disney finishes half as often | 📎 `half-completions` |
| (4) Same spend, fewer completions | 📎 `same-spend` |
| (5) Up to 43% of revenue ends far | 📎 `far-revenue` |
| (5) Far players fade after rares stop | 📎 `keep-playing` |
| (6) Dice pre-album level vs actual spend | 📎 `history` |
| (6) The album moves results more than the segment | 📎 `album-effect` |
| (6) Fix these before segments drive targets | 📎 `fixlist` |
| Open checks | 📎 `open-checks` |
| After close: finishers keep paying | 📎 `finishers-hold` |
| Just-missed players pay less after close | 📎 `staircase` |
| Heavy payers who just miss | 📎 `heavy-missers` |
| They slow down before close | 📎 `give-up` |
| Domino: almost half of finishers did not pay | 📎 `nonpayer-share` |
| Non-payers, not lost payers | 📎 `not-lost` |
| Domino 20: twice the finishers | 📎 `domino-easier` |
| Two Puzzle Jokers cost little | 📎 `puzzle-joker` |

## נספח B: שאלות שהנתונים דחו (בסוף)
✅ `q-rejected` · ✅ `rejected` · ✅ `length`

## יוצאות ❌
`q-intro`, `learned` (המספרים עוברים ל-2), `endlift` (≈2% מהכנסות האלבום עובר להערות של 4), `rec-ch6`, `snap-ch7` (סנאפשוטים בנספח). כפולים מחוץ ל-order: `album-curves`, `progression-type` (אלא אם בוחרים בה ל-12), `q-ch4`–`q-ch7`, `snap-ch2`. אם `royals`/`goldens` מתמזגות, שתיהן יוצאות.

**סה"כ:** 28 ראשי + 31 נספח A + 3 נספח B = 62 (היום 75). בלי שקופיות הסנאפשוט לכל צעד: 22 בחלק הראשי.

---

## ⚠️ החלטות שצריך ממך

1. **צעד 1, הנתונים לא תומכים ב"אין עלייה בכלל" בשלושת המשחקים.** בדייס יש עלייה בכל אלבום (59–63: ‎+15–20%), והרמה המוחלטת ב-4 הימים האחרונים אפילו עלתה ($1.30 → $1.58). מה שנכון בשלושתם: העלייה **נחלשת**. בדייס היא ירדה מ-+31/+33 (53/57), בדומינו היא קופצת בין +6 ל-+32, ובדיסני היא כמעט אפס מאלבום 11. הצעה: כותרת "fading", ו-`album-trend` לנספח עם הערה. גם בהערות: עלייה של ×1.2 שווה לכל היותר ≈2% מהכנסות האלבום, אז הסוף חשוב כסימן לבעיית השלמה יותר מאשר ככסף בפני עצמו.
2. **צעד 3, הניסוח.** "משתחררים מאוחר מדי" (שער Royal 131 נפתח לג'וקרים רק בסוף) או "מפסיקים להגיע מוקדם מדי" (הרויאל החדש האחרון לשחקנים רחוקים מגיע כ-10 ימים לפני הסגירה)? בדק שמוצג עכשיו כתובים שני הניסוחים. הצעה: "Stop Coming Before the End".
3. **צעד 5 מול צעד 6: 3 או 4 ימים?** `stand` מודדת ב-3 ימים, אבל הגדרת היעד ב-`weighting` היא 4 ימים לפני הסגירה. צריך הגדרה אחת.
4. **צעד 6, `groups` מקובצת לפי האלבום הקודם.** זה בדיוק מה שההמלצה אומרת לא לעשות. בהערות כתוב ש"קיבוץ לפי הוצאה בתוך האלבום נותן תמונה דומה", אבל המספרים לא מופיעים בדק. צריך לבדוק אם הם כבר קיימים בפרויקט (`finisher-targets-by-group`). אם לא, זו שאילתה חדשה, ואביא אותה לאישור עם dry run.
5. **המכפיל של דייס:** ×1.19 לא מתיישב עם 9.3% (10 ÷ 9.3 = ×1.08; ‎×1.19 מניח בסיס של 8.4%). צריך לבדוק מאיזה בסיס הוא חושב לפני שהשקופית נשארת.
6. **שקופיות סנאפשוט לכל צעד:** להשאיר 6 (הסגנון שלך) או לקצר ל-22 שקופיות ראשיות ולשים סנאפשוט אחד לפני ההחלטות?
7. **אלבומים לא עקביים בצעד 4:** שיעור מסיימים בדומינו מ-17/19, נתח ההכנסות מ-19/20. הצעה: 19/20 בכל מקום. לבדוק שהמספר קיים.

---

## המידע שיש לי, לפי צעד (מתוך הדק וההנדאוף)

**1. הבעיה**: עלייה בסוף (4 ימים אחרונים מול כל האלבום, הכנסה ליום פעיל): Dice ‎+9% עד +33% (12 אלבומים, 59/61/63 = ‎+18/+15/+20), Domino ‎+6% עד +32% (16 = ‎+6), Disney ‎−1% עד +35% (11–14 = ‎+3/+3/+2/−1; 15 = ‎+8). רמה מוחלטת: Dice $1.30 → $1.58, Domino $0.87 → $1.06, Disney $1.21 → $0.98. גם שחקני 7+ בדיסני כמעט לא עולים (‎+2% עד +8%). ה-10% האחרונים: Dice ×1.23, Domino ×1.16, Disney ×1.06. גודל: ≈2% מהכנסות האלבום, עד ≈$0.7M לאלבום בדיסני (חסם עליון).

**2. 3 ימים אחרונים**: מסיימים משלמים ב-3 הימים האחרונים: Dice 84–88%, Domino 17 ‏63% / 19 ‏93% / 20 ‏85%, Disney 99%. כלי הסגירה במכירה: Dice מ-7 ימים (4.3–4.7K קונים ביום), Domino 5–7, Disney 2–3. בלי Wild/Joker ההוצאה יורדת ל-×0.4–0.6 וכמעט אף אחד לא מסיים. Disney 14: ‏Royal 131 מתמלא בג'וקר 1–48 פעמים ביום עד 4 ימים לפני הסגירה, מול 300–400 לרויאלס אחרים.

**3. רויאלס/גולדנס**: הרייר החדש האחרון לשחקנים משלמים רחוקים (P50–95): Disney/Domino ‏~10–11 ימים לפני הסגירה, Dice ‏~5–6. ימים בלי שום דבר שמזיז את השער: 0 / ~1 / ~7. בסוף: רייר 76% / 64% / 65%, גולדנס 94% / 83% / 83%. Dice פותח מבצע גולדן 7 ימים לפני הסגירה (12K → 45K שחקנים).

**4. תוצאה**: מסיימים 9.3% / 5.1% / 4.0% (יעד ~10%). נתח הכנסות 26% / 26% / 18% (יעד ≥30%). אותה נקודת פתיחה (חסרים 2–3): ‏39% / 47% / 21% מסיימים.

**5. מעמד**: הכנסות 4+ רחוקות, 3 ימים לפני הסגירה: 41% / 47% / 53% (ב-4 ימים: 55/57/56%). יום אחד מזיז Dice 14 נק', Domino 10, Disney 3. בסגירה: עדיין 24% / 35% / 43%, רובן ממשלמים בינוניים.

**6. יעדים**: מסיימים לפי $ ליום, Dice: ‏6% / 7% / 14% / 17% / 27% (Domino עד 35%, Disney עד 21%). חיזוי: האלבום הקודם 55–58% שטוח, הוצאה עד עכשיו 63% ב-25% מהאלבום ו-86–88% ב-75%, בשלושת המשחקים. ‎$5+ = 14% מהמשלמים, 58% מההכנסות. ‎$20+ = 2% מהמשלמים, 24% מההכנסות.
