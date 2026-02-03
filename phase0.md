

WORKOUT — PHASE 0

Product Requirements & Behavioral Specification

Project Name: workout
Platform: iOS-first (Cupertino Native), Android-supported
Architecture Target: Clean Architecture
State Management: Provider
Data Source (Phase 1–2): In-memory only

⸻

1. Product Purpose (North Star)

The app exists to:

Create visual, undeniable proof of body change over time through consistent daily capture of photos, measurements, and nutrition data.

This is not:
	•	A calorie tracker
	•	A workout planner
	•	A fitness social network

This is:
	•	A visual truth engine
	•	A habit-forming accountability tool
	•	A progress visualization system

All decisions must reinforce:
	•	Consistency
	•	Comparability
	•	Emotional impact

⸻

2. Global App Structure

2.1 Primary Navigation

Bottom navigation bar contains 4 fixed tabs:
	1.	Today
	2.	History
	3.	Progress
	4.	Settings

Rules:
	•	Navigation tabs are always visible
	•	No modal navigation replaces the bottom bar (except camera full-screen)
	•	Each tab owns read/write responsibilities

⸻

3. Core Concepts (Shared Vocabulary)

3.1 Tracking Zone

A Tracking Zone is a configurable unit of daily accountability.

Examples:
	•	Face
	•	Body Front
	•	Body Side
	•	Body Back
	•	Measurements
	•	Macronutrients

Rules:
	•	Zones can be enabled/disabled in Settings
	•	Enabled zones define what “completing a day” means
	•	Each zone can produce one or more records per day

⸻

3.2 Daily Record (The Day)

A Day represents a calendar date with:
	•	Zero or more completed zones
	•	A completion percentage
	•	A final completed state (boolean)

Rules:
	•	Days are immutable once past editing cutoff (future phase)
	•	Today is always editable
	•	Past days are read-only (except photo reassignment logic)

⸻

3.3 Completion Logic

Completion is zone-based, not time-based.

Example:
	•	Enabled zones: Face + Body Front + Measurements
	•	Completed zones: Face + Body Front
	•	Completion = 66%

⸻

4. SETTINGS SCREEN — REQUIREMENTS

4.1 Purpose

Settings define:
	•	What the user commits to tracking
	•	What constitutes success each day

This screen controls the entire app behavior.

⸻

4.2 Tracking Zones Section

Title: Tracking Zones

Available zones:

Zone	Description
Face	Front-facing face & neck photo
Body Front	Full frontal body
Body Side	Side profile
Body Back	Rear view

UI Behavior:
	•	Each zone appears as a tile
	•	Emoji icon on left
	•	Label text
	•	Toggle switch on right

Rules:
	•	Toggle ON → zone becomes required daily
	•	Toggle OFF → zone ignored in completion logic
	•	Changes apply from today forward
	•	Past days remain unchanged

⸻

4.3 Additional Tracking Section

Measurements
Includes:
	•	Weight
	•	Waist
	•	Chest
	•	Hips
	•	Arms (Left / Right)
	•	Thighs (Left / Right)
	•	Neck

Rules:
	•	Measurements are optional per day
	•	If Measurements zone is enabled:
	•	At least one measurement must be logged to count as completed

Macronutrients
Includes:
	•	Calories
	•	Protein
	•	Carbs
	•	Fat (future extensibility)

Rules:
	•	Macronutrients count as one zone
	•	Partial logging does not count as completion

⸻

5. TODAY SCREEN — REQUIREMENTS

5.1 Purpose

The Today screen:
	•	Tells the user what is required today
	•	Shows progress toward completion
	•	Provides entry points to capture/log data

⸻

5.2 Header

Displays:
	•	Current date
	•	Current time (live or static per session)
	•	Motivational message

Example:

“Daily goal: 67% complete”

⸻

5.3 Today’s Zones List

For each enabled zone:
	•	Display zone name
	•	Show status:
	•	Not started
	•	In progress
	•	Completed
	•	Provide CTA:
	•	Camera for photo zones
	•	Bottom sheet for measurements/macros

⸻

5.4 Completion Feedback

When all zones are completed:
	•	Show “Day Completed” state
	•	Lock additional entries (future phase configurable)

⸻

6. CAMERA SCREEN — REQUIREMENTS

6.1 Camera Modes

Camera operates in explicit modes:
	•	Face
	•	Body Front
	•	Body Side
	•	Body Back

Each mode defines:
	•	Overlay silhouette
	•	Alignment rules
	•	Ghost image availability

⸻

6.2 Overlays

Silhouette Overlay
	•	Static outline for alignment
	•	Mode-specific

Guide Lines
	•	Optional
	•	Toggleable via UI switch

Ghost Overlay
	•	Shows previous day’s photo
	•	Opacity controlled via vertical scroll
	•	Disabled if no previous photo exists

⸻

6.3 Controls
	•	Cancel
	•	Capture
	•	Reset
	•	Overlay toggle
	•	Ghost opacity control

Rules:
	•	Photo is only saved after explicit confirmation
	•	Photo attaches to current day by default
	•	Reassignment to past days supported (existing behavior)

⸻

7. HISTORY SCREEN — REQUIREMENTS

7.1 Purpose

History answers:

“How consistent have I been?”

⸻

7.2 Behavior
	•	Displays calendar or list of days
	•	Each day shows:
	•	Completion status
	•	Number of zones completed
	•	Selecting a day opens read-only detail view

Missing features (explicitly excluded in Phase 0):
	•	Streaks
	•	Analytics
	•	Editing past days

⸻

8. PROGRESS SCREEN — REQUIREMENTS

8.1 Purpose

Progress answers:

“Am I actually changing?”

⸻

8.2 Views
	•	Side-by-side comparisons
	•	Day-by-day evolution
	•	Timeline playback

⸻

8.3 Timeline Mode
	•	Playable sequence of photos
	•	Fullscreen support
	•	Exportable video

Rules:
	•	Only includes days with valid photos
	•	Respects tracking zones enabled at capture time

⸻

9. DATA RESPONSIBILITIES PER SCREEN

Screen	Reads	Writes
Settings	Tracking configuration	Tracking configuration
Today	Day status, zones	Photo records, logs
Camera	Previous photos	New photo records
History	Day summaries	None
Progress	Photos, measurements	None


⸻

10. Explicit Non-Goals (Phase 0)

These are out of scope and must not be implemented:
	•	Authentication
	•	Cloud sync
	•	AI analysis
	•	Social sharing
	•	Subscriptions
	•	Notifications

⸻

11. Phase 0 Exit Criteria (IMPORTANT)

Phase 0 is considered complete when:

✅ Every screen has:
	•	Clear purpose
	•	Defined inputs
	•	Defined outputs

✅ Every feature:
	•	Has explicit rules
	•	Has known exclusions

✅ No UI or data ambiguity remains

⸻

What Happens Next

If you approve this Phase 0 spec:

➡️ Phase 1 begins: Domain Modeling
	•	Entities
	•	Value Objects
	•	Use Cases
	•	Zero Flutter

