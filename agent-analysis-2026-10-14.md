# ניתוח אלבומים מרובה-סוכנים — 2026-10-14

**הרכב:** 4 אנליסטים במקביל (Dice 61/63, Domino 17/19, Disney 14/15, Cross-game) + Critic שבדק כל טענה והריץ מחדש 3 מספרים מרכזיים. כל המספרים כאן כבר מתוקנים לפי ה-Critic.
**אוכלוסייה:** PU, login ratio ≥ 0.5, יום הסגירה מוחרג, עבודת rares = לא באלבום ראשון. "סיים" = 144 מדבקות ייחודיות לפני הסגירה (לא הדגל של המשחק).

## 1. לפי סטודיו

### Dice (61/63)
**ממצאים**
- **הסופרים האחרונים נעולים בלוח השחרור, לא במזל.** באלבום 63 אף PU לא החזיק יותר מ-10 סופרים עד יום 32/42, ואף אחד לא הגיע ל-12 לפני יום 36. *Known* לגבי התקרה; *Hypothesis* שזו נעילה מתוכננת (צריך את לוח השחרור).
- **ב-Q4, 66–78% מימי ה-PU הם עם 9 סופרים או פחות.** ה-ARPDAU עולה מ-$1.6 (0–7 סופרים) ל-$9–11 (11 סופרים). *Fact only*: זה סלקציה, לא אפקט.
- **ב-72% / 82% מהמסיימים, מדבקת הסופר האחרונה מגיעה עד 10 דקות אחרי רכישה.** תזמון *Known*. שהרכישה היא שקנתה את הסופר זה *Needs Validation*: ה-Critic דחה את ה-placebo, ולכן פריט 2 נשאר פתוח.
- **Easy הם כ-70% מה-PU ו-29–31% מהכנסות ה-PU.** רובם לא מגיעים לשער. *Known*.
- **שיעור סיום PU: 8.1% / 10.5%** (תוקן מ-11.5% / 13.5%, ראו סעיף 3). *Known*.
- אין דליפה אחרי סיום: החציון מסיים ב-94–95% מזמן האלבום. *Known*.

**המלצות**

| פריט | סטטוס |
|---|---|
| A. השלמת סופר (catch-up) ב-Q4 ל-PU עם 9 סופרים או פחות, למשל Trail final reward או Wild זול. Primary: PU ARPDAU ב-Q4. Guardrails: קניבליזציה אצל PU עם 10+ סופרים, שיעור סיום, D7 באלבום הבא. | **Test** |
| B. שחרור הסופרים האחרונים ב-75% מזמן האלבום במקום 86%. | **Do Not Adopt Yet** (עד אישור לוח השחרור) |
| C. יותר משבצות סופר (12→N). קריאת התוצאות לפי Easy מול Medium+. | **Test** (הראיה עדיין NV) |

### Domino (17/19)
**ממצאים**
- **תשובה לשאלה הפתוחה: לא. הרויאלים הם לא השער הסופי כמו הסופרים ב-Dice.** השער הוא פאזת השחרור האחרונה, phase 6 (7 מדבקות Golden/Royal). הרכב השער משתנה לפי אלבום:
  - אלבום 17: השער גולדני. 83% מהמדבקות האחרונות הן Golden.
  - אלבום 19: השער רויאלי. 51% מהמדבקות האחרונות הן Royal.
  - *Known* שהשער הוא phase 6; *Hypothesis* שזה release gate.
- **מדבקות phase 6 מגיעות ממש בסוף.** באלבום 19 החציון מקבל את רויאלי ה-gate ביום 48 מתוך 49, ורק 9–10% מה-PU מחזיקים אותם בסגירה. *Known*.
- **34–37% מה-PU מסיימים 1–5 מדבקות לפני השלמה, והם מביאים 47–52% מהכנסות ה-PU.** *Known*.
- **שיעור סיום PU: 5.7% / 4.5%.** ההוצאה אחרי סיום היא כ-3% בלבד. *Known*.
- **`album_spent_today` = הכנסה ברוטו** (יחס 0.99 מול in-app + Stripe). זה סוגר את הפריט הפתוח. *Known*.
- **רמות ה-ARPDAU של האנליסט מוטות כלפי מטה ב-~10%** (חושבו על rows ולא על ימים פעילים). לכן *Needs Validation*, וצריך לחשב מחדש לפני הדק.

**המלצות**

| פריט | סטטוס |
|---|---|
| 1. שחרור phase 6 כשבוע מוקדם יותר. | **Do Not Adopt Yet** (עד אישור חוקי הפאזות) |
| 2. הצעת "בחר את מדבקת השער" (Specific ל-Golden, Joker ל-Royal) מ-close−7 ל-PU שחסרות להם עד 5 מדבקות. Primary: PU ARPDAU ב-7 הימים האחרונים. Guardrails: ARPDAU של כל האלבום, ARPDAU באלבום הבא. | **Test** |
| 3. Royal מול Golden כשער הסופי. n קטן (112/183), אז רק כזרוע של בדיקה 1. | **Do Not Adopt Yet** |

### Disney (14/15)
**ממצאים**
- **השער הוא "שלישייה נעולה": Royal 131 ועוד 2 Goldens.** בסגירה−5, 99% מה-PU שחסרות להם 1–3 מדבקות מחכים לרויאל אחד, וב-100% / 93% מהמקרים זה 131. 81% / 90% מהם חסרים בדיוק 3 מדבקות. *Known* (אומת בהרצה מחדש).
- **131 משתחרר רק בסוף, דרך Joker.** רק 35K / 44K שחקנים קיבלו אותו, לעומת 0.6–1.36M לכל אחד מהרויאלים האחרים. *Known*. "100% דרך Joker" זה חסם עליון בלבד, ולכן *NV*.
- **למה ה-lift בסוף האלבום שטוח: זו בעצם צניחה.** מול אותם ימים בשבוע מוקדם יותר באלבום, 4 הימים האחרונים הם 0.87× / 0.94×, ו-pay rate יורד. המספרים *Known*. ההסבר ("לא מגיעים לרויאל") הוא *Hypothesis*.
- **המרה בסוף, השוואה זהה (חסרה מדבקה rare אחת):** ב-Disney 61% / 75% שילמו ב-4 הימים האחרונים, מול 83–85% ב-Dice. *Known*.
- **שיעור סיום: 3.8% / 4.1%**, הנמוך מבין שלושת המשחקים. 45–61% מה-PU רחוקים 4–10 מדבקות מהשלמה. *Known*.

**המלצות**

| פריט | סטטוס |
|---|---|
| A. הצעת Joker / רויאל אחרון ממוקדת מ-close−7 ל-PU שחסרות להם 1–3 מדבקות. Primary: PU ARPDAU מ-close−7 עד close−1. Guardrails: Market, שיעור סיום, האלבום הבא. | **Test** |
| B. שחרור 131 באמצע האלבום דרך אירוע (כמו Sugar Rush ביום 32 באלבום 15). | **Do Not Adopt Yet** (עד אישור הקונפיג) |
| C. החלפת כפולים לרויאל מ-close−10. Disney הוא המשחק היחיד בלי החלפת כפולים בכלל. | **Test** |

## 2. Cross-game: ההבדלים הגדולים ומה כל סטודיו יכול ללמוד

1. **השער הסופי הוא תמיד השלישייה / הפאזה הנעולה האחרונה, אבל הרכב ה-rarity שלה משתנה.**
   - Dice: Super (71–83% מהמדבקות האחרונות).
   - Disney 14: Royal (81%).
   - Domino 17: Golden (83%).
   - Domino 19 ו-Disney 15: מעורב.
   - *Known*. זו המסגרת המאחדת שכדאי להציג בדק.
2. **Dice מחזיק את המשלמים ליד השער, השניים האחרים משאירים אותם רחוק.**
   - PU שסיימו 1–3 מדבקות לפני השלמה: Dice 35% / 54%, Domino 15% / 13%, Disney 19% / 15%.
   - שיעורי סיום: Dice 8.1–10.5%, Domino 4.5–5.9%, Disney 3.8–4.1%.
3. **הסיום דחוס לסוף בכל המשחקים.**
   - אחוז המסיימים שקיבלו את המדבקה האחרונה ב-4 הימים האחרונים: Disney 99.95%, Domino 19 98%, Dice 92–94%.
   - רק ב-Domino 17 יש מסיימים מוקדמים (10% סיימו 7+ ימים לפני הסוף).
   - ההוצאה אחרי סיום זניחה בכולם.
4. **מנגנוני סגירה למי שתקוע.**
   - החלפת כפולים: ב-Domino היא נותנת 23–30% מהרויאלים החדשים ב-Q4, ב-Dice 3–12%, וב-Disney 0.
5. **המרה של מי שחסרה לו מדבקה rare אחת:**
   - שילמו ב-4 הימים האחרונים: Dice 83–85%, Domino 81% / 91%, Disney 61% / 75%.
   - סיימו: Dice 68–70%, Domino 61% / 76%, Disney 22% / 55%.

**מה כל סטודיו יכול לאמץ (הכל כ-Test, לא כאימוץ ישיר):**
- **Disney ← Dice:** לפתוח מסלול לרויאל האחרון מוקדם יותר (הצעה ממוקדת / שחרור מוקדם).
- **Disney ← Domino:** החלפת כפולים לרויאל בשבוע האחרון.
- **Dice ← Domino:** החלפת כפולים לסופר ב-Q4. זה מתנגש עם בדיקת משבצות הסופר, אז להריץ בנפרד.
- **Domino:** להחליט אם phase 6 נועד להיות גולדני או רויאלי. כרגע זה משתנה בין אלבומים בלי כוונה ידועה.

## 3. מה ה-Critic שינה או דחה

- **שיעור סיום Dice תוקן ל-8.1% / 10.5%** (במקום 11.5% / 13.5%). הדגל `is_album_finisher` כולל:
  - סיומים ביום הסגירה (~2pp).
  - ~3pp שהדגל שלהם נדלק בלי 144 מדבקות ייחודיות.
  - הסטנדרט מעכשיו: ספירת 144 מדבקות ייחודיות לפני הסגירה.
  - הערת ה-Dice analyst שהגדרת הדגל "מפספסת" סיומים נדחתה. הכיוון הפוך: הדגל סופר יותר מדי.
- **"רכישה ← סופר אחרון" ירד מ-Known ל-NV.**
  - placebo של הזזה ב-24 שעות חלש מדי.
  - הבקרה הנכונה: חלון 10 דקות לפני מדבקת ה-Golden/Common האחרונה של השחקן באותו יום.
  - פריט 2 נשאר פתוח.
- **Domino:**
  - העמודה אומתה כהכנסה ברוטו. ההסתייגות "coins" של ה-Cross-game analyst נדחתה.
  - רמות ה-ARPDAU מוטות כלפי מטה ב-~10% (rows במקום ימים פעילים), ולכן לחשב מחדש.
- **נדחו כמעגליים או לא תואמים:**
  - "<1% מאלה שחסרות להם 2–5 מדבקות מסיימים" (Domino). מעגלי: "חסר בסגירה" נמדד על השורה האחרונה, אז הם לא סיימו מעצם ההגדרה.
  - השוואת ההמרה 55–64% ב-Disney מול 82–84% ב-Dice. הקבוצות לא תואמות, והוחלפה בהשוואה של "חסרה מדבקה rare אחת" (61% / 75% מול 83–85%).
- **"131 100% דרך Joker" ירד ל-NV.** ה-HAVING ≥ 200 מוציא מקורות קטנים מהמכנה, אז זה חסם עליון בלבד.
- **כל מנופי תזמון השחרור ירדו ל-Do Not Adopt Yet** עד שהסטודיו יאשר את לוח השחרור: Dice B, Domino 1, Disney B ו-Cross-game 1.
- **"Domino: gate עקבי"** ירד ל-Do Not Adopt Yet בגלל n קטן.
- **דגל ה-Joker ב-Domino** (40% מול 97%): לא להציג בשקף עד שהסטודיו יאשר את ההגדרה.

## 4. שאלות פתוחות לסטודיו (מאוחד)

**Dice**
- לוח שחרור הסופרים ב-61/63: אילו נעולים ועד איזה יום?
- האם הנעילה ההדוקה ב-63 מכוונת?
- אילו מקורות Wild בתשלום?
- האם יש pity לסופרים?

**Domino**
- האם phase 6 נעול בזמן? האם 17 (Golden) ו-19 (Royal) תוכננו כך?
- מה ההגדרה של `collected_by_joker_flag` אחרי Royal Tower?
- לתקן את ה-dbt doc של `album_spent_today`.
- חלוקת Easy/Hard של הנעילות.

**Disney**
- האם 131 מוחרג מהפאקים בכוונה?
- מה לוח שחרור הרויאלים?
- האם ה-Market בכסף אמיתי?
- האם Sugar Rush ביום 32 היה מכוון?
- האם החלפת כפולים טכנית אפשרית?
- לאשר שעמודת ה-spend היא USD.

## 5. הצעדים הבאים לפני הדק

1. לחשב מחדש את רמות ה-ARPDAU של Domino על `active_flag`.
2. להריץ placebo נכון ל"רכישה ← סופר אחרון" ב-Dice.
3. לבדוק את עמודת ההכנסה ב-Disney.
4. לנסח מחדש את כותרות הגרפים שנשמעות סיבתיות (למשל "too far for the gate to work").
5. לקבל לוחות שחרור משלושת הסטודיו. זה פותח את כל מנופי התזמון.

---
# Appendix — full agent outputs (English, unedited; Critic corrections in section 3 above take precedence)

---

# Critic / validator review of the album analysts (Dice 61/63 · Domino 17/19 · Disney 14/15)

I re-ran three numbers independently. All three reproduce. Each re-run also turned up a problem with a definition or denominator that changes some of the analysts' claims.

## 1. Claims reviewed

