# 📄 SQLite Database Schema Specification

This document defines the schema for the application's persistence layer. All dates are stored as `TEXT` in `YYYY-MM-DD` format to ensure strict "One Record Per Day" constraints using SQLite's uniqueness rules.

---

## 1. Table: `photos`
Stores file paths for progress photos.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique record ID |
| `date` | TEXT | NOT NULL | Format: `YYYY-MM-DD`. The logical day of the photo. |
| `zone_type` | TEXT | NOT NULL | Enum: `face`, `bodyFront`, `bodySide`, `bodyBack` |
| `file_path` | TEXT | NOT NULL | Local path in app documents directory |
| `captured_at` | INTEGER | NOT NULL | Unix timestamp (milliseconds) |

### Constraints & Indexes
- **Uniqueness**: `UNIQUE(date, zone_type)`
  - *Rule*: Replacing a photo for the same day and zone will trigger an `INSERT OR REPLACE` to avoid duplication.
- **Index**: `idx_photos_date` on `date` (ASC/DESC)
- **Index**: `idx_photos_zone` on `zone_type`

---

## 2. Table: `macros`
Stores daily macronutrient intake.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `date` | TEXT | PRIMARY KEY | Format: `YYYY-MM-DD`. One record per day. |
| `calories` | REAL | DEFAULT 0 | Total energy intake (kcal) |
| `protein` | REAL | DEFAULT 0 | Grams of protein |
| `carbs` | REAL | DEFAULT 0 | Grams of carbohydrates |
| `fat` | REAL | DEFAULT 0 | Grams of fat |
| `updated_at` | INTEGER | NOT NULL | Unix timestamp of last update |

---

## 3. Table: `measurements`
Stores daily body measurements.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `date` | TEXT | PRIMARY KEY | Format: `YYYY-MM-DD`. One record per day. |
| `weight` | REAL | DEFAULT 0 | Weight |
| `waist` | REAL | DEFAULT 0 | Waist circumference |
| `chest` | REAL | DEFAULT 0 | Chest circumference |
| `hips` | REAL | DEFAULT 0 | Hips circumference |
| `neck` | REAL | DEFAULT 0 | Neck circumference |
| `arm_right` | REAL | DEFAULT 0 | Right arm circumference |
| `arm_left` | REAL | DEFAULT 0 | Left arm circumference |
| `thigh_right` | REAL | DEFAULT 0 | Right thigh circumference |
| `thigh_left` | REAL | DEFAULT 0 | Left thigh circumference |
| `updated_at` | INTEGER | NOT NULL | Unix timestamp of last update |

---

## 4. Implementation Rules

### Atomic Operations
- All writes to SQLite must use `TRANSACTION` blocks.
- Photo replacement must delete the physical file from the disk before or after the atomic DB update to prevent orphaned assets.

### Search Performance
- Queries for the **Progress** screen (e.g., "Latest 20 photos for Body Front") must use the `idx_photos_date` and `idx_photos_zone` to avoid full table scans.
- The **History** view will query all three tables by `date` range.

### Performance Scaling
- The database is designed to handle up to **10,000+ photographic references** and **lifetime daily logs** without noticeable delay on modern iOS/Android hardware.
- UI layer remains bound to the **In-Memory Repository**, which is hydrated from these tables at boot.
