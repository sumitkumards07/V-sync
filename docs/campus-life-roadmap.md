# Campus Life Feature Roadmap

This roadmap turns V-Sync into a daily-use campus companion, not just an academic portal. The focus is on high-frequency utilities first, followed by community features that require new backend infrastructure.

## 1. Live Mess / Cafeteria Menu

- **Primary placement:** Home dashboard card below `Up Next`.
- **Secondary placement:** Dedicated page reachable from quick access.
- **UI direction:** Auto-switch the visible meal by time of day, plus a segmented meal switcher on the full page.
- **Interaction detail:** Add lightweight community reactions for the main dish.
- **Backend approach:** Use a managed backend such as Supabase or Firebase for weekly menu entries.
- **Operations note:** Create a lightweight admin-only entry flow for manually posting the menu.
- **Performance note:** Cache the full week locally for instant offline access.

## 2. Exam Seating Locator

- **Primary placement:** A conditional home widget that appears only close to exam time.
- **UI direction:** Use a high-priority emergency glass card with strong room and seat emphasis.
- **Interaction detail:** Show a compact countdown like `Starts in 45 mins`.
- **Backend approach:** Pull from the existing academic exam data when possible.
- **Fallback data strategy:** If seating is released only as PDF, parse it server-side and map registration numbers to room and seat values.
- **Trigger rule:** Render the widget only on the exam day or within the planned pre-exam window.

## Suggested Build Order

1. Build `Exam Seating Locator` first because it fits the current academic-data foundation.
2. Build `Live Mess Menu` second because it will increase daily usage immediately.