| Analyst | Claim | Orig. label | Verdict | New label | Reason |
|---|---|---|---|---|---|
| Dice | PU finish rate 11.5% (61) / 13.5% (63); Easy PU finish 9%; Extreme 27–34% | Known | **Downgrade** | Known after restating | These come from `is_album_finisher`, a user-level flag that includes players who finished on the close day (~2 pp). It also includes ~0.8 pp whose flag fired before close without 144 unique stickers. That breaks the close-day-excluded rule. Re-run 1, not-first PU, 144 unique stickers before close: **8.1% / 10.5%**. Restate the segment finish rates the same way. |
| Dice | Data note: "finish_ts NULL undercounts sticker-only finishers" | NV | **Reject** | — | The gap runs the other way. The flag over-counts compared with the sticker count (re-run 1). |
| Dice | Last Supers locked: P99 ≤ 10 until day 32/42 (63) | Known (data) / NV (calendar) | Keep | Known (ceiling) / **Hypothesis** (that it is a design lock) | The ceiling is measured only on not-first PU with login ≥ 0.5. The release calendar has not been confirmed. |
| Dice | Q4 ARPDAU rises with Supers held ($1.6 → $10.9) | Known | Keep, reword | Known, **Fact only** | This is selection: high spenders accumulate Supers. The deck title "too far for the gate to work" is causal and must be rewritten. |
| Dice | A purchase falls ≤ 10 min before the last Super for 72% / 82%; placebo 0.7–1.0%; "closes item 2"; upgrades "gate closed via Wild offers" to Known | Known | **Downgrade** | Known (timing) / **Needs Validation** (the purchase bought the Super) | A ±24h shift is a weak placebo. A payer's sticker pulls come from packs, which often come from purchases. The right control is the same 10-minute window before the player's last Golden or Common on the same day. The paid-Wild link is not identified by any source or offer ID. Item 2 stays open. |
| Dice | Easy ≈ 70% of PU and 29–31% of PU revenue; ARPDAU by segment | Known | Keep | Known | The population is all PU, first album included. Say so. |
| Dice | Two albums' PU ARPDAU $3.34 vs $3.30 | Known | Keep, add a note | Known | The population must be stated. Not-first PU ARPDAU in my re-run is $3.12 / $3.08, and first-album PU are $4.59 / $4.60. |
| Dice | No early-finisher leak: median finish at 94–95% of album time | Known | Keep | Known | Consistent with cross-game (92–94% get the last sticker in the final 4 days). |
| Domino | `album_spent_today` = gross revenue | Known | **Keep, confirmed** | Known | Re-run 2: spend ÷ (in-app + Stripe) = 0.988–0.999. |
| Domino | All ARPDAU levels: $2.97 → $7.08 by Royals held, pre-window ARPDAU $10.3 / $7.8 / $34.6 / $25.8, Q2 ARPDAU | Known | **Downgrade** | Needs Validation (levels) | The denominator is `COUNT(*)` rows, not active days. Only 89.3–90.2% of PU rows are active, so every level is understated by about 10%. Veteran PU: rows $2.53 / $2.35 vs active $2.82 / $2.63. Within-query ratios hold approximately. Re-run with `active_flag`. |
| Domino | Album 17's gate is mostly Golden; album 19's is Royal-led | Known | Keep | Known | Matches cross-game: last sticker Golden 83.4% vs 83.7%; album 19 Royal 50.9% vs 50.7%. |
| Domino | The gate is phase 6 and the late arrival is deliberate | Known / Hyp | Keep | Known (phase field) / **Hypothesis** (release gate) | The phase field is populated for Domino, unlike Disney. Release dates are not in the data. |
| Domino | 34–37% of veteran PU end 1–5 short and bring 47–52% of PU revenue | Known | Keep | Known | OK. |
| Domino | "Fewer than 1% of those missing 2–5 finish" | Known | **Reject** | — | Circular. "Missing at close" is measured on the last row, so these players have not finished by definition. |
| Domino | PU finish 5.7% / 4.5% vs Dice 11.5–13.5% | Known / NV | **Reject the comparator** | Known (Domino) | Domino reproduces: 5.74% / 4.47% (re-run 2). The Dice comparator is flag-based and inflated. Like for like it is **8.1% / 10.5%**. |
| Domino | Joker share of the last 3 stickers 40% vs 97% | NV | Keep | Needs Validation | The flag's meaning may have changed with the Royal Tower launch. That puts cross-game "via Joker 45% / 96%" at risk too. |
| Domino | Royal- vs Golden-blocked in the last 4 days: 91% vs 85% paid, $71 vs $56 per paying day | Known | Keep | Known, n = 112 / 183 | Too small for any lever. Do Not Adopt Yet is correct. |
| Disney | 99% of payers 1–3 short at close−5 miss exactly one Royal, which is 131 | Known | **Keep, add context** | Known | Reproduces (re-run 3). But 81% (album 14) and 90% (album 15) of this group are **exactly 3 short**: 131 plus two other stickers, consistent with a locked trio of 1 Royal + 2 Goldens. The gate is the trio, not 131 alone. |
| Disney | 131 receipts 100% Joker-filled (album 14) | Known | **Downgrade** | Needs Validation | Q4 runs `HAVING COUNT(*) ≥ 200` before the window share, so small sources drop out of the denominator. 100% is an upper bound. |
| Disney | End-of-album dip: 0.87× / 0.94× against weekday-matched windows | Known | Keep | Known (numbers) / **Hypothesis** ("because payers can't reach the Royal") | Good weekday control. The explanation is causal. |
| Disney | 1–3-short Royal-missing payers 55% / 64% paid vs Dice 82–84% | Known | **Downgrade** | Known after restating | Not like for like: Disney's group is 1–3 short, Dice's is 1 short. Like for like (one short): **Disney 61% / 75%** (re-run 3) or 62% / 76% (cross-game), against Dice 83–85%. The direction holds. |
| Disney | Market supplies 67% of 131 | Known | Keep | Known; whether it is paid is Missing | Market currency is unknown. |
| Cross-game | Domino album spend is documented as "coins", so cross-game levels are unsafe | NV | **Reject for Domino** | Known (gross) | Re-run 2. Disney is still unchecked and stays Needs Validation. |
| Cross-game | Finish rates: Dice 8.7–10.4, Domino 4.5–5.9, Disney 3.8–4.1 (144 unique stickers) | Known | Keep | Known | Re-run 1 confirms the definition. Use these as the cross-game standard. |
| Cross-game | Disney's ending is release-gated: 99.95% of finishers get the last sticker in the final 4 days | Known | Keep | Known (timing) / Hypothesis ("gated") | "Release-gated" needs the calendar. |
| Cross-game | One rare short at close−5: Disney 14 finishes 22%, n = 1,064 | Known | **Keep, confirmed** | Known | Re-run 3, not-first PU: n = 1,009, 21.9% finished, 61% paid. |
| Cross-game | Finishers' last sticker via Wild/Joker | Known | Downgrade for Domino only | NV (Domino) | Joker flag issue (see the Domino row above). |

**Status changes**
- **Release-timing levers → Do Not Adopt Yet until the release calendar is confirmed.** This covers Domino item 1 (phase 6 earlier), Disney item B (131 earlier) and cross-game item 1. It makes them consistent with Dice B.
- **Cross-game item 2 (Domino: make the final gate consistent): Test → Do Not Adopt Yet.** It is the same lever as Domino item 3, and the sample is small. Run it as an arm of the phase test once that is confirmed.
- **Dice C (more Super slots) stays Test,** but its evidence label goes back to Needs Validation (see the placebo row).
- **Unchanged:** Dice A (Test), Domino item 2 (Test), Disney A and C (Test, proposed), cross-game item 3 (Test; sequence it separately from Super slots).

## 2. Re-runs

| # | Number | Original | Re-run | Verdict |
|---|---|---|---|---|
| R1 | Dice PU finish rate (not-first, login ≥ 0.5, close day excluded) | Dice analyst: 11.5% / 13.5% (flag). Cross-game: 8.7% / 10.4% (144 stickers, all PU) | Flag 10.9% / 13.7%. **144 unique before close: 8.1% / 10.5%.** Flag finish date = close day: 1.9% / 2.3%. Flag set but < 144 before close: 2.8% / 3.3%. | **The flag violates close-day exclusion.** Use the sticker-count definition. Cross-game is right. |
| R2 | Domino revenue column and PU ARPDAU denominator | Domino analyst: spend = gross ±1–3%; ARPDAU on rows. Cross-game: "coins" | Spend ÷ gross = 0.988–0.999. PU ARPDAU on rows vs active days, veteran: 17: $2.53 vs **$2.82**; 19: $2.35 vs **$2.63**. Active share of rows 0.89–0.90. Spend on inactive rows 0. Veteran finish (144): 5.74% / 4.47% | Revenue column **confirmed**. Domino **ARPDAU levels understated ~10%**, so re-run on active days. Finish rate confirmed. |
| R3 | Disney 131 gate (not-first PU, 1–3 short at close−5) | Disney analyst: 48,905 / 30,823 Royal-missing; 131 for 100% / 93%; 13% / 18% finish | Total 1–3 short: 49,247 / 32,197, which equals 48,905 + 342 and 30,823 + 1,374 exactly. Missing 131 among the Royal-missing ≈ 99% / 93%. Exactly 3 short: 81% / 90%. One short: n = 1,009 / 171, paid 61% / 75%, finished 21.9% / 52% | Numbers **confirmed**. The framing changes to a locked trio (131 + 2). Album 15 one-short players are mostly not missing 131 (55%), which is why they finish 52% of the time. |

## 3. Contradictions between analysts and how to resolve them

1. **Dice finish rate, 11.5–13.5 vs 8.7–10.4.** Resolved by R1: the flag includes close-day and event-only finishes. Standard: 144 unique stickers before close. Dice analyst items B and C and Domino insight 4 should restate their finish rates. The 63 > 61 direction holds (10.5% vs 8.1%).
2. **Domino revenue column (gross vs "coins").** Resolved by R2: it is gross. Remove the caveat from cross-game. Keep it for Disney until that column is checked, and ask Domino to fix the dbt doc.
3. **Domino ARPDAU levels** (Domino analyst on rows vs cross-game on active days). Use active days. The Domino deck numbers must be regenerated.
4. **Disney vs Dice end conversion** (55–64% vs 82–84%). The cohorts are mismatched. Use the like-for-like one-short figures: Disney 61% / 75% vs Dice 83–85%.
5. **What the gate is** (Domino "phase 6" vs cross-game "Golden in 17"; Disney "131" vs cross-game "1 Royal + 2 Golden lock"). These are compatible. The unifying frame is that **the last locked trio or phase is the gate in every game; its rarity mix varies by album**. R3 supports this for Disney.
6. **Placebo.** Dice says item 2 is closed; I say it is not. Re-run with a Golden/Common last-pull control before the deck uses "Known".
7. **Joker flag** (Domino 40% vs 97%). Neither the Domino nor the cross-game Joker shares should go on a slide until Domino confirms the flag definition.

## 4. SQL appendix (critic re-runs; every query was dry-run first with identical SQL, read-only, partition-filtered)

**R1 — `dice-dreams-dbt`, 6.25 GB**
```sql
WITH b AS (
  SELECT album_id, user_id, date_dim, album_end_date, album_login_ratio, user_past_album_count,
    IFNULL(spent_in_album_today,0) AS sp, IFNULL(is_active,FALSE) AS act, is_album_finisher, user_album_finish_date,
    IFNULL(unique_common_stickers_lt,0)+IFNULL(unique_golden_stickers_lt,0)+IFNULL(unique_super_stickers_lt,0) AS u
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN '2026-06-22' AND '2026-09-07' AND album_id IN (61,63) AND IFNULL(is_excluded,FALSE)=FALSE),
u AS (
  SELECT album_id, user_id, ANY_VALUE(album_end_date) AS a_end,
    SUM(IF(date_dim < album_end_date, sp, 0)) AS rev_pre_close,
    COUNTIF(date_dim < album_end_date AND act) AS adays,
    ARRAY_AGG(IF(date_dim < album_end_date, album_login_ratio, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS lr,
    MAX(user_past_album_count) AS past, LOGICAL_OR(IFNULL(is_album_finisher,FALSE)) AS flag_fin,
    MAX(user_album_finish_date) AS fdate, MAX(IF(date_dim < album_end_date, u, NULL)) AS u_pre, MAX(u) AS u_any
  FROM b GROUP BY 1,2)
SELECT album_id, IF(past>0,'not_first','first') AS grp, COUNT(*) AS pu,
  ROUND(COUNTIF(flag_fin)/COUNT(*),4) AS fin_flag,
  ROUND(COUNTIF(u_pre>=144)/COUNT(*),4) AS fin_144_before_close,
  ROUND(COUNTIF(fdate < a_end)/COUNT(*),4) AS fin_date_before_close,
  ROUND(COUNTIF(fdate = a_end)/COUNT(*),4) AS fin_date_on_close,
  ROUND(COUNTIF(flag_fin AND IFNULL(u_pre,0)<144)/COUNT(*),4) AS flag_but_not144_preclose,
  ROUND(COUNTIF(u_any>=144)/COUNT(*),4) AS fin_144_incl_close,
  ROUND(SUM(rev_pre_close)/SUM(adays),3) AS pu_arpdau
FROM u WHERE rev_pre_close > 0 AND lr >= 0.5
GROUP BY 1,2 ORDER BY 1,2
```

**R2 — `domino-dreams-dbt`, 11.76 GB**
```sql
WITH ex AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN '2026-04-02' AND '2026-08-23' AND suspected_cheater_flag),
rv AS (SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0)+IFNULL(user_daily_stripe_amount,0) AS g
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN '2026-04-02' AND '2026-08-23'),
b AS (SELECT a.album_id, a.user_id, a.date_dim, a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today,0) AS sp,
    IFNULL(a.active_flag,FALSE) AS act, IFNULL(r.g,0) AS g,
    IFNULL(a.unique_common_stickers_lt,0)+IFNULL(a.unique_golden_stickers_lt,0)+IFNULL(a.unique_royal_stickers_tl,0) AS u
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  LEFT JOIN ex e ON e.user_id=a.user_id LEFT JOIN rv r ON r.user_id=a.user_id AND r.date_dim=a.date_dim
  WHERE a.date_dim BETWEEN '2026-04-02' AND '2026-08-23' AND a.album_id IN (17,19)
    AND a.special_user_flag=FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
u AS (SELECT album_id, user_id, SUM(sp) AS sp, SUM(g) AS g, COUNT(*) AS rows_, COUNTIF(act) AS adays,
    SUM(IF(act,0,sp)) AS sp_inactive_rows,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, MAX(u) AS u_end
  FROM b GROUP BY 1,2)
SELECT album_id, l.uac > 1 AS veteran, COUNT(*) AS pu, ROUND(SUM(sp)/SUM(g),4) AS spend_over_gross,
  ROUND(SUM(sp)/SUM(rows_),3) AS arpdau_rows, ROUND(SUM(sp)/SUM(adays),3) AS arpdau_active,
  ROUND(SUM(adays)/SUM(rows_),4) AS active_share_of_rows, ROUND(SUM(sp_inactive_rows)/SUM(sp),4) AS spend_on_inactive_rows,
  ROUND(COUNTIF(u_end>=144)/COUNT(*),4) AS fin_144
FROM u WHERE sp > 0 AND l.lr >= 0.5 GROUP BY 1,2 ORDER BY 1,2
```

