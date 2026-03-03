---
name: notime:sprint-plan
description: Interactive sprint planning - retro on previous sprint, generate new sprint, review capacity, refine cards
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

# Sprint Planning

You are facilitating a sprint planning session. This is an interactive session - guide the user through each phase, pausing for discussion.

## Phase 1: Retro

1. Call `current_sprint` to get the current sprint number.
2. Call `sprint_report` for the **previous** sprint (current - 1). Present:
   - Completion percentage
   - Hours completed vs assigned
   - Category breakdown
3. Call `complete_sprint` on the previous sprint to finalise it.
4. Facilitate a brief retro: ask what went well and what could improve. Keep it to 2-3 minutes.

## Phase 2: Generate

5. Call `generate_sprint` for the **current** sprint number. This creates recurring cards and carries over incomplete tasks from last sprint.
6. Report what was generated: recurring cards created, cards carried over.

## Phase 3: Review Capacity

7. Call `plan_sprint` for the current sprint. Present:
   - Total hours assigned
   - Cards by status
   - Card names
8. Compare against previous sprint's actual completed hours (from the retro report).
9. **Enforce constraints:**
   - Warn if total hours exceed 80% of previous sprint's completed hours (leave buffer for unplanned work)
   - Flag any cards without time estimates
   - Question any cards that appear to have been carried over from 2+ sprints ago

## Phase 4: Refine

10. Enter a refinement loop. The user can:
    - Add new cards with `create_card` (ask for name, category, hours estimate)
    - Remove cards by setting status to "Removed" with `update_card_status`
    - Adjust priorities
11. After each change, re-check total hours against the capacity constraint.
12. Push back if the user is over-committing. Suggest deferring lower-priority items.

## Phase 5: Commit

13. Call `generate_week_plan` for the sprint to create the journal week plan.
14. Present the final sprint commitment: total cards, total hours, key focus areas by category.

Throughout: be direct about capacity concerns. The goal is a realistic sprint, not an aspirational one.
