---
allowed-tools: Bash(git diff:*), Bash(git log:*), mcp__ccsession__sync_planning_doc
description: Perform a comprehensive code review of recent changes with auto-sync to plan
---

## Context

- Current git status: !`git status`
- Recent changes: !`git diff HEAD~1`
- Recent commits: !`git log --oneline -5`
- Current branch: !`git branch --show-current`

## Your task

Perform a comprehensive code review focusing on:

1. **Code Quality**: Check for readability, maintainability, and adherence to best practices
2. **Security**: Look for potential vulnerabilities or security issues
3. **Performance**: Identify potential performance bottlenecks
4. **Testing**: Assess test coverage and quality
5. **Documentation**: Check if code is properly documented

Provide specific, actionable feedback with line-by-line comments where appropriate.

## After Review (Auto-Sync)

After completing the code review, auto-sync to the plan document:

1. **Attempt to sync to plan (MCP):**
   - Try to call: `mcp__ccsession__sync_planning_doc` with params:
     ```
     {
       mode: "append_progress_log",
       completed_tasks: ["Code review completed"],
       decisions: [extract any key findings or recommendations if notable],
       blockers: []
     }
     ```

2. **Display feedback:**
   - If MCP available and succeeds:
     - Display: "✓ Review complete · Plan synced"
   - If MCP unavailable or fails:
     - Display: "✓ Review complete"
     - Fail silently (don't show MCP errors to user)

**Auto-Sync Behavior:**
- Non-blocking: Review succeeds even if sync fails
- Subtle: Single-line feedback when sync works
- Silent failure: No error messages if MCP unavailable
- Optional details: Only include key decisions if review found significant issues or recommendations