**R3 — `solitaire-dreams-411507`, 24.10 GB**
```sql
WITH ex AS (SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN '2020-01-01' AND '2026-10-05' AND exclude_reason IS NOT NULL),
b AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, a.login_ratio, a.user_album_count,
    IFNULL(a.album_spent_today,0) AS sp,
    IFNULL(a.unique_common_stickers_lt,0)+IFNULL(a.unique_golden_stickers_lt,0)+IFNULL(a.unique_royal_stickers_tl,0) AS u,
    IFNULL(a.unique_royal_stickers_tl,0) AS r
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN ex e ON e.user_id=a.user_id
  WHERE a.date_dim BETWEEN '2026-07-13' AND '2026-10-04' AND a.album_id IN (14,15)
    AND a.special_user_flag=FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
p AS (SELECT album_id, user_id, ANY_VALUE(c) AS c,
    MAX(IF(date_dim <= DATE_SUB(c, INTERVAL 5 DAY), u, NULL)) AS u5,
    MAX(IF(date_dim <= DATE_SUB(c, INTERVAL 5 DAY), r, NULL)) AS r5, MAX(u) AS u_end,
    COUNTIF(date_dim >= DATE_SUB(c, INTERVAL 4 DAY) AND sp > 0) AS pd4
  FROM b GROUP BY 1,2
  HAVING SUM(sp) > 0 AND MAX(user_album_count) > 1 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
s131 AS (SELECT album_id, user_id, MIN(sticker_collected_min_date) AS d131
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
  WHERE sticker_collected_min_date BETWEEN '2026-07-13' AND '2026-10-04' AND album_id IN (14,15)
    AND user_collected_sticker_flag AND sticker_id = 131 GROUP BY 1,2)
SELECT p.album_id, 144 - p.u5 AS short_c5, COUNT(*) AS payers, ROUND(AVG(7 - p.r5),3) AS avg_royals_missing,
  ROUND(COUNTIF(7 - p.r5 = 1)/COUNT(*),4) AS exactly_one_royal_missing,
  ROUND(COUNTIF(s.d131 IS NULL OR s.d131 > DATE_SUB(p.c, INTERVAL 5 DAY))/COUNT(*),4) AS missing_131_at_c5,
  ROUND(COUNTIF(p.pd4 > 0)/COUNT(*),4) AS paid_last4, ROUND(COUNTIF(p.u_end >= 144)/COUNT(*),4) AS finished_c1
FROM p LEFT JOIN s131 s ON s.album_id=p.album_id AND s.user_id=p.user_id
WHERE 144 - p.u5 BETWEEN 1 AND 3 GROUP BY 1,2 ORDER BY 1,2
```

Total scanned by the critic: 42.1 GB across 3 queries, each under 100 GB.

**Worth saving to memory:**
- **Dice finish definition:** `is_album_finisher` includes close-day finishes. The standard is 144 unique stickers before close: not-first PU 8.1% (61) / 10.5% (63).
- **Domino revenue and ARPDAU:** `album_spent_today` equals gross revenue (98.8–99.9%). ARPDAU must use `active_flag`, because rows include about 10% inactive days.
- **Disney gate:** players 1–3 short at close−5 are mostly exactly 3 short. They miss the locked trio (Royal 131 plus two others), not 131 alone.
---

# Dice Dreams albums 61/63: what limits payers and monetization (Dice analyst)

Project `dice-dreams-dbt`. Population: payers (PU), not excluded, login ratio on the last row before close ≥ 0.5, close day excluded. "Not-first" means `user_past_album_count > 0`. Revenue = `spent_in_album_today`. This builds on the Supers one-pager (12 Oct) and Topic 4/5; it does not redo them.

## 1. Top 5 insights

1. **The last Supers are locked behind the release schedule, not luck.** Population: not-first PU.
   - **Album 63:** no payer held more than 10 Supers until day 32 of 42 (76% of album time). Nobody held 12 before day 36 (86%). The sticker maximum stayed at 141 of 144 until day 36. **Known** (from data). Whether this matches the design release calendar is **Needs Validation**.
   - **Album 61:** looser. One payer reached 12 by day 17, but P99 stayed ≤ 9 until day 28 and the maximum was 143 until day 29.
   - Also in 63's Q3, payers holding 8–9 Supers got a new one on only 4–6% of active days, against about 21% for payers holding 0–7. **Known**.
2. **The end-of-album Super gate reaches only a minority of payer-days.** Population: not-first PU, Q4 (the last 25% of album time). **Known**.
   - Payer-days by Supers held: 0–7 is 51% (61) / 34% (63); 10–12 is 12% / 22%.
   - ARPDAU: $1.6–1.7 at 0–7 Supers, $4.8–6.8 at 10, $9.4–10.9 at 11.
   - In Q4, a new Super for a player holding 10–11 lands on a paying day 87–95% of the time. For players holding 0–8 it is 29–37%.
3. **The purchase before the last Super is real, not coincidence.** Population: not-first PU who end with 12 Supers. **Known** (timing; there is no shared ID between purchase and sticker).
   - 72% (61) / 82% (63) had a purchase in the 10 minutes before their last Super.
   - Placebo, same window shifted 24h or 48h earlier: 0.7–1.0%. That is about 70–80 times the base rate.
   - For payers who end below 12, the last Super came through a Wild only 11% of the time.
   - This closes open validation item 2.
4. **Easy payers are about 70% of PU but bring 29–31% of PU revenue, and most never reach the gate.** Population: all PU, plus not-first PU at close−5. **Known**.
   - PU ARPDAU by segment: Easy $1.41–1.53, Medium $3.8–3.9, Hard $8.9–9.4, Extreme $26–28.
   - Easy PU finish rate 9%. Extreme 27–34%.
   - At close−5, 61% (61) / 33% (63) of Easy PU held ≤ 7 Supers. Only 5% / 19% held 10 or more.
5. **There is no early-finisher leak: finishing happens at the very end.** Population: PU finishers. **Known**.
   - Median finisher completes at 94–95% of album time. 0–0.15% finish by 75%.
   - Days after finishing are only 2.5–5% of finishers' active days.
   - Post-finish spend is not a lever.

## 2. What to improve

**A. A Super catch-up for payers far from the gate (Test).**
- **Mechanic:** a targeted Super source in Q4 for PU holding ≤ 9 Supers, for example a guaranteed Super in the Trail final reward, or a Super Wild offer at a lower price point.
- **Evidence:** insights 2, 3 and 4. The conversion point works (about 70–80× the placebo rate), but 66–78% of Q4 payer-days sit at ≤ 9 Supers, where ARPDAU is $1.6–5.3.
- **Hypothesis:** extending the gate's reach converts more of these payers. Not causal.
- **A/B:** split PU at ≤ 9 Supers on Q4 day 1.
  - Primary: PU ARPDAU over the Q4 window.
  - Guardrails: Wild-offer revenue among PU holding 10 or more (cannibalization), PU finish rate, next-album D7 retention.
- **Status:** Test (proposed; not yet agreed with the Dice team).

**B. Release timing of the last Supers (Test, once the calendar is confirmed).**
- **Mechanic:** when the last 2–3 Supers unlock. Album 63 locked them until about 86% of album time; album 61 was softer.
- **Evidence:** insight 1. The two albums show similar PU ARPDAU ($3.34 vs $3.30). Album 63 shows a higher PU finish rate (13.5% vs 11.5%). A 61 vs 63 comparison is confounded, so it proves nothing.
- **A/B:** unlock the last Supers at 75% vs 86% of album time.
  - Primary: PU ARPDAU for the whole album.
  - Guardrails: finish rate, share of PU paying in the last 4 days, last-4-day lift, next-album retention.
- **Status:** Do Not Adopt Yet. It becomes Test after the Dice team confirms the release calendar.

**C. More Super slots, 12 → N (Test; the existing recommendation, now with stronger evidence).**
- **Evidence:** insight 3 upgrades "the gate is closed through Wild offers" from Needs Validation to **Known** (timing).
- **Caveat:** insights 2 and 4 show that extra slots add gates mainly for payers who are already near 12, which is mostly Medium+.
- **A/B:** primary PU ARPDAU.
  - Guardrails: PU finish rate, share of PU ending with all Supers, next-album retention.
  - Read results split Easy vs Medium+.
- **Status:** Test.

## 3. Charts for the deck

**Chart 1 — "The last Supers unlock late: the ceiling, not the pace, sets the end gate"**
Line chart: x = day of album, y = Supers held. Three lines per album: max held by any PU, P99, P50. Population: not-first PU.

| Album | Day | 10 | 17 | 23 | 28 | 32 | 36 | 39 | 42 |
|---|---|---|---|---|---|---|---|---|---|
| 63 | Max | 9 | 10 | 10 | 10 | 11 | 12 | 12 | 12 |
| 63 | P99 | 5 | 6 | 8 | 8 | 9 | 10 | 12 | 12 |
| 63 | P50 | 2 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
| 61 | Max | 9 | 12 | 12 | 12 | 12 | 12* | – | – |
| 61 | P99 | 6 | 8 | 9 | 10 | 12 | 12* | – | – |
| 61 | P50 | 2 | 4 | 5 | 7 | 8 | 9* | – | – |

\*Album 61 ends on day 35, so its last column is day 35.

**Chart 2 — "In Q4, two-thirds of payer-days are too far from 12 Supers for the gate to work"**
Combo chart: stacked bars = share of Q4 PU active days by Supers held; line = ARPDAU. Population: not-first PU.

| Supers held (start of day) | 61: % of days | 61: ARPDAU | 63: % of days | 63: ARPDAU |
|---|---|---|---|---|
| 0–7 | 50.9% | $1.59 | 33.9% | $1.74 |
| 8 | 19.7% | $2.77 | 26.8% | $2.79 |
| 9 | 17.5% | $5.29 | 17.4% | $4.12 |
| 10 | 8.4% | $6.84 | 17.2% | $4.80 |
| 11 | 2.0% | $10.91 | 3.0% | $9.36 |
| 12 | 1.5% | $10.49 | 1.7% | $9.88 |

Footnote: Q4 is 23.5% (61) / 25.5% (63) of album PU revenue.

**Supporting table (backup slide, not-first PU, state at close−5):**

| Album | Segment | Holding 0–7 Supers | Holding 10–12 Supers | End ÷ pre ARPDAU (0–7 / 10–12) | Paid in last 4 days (0–7 / 10–12) |
|---|---|---|---|---|---|
| 61 | Easy | 61% | 5% | 1.46 / 1.44 | 30% / 53% |
| 61 | Medium+ | 41% | 12% | 1.18 / 1.18 | 48% / 71% |
| 63 | Easy | 33% | 19% | 1.33 / 1.45 | 25% / 41% |
| 63 | Medium+ | 22% | 31% | 1.10 / 1.20 | 42% / 69% |

## 4. Open questions for the Dice studio team

1. What is the Super and sticker release calendar for albums 61 and 63? Which Supers were locked, and until which day? In 63, three stickers were unavailable until day 36.
2. Was the tighter late lock in 63 a deliberate design change from 61?
3. Are there pity or duplicate-protection rules for Supers, and do they differ by segment?
4. Which Wild sources are paid offers and which are earned? Specifically DP_Big_Chest_WithStamp, Trail Final Reward, OnePlusSixteen, BuildYourBundle, Decoy.
5. Are Supers or Wild offers targeted by segment (Easy vs Medium+)? Easy payers rarely reach the gate.
6. Can the Trail final reward or a Q4 offer be targeted to payers holding ≤ 9 Supers? (Feasibility for item A.)

Data note: `user_album_finish_ts` is NULL when the album_completed event is missing (LEAST() NULL-propagation). Finisher timing may slightly undercount sticker-only finishers. **Needs Validation**.

## 5. SQL appendix (all run in `dice-dreams-dbt`; every query was dry-run first with identical SQL)

**Q1 — Segment view and finisher timing / post-finish spend (6.07 GB)**
```sql
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.day_in_album, a.album_number_of_days, a.album_segment, a.user_past_album_count,
    a.album_login_ratio, a.is_album_pu, a.is_album_finisher, a.user_album_finish_date, a.is_active,
    IFNULL(a.spent_in_album_today, 0) AS spend, a.unique_super_stickers_lt, a.unique_stickers_lt
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
u AS (
  SELECT album_id, user_id, ANY_VALUE(album_segment) AS seg, MAX(user_past_album_count) AS past,
    LOGICAL_OR(IFNULL(is_album_pu, FALSE)) AS pu, LOGICAL_OR(IFNULL(is_album_finisher, FALSE)) AS fin,
    MAX(user_album_finish_date) AS fdate, MAX(album_number_of_days) AS ndays,
    MAX(unique_super_stickers_lt) AS sup_end,
    SUM(spend) AS rev, COUNTIF(is_active) AS adays,
    SUM(IF(date_dim < user_album_finish_date, spend, 0)) AS rev_pre, COUNTIF(is_active AND date_dim < user_album_finish_date) AS ad_pre,
    SUM(IF(date_dim > user_album_finish_date, spend, 0)) AS rev_post, COUNTIF(is_active AND date_dim > user_album_finish_date) AS ad_post,
    MAX(IF(date_dim = user_album_finish_date, day_in_album, NULL)) AS fday
  FROM r GROUP BY 1, 2
  HAVING ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5)
SELECT album_id, IFNULL(seg, 'null') AS seg, COUNT(*) AS players, COUNTIF(pu) AS pu,
  ROUND(COUNTIF(pu) / COUNT(*), 4) AS pu_rate,
  ROUND(SUM(rev) / SUM(adays), 3) AS arpdau_all,
  ROUND(SUM(IF(pu, rev, 0)) / SUM(IF(pu, adays, 0)), 3) AS arpdau_pu,
  ROUND(COUNTIF(pu AND fin) / NULLIF(COUNTIF(pu), 0), 4) AS pu_finish_rate,
  APPROX_QUANTILES(IF(pu, sup_end, NULL), 100)[OFFSET(50)] AS pu_p50_supers_end,
  ROUND(SUM(IF(pu, rev, 0)) / SUM(SUM(IF(pu, rev, 0))) OVER (PARTITION BY album_id), 4) AS pu_rev_share,
  APPROX_QUANTILES(IF(pu AND fin, fday / ndays, NULL), 100)[OFFSET(50)] AS fin_p50_pct_album,
  ROUND(COUNTIF(pu AND fin AND fday / ndays <= 0.75) / NULLIF(COUNTIF(pu AND fin), 0), 4) AS fin_share_by_75pct,
  ROUND(SUM(IF(pu AND fin, rev_pre, 0)) / NULLIF(SUM(IF(pu AND fin, ad_pre, 0)), 0), 2) AS fin_arpdau_before,
  ROUND(SUM(IF(pu AND fin, rev_post, 0)) / NULLIF(SUM(IF(pu AND fin, ad_post, 0)), 0), 2) AS fin_arpdau_after,
  ROUND(SUM(IF(pu AND fin, ad_post, 0)) / NULLIF(SUM(IF(pu AND fin, adays, 0)), 0), 4) AS fin_share_days_after,
  ROUND(SUM(IF(pu AND fin, rev_post, 0)) / NULLIF(SUM(IF(pu AND fin, rev, 0)), 0), 4) AS fin_share_rev_after,
  ROUND(SUM(IF(pu AND NOT fin, rev, 0)) / NULLIF(SUM(IF(pu AND NOT fin, adays, 0)), 0), 2) AS nonfin_pu_arpdau
FROM u GROUP BY 1, 2
UNION ALL
SELECT album_id, IF(past > 0, 'ALL_not_first', 'ALL_first_album'), COUNT(*), COUNTIF(pu), ROUND(COUNTIF(pu) / COUNT(*), 4),
  ROUND(SUM(rev) / SUM(adays), 3), ROUND(SUM(IF(pu, rev, 0)) / SUM(IF(pu, adays, 0)), 3),
  ROUND(COUNTIF(pu AND fin) / NULLIF(COUNTIF(pu), 0), 4), APPROX_QUANTILES(IF(pu, sup_end, NULL), 100)[OFFSET(50)], NULL,
  APPROX_QUANTILES(IF(pu AND fin, fday / ndays, NULL), 100)[OFFSET(50)],
  ROUND(COUNTIF(pu AND fin AND fday / ndays <= 0.75) / NULLIF(COUNTIF(pu AND fin), 0), 4),
  ROUND(SUM(IF(pu AND fin, rev_pre, 0)) / NULLIF(SUM(IF(pu AND fin, ad_pre, 0)), 0), 2),
  ROUND(SUM(IF(pu AND fin, rev_post, 0)) / NULLIF(SUM(IF(pu AND fin, ad_post, 0)), 0), 2),
  ROUND(SUM(IF(pu AND fin, ad_post, 0)) / NULLIF(SUM(IF(pu AND fin, adays, 0)), 0), 4),
  ROUND(SUM(IF(pu AND fin, rev_post, 0)) / NULLIF(SUM(IF(pu AND fin, rev, 0)), 0), 4),
  ROUND(SUM(IF(pu AND NOT fin, rev, 0)) / NULLIF(SUM(IF(pu AND NOT fin, adays, 0)), 0), 2)
FROM u GROUP BY 1, 2
ORDER BY 1, 2
```

