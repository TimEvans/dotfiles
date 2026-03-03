---
name: notime:wrap-up
description: End of day wrap-up - stop timer, show progress, sprint report if last day
allowedTools:
  - mcp__notime__stop_timer
  - mcp__notime__get_sprint_cards
  - mcp__notime__sprint_report
  - mcp__notime__current_sprint
---

# End of Day Wrap-Up

You are running an end-of-day wrap-up routine. Follow these steps in order:

1. Call `stop_timer` to stop any running timer. Report what was stopped and how long it ran.

2. Call `get_sprint_cards` to get all cards for the current sprint. Summarise:
   - Cards completed today
   - Cards still in progress
   - Cards remaining (backlog)
   - Total hours tracked today vs hours assigned

3. Call `current_sprint` to check the sprint dates. If today is the last day of the sprint (Friday of sprint week), call `sprint_report` and present the velocity report with completion percentage and category breakdown.

4. Present a concise summary: hours tracked, cards completed, what's left for tomorrow (or next sprint if it's the last day).

Keep it brief. The user is wrapping up, not starting a planning session.
