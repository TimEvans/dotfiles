---
description: Reset conversation context to branch plan state with intelligent MCP-powered analysis
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, mcp__ccsession__should_reset_context, mcp__ccsession__get_session_history, mcp__ccsession__check_context_budget, mcp__ccsession__sync_planning_doc, mcp__ccsession__get_session_state
---

You are helping the user compress an expensive conversation context down to its essential state by synchronizing all progress into the branch plan documents using intelligent MCP tools, then preparing for a context reset.

## Command Modes

- `/reset-context` or `/reset-context SAFE` - Full analysis + update all files (default)
- `/reset-context STATUS` - Check-only mode (no file updates)

## Workflow

### Phase 0: Parse Mode

1. **Determine execution mode:**
   - Check {args} parameter
   - If {args} contains "STATUS" (case-insensitive): `mode = "status_only"`
   - Otherwise: `mode = "safe"` (default)
   - Store mode for use in later phases

### Phase 1: Intelligent Analysis with MCP Tools

1. **Get intelligent reset recommendation (MCP):**
   - Try to call: `mcp__ccsession__should_reset_context`
   - If MCP unavailable:
     - Set `mcp_available = false`
     - Display: "⚠️  MCP tools unavailable. Falling back to manual mode."
     - Skip to Phase 1 Step 4 (manual analysis)
   - If successful:
     - Set `mcp_available = true`
     - Extract: `should_reset`, `confidence`, `reasoning`, `safe_to_reset`, `blockers`, `suggested_summary`

2. **Display formatted recommendation:**
   ```
   ╔══════════════════════════════════════════════════════╗
   ║        CONTEXT RESET RECOMMENDATION                  ║
   ╚══════════════════════════════════════════════════════╝

   Recommendation: {should_reset ? "RESET RECOMMENDED" : "CONTINUE WORKING"}
   Confidence: {confidence}

   Reasoning:
   {for each reason in reasoning:}
   • {reason}

   {if blockers.length > 0:}
   ⚠️  Blockers preventing safe reset:
   {for each blocker in blockers:}
   • {blocker}
   {endif}

   {if should_reset && safe_to_reset:}
   ✓ Safe to reset
     - No uncommitted changes
     - All in-progress todos completed
     - Clean git state
   {endif}

   Suggested session summary:
   "{suggested_summary}"
   ```

3. **Get session history and context budget (MCP):**
   - If `mcp_available == true`:
     - Call: `mcp__ccsession__get_session_history`
     - Extract: `completed_todos`, `files_modified`, `tool_calls`, `git_commits`
     - Call: `mcp__ccsession__check_context_budget`
     - Extract: `tokens_used`, `tokens_remaining`, `percentage_used`, `status`
     - Display:
     ```

     Session Summary:
     • Completed todos: {completed_todos.length}
     • Files modified: {files_modified.created.length + files_modified.edited.length}
     • Git commits: {git_commits.length}

     Context Status:
     • Usage: {tokens_used:,}/{context_limit:,} tokens ({percentage_used}%)
     • Status: {status}
     {if status == "critical":}
     • ⚠️  CRITICAL: Context >80% full - reset strongly recommended
     {elif status == "low":}
     • ⚠️  LOW: Context 60-80% full - consider resetting soon
     {else:}
     • ✓ SUFFICIENT: Context <60% full
     {endif}
     ```

4. **Manual analysis fallback (if MCP unavailable):**
   - Review the conversation history manually:
     - Identify completed tasks
     - Identify in-progress work
     - Identify key decisions
     - Identify files modified
     - Identify blockers/issues
     - Identify next steps
   - Display brief summary of findings

### Phase 1.5: Exit Early if STATUS Mode

1. **Check mode:**
   - If `mode == "status_only"`:
     - Display:
     ```

     ═══════════════════════════════════════════════════════

     STATUS CHECK COMPLETE

     This was a status-only check. No files have been updated.

     To update files and prepare for reset, run:
     /reset-context SAFE

     Or simply:
     /reset-context
     ═══════════════════════════════════════════════════════
     ```
     - Exit workflow (do not proceed to Phase 2)

### Phase 2: Update Plan Document with MCP

**Note:** Only execute this phase if `mode == "safe"`

