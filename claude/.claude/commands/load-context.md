---
description: Load branch context files after /clear with intelligent todo detection
allowed-tools: Bash, Read, mcp__ccsession__check_context_budget, mcp__ccsession__get_session_state
---

You are helping the user load their branch context files after running `/clear`, with intelligent detection of existing todos to avoid duplicates.

## Workflow

### Phase 1: Detect Current Branch

1. **Get current branch:**
   - Run: `git branch --show-current`
   - Store branch name in variable
   - If command fails or returns empty:
     - Display: "⚠️  Not on a git branch. Please checkout a feature branch first."
     - Exit workflow

### Phase 2: Verify Context Files Exist

1. **Construct file paths:**
   - Agent context: `.context/dev/{branch-name}/{branch-name}-agent.md`
   - Detailed plan: `.context/dev/{branch-name}/{branch-name}-detailed-plan.md`
   - Session history: `.context/dev/{branch-name}/{branch-name}-session-history.md`

2. **Check if files exist:**
   - Use Bash to check each file: `test -f "{file-path}" && echo "exists" || echo "missing"`
   - Track which files are missing

3. **Handle missing files:**
   - If ALL three files are missing:
     - Display: "⚠️  No context files found for branch '{branch-name}'.

     This branch doesn't have a context workspace yet.

     Options:
     - Run `/new-branch {branch-name}` to create the context workspace
     - Or manually create the files in: .context/dev/{branch-name}/"
     - Exit workflow

   - If SOME files are missing:
     - Display: "⚠️  Some context files are missing for branch '{branch-name}':

     {List missing files}

     Expected files:
     - {branch-name}-agent.md (agent context)
     - {branch-name}-detailed-plan.md (development plan)
     - {branch-name}-session-history.md (session history)

     Please create the missing files or run `/new-branch` to recreate the workspace."
     - Exit workflow

### Phase 3: Check Existing Todos (MCP)

1. **Call MCP tool to get session state:**
   - Try to call: `mcp__ccsession__get_session_state`
   - If MCP unavailable:
     - Skip this phase
     - Display: "ℹ️  MCP tools unavailable. Skipping todo check."
     - Continue to Phase 4

2. **Analyze todo state:**
   - Extract `todos.in_progress` and `todos.pending` from response
   - Count total existing todos: `len(in_progress) + len(pending)`

3. **Display todo warning if needed:**
   - If total > 0:
     - Display:
     ```
     ⚠️  Found {total} existing todos (persist across /clear):

     In Progress ({count}):
     {for each todo in in_progress:}
     • {todo.content}

     Pending ({count}):
     {for each todo in pending:}
     • {todo.content}

     These todos survived /clear and are still active.
     I'll avoid creating duplicates.
     ```
   - If total == 0:
     - Display: "ℹ️  No existing todos detected. Starting fresh."

### Phase 4: Load Context Files

1. **Display loading instructions:**
   - Show clear, formatted instructions:

   ```
   Loading context for branch: {branch-name}
   ═══════════════════════════════════════════════════════

   I'm loading these files in the correct order:

   @.context/dev/{branch-name}/{branch-name}-agent.md
   @.context/dev/{branch-name}/{branch-name}-detailed-plan.md
   @.context/dev/{branch-name}/{branch-name}-session-history.md

   ───────────────────────────────────────────────────────

   What's being loaded:
   • Agent Context - Expertise framing and working protocol
   • Detailed Plan - Tasks, progress, and implementation details
   • Session History - Last 5 sessions for continuity
   ```

2. **Note about structure:**
   - Add explanation:
   ```
   These three files provide complete branch context:
   - Agent context guides HOW to work on this branch
   - Detailed plan shows WHAT to work on
   - Session history provides continuity from previous sessions
   ```

### Phase 5: Verify Context Budget (MCP)

1. **Call MCP tool to check context:**
   - Try to call: `mcp__ccsession__check_context_budget`
   - If MCP unavailable:
     - Skip this phase
     - Display: "✓ Context loaded successfully"
     - Exit workflow

2. **Display context status:**
   - Extract: `tokens_used`, `percentage_used`, `status` from response
   - Format with thousands separators for readability
   - Display:
   ```
   ✓ Context loaded successfully

   Context Status:
   • {tokens_used:,} tokens ({percentage_used}%)
   • Status: {status}
   {if status == "critical":}

   ⚠️  Context usage is critical (>80%)
   Consider running focused work or /reset-context soon.
   {elif status == "low":}

   ⚠️  Context usage is low (60-80%)
   Monitor usage and reset if needed.
   {else:}

   ✓ Sufficient context available
   {endif}
   ```

3. **Provide next steps:**
   - Display:
   ```

   Next steps:
   1. Review "Active Work" section in the plan for current tasks
   2. Check "Next Immediate Steps" for what to work on
   3. Use `/reset-context STATUS` anytime to check if reset recommended

   Happy coding! 🚀
   ```

## Error Handling

### Git Errors
- **Not in git repo:**
  - Display: "⚠️  Not a git repository. This command requires a git-managed project."
  - Suggest: "Run `git init` to initialize a repository or navigate to a git project."
  - Exit workflow

- **Detached HEAD:**
  - Display: "⚠️  You're in detached HEAD state (not on a branch)."
  - Suggest: "Checkout a feature branch with: `git checkout {branch-name}`"
  - Exit workflow

### MCP Tool Errors
- **MCP server not available:**
  - Continue workflow with degraded functionality
  - Skip MCP-dependent phases
  - Display informational message (not error)

- **MCP tool returns error:**
  - Log error silently
  - Continue workflow
  - Display: "ℹ️  Some features unavailable (MCP error). Context files loaded successfully."

### File Read Errors
- **Permission denied:**
  - Display: "⚠️  Permission denied reading context files."
  - Suggest: "Check file permissions for: .context/dev/{branch-name}/"

- **File corruption:**
  - Display: "⚠️  Error reading {filename}. File may be corrupted."
  - Suggest: "Restore from git history or recreate with /new-branch"

## Additional Notes

- This command is designed to be run immediately after `/clear`
- It replaces the manual process of @ referencing three files
- MCP integration is optional - command works without it (degraded functionality)
- The three-file structure separates concerns:
  - Agent context (expertise) - rarely changes
  - Detailed plan (tasks) - frequently updated
  - Session history (continuity) - grows over time
- Todos persist across `/clear` because they're stored in `~/.claude/todos/{session_id}.json`
- Session ID doesn't change when running `/clear`, so todos remain accessible
