---
name: notime-standup
description: Use when the user wants to run a morning standup, start their work day, or pick up a card to work on
allowedTools:
  - mcp__notime__complete_sprint
  - mcp__notime__create_card
  - mcp__notime__create_epic
  - mcp__notime__create_story
  - mcp__notime__current_sprint
  - mcp__notime__delete_time_entry
  - mcp__notime__done
  - mcp__notime__generate_day_plan
  - mcp__notime__generate_sprint
  - mcp__notime__generate_week_plan
  - mcp__notime__get_sprint_cards
  - mcp__notime__get_todays_timesheet
  - mcp__notime__list_categories
  - mcp__notime__list_epics
  - mcp__notime__list_stories
  - mcp__notime__log_time
  - mcp__notime__plan_sprint
  - mcp__notime__sprint_info
  - mcp__notime__sprint_report
  - mcp__notime__start_timer
  - mcp__notime__stop_timer
  - mcp__notime__sync_cache
  - mcp__notime__timer_status
  - mcp__notime__update_card_status
---

# Morning Standup

Run a morning standup routine. Follow these steps in order. Keep output concise - no preamble.

## 1. Sprint Context

Call `current_sprint` to get the sprint number and circuit phase. Display as a header.

## 2. Sprint Cards + Capacity Check

Call `get_sprint_cards` for the current sprint. Present cards relevant to today (check day-based assignments) showing name, status, and hours assigned.

**Capacity check:** If total assigned hours for the sprint exceeds 10h, flag it: "Sprint has Xh assigned - realistic weekly capacity is 8-10h. Consider deferring cards."

## 3. Pre-standup Work

Before starting any timer, ask: **"Have you done any work this morning before this standup?"**

If yes:
- Log each block with `log_time` (supports `start_time`/`end_time` for ranges)
- If they're continuing the same card, use `start_timer` with the `since` param to backdate

## 4. Day Plan

Call `generate_day_plan` with today's date (YYYY-MM-DD format).

## 5. Start Working

Ask which card to work on. Present cards as numbered options.

Once chosen:
- Call `update_card_status` to set it to "In Progress"
- Call `start_timer` on that card (use `since` param if backdating needed)
- Confirm the timer is running

## Rules

### After Creating Cards

**Always** call `get_sprint_cards` to refresh the cache before any `log_time`, `start_timer`, or `update_card_status` that references newly created cards. Fuzzy matching uses the cache - stale cache will match wrong cards.

### Fixing Mistakes

Use `delete_time_entry` to remove entries logged to the wrong card, then re-log correctly.

### Finishing a Card

Use `done` to stop the timer AND mark the card Completed in one call.

## Quick Reference

| Status values | `Backlog`, `To Do`, `In Progress`, `Completed` |
|---|---|
| Log time range | `log_time(card, hours, start_time="9am", end_time="10:30am")` |
| Backdate timer | `start_timer(card, since="9am")` |
| Delete entry | `delete_time_entry(card, date="YYYY-MM-DD")` |
| Stop + complete | `done()` |
| Check timer | `timer_status()` |
| Sync cache | `sync_cache(full=True)` |