1. **Get current branch and construct paths:**
   - Run: `git branch --show-current`
   - Store branch name in variable
   - Construct paths:
     - Plan: `.context/dev/{branch-name}/{branch-name}-detailed-plan.md`
     - Session history: `.context/dev/{branch-name}/{branch-name}-session-history.md`

2. **Verify plan file exists:**
   - Use Bash to check: `test -f "{plan-path}" && echo "exists" || echo "missing"`
   - If missing:
     - Display: "⚠️  No plan found for branch '{branch-name}' at: {plan-path}

     Options:
     - Run `/new-branch` to create the context workspace
     - Or switch to a branch that has a plan"
     - Exit workflow

3. **Update plan using MCP tools (if available):**

   **Step 2.3a: Mark completed tasks (MCP):**
   - If `mcp_available == true`:
     - Extract task names from `completed_todos` (from Phase 1)
     - Call: `mcp__ccsession__sync_planning_doc` with params:
       ```
       {
         mode: "mark_tasks_complete",
         completed_tasks: [array of completed task names]
       }
       ```
     - If successful:
       - Display: "✓ Marked {N} tasks as complete in Implementation Plan"
     - If fails:
       - Display: "⚠️  Could not auto-mark tasks. You may need to manually update checkboxes."

   **Step 2.3b: Update Active Work section (MCP):**
   - If `mcp_available == true`:
     - Call: `mcp__ccsession__get_session_state` to get current state
     - Extract: `todos.in_progress`, `todos.pending`
     - Build decisions array from `git_commits` (extract from commit messages)
     - Call: `mcp__ccsession__sync_planning_doc` with params:
       ```
       {
         mode: "update_active_work",
         in_progress: {current in-progress work description},
         next_steps: [array of pending todo descriptions],
         decisions: [array of key decisions],
         blockers: [array of blockers if any]
       }
       ```
     - If successful:
       - Display: "✓ Updated Active Work section with current session state"
     - If fails:
       - Display: "⚠️  Could not auto-update Active Work. Manual update may be needed."

   **Step 2.3c: Append to Progress Log (MCP):**
   - If `mcp_available == true`:
     - Call: `mcp__ccsession__sync_planning_doc` with params:
       ```
       {
         mode: "append_progress_log",
         completed_tasks: [array from completed_todos],
         decisions: [array from git commits or analysis],
         blockers: [array if any]
       }
       ```
     - If successful:
       - Display: "✓ Added session entry to Progress Log"
     - If fails:
       - Display: "⚠️  Could not append to Progress Log. Manual update may be needed."

4. **Manual plan update fallback (if MCP unavailable):**
   - If `mcp_available == false`:
     - Read current plan using Read tool
     - Parse structure to find Implementation Plan, Active Work, Progress Log sections
     - Use Edit tool to:
       - Change `- [ ]` to `- [x]` for completed tasks
       - Replace Active Work section with current state
       - Add new entry to Progress Log
     - Display: "✓ Plan synchronized manually (MCP unavailable)"

### Phase 3: Update Session History with Rolling Window

**Note:** Only execute this phase if `mode == "safe"`

1. **Read current session history file:**
   - Path: `.context/dev/{branch-name}/{branch-name}-session-history.md`
   - Use Read tool to read the file
   - If file doesn't exist:
     - Display: "⚠️  Session history file not found. Creating new one."
     - Initialize empty history

2. **Parse existing sessions:**
   - Search for all `## Session N` headers using regex
   - Count total sessions
   - Store session count

3. **Implement rolling window (keep last 5):**
   - If session count >= 5:
     - Find `## Session 1` section (oldest)
     - Remove entire `## Session 1` section (from header to next `---` or `## Session 2`)
     - Renumber remaining sessions: Session 2→1, Session 3→2, Session 4→3, Session 5→4
   - Determine new session number: `new_number = min(session_count + 1, 5)`