**Q2 — Payer-days by Supers held × album period: ARPDAU, payer-day rate, P(new Super) (5.53 GB)**
```sql
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.percent_of_album_days AS pct, a.album_login_ratio, a.is_album_pu, a.is_active,
    IFNULL(a.spent_in_album_today, 0) AS spend, IFNULL(a.unique_super_stickers_lt, 0) AS s_lt,
    IFNULL(a.unique_super_stickers_today, 0) AS s_new, a.user_past_album_count AS past
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
pop AS (
  SELECT album_id, user_id FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(IFNULL(is_album_pu, FALSE)) AND MAX(past) > 0
     AND ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
d AS (
  SELECT r.album_id, r.user_id, r.date_dim, r.pct, r.is_active, r.spend, r.s_new,
    IFNULL(LAG(r.s_lt) OVER (PARTITION BY r.album_id, r.user_id ORDER BY r.date_dim), 0) AS s_start
  FROM r JOIN pop USING (album_id, user_id))
SELECT album_id,
  CASE WHEN pct <= 0.5 THEN 'H1' WHEN pct <= 0.75 THEN 'Q3' ELSE 'Q4' END AS period,
  CASE WHEN s_start <= 7 THEN '0-7' ELSE CAST(s_start AS STRING) END AS supers_held,
  COUNTIF(is_active) AS active_pu_days,
  ROUND(SUM(spend) / NULLIF(COUNTIF(is_active), 0), 2) AS arpdau,
  ROUND(COUNTIF(is_active AND spend > 0) / NULLIF(COUNTIF(is_active), 0), 4) AS payer_day_rate,
  ROUND(SUM(spend) / NULLIF(COUNTIF(spend > 0), 0), 2) AS rev_per_paying_day,
  ROUND(COUNTIF(is_active AND s_new > 0) / NULLIF(COUNTIF(is_active), 0), 4) AS p_new_super_day,
  ROUND(COUNTIF(is_active AND s_new > 0 AND spend > 0) / NULLIF(COUNTIF(is_active AND s_new > 0), 0), 4) AS share_new_super_days_paid,
  ROUND(SUM(spend) / SUM(SUM(spend)) OVER (PARTITION BY album_id), 4) AS rev_share
FROM d GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
```

**Q3 — Supers ceiling by album day, an inferred release calendar (4.89 GB)**
```sql
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.day_in_album, a.album_login_ratio, a.is_album_pu, a.user_past_album_count AS past,
    IFNULL(a.unique_super_stickers_lt, 0) AS s_lt, IFNULL(a.unique_stickers_lt, 0) AS u_lt
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
pop AS (
  SELECT album_id, user_id FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(IFNULL(is_album_pu, FALSE)) AND MAX(past) > 0
     AND ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
x AS (SELECT r.album_id, r.day_in_album, r.s_lt, r.u_lt FROM r JOIN pop USING (album_id, user_id)),
mx AS (SELECT album_id, day_in_album, MAX(s_lt) AS max_s FROM x GROUP BY 1, 2)
SELECT x.album_id, x.day_in_album, COUNT(*) AS pu_rows, ANY_VALUE(m.max_s) AS max_supers_any_pu,
  APPROX_QUANTILES(x.s_lt, 100)[OFFSET(99)] AS p99_supers,
  APPROX_QUANTILES(x.s_lt, 100)[OFFSET(50)] AS p50_supers,
  ROUND(COUNTIF(x.s_lt >= m.max_s - 0) / COUNT(*), 4) AS share_at_max,
  APPROX_QUANTILES(x.u_lt, 100)[OFFSET(99)] AS p99_stickers,
  MAX(x.u_lt) AS max_stickers
FROM x JOIN mx m USING (album_id, day_in_album)
GROUP BY 1, 2 ORDER BY 1, 2
```

**Q4 — Placebo for "purchase ≤ 10/60 min before the last Super" (shift 0 / −24h / −48h) (14.16 GB)**
```sql
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_login_ratio, a.is_album_pu, a.user_past_album_count AS past,
    IFNULL(a.unique_super_stickers_lt, 0) AS s_lt
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
pop AS (
  SELECT album_id, user_id, MAX(s_lt) AS sup_end FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(IFNULL(is_album_pu, FALSE)) AND MAX(past) > 0
     AND ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
ls AS (
  SELECT p.album_id, p.user_id, p.sup_end, s.sticker_collected_ts AS ts, s.collected_from_wild AS wild
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
    ON s.album_id = p.album_id AND s.user_id = p.user_id
  JOIN alb a ON a.album_id = p.album_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63)
    AND s.sticker_type = 'super' AND s.is_sticker_collected AND s.sticker_collected_date < a.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id ORDER BY s.sticker_collected_ts DESC, s.sticker_id DESC) = 1),
pur AS (
  SELECT v.user_id, v.timestamp AS ts
  FROM `dice-dreams-dbt.20_core.purchase_completed_vw` v
  WHERE v.pdate BETWEEN DATE '2026-06-19' AND DATE '2026-09-06' AND v.purchase_amount > 0
  QUALIFY ROW_NUMBER() OVER (PARTITION BY v.user_id, v.timestamp, v.external_order_id ORDER BY v.timestamp) = 1),
sh AS (
  SELECT l.album_id, l.user_id, l.sup_end, l.wild, k AS shift_h, TIMESTAMP_SUB(l.ts, INTERVAL k HOUR) AS ref_ts
  FROM ls l, UNNEST([0, 24, 48]) AS k),
m AS (
  SELECT sh.album_id, sh.user_id, sh.sup_end, sh.wild, sh.shift_h,
    LOGICAL_OR(p.ts BETWEEN TIMESTAMP_SUB(sh.ref_ts, INTERVAL 10 MINUTE) AND sh.ref_ts) AS p10,
    LOGICAL_OR(p.ts BETWEEN TIMESTAMP_SUB(sh.ref_ts, INTERVAL 60 MINUTE) AND sh.ref_ts) AS p60
  FROM sh LEFT JOIN pur p ON p.user_id = sh.user_id
    AND p.ts BETWEEN TIMESTAMP_SUB(sh.ref_ts, INTERVAL 60 MINUTE) AND sh.ref_ts
  GROUP BY 1, 2, 3, 4, 5)
SELECT album_id, IF(sup_end = 12, '12_supers', 'under_12') AS grp, IF(wild, 'wild', 'not_wild') AS via, shift_h,
  COUNT(*) AS pu, ROUND(COUNTIF(p10) / COUNT(*), 4) AS share_purchase_10m, ROUND(COUNTIF(p60) / COUNT(*), 4) AS share_purchase_60m
FROM m GROUP BY 1, 2, 3, 4
UNION ALL
SELECT album_id, IF(sup_end = 12, '12_supers', 'under_12'), 'all', shift_h, COUNT(*), ROUND(COUNTIF(p10) / COUNT(*), 4), ROUND(COUNTIF(p60) / COUNT(*), 4)
FROM m GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4
```
Key results:

| Group | Album | Shift 0 (10 min / 60 min) | −24h (10 min) | −48h (10 min) |
|---|---|---|---|---|
| 12 Supers | 61 | 72.4% / 86.8% | 1.0% | 0.7% |
| 12 Supers | 63 | 82.0% / 94.4% | 1.0% | 0.7% |
| Under 12 | 61 | 13.0% | 0.3% | 0.3% |
| Under 12 | 63 | 13.4% | 0.3% | 0.2% |

**Q5 — Supers held at close−5 by segment (Easy vs Medium+): end lift and payer conversion (4.90 GB)**
The first dry-run failed with a BigQuery GROUP BY / PARTITION BY error (0 bytes). The corrected SQL that ran:
```sql
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.a_end, a.album_segment, a.album_login_ratio, a.is_album_pu, a.is_album_finisher,
    a.user_past_album_count AS past, a.is_active, IFNULL(a.spent_in_album_today, 0) AS spend, IFNULL(a.unique_super_stickers_lt, 0) AS s_lt
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
u AS (
  SELECT album_id, user_id, IF(ANY_VALUE(album_segment) = 'Easy', 'Easy', 'Medium+') AS seg,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 5 DAY), s_lt, NULL)) AS sup_c5,
    LOGICAL_OR(IFNULL(is_album_finisher, FALSE)) AS fin,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 5 DAY), spend, 0)) AS pre_rev,
    COUNTIF(is_active AND date_dim <= DATE_SUB(a_end, INTERVAL 5 DAY)) AS pre_d,
    SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS end_rev,
    COUNTIF(is_active AND date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY)) AS end_d
  FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(IFNULL(is_album_pu, FALSE)) AND MAX(past) > 0
     AND ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
b AS (
  SELECT album_id, seg, fin, pre_rev, pre_d, end_rev, end_d,
    CASE WHEN sup_c5 IS NULL THEN 'na' WHEN sup_c5 <= 7 THEN 'c5_0-7' WHEN sup_c5 <= 9 THEN 'c5_8-9' ELSE 'c5_10-12' END AS bucket
  FROM u)
SELECT album_id, seg, bucket, COUNT(*) AS pu,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, seg), 4) AS share_of_seg_pu,
  ROUND(SUM(pre_rev) / NULLIF(SUM(pre_d), 0), 2) AS pre_arpdau,
  ROUND(SUM(end_rev) / NULLIF(SUM(end_d), 0), 2) AS end_arpdau,
  ROUND(SAFE_DIVIDE(SUM(end_rev) / NULLIF(SUM(end_d), 0), SUM(pre_rev) / NULLIF(SUM(pre_d), 0)), 2) AS end_vs_pre,
  ROUND(COUNTIF(end_rev > 0) / COUNT(*), 4) AS share_paid_last4,
  ROUND(COUNTIF(fin) / COUNT(*), 4) AS finish_rate,
  ROUND(SUM(end_rev) / SUM(SUM(end_rev)) OVER (PARTITION BY album_id), 4) AS share_of_album_end_rev
FROM b GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
```

Total scanned: about 35.6 GB across 5 executed queries, each under 100 GB.

**For the lead / memory:**
- Open item 2 (placebo for the purchase-before-last-Super timing) is now closed: real 72–82% vs 0.7–1.0% placebo.
- New Dice finding to log: the album 63 Super ceiling stayed at 10 until day 32 and reached 12 only from day 36 of 42.
- Suggested project doc to save: `claude/dice-analyst-limits-2026-10-14.md` with the SQL in `claude/dice_limits_queries.sql`. Neither file has been written.
---

# Domino Dreams: album 17/19, what limits payers and monetization

**Answer to the open question: no, Royals are not the final completion gate in Domino the way Supers are in Dice.** The last gate is the album's **last release phase (phase 6)**. That phase holds 7 stickers, mostly in set 9 with some in sets 11 and 12, and which rarity those stickers are changes by album. In album 17 the gate is mostly Goldens. In album 19 the two set-9 Royals sit in phase 6, so the gate becomes Royal-led.

Scope and method:
- **Project:** `domino-dreams-dbt`.
- **Population:** payers (PU), not special users, not suspected cheaters, login ratio ≥ 0.5 on the last row before close, close day excluded. "Veteran" means `user_album_count` > 1. Rare-gate work uses veteran PU unless a table says otherwise.
- **Album dates:** 17 runs 04-02 → 05-11 (39 days). 19 runs 07-06 → 08-24 (49 days).
- **Album layout:** 17 has 108 Common / 28 Golden / 8 Royal. 19 has 107 Common / 28 Golden / 9 Royal.
- **Revenue check (Known):** `album_spent_today` matches gross in-app plus Stripe revenue from `user_daily_metrics` within about 1–3% in every bin. This closes the open Domino "revenue column check" from the content pack. Its column description still says "coins", so it should be corrected in dbt docs.

## 1. Top 5 insights

1. **In album 17, Goldens are the final gate, not Royals.** Golden is 79% of finishers' last 3 stickers (baseline 19%); Royal is 21% (baseline 6%). Among PU one sticker short at close, 83–87% are missing a Golden and 12–16% a Royal. Known; veteran PU, 7,973 finishers.
2. **In album 19, Royals become the main gate.** Royal is 58% of finishers' last 3 stickers (baseline 6%, about 9×) and 51% of last stickers. 54–57% of PU missing 1 sticker are missing a Royal. Known; veteran PU, about 5,600 finishers.
3. **The gate lines up with the last release phase, not with rarity. These stickers arrive at the very end.**
   - Phase 6 holds exactly 7 Golden/Royal stickers in both albums.
   - In album 19, phase-6 Royals 107/108 first appear for players around day 31–32. The median holder got them on **day 48 of 49**. At close, only 9–10% of veteran PU hold each one.
   - In album 17, the phase-6 set-9 stickers (Goldens 104/106/107 and Royal 108) are held by 9–33% of veteran PU at close.
   - Labels: Known that the gate is phase 6 and arrives late. Hypothesis that the late arrival is a deliberate release gate; the config shows phase but no release date.
4. **About a third of payers end the album just short, and they bring half the revenue.**
   - 34% (17) and 37% (19) of veteran PU end 1–5 stickers short. They bring 47% and 52% of PU revenue.
   - Fewer than 1% of those missing 2–5 finish.
   - PU finish rate is 5.7% (17) and 4.5% (19), against Dice's 11.5–13.5%. The Dice population is not identical.
   - Labels: Known for the shares; Needs Validation for the cross-game comparison.
5. **Finishing is squeezed into the last days, so there is almost no spending after finishing.**
   - 72% (17) and **98% (19)** of veteran PU finishers finish in the last 4 days.
   - Spend after finishing is about 3% of their album spend.
   - Known. Hypothesis: the late gate removes the Deluxe / after-finish spending window.

Supporting evidence, entering the last 4 days (state at close−5), veteran PU:

| Missing at close−5 | Paid in last 4 days | Revenue per paying day | Finished by close−1 |
|---|---|---|---|
| 1 Royal | 76% (17), 91% (19) | $30 / $71 | 61% / 76% |
| 1 Golden | 58% (17), 85% (19) | $31 / $56 | 57% / 81% |

- Players missing a Royal were already bigger spenders before the window (pre ARPDAU $10.3 vs $7.8 in 17; $34.6 vs $25.8 in 19).
- This is the same direction as Dice (more players pay when the rare is missing) and the same selection bias. Not causal.

## 2. What to improve

