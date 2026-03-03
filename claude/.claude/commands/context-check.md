---
description: Quick check of context status and reset recommendations without making changes
allowed-tools: mcp__ccsession__check_context_budget, mcp__ccsession__should_reset_context
---

You are providing a quick, read-only status check of the current context budget and intelligent reset recommendations.

## Workflow

### Phase 1: Check Context Budget

1. **Call MCP tool:**
   - Try to call: `mcp__ccsession__check_context_budget`
   - If MCP unavailable:
     - Display: "⚠️  MCP tools unavailable. Context check requires the claude-session-mcp server."
     - Exit workflow
   - If successful:
     - Extract: `tokens_used`, `tokens_remaining`, `percentage_used`, `context_limit`, `status`

2. **Store budget info for display**

### Phase 2: Get Reset Recommendation

1. **Call MCP tool:**
   - Try to call: `mcp__ccsession__should_reset_context`
   - If fails:
     - Skip recommendations
     - Continue with budget info only
   - If successful:
     - Extract: `should_reset`, `confidence`, `reasoning`, `safe_to_reset`, `blockers`, `suggested_summary`

### Phase 3: Display Formatted Report

1. **Show comprehensive status:**

```
╔══════════════════════════════════════════════════════╗
║            CONTEXT STATUS CHECK                      ║
╚══════════════════════════════════════════════════════╝

CONTEXT USAGE:
• Tokens used: {tokens_used:,} / {context_limit:,}
• Percentage: {percentage_used}%
• Remaining: {tokens_remaining:,} tokens
• Status: {status}

{if status == "critical":}
⚠️  CRITICAL: Context >80% full
    - Reset strongly recommended
    - May trigger automatic compaction soon
{elif status == "low":}
⚠️  LOW: Context 60-80% full
    - Consider resetting soon
    - Monitor usage closely
{else:}
✓ SUFFICIENT: Context <60% full
  - Plenty of room to continue working
{endif}

═══════════════════════════════════════════════════════

RESET RECOMMENDATION:
• Recommendation: {should_reset ? "RESET RECOMMENDED" : "CONTINUE WORKING"}
• Confidence: {confidence}
• Safe to reset: {safe_to_reset ? "Yes" : "No" + " (blockers below)"}

Reasoning:
{for each reason in reasoning:}
• {reason}

{if blockers.length > 0:}
⚠️  Blockers preventing safe reset:
{for each blocker in blockers:}
• {blocker}
{endif}

{if should_reset:}
Suggested session summary:
"{suggested_summary}"
{endif}

═══════════════════════════════════════════════════════

NEXT STEPS:
{if should_reset && safe_to_reset:}
✓ Ready to reset:
  1. Run: /reset-context
  2. Run: /clear
  3. Run: /load-context

{elif should_reset && !safe_to_reset:}
⚠️  Address blockers first:
  {if blockers includes "uncommitted":}
  • Commit or stash uncommitted changes
  {endif}
  {if blockers includes "todos":}
  • Complete or cancel in-progress todos
  {endif}
  Then run: /reset-context

{else:}
✓ Continue working:
  • Context is healthy
  • Reset not needed at this time
  • Check again later if context grows

{endif}
```

2. **Provide context command reference:**
```

CONTEXT MANAGEMENT COMMANDS:
• /context-check        - Run this check again
• /reset-context STATUS - Check status (same as this)
• /reset-context        - Update files and prepare for reset
• /load-context         - Reload context after /clear

═══════════════════════════════════════════════════════
```

## Error Handling

### MCP Tools Unavailable
- **check_context_budget fails:**
  - Display: "⚠️  MCP tools unavailable. Context check requires the claude-session-mcp server to be running."
  - Suggest: "Verify MCP server is configured in ~/.claude/mcp.json"
  - Exit workflow

### Partial MCP Availability
- **Budget check succeeds, recommendation fails:**
  - Display budget information only
  - Show message: "ℹ️  Reset recommendations unavailable. Showing context budget only."

## Additional Notes

- This command is read-only - it makes no changes
- Use this for quick status checks without running full `/reset-context`
- Equivalent to running `/reset-context STATUS`
- Faster than full reset-context since it doesn't analyze session history
- Great for checking "should I reset?" during long work sessions
- All data comes from MCP tools for accuracy
- No git operations required