4. **Build new session entry:**
   - Get session info from `get_session_state` MCP call (if available):
     - Session start time
     - Session duration
   - Format entry:
   ```markdown
   ## Session {new_number} (Most Recent) - {start_time} to {current_time}
   **Duration:** {duration_hours}h {duration_minutes}m | **Commits:** {git_commits.length} | **Status:** {git_state}

   ### Completed
   {if completed_todos.length > 0:}
   {for each todo in completed_todos:}
   - {todo}
   {else:}
   - (no todos completed this session)
   {endif}

   ### Key Decisions
   {if decisions.length > 0:}
   {for each decision in decisions:}
   - {decision}
   {else:}
   - (no major decisions recorded)
   {endif}

   ### Files Modified
   {if files_modified total > 0:}
   - Created: {join files_modified.created with ", "}
   - Edited: {join files_modified.edited with ", "}
   {if files_modified.deleted.length > 0:}
   - Deleted: {join files_modified.deleted with ", "}
   {endif}
   {else:}
   - (no files modified)
   {endif}

   ### Git Commits
   {if git_commits.length > 0:}
   {for each commit in git_commits:}
   - `{commit.sha}` {commit.message}
   {else:}
   - (no commits)
   {endif}

   {if blockers.length > 0:}
   ### Blockers
   {for each blocker in blockers:}
   - {blocker}
   {endif}

   ---
   ```

5. **Write updated session history:**
   - Insert new session entry at the top (after title)
   - Write back to file using Edit tool
   - Display: "✓ Session history updated (tracking last {session_count} sessions)"

### Phase 4: Display Reset Instructions

1. **Show completion summary:**
   ```
   ╔══════════════════════════════════════════════════════╗
   ║        CONTEXT FILES UPDATED                         ║
   ╚══════════════════════════════════════════════════════╝

   All branch context files have been synchronized with your current session:

   ✓ {branch-name}-detailed-plan.md
     - Tasks marked complete
     - Active Work updated
     - Progress Log entry added

   ✓ {branch-name}-session-history.md
     - New session entry added
     - Rolling window maintained (last 5 sessions)

   Your work is fully preserved in these files.
   ```

2. **Display reset protocol:**
   ```

   To reset context and reload:
   ═══════════════════════════════════════════════════════

   Step 1: Run /clear
   Step 2: Run /load-context

   This will reload all three context files:
   • Agent context (expertise and protocol)
   • Detailed plan (tasks and progress)
   • Session history (continuity from previous sessions)

   ───────────────────────────────────────────────────────

   Context optimization:
   • Before reset: ~{current_tokens:,} tokens ({percentage}%)
   • After reset: ~5,000-10,000 tokens
   • Savings: ~{savings:,} tokens

   {if should_reset:}
   ✓ Reset recommended - {confidence} confidence
   {else:}
   ℹ️  Reset not critical, but you can reset anytime for optimal performance
   {endif}
   ```

3. **Provide next steps:**
   ```

   After reload:
   • Check "Active Work" section for current tasks
   • Review "Next Immediate Steps" for what to work on
   • See "Session History" for context from previous sessions
   • Use `/reset-context STATUS` anytime to check status again
   ```

## Error Handling

### MCP Tool Failures
- **All MCP tools fail:**
  - Set `mcp_available = false`
  - Continue with manual mode
  - Display: "⚠️  MCP tools unavailable. Using manual analysis and updates."

- **Individual MCP tool fails:**
  - Log error silently
  - Skip that specific MCP operation
  - Continue with workflow
  - Display: "⚠️  Some MCP features unavailable. Continuing with partial automation."

### File Errors
- **Plan file not found:**
  - Display error with path
  - Suggest `/new-branch` or manual creation
  - Exit workflow

- **Session history not found:**
  - Create new session history file
  - Initialize with current session as Session 1
  - Continue workflow

- **File write fails:**
  - Display error
  - Suggest manual file updates
  - Continue with remaining operations

### Git Errors
- **Not on a branch:**
  - Display: "⚠️  Not on a feature branch. Please checkout a branch first."
  - Exit workflow

- **Git command fails:**
  - Skip git-dependent features
  - Continue with file operations
  - Display: "⚠️  Git unavailable. Skipping git-based features."

## Additional Notes

- Default mode is SAFE (full update) for convenience
- STATUS mode is for checking recommendations without making changes
- MCP integration is optional - command works without it (manual mode)
- Session history rolling window keeps last 5 sessions automatically
- All session data comes from MCP `get_session_history` tool for accuracy
- Manual mode fallback ensures command always works
- This command does NOT automatically run `/clear` - user must do that manually
- After `/clear`, user should run `/load-context` to restore context