**1. Late phase-6 release (the final gate)**
- **Evidence:** the gate follows phase 6 in both albums. In album 19, 98% of finishes come in the last 4 days and the gate Royals' median holder day is 48 of 49. Spend after finishing is about 3%.
- **Proposed A/B:** release phase 6 about 7 days earlier (or remove time-gating on 1–2 of the 7 stickers) vs control.
  - Primary: PU album ARPDAU (close−1).
  - Guardrails: PU finish rate, last-4-days ARPDAU lift (currently 1.13–1.23×), Deluxe / after-finish revenue, next-album D7 retention and spend.
- **Status: Test.** Risk: an earlier release may move revenue earlier without adding to it.

**2. The near-finisher block (1–5 short, 34–37% of PU, about half of revenue, under 1% finish)**
- **Evidence:**
  - Album 17 near-finishers are Golden-blocked. Album 19 near-finishers are Royal-blocked.
  - Royals are not sold directly; players get them only by picking them with a Joker.
  - The Duplicates Bar switches to Royal Vague only when 2 Royals are left.
- **Proposed A/B:** at close−7, show PU missing ≤ 5 a priced "pick the gate sticker" offer (Specific for Goldens, Joker for Royals), vs control.
  - Primary: PU ARPDAU over the last 7 days.
  - Secondary: finish rate.
  - Guardrails: total album ARPDAU (cannibalization of the end lift), next-album ARPDAU, share of PU finishing with no spend in the window.
- **Status: Test.**

**3. Choosing the rarity of the final phase (Royal-led like album 19 vs Golden-led like album 17)**
- **Evidence:** in album 19, Royal-blocked players pay more often in the last 4 days (91% vs 85%) and spend more per paying day ($71 vs $56).
- But the samples are small (112 / 183 players). Album 19 also launched Royal Tower, has 9 Royals and runs 10 days longer.
- **Status: Do Not Adopt Yet.** If pursued, run it as a second arm of test 1 (phase 6 = Royals vs Goldens) with the same primary metric and guardrails.

**Fact only:**
- No PU finishes without holding every Royal. ARPDAU climbs steeply with Royals held (veteran PU, album 17: 7 Royals $2.97 → 8 Royals $7.08; album 19: 8 Royals $4.91 → 9 Royals $10.31). This is correlation; it can run both ways.
- In album 17, holding all 8 Royals goes with only a 32–45% finish rate, because Goldens are still missing. In album 19, holding all 9 goes with 78%. In Dice, holding all 12 Supers goes with 94–96%.

## 3. Charts for the deck

**Chart 1: "Domino's final gate changes by album: Goldens in 17, Royals in 19." Grouped bar** (share of finishers' last 3 stickers vs share of the album), veteran PU finishers.

| Album | Type | % of last 3 | % of album (baseline) | % of last sticker |
|---|---|---|---|---|
| 17 | Golden | 78.7 | 19.4 | 83.7 |
| 17 | Royal | 21.1 | 5.6 | 15.9 |
| 17 | Common | 0.2 | 75.0 | 0.3 |
| 19 | Royal | 57.5 | 6.3 | 50.7 |
| 19 | Golden | 41.9 | 19.4 | 48.2 |
| 19 | Common | 0.6 | 74.3 | 1.1 |

**Chart 2: "The gate is the last release phase: few payers hold it at close." Horizontal bar** of % of veteran PU holding the sticker at close, labelled with the median holder's collection day.

| Album | Sticker (set, type, phase) | Held at close | 1st-percentile collection day | Median collection day / album days |
|---|---|---|---|---|
| 17 | 106 (set 9, Golden, phase 6) | 9% | 21 | 37 / 39 |
| 17 | 104 (set 9, Golden, phase 6) | 12% | 23 | 36 / 39 |
| 17 | 108 (set 9, Royal, phase 6) | 20% | 23 | 35 / 39 |
| 17 | 130 (set 11, Golden, phase 6) | 23% | 25 | 35 / 39 |
| 17 | 107 (set 9, Golden, phase 6) | 33% | 26 | 34 / 39 |
| 19 | 107 (set 9, Royal, phase 6) | 9% | 31 | 48 / 49 |
| 19 | 108 (set 9, Royal, phase 6) | 10% | 32 | 48 / 49 |
| 19 | 101 (set 9, Golden, phase 6) | 11% | 41 | 48 / 49 |
| 19 | 130 (set 11, Golden, phase 6) | 17% | 40 | 47 / 49 |

An alternative to Chart 2 is a stacked bar of what near-finishers are missing:

| Missing at close | Album 17: % missing a Royal / only Goldens | Album 19: % missing a Royal / only Goldens |
|---|---|---|
| 1 | 12% / 87% | 54% / 45% |
| 2 | 22% / 78% | 95% / 5% |
| 3 | 56% / 44% | 98% / 2% |

## 4. Open questions for the Domino team

1. **Phase release rules:** is phase 6 time-gated (release day per phase), and was the day-31 / day-40 timing in album 19 intended? This decides whether insight 3 is design or behaviour.
2. **Joker flag:** `collected_by_joker_flag` is about 40% on album 17's last-3 Royals and 97% on album 19's. If Royals come only from Joker picks, did the flag's meaning or the Royal Tower launch (07-06) change it? (Needs Validation)
3. **Finish flag:** about 5–7% of PU with 143/144 unique stickers have `album_finished_flag` = TRUE. Is that a unique-count lag or a definition difference? (Needs Validation)
4. **Duplicates Bar rules:** the Royal Vague reward starts at 2 Royals left. Is there a Golden equivalent for the album-17-type gate?
5. **Event grouping:** event grouping for Domino is still pending (5g). Also needed: the meaning of the "Empty" and "Event" source labels, which appear among the last-3 sources.
6. **Data fix:** `album_finish_date` is filled only from the finish day onward. Because of that, my pre-finish ARPDAU split (query 7) is invalid and is not reported. A re-run would anchor on the user-level finish date.

## 5. SQL appendix

All queries were run in `domino-dreams-dbt`, read-only, dry-run first with identical SQL, and every partition was filtered. Total scanned: about 101 GB; the largest single query was 24.65 GB.

**Q1 — End state by Royals held (PU), plus revenue check — 13.08 GB**
```sql
WITH excluded AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND suspected_cheater_flag),
rev AS (SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23'),
rows_ AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date, a.album_close_date, a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today,0) AS spend, IFNULL(r.rev,0) AS rev,
    a.unique_album_stickers_lt, a.unique_royal_stickers_tl, a.missing_royal_stickers_today, a.missing_golden_stickers_today, a.album_finished_flag
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id LEFT JOIN rev r ON r.user_id = a.user_id AND r.date_dim = a.date_dim
  WHERE a.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND a.album_id IN (17, 19) AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
u AS (SELECT album_id, user_id, ANY_VALUE(album_open_date) AS o, ANY_VALUE(album_close_date) AS c, SUM(spend) AS spend, SUM(rev) AS rev, COUNT(*) AS days,
    ARRAY_AGG(STRUCT(login_ratio, user_album_count, unique_album_stickers_lt AS uniq, unique_royal_stickers_tl AS royals, missing_royal_stickers_today AS mr, missing_golden_stickers_today AS mg, album_finished_flag AS fin) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l
  FROM rows_ GROUP BY 1, 2)
SELECT album_id, ANY_VALUE(o) AS open_d, ANY_VALUE(c) AS close_d, l.user_album_count > 1 AS veteran, IFNULL(l.royals,0) AS royals_held,
  COUNT(*) AS pu, SUM(rev) AS rev, SUM(spend) AS spend, SUM(days) AS days, ROUND(SUM(rev)/SUM(days),2) AS arpdau, ROUND(AVG(IF(IFNULL(l.fin,FALSE),1,0)),3) AS finish_rate,
  ROUND(AVG(l.uniq),1) AS avg_unique, ROUND(AVG(l.mr),2) AS avg_missing_royal, ROUND(AVG(l.mg),2) AS avg_missing_golden
FROM u WHERE l.login_ratio >= 0.5 AND rev > 0 GROUP BY album_id, veteran, royals_held ORDER BY 1, 4, 5
```

**Q2 — Near-finishers: what is missing at close (PU) — 11.70 GB**
```sql
WITH excluded AS (...same as Q1...),
rows_ AS (SELECT a.album_id, a.user_id, a.date_dim, a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today,0) AS spend,
    a.unique_album_stickers_lt AS uniq, a.missing_royal_stickers_today AS mr, a.missing_golden_stickers_today AS mg, a.album_finished_flag AS fin
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND a.album_id IN (17, 19) AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
u AS (SELECT album_id, user_id, SUM(spend) AS spend, COUNT(*) AS days, ARRAY_AGG(STRUCT(login_ratio, user_album_count, uniq, mr, mg, fin) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l FROM rows_ GROUP BY 1, 2),
f AS (SELECT album_id, user_id, spend, days, l.user_album_count > 1 AS veteran, IFNULL(l.fin, FALSE) AS fin, 144 - l.uniq AS miss, IFNULL(l.mr,0) AS mr, IFNULL(l.mg,0) AS mg,
    GREATEST(144 - l.uniq - IFNULL(l.mr,0) - IFNULL(l.mg,0), 0) AS mc FROM u WHERE l.login_ratio >= 0.5 AND spend > 0)
SELECT album_id, veteran, CASE WHEN miss <= 0 THEN '0' WHEN miss <= 5 THEN CAST(miss AS STRING) WHEN miss <= 10 THEN '6-10' ELSE '11+' END AS missing,
  COUNT(*) AS pu, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, veteran), 3) AS share_pu, ROUND(SUM(spend) / SUM(SUM(spend)) OVER (PARTITION BY album_id, veteran), 3) AS share_rev,
  ROUND(SUM(spend) / SUM(days), 2) AS arpdau, ROUND(COUNTIF(mr > 0) / COUNT(*), 3) AS any_royal_missing, ROUND(COUNTIF(mr = miss AND miss > 0) / COUNT(*), 3) AS only_royals_missing,
  ROUND(COUNTIF(mr = 0 AND mg > 0) / COUNT(*), 3) AS golden_no_royal, ROUND(SUM(mr) / NULLIF(SUM(miss),0), 3) AS royal_share_of_missing,
  ROUND(SUM(mg) / NULLIF(SUM(miss),0), 3) AS golden_share_of_missing, ROUND(SUM(mc) / NULLIF(SUM(miss),0), 3) AS common_share_of_missing, ROUND(AVG(IF(fin,1,0)), 3) AS finish_rate
FROM f GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
```

**Q3 — Finishers' last 3 stickers by type (veteran PU) — 24.65 GB**
```sql
WITH excluded AS (...),
rows_ AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today,0) AS spend, a.album_finished_flag AS fin
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND a.album_id IN (17, 19) AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (SELECT album_id, user_id, ANY_VALUE(c) AS c FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(STRUCT(login_ratio, user_album_count, fin) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)].login_ratio >= 0.5
    AND ARRAY_AGG(STRUCT(login_ratio, user_album_count, fin) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)].user_album_count > 1
    AND IFNULL(ARRAY_AGG(STRUCT(login_ratio, user_album_count, fin) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)].fin, FALSE)),
st AS (SELECT s.album_id, s.user_id, s.sticker_id, LOWER(s.sticker_type) AS t, IFNULL(s.collected_by_joker_flag, FALSE) AS jk, IFNULL(NULLIF(s.new_sticker_source,''),'(null)') AS src, s.sticker_collected_min_ts AS ts
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND s.album_id IN (17, 19) AND s.user_collected_sticker_flag),
cfg AS (SELECT album_id, t, COUNT(DISTINCT sticker_id) AS n_cfg FROM st GROUP BY 1, 2),
fin_st AS (SELECT st.album_id, st.user_id, st.t, st.jk, st.src, ROW_NUMBER() OVER (PARTITION BY st.album_id, st.user_id ORDER BY st.ts DESC) AS rn_desc
  FROM st JOIN pop p ON p.album_id = st.album_id AND p.user_id = st.user_id WHERE DATE(st.ts) < p.c)
SELECT f.album_id, f.t, ANY_VALUE(c.n_cfg) AS stickers_in_album, COUNTIF(rn_desc = 1) AS last_1, COUNTIF(rn_desc <= 3) AS last_3,
  ROUND(COUNTIF(rn_desc = 1) / SUM(COUNTIF(rn_desc = 1)) OVER (PARTITION BY f.album_id), 3) AS share_last_1,
  ROUND(COUNTIF(rn_desc <= 3) / SUM(COUNTIF(rn_desc <= 3)) OVER (PARTITION BY f.album_id), 3) AS share_last_3,
  ROUND(COUNTIF(rn_desc <= 3 AND jk) / NULLIF(COUNTIF(rn_desc <= 3), 0), 3) AS last3_joker_share,
  COUNT(DISTINCT IF(rn_desc <= 3, f.user_id, NULL)) AS finishers_with_type_in_last3, APPROX_TOP_COUNT(IF(rn_desc <= 3, f.src, NULL), 6) AS top_sources_last3
FROM fin_st f JOIN cfg c ON c.album_id = f.album_id AND c.t = f.t GROUP BY 1, 2 ORDER BY 1, 2
```
Note: the top-source arrays include NULL from the IF; I ignored the NULL entries.

**Q4 — Missing 1–2 at close−5: Royal vs Golden outcomes in the last 4 days (veteran, login ≥ 0.5) — 11.70 GB**
```sql
WITH excluded AS (...),
rows_ AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today,0) AS spend,
    a.unique_album_stickers_lt AS uniq, IFNULL(a.missing_royal_stickers_today,0) AS mr, IFNULL(a.missing_golden_stickers_today,0) AS mg, IFNULL(a.album_finished_flag,FALSE) AS fin
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND a.album_id IN (17, 19) AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
u AS (SELECT album_id, user_id, ARRAY_AGG(STRUCT(login_ratio, user_album_count) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l,
    ARRAY_AGG(IF(date_dim <= DATE_SUB(c, INTERVAL 5 DAY), STRUCT(uniq, mr, mg, fin), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS s5,
    SUM(IF(date_dim <= DATE_SUB(c, INTERVAL 5 DAY), spend, 0)) AS pre_rev, COUNTIF(date_dim <= DATE_SUB(c, INTERVAL 5 DAY)) AS pre_days,
    SUM(IF(date_dim > DATE_SUB(c, INTERVAL 5 DAY), spend, 0)) AS end_rev, COUNTIF(date_dim > DATE_SUB(c, INTERVAL 5 DAY)) AS end_days,
    COUNTIF(date_dim > DATE_SUB(c, INTERVAL 5 DAY) AND spend > 0) AS end_pay_days, LOGICAL_OR(fin) AS fin_end FROM rows_ GROUP BY 1, 2),
g AS (SELECT album_id, user_id, pre_rev, pre_days, end_rev, end_days, end_pay_days, fin_end, 144 - s5.uniq AS miss,
    CASE WHEN 144 - s5.uniq = 1 AND s5.mr = 1 THEN '1: Royal' WHEN 144 - s5.uniq = 1 AND s5.mg = 1 THEN '1: Golden' WHEN 144 - s5.uniq = 1 THEN '1: Common'
         WHEN 144 - s5.uniq = 2 AND s5.mr = 2 THEN '2: Royal+Royal' WHEN 144 - s5.uniq = 2 AND s5.mr = 1 AND s5.mg = 1 THEN '2: Royal+Golden'
         WHEN 144 - s5.uniq = 2 AND s5.mg = 2 THEN '2: Golden+Golden' WHEN 144 - s5.uniq = 2 THEN '2: other' END AS grp
  FROM u WHERE l.login_ratio >= 0.5 AND l.user_album_count > 1 AND s5.fin = FALSE)
SELECT album_id, grp, COUNT(*) AS players, ROUND(COUNTIF(pre_rev > 0) / COUNT(*), 3) AS pre_payer, ROUND(SUM(pre_rev) / SUM(pre_days), 2) AS pre_arpdau,
  ROUND(SUM(end_rev) / SUM(end_days), 2) AS end_arpdau, ROUND(SAFE_DIVIDE(SUM(end_rev) / SUM(end_days), SUM(pre_rev) / SUM(pre_days)), 2) AS end_over_pre,
  ROUND(COUNTIF(end_pay_days > 0) / COUNT(*), 3) AS paid_last4, ROUND(SUM(end_pay_days) / SUM(end_days), 2) AS payer_day_rate,
  ROUND(SAFE_DIVIDE(SUM(end_rev), SUM(end_pay_days)), 2) AS rev_per_paying_day, ROUND(COUNTIF(fin_end) / COUNT(*), 3) AS finished_by_close_1
FROM g WHERE grp IS NOT NULL GROUP BY 1, 2 ORDER BY 1, 2
```

**Q5 — Per-sticker timing and hold rate at close, Royals plus Goldens held < 45% (veteran PU) — 22.84 GB**
```sql
WITH excluded AS (...),
rows_ AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS o, a.album_close_date AS c, a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND a.album_id IN (17, 19) AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (SELECT album_id, user_id, ANY_VALUE(o) AS o, ANY_VALUE(c) AS c FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(STRUCT(login_ratio, user_album_count) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)].login_ratio >= 0.5
    AND ARRAY_AGG(STRUCT(login_ratio, user_album_count) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)].user_album_count > 1),
npu AS (SELECT album_id, COUNT(*) AS n FROM pop GROUP BY 1),
st AS (SELECT s.album_id, s.user_id, s.set_id, s.sticker_id, LOWER(s.sticker_type) AS t, s.sticker_collected_min_date AS d
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND s.album_id IN (17, 19) AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('royal', 'golden')),
j AS (SELECT st.album_id, st.set_id, st.sticker_id, st.t, DATE_DIFF(st.d, p.o, DAY) + 1 AS day_in_album, DATE_DIFF(p.c, p.o, DAY) AS album_days
  FROM st JOIN pop p ON p.album_id = st.album_id AND p.user_id = st.user_id WHERE st.d < p.c)
SELECT j.album_id, j.t, j.set_id, j.sticker_id, ANY_VALUE(album_days) AS album_days, APPROX_QUANTILES(day_in_album, 100)[OFFSET(1)] AS p1_day,
  APPROX_QUANTILES(day_in_album, 100)[OFFSET(50)] AS p50_day, ROUND(COUNT(*) / ANY_VALUE(npu.n), 3) AS held_at_close
FROM j JOIN npu USING (album_id) GROUP BY 1, 2, 3, 4 HAVING t = 'royal' OR held_at_close < 0.45 ORDER BY 1, 2, held_at_close
```

**Q6 — Sticker config: phase and high-monetization flag — 7.33 GB**
```sql
SELECT album_id, LOWER(sticker_type) AS t, phase, pull_high_monetization AS hm, COUNT(DISTINCT sticker_id) AS stickers,
  STRING_AGG(DISTINCT CAST(sticker_id AS STRING) ORDER BY CAST(sticker_id AS STRING)) AS ids, MIN(sticker_collected_min_date) AS first_seen
FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers`
WHERE sticker_collected_min_date BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND album_id IN (17, 19) AND user_collected_sticker_flag AND LOWER(sticker_type) IN ('royal', 'golden')
GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3, 4
```
Result: phase 6 = album 17 Goldens 104/106/107/125/130 plus Royals 108/132; album 19 Goldens 101/104/106/125/130 plus Royals 107/108. All Royals carry the high-monetization flag.

**Q7 — Finish timing and spend after finishing (veteran PU finishers) — 9.63 GB**
```sql
WITH excluded AS (...),
rows_ AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today,0) AS spend, a.album_finish_date AS fd
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND a.album_id IN (17, 19) AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
u AS (SELECT album_id, user_id, ANY_VALUE(c) AS c, MAX(fd) AS fd, ARRAY_AGG(STRUCT(login_ratio, user_album_count) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, SUM(spend) AS rev,
    SUM(IF(date_dim <= fd, spend, 0)) AS rev_to_finish, COUNTIF(date_dim <= fd) AS days_to_finish,
    SUM(IF(date_dim > fd, spend, 0)) AS rev_after, COUNTIF(date_dim > fd) AS days_after, COUNTIF(date_dim > fd AND spend > 0) AS pay_days_after FROM rows_ GROUP BY 1, 2)
SELECT album_id, CASE WHEN DATE_DIFF(c, fd, DAY) <= 4 THEN 'a: last 4 days' WHEN DATE_DIFF(c, fd, DAY) <= 10 THEN 'b: 5-10 days before close' WHEN DATE_DIFF(c, fd, DAY) <= 20 THEN 'c: 11-20' ELSE 'd: 21+' END AS finish_timing,
  COUNT(*) AS finishers, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 3) AS share, ROUND(SUM(rev_to_finish) / SUM(days_to_finish), 2) AS arpdau_to_finish,
  ROUND(SAFE_DIVIDE(SUM(rev_after), SUM(days_after)), 2) AS arpdau_after_finish, ROUND(SAFE_DIVIDE(SUM(pay_days_after), SUM(days_after)), 2) AS payer_day_rate_after,
  ROUND(SUM(rev_after) / SUM(rev), 3) AS share_rev_after_finish, ROUND(AVG(rev_to_finish), 0) AS avg_spend_to_finish
