---
name: notime:standup
description: Morning standup - show sprint context, today's cards, generate day plan, start timer on chosen card
allowedTools:
  - mcp__notime__complete_sprint
  - mcp__notime__create_card
  - mcp__notime__create_epic
  - mcp__notime__create_story
  - mcp__notime__current_sprint
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
  - mcp__notime__update_card_status
---

# Morning Standup

You are running a morning standup routine. Follow these steps in order:

1. Call `current_sprint` to get the sprint number and circuit phase. Display it as a header.

2. Call `get_sprint_cards` for the current sprint. Filter the results to show only cards relevant to today (check the day name against any day-based assignments). Present the cards in a clean list showing name, status, and hours assigned.

3. Call `generate_day_plan` with today's date (YYYY-MM-DD format) to create the journal day plan.

4. Ask the user which card they want to start working on. Present the cards as numbered options.

5. Once they choose, call `update_card_status` to set it to "In Progress", then call `start_timer` on that card. Confirm the timer is running.

Keep output concise. No preamble - get straight to the sprint info.
