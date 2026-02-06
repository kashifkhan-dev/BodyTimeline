
# 📘 CORRECTED PRD — TIME-SHIFTED REAL DATA (NO FAKE MOCK UI DATA)

## Purpose of This Document

This specification exists to **fix a critical misunderstanding**:

❌ We are **NOT** showing fake / pre-generated mock data in the UI
❌ We are **NOT** simulating 30 days upfront
❌ We are **NOT** pre-filling history

✅ We **ONLY** use **real user actions** (photos, logs, measurements)
✅ We **TIME-SHIFT** those real actions into consecutive days
✅ This is a **temporary testing behavior** to simulate 30 days of usage **quickly**

This must be implemented **exactly** as written below.

---

## 1. Core Concept — Time-Shifted Real Records (CRITICAL)

### Story (Intent)

We cannot wait 30 real days to test the app.

Instead:

* Each time the user **takes a real action**
* That action is **assigned to a different day**
* This creates a realistic timeline using **real captured data**

This allows:

* Testing streaks
* Testing charts
* Testing history
* Testing progress
* Without fake data and without waiting a month

---

### Absolute Rules (NON-NEGOTIABLE)

1. **There is NO mock UI data**
2. **Nothing appears unless the user actually records it**
3. **Every save action = a new day**
4. **Data is real, only the timestamp is shifted**

---

## 2. Time-Shift Logic (THE MOST IMPORTANT PART)

### Base Date

* The **first ever record** is saved as:

  ```
  today - 30 days
  ```

### After That

Each **successful save** advances the date:

| User Action        | Saved As    |
| ------------------ | ----------- |
| First photo or log | Day -30     |
| Second save        | Day -29     |
| Third save         | Day -28     |
| ...                | ...         |
| Nth save           | Day -30 + N |

⚠️ This applies to:

* Photos
* Measurements
* Macronutrient logs

---

### What counts as a “Save”

A save happens when:

* A photo is **captured and accepted**
* A macro bottom sheet is **confirmed**
* A measurement bottom sheet is **confirmed**

Opening sheets does **nothing**
Canceling does **nothing**

---

## 3. One Record Per Day Rule

### Story

Each day represents **one snapshot of the body**.

### Specification

* A day can have:

  * Multiple photos (face, front, side, back)
  * Multiple measurements
  * Macro logs
* BUT:

  * They all belong to **the same shifted day**
* Editing later:

  * Creates a **new day**
  * Does NOT overwrite past days

❌ No overwriting history
❌ No merging days

---

## 4. Today Screen — Correct Behavior

### Story

“Today” means:

> The **current active shifted day**, not the real calendar day.

---

### Photo Capture

* When a photo is taken:

  * It is saved to the **current shifted day**
  * The task is marked complete
* Retaking:

  * Creates a **new shifted day**
  * Old photo remains in history

---

### Measurements & Macros

* When logs are saved:

  * They belong to the **current shifted day**
* Editing measurements:

  * Creates a **new shifted day**
  * Old values remain intact

---

## 5. History Screen — Data Must Come ONLY From Real Actions

### Story

History is a **truth log** of what the user actually did.

---

### Weekly View

* Only days that actually exist appear
* No empty or fabricated days
* Intensity = % of enabled tasks completed

---

### Streak

* A day counts as streak if:

  * **ANY real data exists**
* Even one photo or one measurement counts

---

### Nutrients Overview

* Uses ONLY saved logs
* Averages calculated from real saved days
* Hidden if nutrients are disabled

---

### Measurements Overview

* Shows latest saved values
* Only non-zero
* Only if measurements are enabled

---

## 6. Statistics & Charts — REAL DATA ONLY

### Story

Charts must tell the story of **what the user actually recorded**.

---

### Rules

* Each bar = one saved day
* Dates reflect shifted timestamps
* No gaps unless user skipped saves
* Infinite horizontal scrolling still applies
* Data loads dynamically as user scrolls

❌ No placeholder bars
❌ No empty days

---

## 7. Progress Screen — Truthful Progress

### Completed Days

* Count = number of saved shifted days

### Streak

* Based on consecutive shifted days
* Breaks only if user stops saving

---

### Tabs

* Tabs appear ONLY for enabled tracking zones
* Scrollable when many zones are enabled

---

## 8. Timeline — Visual Proof

### Story

Timeline is the **visual evidence** of progress.

---

### Specification

* Shows last **20 real photos**
* Lazy load next 20
* Ordered by shifted date
* No fake images
* No placeholders

---

## 9. Explicit Things the Agent MUST NOT Do

🚫 DO NOT pre-generate days
🚫 DO NOT fabricate measurements
🚫 DO NOT simulate days without user actions
🚫 DO NOT reset timestamps silently
🚫 DO NOT mix old mock logic with this system

If the user does nothing → **nothing appears**

---

## 10. Why This Matters (For the Agent)

This system is:

* Temporary
* Purpose-built for testing
* Designed to behave like real usage
* Designed to reveal UX flaws early

If this logic is wrong:

* Streaks lie
* Charts lie
* Progress lies
* The app cannot be trusted

---

## 11. Acceptance Criteria (FINAL CHECK)

This phase is correct ONLY if:

✅ UI shows only user-generated data
✅ Every save advances the shifted day
✅ History grows only via real actions
✅ Charts reflect saved data exactly
✅ Editing creates new days
✅ No mock UI data exists anywhere