FROM u WHERE fd IS NOT NULL AND fd < c AND rev > 0 AND l.login_ratio >= 0.5 AND l.user_album_count > 1 GROUP BY 1, 2 ORDER BY 1, 2
```
Caveat (Known bug): the row-level `album_finish_date` is NULL before the finish day. The "to finish" columns therefore capture only the finish day; they are not reported. The finish timing, after-finish ARPDAU and after-finish revenue share are valid. Finish-timing shares: 17 = 72% in the last 4 days / 28% 5–10 days before close; 19 = 98% / 2%. Revenue after finishing = 3% (17) and 2.7% (19) of the last-4-days group's album spend.

Suggested memory update for the main session: Domino's final completion gate is the last release phase (phase 6), not the Royal tier (Golden-led in album 17, Royal-led in album 19). Domino `album_spent_today` matches gross in-app plus Stripe revenue within about 1–3%.
---

# Disney Solitaire: Albums 14/15 — what limits payers and monetization (Disney analyst)

All data comes from project `solitaire-dreams-411507`.

**Population, unless a line says otherwise:** payers (PU) who are not in their first album (`user_album_count > 1`), with login ratio ≥ 0.5 on their last row before close. Special and excluded users are removed and the close day is excluded. That leaves about 370K PU in album 14 and 325K in album 15.

**Short answers to the two open questions:**
- **Are Royals release-gated?** Yes. One Royal, sticker 131, can only be obtained in the last days of the album, almost entirely through a Joker. The other six Royals arrive in pulses tied to events.
- **Why is the album-end lift flat?** Fewer payers pay at the end: the share of active payers who pay falls 4–9% in the last 4 days. Once you compare the same weekdays, the last 4 days are a dip of 6–13%, not a lift. Most payers cannot reach the last Royal before the final days.

## 1. Top 5 insights

1. **One Royal (131) is the completion gate.** Known; PU not first album.
   - At close−5, 99% of payers who are 1–3 stickers short are missing exactly one Royal (1.00–1.02 on average).
   - That Royal is sticker 131 for 100% of them in album 14 and 93% in album 15.
   - Only 13% / 18% of these payers finish by close−1.
2. **Sticker 131 is held back until the last days and arrives through a Joker.** Known; all players.
   - Only 35K / 44K players ever get it, against about 0.6–1.36M for each of the other Royals.
   - It first reaches 1K players on day 40 in album 14 and day 32 in album 15.
   - In album 14, 100% of 131 receipts are Joker-filled: Market 67%, 8Box 8%, paid Joker / 2PO / 1+15 offers 18%.
   - In album 15, 15% came directly from Sugar Rush on day 32 and 10% from Momentum on day 41.
   - Only 6 payers per album had finished by close−5.
3. **The end is a dip once weekdays are matched.** Known; PU not first album.
   - PU ARPDAU in the last 4 days ÷ whole album = 0.95 (album 14) and 1.01 (album 15).
   - The last 4 days fall Thursday–Sunday. Against the other five Thursday–Sunday windows of the same album they are 0.87× and 0.94×, the lowest window in album 14.
   - Pay rate drops: 0.174 → 0.158 (album 14) and 0.169 → 0.161 (album 15). Revenue per paying day rises only 5%.
4. **Payers blocked by the Royal convert less at the end than Dice payers blocked by a Super.** Known (Disney); Dice figure from the content pack.
   - Disney payers 1–3 short with a Royal missing: 55% / 64% pay in the last 4 days, $29–34 per paying day.
   - Dice payers missing a Super: 82–84% pay in the last 4 days.
   - These Disney payers are only 13% / 9.5% of PU but bring 44% / 41% of last-4-day revenue.
5. **Most payers are out of reach at the end, and the other Royals come in pulses.** Known; PU not first album.
   - At close−5, 61% / 45% of PU are 4–10 stickers short and missing 2.4 Royals on average. In the last 4 days they spend $7.5–10 per payer and 3–4% of them finish.
   - The other six Royals arrive in fixed pulses (days 7, 10, 16, 21–26, 32–36). These are mostly event drops on days with average or below-average ARPDAU (day 25: 0.51–0.59 new Royals per DAU, ARPDAU $2.86–2.96).
   - Whether these Royals are locked by the album config is not confirmed (Needs Validation).

## 2. What to improve

**A. Final-Royal (131) gate → open a paid route earlier for payers within reach.** Status: **Test**.
- **Evidence:**
  - The 1–3-short Royal-missing group pays 55–64% in the last 4 days, against 82–84% for the equivalent Dice group.
  - Joker access exists only from about day 38–42, and paid Joker offers cover only 18–25% of 131 receipts.
  - In album 15, where 131 was first available through Sugar Rush on day 32, this group did better: 64% paid vs 55% in album 14, and 18% finished vs 13%. This comparison is confounded.
- **Proposed A/B:** from close−7, offer a targeted Joker / last-Royal offer to payers 1–3 short.
  - Primary: PU ARPDAU from close−7 to close−1.
  - Guardrails: total album revenue (cannibalisation of Market and other events), finish rate, next-album ARPDAU and retention.

**B. 131 release timing → release it mid-album through an event, as Sugar Rush did in album 15.** Status: **Test**, once the studio confirms how 131 is configured.
- **Evidence:** in album 15, 15% of 131 receipts came from an event on day 32, compared with 0 before day 38 in album 14 apart from recovery and sceneboost.
- **Hypothesis:** an earlier gate keeps more payers within reach in the final week.
- **Proposed A/B:** release day 32 vs day 40+.
  - Primary: PU ARPDAU over the last 10 days.
  - Guardrails: finish rate (early finishers may stop spending), whole-album PU ARPDAU, next-album retention.

**C. No closing mechanism for payers far from finishing → add a Royal duplicate exchange in the last week.** Status: **Test** (proposed; not agreed with the Disney team).
- **Evidence:**
  - Disney is the only game with 0% duplicate exchange. In Domino it gives 23–30% of Q4 new Royals; in Dice, 3–12% of Q4 new Supers.
  - 45–61% of PU sit 4–10 stickers short and spend about $8–10 each in the last 4 days.
- **Proposed A/B:** allow duplicates to be exchanged for a Royal from close−10.
  - Primary: PU pay rate and ARPDAU over the last 10 days.
  - Guardrails: Market revenue, finish rate, next-album ARPDAU.

The release pattern of the other six Royals (pulses on low-revenue days) is **Fact only** for now.

## 3. Charts for the deck

**Chart 1.** Title: "Disney's album end is a dip, not a lift: the same weekdays earlier in the album earn more." Grouped bar chart: x = Thursday–Sunday window (album days 4–7, 11–14, 18–21, 25–28, 32–35, 39–42), y = PU ARPDAU, one series per album. Pay rate can go on a secondary line.

| Window (album days) | 4–7 | 11–14 | 18–21 | 25–28 | 32–35 | 39–42 (end) |
|---|---|---|---|---|---|---|
| Album 14 ARPDAU / pay rate | 3.39 / .198 | 3.03 / .176 | 3.32 / .195 | 3.14 / .181 | 2.92 / .167 | **2.74 / .158** |
| Album 15 ARPDAU / pay rate | 3.62 / .202 | 3.07 / .169 | 2.81 / .162 | 3.17 / .170 | 3.19 / .167 | **2.98 / .161** |

**Chart 2.** Title: "Six Royals arrive in pulses; the seventh (131) only at the end, through a Joker." Dot or range chart per Royal: the bar runs from the day 10% of collectors had it to the day 50% had it, and the label shows collectors. Highlight 131.

| Royal | 14: day 10% / 50% / collectors | 15: day 10% / 50% / collectors |
|---|---|---|
| 108 | 5 / 7 / 1.36M | 3 / 10 / 1.28M |
| 120 | 5 / 16 / 0.88M | 19 / 25 / 0.50M |
| 96 | 7 / 25 / 0.80M | 18 / 25 / 0.51M |
| 143 | 21 / 25 / 0.81M | 19 / 25 / 0.53M |
| 144 | 22 / 25 / 0.71M | 23 / 31 / 0.54M |
| 132 | 22 / 37 / 0.62M | 24 / 32 / 0.63M |
| **131** | **40 / 42 / 35K** | **32 / 41 / 44K** |

A small table to go beside chart 2 (state at close−5, PU): payers 1–3 short with a Royal missing are 13% / 9.5% of PU. 55% / 64% of them pay in the last 4 days (Dice equivalent: 82–84%), and 13% / 18% finish.

## 4. Open questions for the Disney studio

1. Is Royal 131 excluded from the pack pool by design, so it can only be obtained by Joker or as a direct reward? Is the same true in album 16?
2. What is the Royal release calendar per album? Pulses fall on days 7, 10, 16, 21–26 and 32–36, yet several Royals reach 1K players on day 1 in album 14. Are Royals locked by config or only by events?
3. What does a player spend in the Market (marketplace): paid currency or a free resource? It supplies 67% of 131 in album 14 and 21% in album 15.
4. Were paid Joker offers shown to all payers who were 1–3 short, and from which day?
5. Was Sugar Rush delivering 131 on day 32 of album 15 a deliberate change from album 14?
6. Is the sticker-to-set mapping 12 consecutive IDs per set? If so, Royals sit in sets 8–12 and set 11 holds two Royals (131 and 132). Needs Validation.
7. Is a duplicate exchange for Royals technically possible in Disney?

## 5. SQL appendix

All five queries ran on `solitaire-dreams-411507`, read-only, with a partition filter and a dry run first. Total scanned: about 97.6 GB.

**Q1. Sticker types and phase (23.86 GB).** Result: `phase` = 1 for every sticker. Each album has 113 Common, 24 Golden and 7 Royal stickers (144), plus 36 Magic stickers outside the 144. `phase` cannot be used as a release flag.
```sql
SELECT album_id, sticker_type, phase, COUNT(DISTINCT sticker_id) AS stickers,
  MIN(sticker_collected_min_date) AS first_date, COUNT(*) AS rows_
FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
WHERE sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-05'
  AND album_id IN (14, 15) AND user_collected_sticker_flag
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
```

**Q2. Per-Royal release timing (15.83 GB).** Each user × sticker is deduplicated to its first date.
```sql
WITH r AS (
  SELECT album_id, sticker_id, user_id, MIN(sticker_collected_min_date) AS d
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
  WHERE sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-04'
    AND album_id IN (14, 15) AND user_collected_sticker_flag AND sticker_type = 'Royal'
  GROUP BY 1, 2, 3),
daily AS (SELECT album_id, sticker_id, d, COUNT(*) AS n FROM r GROUP BY 1, 2, 3),
cum AS (
  SELECT album_id, sticker_id, d, n,
    SUM(n) OVER (PARTITION BY album_id, sticker_id ORDER BY d) / SUM(n) OVER (PARTITION BY album_id, sticker_id) AS cshare,
    SUM(n) OVER (PARTITION BY album_id, sticker_id) AS total
  FROM daily),
op AS (SELECT 14 AS album_id, DATE '2026-07-13' AS o UNION ALL SELECT 15, DATE '2026-08-24')
SELECT c.album_id, c.sticker_id, ANY_VALUE(c.total) AS collectors,
  MIN(IF(c.n >= 1000, DATE_DIFF(c.d, op.o, DAY) + 1, NULL)) AS first_day_1k_users,
  MIN(IF(c.cshare >= 0.10, DATE_DIFF(c.d, op.o, DAY) + 1, NULL)) AS day_10pct,
  MIN(IF(c.cshare >= 0.50, DATE_DIFF(c.d, op.o, DAY) + 1, NULL)) AS day_50pct,
  ARRAY_AGG(STRUCT(DATE_DIFF(c.d, op.o, DAY) + 1 AS day, c.n) ORDER BY c.n DESC LIMIT 3) AS top_days
FROM cum c JOIN op USING (album_id)
GROUP BY 1, 2 ORDER BY 1, 4
```

**Q3. State at close−5 → behaviour in the last 4 days and the 131 gate (23.50 GB).** Population: PU not first album, login ratio ≥ 0.5, close day excluded.
```sql
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, a.login_ratio, a.user_album_count,
    IFNULL(a.album_spent_today, 0) AS spend, a.active_flag,
    a.unique_album_stickers_lt AS stk, a.unique_royal_stickers_tl AS roy, a.unique_golden_stickers_lt AS gold
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
u AS (
  SELECT album_id, user_id,
    ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS lr,
    MAX(user_album_count) AS uac, SUM(spend) AS spend_all,
    SUM(IF(date_dim >= DATE_SUB(c, INTERVAL 4 DAY), spend, 0)) AS spend_l4,
    COUNTIF(date_dim >= DATE_SUB(c, INTERVAL 4 DAY) AND spend > 0) AS paydays_l4,
    MAX(IF(date_dim <= DATE_SUB(c, INTERVAL 5 DAY), stk, NULL)) AS stk5,
    MAX(IF(date_dim <= DATE_SUB(c, INTERVAL 5 DAY), roy, NULL)) AS roy5,
    MAX(IF(date_dim <= DATE_SUB(c, INTERVAL 5 DAY), gold, NULL)) AS gold5,
    MAX(stk) AS stk_end, MAX(roy) AS roy_end
  FROM rows_ GROUP BY 1, 2),
pop AS (SELECT album_id, user_id, spend_l4, paydays_l4, stk5, roy5, gold5, stk_end, roy_end FROM u WHERE lr >= 0.5 AND uac > 1 AND spend_all > 0),
r131 AS (
  SELECT DISTINCT album_id, user_id
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
  WHERE sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-04'
    AND album_id IN (14, 15) AND user_collected_sticker_flag AND sticker_type = 'Royal' AND sticker_id = 131
    AND sticker_collected_min_date <= IF(album_id = 14, DATE '2026-08-19', DATE '2026-09-30'))
SELECT p.album_id,
  CASE WHEN p.stk5 >= 144 THEN 'a finished'
       WHEN 144 - p.stk5 BETWEEN 1 AND 3 AND 7 - p.roy5 >= 1 THEN 'b 1-3 short, Royal missing'
       WHEN 144 - p.stk5 BETWEEN 1 AND 3 THEN 'c 1-3 short, no Royal missing'
       WHEN 144 - p.stk5 BETWEEN 4 AND 10 THEN 'd 4-10 short'
       ELSE 'e >10 short' END AS state_close_minus5,
  COUNT(*) AS payers, ROUND(AVG(7 - p.roy5), 2) AS avg_royals_missing,
  ROUND(COUNTIF(r.user_id IS NULL AND p.stk5 < 144) / COUNT(*), 3) AS share_missing_131,
  ROUND(COUNTIF(p.paydays_l4 > 0) / COUNT(*), 3) AS paid_last4,
  ROUND(SUM(p.spend_l4) / NULLIF(SUM(p.paydays_l4), 0), 2) AS rev_per_payday_l4,
  ROUND(SUM(p.spend_l4) / COUNT(*), 2) AS rev_per_payer_l4,
  ROUND(COUNTIF(p.stk_end >= 144) / COUNT(*), 3) AS finished_by_close_minus1
FROM pop p LEFT JOIN r131 r ON r.album_id = p.album_id AND r.user_id = p.user_id
GROUP BY 1, 2 ORDER BY 1, 2
```
Key rows from the result:

| Album | State at close−5 | Payers | Paid in last 4 days | $ per paying day | $ per payer | Finished |
|---|---|---|---|---|---|---|
| 14 | 1–3 short, Royal missing | 48,905 | 55.2% | 28.79 | 31.11 | 13.1% |
| 14 | 4–10 short | 226,255 | 35.0% | 13.70 | 7.50 | 3.2% |
| 14 | >10 short | 94,785 | 18.9% | 9.33 | 2.26 | 0.3% |
| 15 | 1–3 short, Royal missing | 30,823 | 63.6% | 34.38 | 44.09 | 17.9% |
| 15 | 4–10 short | 145,082 | 40.5% | 15.72 | 10.18 | 4.2% |
| 15 | >10 short | 147,870 | 22.9% | 9.50 | 2.87 | 0.9% |

The "1–3 short, no Royal missing" rows hold only 342 / 1,374 payers, and "finished" only 6 per album.

**Q4. How players get Royal 131: source, campaign, Joker flag (12.65 GB).**
```sql
WITH r AS (
  SELECT album_id, user_id, ARRAY_AGG(STRUCT(sticker_collected_min_date AS d, IFNULL(NULLIF(new_sticker_source, ''), '(null)') AS src,
      IFNULL(new_sticker_mtx_campaign_name, '(none)') AS camp, IFNULL(collected_by_joker_flag, FALSE) AS joker)
      ORDER BY sticker_collected_min_ts LIMIT 1)[OFFSET(0)] AS x
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
  WHERE sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-04'
    AND album_id IN (14, 15) AND user_collected_sticker_flag AND sticker_type = 'Royal' AND sticker_id = 131
  GROUP BY 1, 2),
op AS (SELECT 14 AS album_id, DATE '2026-07-13' AS o UNION ALL SELECT 15, DATE '2026-08-24')
SELECT r.album_id, x.src, x.camp, COUNT(*) AS users,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY r.album_id), 3) AS share,
  ROUND(COUNTIF(x.joker) / COUNT(*), 3) AS joker_share,
  MIN(DATE_DIFF(x.d, op.o, DAY) + 1) AS min_day, APPROX_QUANTILES(DATE_DIFF(x.d, op.o, DAY) + 1, 2)[OFFSET(1)] AS med_day
FROM r JOIN op USING (album_id)
GROUP BY 1, 2, 3 HAVING COUNT(*) >= 200 ORDER BY 1, 4 DESC
```

**Q5. Daily PU curve: ARPDAU, pay rate, revenue per paying day, new Royals, Jokers, new stickers and packs per DAU (21.74 GB).** The weekday-matched windows and quarter splits were computed offline from this output.
```sql
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS o, a.login_ratio, a.user_album_count,
    IFNULL(a.album_spent_today, 0) AS spend, IFNULL(a.active_flag, FALSE) AS act,
    IFNULL(a.unique_royal_stickers_today, 0) AS new_roy, IFNULL(a.number_of_jokers_today, 0) AS jok,
    IFNULL(a.unique_album_stickers_today, 0) AS new_stk, IFNULL(a.unique_packs_received_today, 0) AS packs
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (
  SELECT album_id, user_id FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND MAX(user_album_count) > 1
    AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5)
SELECT r.album_id, DATE_DIFF(r.date_dim, r.o, DAY) + 1 AS day, COUNTIF(r.act) AS dau,
  ROUND(SUM(r.spend) / COUNTIF(r.act), 3) AS arpdau,
  ROUND(COUNTIF(r.spend > 0) / COUNTIF(r.act), 4) AS pay_rate,
  ROUND(SUM(r.spend) / NULLIF(COUNTIF(r.spend > 0), 0), 2) AS rev_per_payday,
  ROUND(SUM(r.new_roy) / COUNTIF(r.act), 4) AS new_royals_per_dau,
  ROUND(SUM(r.jok) / COUNTIF(r.act), 4) AS jokers_per_dau,
  ROUND(SUM(r.new_stk) / COUNTIF(r.act), 3) AS new_stickers_per_dau,
  ROUND(SUM(r.packs) / COUNTIF(r.act), 2) AS packs_per_dau
