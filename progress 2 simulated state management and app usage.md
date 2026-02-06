
This is meant to be the **single source of truth** for the current implementation phase.

---

# 📘 Product Requirements Document (PRD)

## Workout App — Advanced Mock Data & UI Behavior Phase

### Scope: Mock Repository, State Management, Screen Behavior

### Goal: Enable realistic, time-simulated data to validate UI/UX and logic across the entire app.

---

## 1. Product Story & Intent

This app is a **visual truth engine for body change**.

At this stage, we are **not** optimizing for real-world daily usage.
Instead, we are building a **time-simulated environment** that behaves like a real app over weeks of usage — even if the user interacts with it in minutes.

The intent is:

* To **see 30 days of realistic data**
* To observe how UI components react over time
* To validate streaks, charts, progress, and timelines
* To stress-test navigation and data visibility

This phase is critical.
If mock data does not behave like real data, the UI will lie to us.

---

## 2. Core Principle: Time-Simulated Mock Repository

### Story

Instead of waiting 30 real days to test the app, the app should **pretend time is passing** each time the user logs something.

Each user action represents **a new day advancing**.

---

### Specification

#### Mock Repository Rules (MANDATORY)

* The repository must initialize with:

  * A starting date **30 days in the past**
* Every new save action:

  * Advances the “current mock day” by **+1 day**
  * Saves the data under that day
* This applies to:

  * Photos
  * Measurements
  * Macronutrients

#### Key Rules

* There is **only one record per day**
* Updating a record modifies that day
* Saving again creates a **new day**
* This allows:

  * Viewing up to 30 days of history
  * Visualizing trends across all screens

The mock repository must always expose:

* Last 7 days
* Last 30 days
* Latest day (“Today”)

---

## 3. Settings Screen — Tracking Configuration

### Story

The Settings screen defines **what the user cares about**.
Anything disabled here should **disappear everywhere else**.

---

### Specification

#### Tracking Zones

Each toggle controls visibility + tracking:

* Face
* Body Front
* Body Side
* Body Back

If ON:

* Appears in Today screen
* Counts toward daily completion
* Appears in History & Progress

If OFF:

* Hidden everywhere
* Does NOT count toward completion

---

#### Measurements

* Multiple body measurements (waist, chest, arms, thighs, etc.)
* Only enabled measurements:

  * Appear in bottom sheets
  * Appear in History & Statistics
  * Count toward daily progress

---

#### Macronutrients

* Calories
* Protein
* Carbs
* Fats

Same visibility rules apply.

---

#### Preferences

* Theme (Light / Dark)
* Locale

---

## 4. Today Screen — Daily Execution Hub

### Story

The Today screen answers one question:

> “How much of today’s tracking have I completed?”

---

### Specification

#### Header

* Shows:

  * Current date (mock date)
  * Daily completion percentage

Completion logic:

* Based ONLY on enabled settings
* Example:

  * If Face + Body Front + Macros are ON
  * Only those count toward 100%

---

#### Photo Capture

* Each enabled zone:

  * Appears as a to-do
  * Once photo is taken → marked completed
* User can re-take to update the same day

⚠️ Mock Rule:

* Each accepted photo save advances the mock day

---

#### Macros & Measurements

* Open via bottom sheets
* Logging values:

  * Completes that task
  * Advances mock day
* Updating overwrites current mock day

---

## 5. History Screen — Reflection & Consistency

### Story

The History screen shows:

* Consistency
* Effort
* Trends

Not perfection.

---

### Specification

#### Weekly Overview (7 Days)

* Days: Mon → Sun
* Each day:

  * Intensity based on % completion
  * 100% = bright
  * Lower % = dimmer

---

#### Checklist

* Shows which parameters were:

  * Completed
  * Pending
* Based on settings

---

#### Streak

* Shows consecutive days with **any activity**
* Even 10% completion counts as a streak day

---

#### Activity Heatmap

* Visualizes intensity per day
* Based on % completion

---

#### Nutrients Overview

* Shows averages:

  * Calories
  * Protein
  * Carbs
  * Fats
* Visible ONLY if nutrients are enabled
* Tapping navigates to **Nutrient Statistics Page**

---

#### Measurements Overview

* Shows latest recorded values
* Only non-zero measurements
* Visible ONLY if measurements are enabled
* Tapping navigates to **Measurement Statistics Page**

---

## 6. Statistics Screens — Insight, Not Noise

### Story

Charts should **tell a story clearly**, not confuse the user.

---

### Shared Chart Rules

* Use `fl_chart` bar charts
* One bar = one day
* X-axis labels:

  * Human-readable dates (e.g., `30 Jan`)
* Tooltips:

  * Always visible
  * High contrast
  * Show value + unit + date

---

### Infinite Scrolling

* Charts scroll horizontally
* Load data dynamically
* Cache up to **2 weeks**
* Load more as user scrolls
* Never compromise performance

---

### Nutrient Statistics Page

* Shows:

  * Calories chart
  * Protein chart
  * Carbs chart
  * Fats chart
* Same time scale

---

### Measurement Statistics Page

* Shows ALL measurement charts together
* Only measurements that exist
* Below charts:

  * “Today’s Measurements” containers
  * Styled like History page

---

## 7. Progress Screen — Long-Term View

### Story

Progress is about **showing change**, not raw data.

---

### Specification

#### Streak Container

* Shows:

  * Current streak length

---

#### Completed Days

* Count of days since first record
* Based on mock start date

---

#### Dynamic Tabs

* Tabs represent tracked zones
* If more zones are enabled:

  * Tabs become scrollable
* Switching tabs:

  * Shows different progress visuals

---

## 8. Timeline — Visual Memory

### Story

Timeline is the **visual proof** of change.

---

### Specification

* Display latest **20 images**
* Lazy load next 20 on scroll
* No performance drops
* Maintain correct ordering by date

---

## 9. Non-Negotiable Rules

* Mock data must behave like real time
* Settings control visibility everywhere
* No screen shows irrelevant data
* UI consistency across screens
* Performance must remain smooth

---

## 10. Acceptance Criteria (Global)

This phase is complete ONLY if:

✅ 30-day simulated history works
✅ Every save advances mock day
✅ All screens reflect mock time correctly
✅ Charts are readable and scroll infinitely
✅ Settings fully control UI visibility
✅ No skipped requirements