FROM rows_ r JOIN pop USING (album_id, user_id)
GROUP BY 1, 2 ORDER BY 1, 2
```
Q5 summary:
- **Whole album, PU ARPDAU / pay rate / $ per paying day:** album 14 = 2.878 / 0.174 / 16.50; album 15 = 2.958 / 0.169 / 17.55.
- **Last 4 days, same metrics:** album 14 = 2.743 / 0.158 / 17.31; album 15 = 2.981 / 0.161 / 18.50.

**Caveats:**
- Q5 counts PU from days with `active_flag`, so its ARPDAU is a PU-only figure. It is not comparable to the all-engaged $0.93 in `disney-album-context.md`.
- Another agent re-locked the session to three projects partway through, so Q3–Q5 pass `project=solitaire-dreams-411507` explicitly. This had no effect on results.

**Possible memory to save** (Disney album context, project subtree): Royal 131 is the Joker-only final gate in albums 14 and 15. `dim_user_album_stickers.phase` is always 1 and cannot be used as a release flag. Sticker types per album: Common 113, Golden 24, Royal 7, plus Magic 36 outside the 144.
---

## Cross-game analyst: end-of-album structure (Dice 61/63 · Domino 17/19 · Disney 14/15)

**Scope.** Every number below comes from one SQL template run once per game, with only the table and column names changed (see the appendix).

**Population.** Payers only, meaning album spend above 0 before close. Not excluded, and login ratio on the player's last row before close is at least 0.5. The close day is left out because it is partial. "End state" is the player's state on the day before close.

**Finished** means holding all 144 set stickers (Common + Golden + rare, unique). I did not use the games' own finish flags. In Dice the flag-based payer finish rate is 11.5% / 13.5%; with my sticker-count rule it is 8.7% / 10.4%. The gap is players marked finished by the "album completed" event. Results for "not in first album" players are within 1–2 points of all payers, so all payers are shown.

### 1. Top 5 insights
1. **Disney's ending is entirely release-gated.** 99.95% of Disney payer finishers got their last sticker in the final 4 days, and 0% finished with 7 or more days left. Dice: 92–94% in the final 4 days. Domino: 71% (album 17) and 98% (album 19). Domino 17 is the only album with real early finishers: 10% finished with 7+ days left. *Known; payers.*
2. **The final gate is a different sticker type in each game.**
   - The last sticker is the rare in Dice (71–83%) and in Disney 14 (81%).
   - In Domino 17 it is a **Golden** (83%).
   - Payers holding every rare go on to finish: Dice 86–88%, Disney 61–79%, Domino 19 76%, **Domino 17 only 32%**.
   - Across all near-finishers (1–10 stickers short), the share of their missing stickers that are rares: Dice 65–75%, Domino 29% / 54%, Disney 40–41%.
   - *Known; payers.*
3. **Dice holds payers at the gate; the other two leave them far from it.**
   - Payers ending 1–3 stickers short: Dice 35% / 54%, Domino 15% / 13%, Disney 19% / 15%.
   - Payers ending 11+ short: Dice 12–14%, Domino 30–38%, Disney 20–30%.
   - Finish rate: Dice 8.7–10.4%, Domino 4.5–5.9%, Disney 3.8–4.1%.
   - *Known; payers.*
4. **One rare short entering the last 4 days (state at the end of close−5):**
   - Finished by close−1: Dice 68–70%, Domino 61% / 76%, **Disney 14: 22%** (n = 1,064), Disney 15: 55%.
   - Paid in the last 4 days: Dice 83–85%, Domino 81% / 91%, Disney 62% / 76%.
   - Disney 14's near-finishers at close−5 were almost all short a Royal (1,064 players vs 12 short a Golden).
   - *Known for the numbers. Hypothesis: the locked Royal was not yet obtainable.*
5. **Finishers close the album with Wild/Joker stickers in every game.**
   - Last sticker via Wild/Joker: Dice 87–90%, Domino 45% / 96%, Disney 69–86%.
   - Finishers' share of payer revenue: Dice 25–28%, Domino 22–30%, Disney 17–19%.
   - *Known; payers. Wild (Dice) and Joker (Domino, Disney) are different mechanics; see the definition gaps below.*

### 2. What to improve
1. **Disney ← Dice: open the locked-Royal window earlier.**
   - *Evidence:* nobody can finish before the last 4 days. Disney's end-of-album revenue lift is flat (0.98–1.06×, Topic 2). One-Royal-short payers at close−5 finish 22–55% of the time, against 68–70% in Dice. The finishers' last 3 stickers are 38% Royal and 62% Golden, which matches the stated lock design of 1 Royal + 2 Goldens (Topic 8, not yet validated).
   - *A/B:* release the locked Royal at close−7 instead of the current day.
     - Primary: payer revenue per active day (ARPDAU) over the last 7 full days.
     - Guardrails: whole-album payer ARPDAU, payer finish rate, next-album D7 retention.
   - **Status: Test**, but only after the Royal release calendar is confirmed (Needs Validation).
2. **Domino: make the final gate consistent.**
   - *Evidence:* album 17 is Golden-gated. 13% of its non-finishers already hold every Royal (1–3% in the other albums), and holding all Royals leads to finishing only 32% of the time. Album 19 is split between Royal and Golden. Near-finishers paid in the last 4 days at 64% in album 17 vs 80% in album 19.
   - These are two albums with different designs, so this is descriptive, not causal.
   - *A/B:* the last locked sticker is a Royal vs a Golden.
     - Primary: payer ARPDAU over the last 4 full days.
     - Guardrails: finish rate, Joker revenue, retention.
   - **Status: Test.**
3. **Dice ← Domino: a late-album exchange path for stuck near-finishers.**
   - *Evidence:* 35–54% of Dice payers end 1–3 stickers short, and 99% of those 2–3 short are missing a Super. Duplicate exchange supplies 23–30% of Domino's last-quarter new Royals vs 3–12% of Dice's (Topic 5).
   - *A/B:* Super duplicate-exchange in the last quarter of the album.
     - Primary: payer finish rate plus payer ARPDAU over the last 7 days.
     - Guardrails: Wild-offer revenue (cannibalisation), whole-album ARPDAU, next-album retention.
   - **Status: Test.** This works against the current "more Super slots" test, so run them separately.

**Fact only:** near-finishers spend 2–7× more per active day than players 11+ short: Dice $3.14–4.08 vs $1.44–1.58, Domino $5.0–5.6 vs $0.81–1.08, Disney $5.7–7.2 vs ~$1.0. This is selection, not an effect.

### 3. Charts for the deck
**Chart 1 – "What closes the album"** (100% stacked bar per album, plus a dot for the share via Wild/Joker)

| Album | Last sticker rare % | Golden % | Common % | Via Wild/Joker % | Last sticker in final 4 days % |
|---|---|---|---|---|---|
| Dice 61 | 83.0 | 16.4 | 0.6 | 90.3 | 92.3 |
| Dice 63 | 71.2 | 28.3 | 0.6 | 86.9 | 93.5 |
| Domino 17 | 16.3 | 83.4 | 0.3 | 45.1 | 71.2 |
| Domino 19 | 50.9 | 48.5 | 0.7 | 95.6 | 97.9 |
| Disney 14 | 80.6 | 19.4 | 0 | 86.4 | 99.95 |
| Disney 15 | 48.0 | 52.0 | 0 | 69.1 | 99.96 |

**Chart 2 – "Where payers end the album"** (100% stacked bar, payers at close−1)

| Album | Finished | 1 short | 2–3 short | 4–10 short | 11+ short |
|---|---|---|---|---|---|
| Dice 61 | 8.7 | 3.7 | 31.1 | 42.9 | 13.6 |
| Dice 63 | 10.4 | 4.2 | 50.2 | 22.8 | 12.4 |
| Domino 17 | 5.9 | 2.3 | 12.4 | 41.8 | 37.7 |
| Domino 19 | 4.5 | 2.2 | 10.3 | 52.8 | 30.2 |
| Disney 14 | 3.8 | 2.7 | 15.9 | 57.5 | 20.1 |
| Disney 15 | 4.1 | 2.2 | 12.8 | 50.9 | 30.0 |

**Where definitions cannot be fully aligned (flag on the slides):**
- **Revenue.** Domino's `album_spent_today` is documented in the schema as "coins spent". Earlier sessions treated it as game revenue. Cross-game ARPDAU levels need this checked first; within-game ratios are safe.
- **Duplicate share** (Dice 78–82%, Domino 84–86%, Disney 83–86%). The total-stickers column may include Pixie or Magic stickers in Domino and Disney. Needs Validation.
- **Wild vs Joker** are different mechanics.
- **Locked stickers** differ by design: Dice 2 Super + 1 Golden, Domino Easy 5 / Hard 2 Royal + 1 Golden, Disney 1 Royal + 2 Golden. Domino results mix its Easy and Hard segments.
- **Login ratio** is fixed per album in Dice and daily in Domino/Disney. I used the last row before close in all three.

### 4. Open questions for the studio teams
- **Disney:** on which day is each locked sticker released in albums 14 and 15? Is the Joker free or paid? Why did album 15 let 52% of finishers end on a Golden?
- **Domino:** were albums 17 and 19 designed with different last locks (Golden vs Royal)? What do the 10% early finishers of album 17 get (deluxe album?), and what is the Easy/Hard split of the locks?
- **Dice:** what share of the Wild sources that close the album are paid? Is there any duplicate protection for Supers late in the album?
- **All teams:** confirm that the album spend column means real money (USD) in Domino and Disney.

### 5. SQL appendix
Six queries, all dry-run first with identical SQL, all read-only, partition-filtered and under 100 GB each.

| Query | Project | Bytes scanned |
|---|---|---|
| Q1 end state | dice-dreams-dbt | 7.19 GB |
| Q1 end state | domino-dreams-dbt | 13.02 GB |
| Q1 end state | solitaire-dreams-411507 | 21.74 GB |
| Q2 finishers' last 3 stickers | dice-dreams-dbt | 16.89 GB |
| Q2 finishers' last 3 stickers | domino-dreams-dbt | 23.68 GB |
| Q2 finishers' last 3 stickers | solitaire-dreams-411507 | 59.93 GB |

The full Q1 text per game is saved in:
- /tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/dice_q1_endstate.sql
- /tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/domino_q1_endstate.sql
- /tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/disney_q1_endstate.sql

**Q1 – game-specific `base` CTE (only part that differs)**
```sql
-- Dice
WITH base AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_start_date AS a_start, a.album_end_date AS a_end,
  a.album_login_ratio AS blr, IFNULL(a.spent_in_album_today,0) AS bsp, IFNULL(a.is_active,FALSE) AS bact,
  IFNULL(a.unique_common_stickers_lt,0) AS bc, IFNULL(a.unique_golden_stickers_lt,0) AS bg, IFNULL(a.unique_super_stickers_lt,0) AS br,
  IFNULL(a.total_stickers_lt,0) AS btot, IFNULL(a.user_past_album_count,0) > 0 AS bnf
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a
  WHERE a.date_dim BETWEEN '2026-06-22' AND '2026-09-06' AND a.album_id IN (61,63)
    AND IFNULL(a.is_excluded,FALSE) = FALSE AND a.date_dim < a.album_end_date),
-- Domino: excluded = suspected_cheater_flag users from prod_40_mart.user_daily_metrics (2026-04-02..08-23);
--   base from `domino-dreams-dbt.prod_40_mart.user_daily_album`: album_open_date / album_close_date, login_ratio,
--   album_spent_today, active_flag, unique_common/golden_stickers_lt, unique_royal_stickers_tl, album_stickers_lt,
--   user_album_count > 1; special_user_flag = FALSE; albums 17,19; date_dim < album_close_date.
-- Disney: identical to Domino using `solitaire-dreams-411507.bi_prod.user_daily_album` (2026-07-13..10-04, albums 14,15);
--   excluded = bi_prod.user_profile with exclude_reason IS NOT NULL.
```

**Q1 – shared body (identical for all three games)**
```sql
tt AS (SELECT album_id, MAX(bc) AS C, MAX(bg) AS G, MAX(br) AS R FROM base GROUP BY 1),
pop AS (SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, LOGICAL_OR(bnf) AS not_first,
  SUM(bsp) AS spend, COUNTIF(bact) AS act_days, MAX(bc) AS uc, MAX(bg) AS ug, MAX(br) AS ur, MAX(btot) AS tot,
  ARRAY_AGG(IF(date_dim <= DATE_SUB(a_end, INTERVAL 5 DAY), STRUCT(bc AS c5, bg AS g5, br AS r5), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1) AS s5,
  SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY), bsp, 0)) AS end_rev, COUNTIF(bact AND date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY)) AS end_days,
  SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 5 DAY), bsp, 0)) AS pre_rev, COUNTIF(bact AND date_dim <= DATE_SUB(a_end, INTERVAL 5 DAY)) AS pre_days,
  ARRAY_AGG(STRUCT(date_dim AS d, bc+bg+br AS u) ORDER BY date_dim) AS hist, ARRAY_AGG(STRUCT(date_dim AS d, bsp AS s, bact AS a) ORDER BY date_dim) AS days
  FROM base GROUP BY 1,2
  HAVING SUM(bsp) > 0 AND ARRAY_AGG(blr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
u AS (SELECT p.album_id, p.user_id, p.not_first, p.spend, p.act_days, p.end_rev, p.end_days, p.pre_rev, p.pre_days, t.R, t.C AS qc, t.G AS qg, p.ur, p.tot,
  p.uc+p.ug+p.ur AS useti, (t.C+t.G+t.R)-(p.uc+p.ug+p.ur) AS miss, t.R-p.ur AS miss_r, t.G-p.ug AS miss_g, t.C-p.uc AS miss_c,
  (t.C+t.G+t.R)-(p.s5[SAFE_OFFSET(0)].c5+p.s5[SAFE_OFFSET(0)].g5+p.s5[SAFE_OFFSET(0)].r5) AS miss5,
  t.R-p.s5[SAFE_OFFSET(0)].r5 AS miss5_r, t.G-p.s5[SAFE_OFFSET(0)].g5 AS miss5_g,
  (SELECT MIN(h.d) FROM UNNEST(p.hist) h WHERE h.u >= t.C+t.G+t.R) AS fin_d, DATE_DIFF(p.a_end, p.a_start, DAY) AS span, p.a_start, p.a_end, p.days
  FROM pop p JOIN tt t USING (album_id)),
f AS (SELECT album_id, not_first, spend, act_days, end_rev, end_days, pre_rev, pre_days, R, qc, qg, tot, useti, miss, miss_r, miss_g, miss5, miss5_r, miss5_g,
  IF(fin_d IS NULL, NULL, DATE_DIFF(fin_d, a_start, DAY)/span) AS fin_pct, IF(fin_d IS NULL, NULL, DATE_DIFF(a_end, fin_d, DAY)) AS fin_days_left,
  (SELECT SUM(x.s) FROM UNNEST(days) x WHERE fin_d IS NOT NULL AND x.d > fin_d) AS post_rev, (SELECT COUNTIF(x.a) FROM UNNEST(days) x WHERE fin_d IS NOT NULL AND x.d > fin_d) AS post_days,
  (SELECT SUM(x.s) FROM UNNEST(days) x WHERE fin_d IS NOT NULL AND x.d <= fin_d) AS prefin_rev, (SELECT COUNTIF(x.a) FROM UNNEST(days) x WHERE fin_d IS NOT NULL AND x.d <= fin_d) AS prefin_days
  FROM u),
s AS (SELECT album_id, not_first, spend, act_days, end_rev, end_days, pre_rev, pre_days, R, qc, qg, tot, useti, miss, miss_r, miss_g, miss5, miss5_r, miss5_g,
  fin_pct, fin_days_left, post_rev, post_days, prefin_rev, prefin_days, seg FROM f, UNNEST(['all_pu','not_first']) seg WHERE seg='all_pu' OR not_first)
SELECT album_id, seg, COUNT(*) AS pu, SUM(spend)/SUM(act_days) AS arpdau, COUNTIF(miss=0)/COUNT(*) AS finish_rate,
  -- shares missing 1 / 2-3 / 4-10 / 11+
  -- miss1_is_rare / miss1_is_golden; miss2_3_any_rare; rare and golden share of missing stickers (1-10 short)
  -- ARPDAU for 1-3 short vs 11+ short; share holding all rares; finish rate given all rares; non-finishers holding all rares
  -- dup share = 1 - SUM(useti)/SUM(tot); P50 stickers received; P50 finish point (% of album); finishers with 7+ days left
  -- finisher ARPDAU before/after finishing; finisher revenue share
  -- close-5 one-short groups (rare / golden / common): n, share paid in close-4..close-1, end-vs-pre ARPDAU, finished by close-1
  ...
FROM s GROUP BY 1,2
```
Exact column expressions are in the saved files.

**Q2 – finishers' last 3 stickers** (shown for Domino; Dice and Disney differ only as noted below)
```sql
WITH excluded AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN '2026-04-02' AND '2026-08-23' AND suspected_cheater_flag),
base AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS a_end, a.login_ratio AS blr, IFNULL(a.album_spent_today,0) AS bsp,
  IFNULL(a.unique_common_stickers_lt,0)+IFNULL(a.unique_golden_stickers_lt,0)+IFNULL(a.unique_royal_stickers_tl,0) AS bu
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN '2026-04-02' AND '2026-08-23' AND a.album_id IN (17,19)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
fin AS (SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end FROM base GROUP BY 1,2
  HAVING SUM(bsp) > 0 AND ARRAY_AGG(blr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5 AND MAX(bu) >= 144),
st AS (SELECT f.album_id, f.user_id, LOWER(s.sticker_type) AS typ, IFNULL(s.collected_by_joker_flag,FALSE) AS jk, s.sticker_collected_min_ts AS ts,
  DATE_DIFF(f.a_end, s.sticker_collected_min_date, DAY) AS days_before_close
  FROM fin f JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN '2026-04-02' AND '2026-08-23' AND s.album_id IN (17,19)
    AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.user_collected_sticker_flag
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
rk AS (SELECT album_id, user_id, typ, jk, days_before_close, ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) AS rn FROM st)
SELECT album_id, COUNT(DISTINCT user_id) AS finishers,
  COUNTIF(rn=1 AND typ='royal')/COUNTIF(rn=1) AS last1_rare, COUNTIF(rn=1 AND typ='golden')/COUNTIF(rn=1) AS last1_golden,
  COUNTIF(rn<=3 AND typ='royal')/COUNTIF(rn<=3) AS last3_rare, COUNTIF(rn<=3 AND typ='golden')/COUNTIF(rn<=3) AS last3_golden,
  COUNTIF(rn<=3 AND jk)/COUNTIF(rn<=3) AS last3_joker, COUNTIF(rn=1 AND jk)/COUNTIF(rn=1) AS last1_joker,
  APPROX_QUANTILES(IF(rn=1, days_before_close, NULL),100)[OFFSET(50)] AS p50_last_days_before_close,
  COUNTIF(rn=1 AND days_before_close<=4)/COUNTIF(rn=1) AS last_in_final_4_days, MAX(rn) AS qa_max_rows_per_user
FROM rk GROUP BY 1
```
- **Disney:** same query on `bi_prod.user_daily_album` plus `bi_entity_prod.dim_user_album_stickers`, deduped per player × sticker, 2026-07-13..10-04, albums 14/15.
- **Dice:** same query on `50_reporting.user_daily_album` plus `30_intermediate.fact_user_album_stickers`, using `collected_from_wild`, `sticker_collected_ts` / `sticker_collected_date`, `is_sticker_collected`, type `'super'`, 2026-06-22..09-06, albums 61/63.

**QA (Known):** the derived sticker totals match the album design in every album — Common/Golden/rare = 104/28/12 (Dice), 108/28/8 and 107/28/9 (Domino 17/19), 113/24/7 (Disney). Every finisher has 144 sticker rows. Dice's one-short-at-close−5 numbers reproduce the earlier one-pager: 835 vs 840 and 1,460 vs 1,481 players, 85% and 83% paid in the last 4 days.

**Worth remembering:**
- Disney's ending is release-gated: 99.95% of finishers get their last sticker in the final 4 days.
- Domino 17's final gate was a Golden, not a Royal.
- The Domino album spend column is documented as "coins spent", so cross-game revenue levels need checking before use.
