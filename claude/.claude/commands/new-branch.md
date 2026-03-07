---
description: Create a new feature branch with automated planning, workspace setup, and specialized agent creation
allowed-tools: Bash, Read, Write, Glob, Grep, AskUserQuestion, TodoWrite
---

You are orchestrating a complete feature development workflow with git branch management, planning, and specialized agent creation.

## Command Arguments

Branch name provided: {args}

## Workflow Implementation

### Phase 1: Git Branch Setup

1. **Parse branch name:**
   - If args is empty, use AskUserQuestion to prompt: "What would you like to name this branch? (Use kebab-case, e.g., 'feat-user-authentication')"
   - Validate branch name format (no spaces, special characters; kebab-case recommended)
   - Store branch name in a variable for use throughout workflow

2. **Pre-flight checks:**
   - Run: `git status --porcelain`
   - If there are unstaged/uncommitted changes, use AskUserQuestion with options:
     - Question: "You have unstaged changes. How would you like to proceed?"
     - Header: "Unstaged changes"
     - Options:
       - "Commit now" (description: "Use /smart-commit to commit all changes first")
       - "Stash changes" (description: "Stash changes and proceed with branch creation")
       - "Cancel" (description: "Cancel the /new-branch operation")
   - Handle user selection:
     - If "Commit now": Ask user to run /smart-commit first, then exit
     - If "Stash changes": Run `git stash push -m "Auto-stash before creating branch {branch-name}"`, then proceed
     - If "Cancel": Exit workflow with message

3. **Create branch:**
   - Run: `git checkout -b {branch-name}`
   - Verify success by checking exit code
   - Report: "✓ Created and switched to branch: {branch-name}"

### Phase 2: Context Directory Setup

1. **Create branch workspace:**
   - Create directory structure: `.context/dev/{branch-name}/`
   - Use Bash: `mkdir -p ".context/dev/{branch-name}"`
   - Verify directory creation
   - Report: "✓ Branch workspace created: .context/dev/{branch-name}/"

### Phase 3: Feature Planning

1. **Gather branch focus:**
   - Use AskUserQuestion:
     - Question: "Do you have a markdown file with the feature details?"
     - Header: "Feature details"
     - Options:
       - "Provide file path" (description: "I'll provide the path to a markdown file")
       - "Describe now" (description: "I'll describe the feature in a text prompt")
   - If "Provide file path":
     - Use AskUserQuestion to get the path (free-form text)
     - Read the file using Read tool
     - Extract feature description, objectives, requirements
   - If "Describe now":
     - Use AskUserQuestion with free-form text:
       - "Please describe the feature/focus for this branch. Include:\n- Main objective\n- Key deliverables\n- Specific constraints or requirements"
     - Parse the response

2. **Generate agent context file:**
   - Analyze the feature description
   - Determine feature type (frontend/UI, backend/API, full-stack, data, etc.)
   - Create agent context document at: `.context/dev/{branch-name}/{branch-name}-agent.md`

   Agent context structure:
   ```markdown
   # {Branch Name} - Agent Context

   You are a {specialized} development expert focused on {branch objective}.

   ## Branch Objective
   {1-2 sentence summary of what this branch aims to accomplish}

   ## Expertise & Priorities

   {FOR FRONTEND/UI WORK:}
   **Frontend Development Expertise:**
   - Component reusability and accessibility (WCAG compliance)
   - Responsive design and user experience optimization
   - Integration with existing design system
   - Type safety with TypeScript
   - React best practices and modern patterns

   {FOR BACKEND/API WORK:}
   **Backend Development Expertise:**
   - RESTful API design and implementation
   - Data validation with Pydantic/Zod
   - Error handling and security best practices
   - Performance optimization and scalability
   - FastAPI/Express patterns and conventions

   {FOR DATA ENGINEERING WORK:}
   **Data Engineering Expertise:**
   - Schema enforcement and validation
   - Data lineage and type safety
   - Reliable ETL patterns and pipelines
   - Parquet-based persistence patterns
   - Data quality and integrity

   {FOR FULL-STACK WORK:}
   **Full-Stack Development Expertise:**
   - Balance frontend UX with backend performance
   - End-to-end type safety across the stack
   - Integration consistency and API contracts
   - Modern full-stack patterns

   ## Working Protocol

   1. **Context Loading:**
      - Use `/load-context` after `/clear` to restore branch context
      - This command loads all three context files and checks for existing todos

   2. **Todo Management:**
      - Check existing todos via `get_session_state` MCP tool before creating new ones
      - Todos persist across `/clear`, avoid duplicates

   3. **Progress Tracking:**
      - Update plan sections as work progresses
      - Mark tasks complete in Implementation Plan
      - Add significant milestones to Progress Log

   4. **Context Management:**
      - Use `should_reset_context` MCP tool to check if reset recommended
      - Run `/reset-context STATUS` to check context budget and recommendations
      - Run `/reset-context` (SAFE mode) to update all files before `/clear`

   ## MCP Tool Availability

   This branch has access to intelligent context management tools:

   - `check_context_budget` - Monitor context window usage and status
   - `get_session_state` - View current todos, git state, context files, session info
   - `get_session_history` - Review current session accomplishments
   - `sync_planning_doc` - Update plan document programmatically
   - `should_reset_context` - Get intelligent reset recommendations with reasoning

   ## Context Files

   - **Agent prompt:** This file (`{branch-name}-agent.md`)
   - **Plan:** `.context/dev/{branch-name}/{branch-name}-detailed-plan.md`
   - **History:** `.context/dev/{branch-name}/{branch-name}-session-history.md`

   ---
   *This file provides the expertise framing and working protocol for this branch. Load it at the start of each session along with the plan and history files.*
   ```

   - Write this file using the Write tool
   - Report: "✓ Agent context created: {branch-name}-agent.md"

3. **Generate session history file:**
   - Create session history document at: `.context/dev/{branch-name}/{branch-name}-session-history.md`

   Session history structure:
   ```markdown
   # {Branch Name} - Session History

   Tracks the last 5 sessions for continuity across context resets.

   ---

   ## Session 1 (Initial) - {current-timestamp}
   **Duration:** Setup | **Commits:** 0 | **Status:** Clean

   ### Completed
   - Branch created and workspace initialized
   - Planning documents generated
   - Ready to begin development

   ### Notes
   - Initial plan created with {N} implementation phases
   - Agent context configured for {feature-type} development
   - All context files ready for use

   ---
   ```

   - Write this file using the Write tool
   - Report: "✓ Session history initialized: {branch-name}-session-history.md"

4. **Generate detailed plan:**
   - Create comprehensive plan document at: `.context/dev/{branch-name}/{branch-name}-detailed-plan.md`
   - **Note:** This file NO LONGER contains the agentic header (moved to agent.md)

   Plan structure:
   ```markdown
   # {Branch Name} - Development Plan

   **Branch:** {branch-name}
   **Created:** {current-timestamp}
   **Status:** In Progress

   ## Feature Overview
   {User-provided or extracted feature description}

   ## Active Work (Current Session)
   **Last updated:** {current-timestamp}

   ### In Progress:
   - Branch setup and initial planning

   ### Next Immediate Steps:
   - Review implementation plan
   - Begin Phase 1 tasks

   ## Success Criteria
   - [ ] {Criterion 1 - generated based on feature description}
   - [ ] {Criterion 2}
   - [ ] {etc.}

   ## Implementation Plan

   ### Phase 1: {Phase Name}
   - [ ] {Task 1}
   - [ ] {Task 2}

   ### Phase 2: {Phase Name}
   - [ ] {Task 1}

   {Additional phases as needed based on feature scope}

   ## Technical Considerations
   {Auto-generated based on codebase analysis and feature type}
   - Relevant files to modify
   - Dependencies to consider
   - Integration points
   - Potential risks

   ## Testing Requirements
   - [ ] Unit tests for {specific components}
   - [ ] Integration tests for {specific workflows}
   - [ ] {Feature-specific test requirements}

   ## Pre-Merge Checklist
   - [ ] All implementation tasks completed
   - [ ] All tests passing
   - [ ] /code-review completed
   - [ ] /design-review completed (REQUIRED for frontend/UI changes)
   - [ ] Documentation updated
   - [ ] No unstaged changes

   ## Progress Log
   {This section will be updated throughout development via /reset-context}

   ---
   **Initial plan generated:** {timestamp}
   ```

   - Write this plan using the Write tool
   - Report: "✓ Detailed plan created: {branch-name}-detailed-plan.md"

### Phase 4: Specialized Agent Creation

1. **Analyze branch focus for agent specialization:**
   - Based on feature description and type, determine optimal agent configuration:
     - Frontend/UI work → Frontend expert with Playwright MCP tools
     - Backend/API work → Backend expert with pytest, API testing
     - Full-stack → General-purpose with broad toolset
     - Data engineering → Data processing with pandas, validation tools

2. **Create agent configuration:**
   - This is a **reference document** (not an invokable custom agent)
   - Provides guidelines for working on this branch
   - Store in: `.context/dev/{branch-name}/agent-config.md`
   - User references the plan document for context (which includes expertise prompt)

   Agent config structure:
   ```markdown
   # Branch Working Guidelines

   > **NOTE:** This is a reference document, not an invokable agent.
   > To activate the branch context and expertise, reference the plan document:
   > `@.context/dev/{branch-name}/{branch-name}-detailed-plan.md`

   **Specialization:** {Determined from branch focus}
   **Created:** {timestamp}
   **Status:** Active

   ## Context Awareness
   - Primary workspace: `.context/dev/{branch-name}/`
   - Plan document: `{branch-name}-detailed-plan.md` (reference this to load branch context)
   - All work artifacts must be stored in workspace directory

   ## Tools Access
   - Bash tools (always available for git, file operations, testing)
   {If frontend specialization:}
   - Playwright MCP for browser testing
   - Component testing frameworks
   - Accessibility validation tools
   {If backend specialization:}
   - pytest for unit/integration tests
   - API testing tools (requests, httpx)
   - Database tools

   ## Responsibilities
   - Implement tasks from detailed plan in priority order
   - Suggest plan updates as work progresses
   - Store all branch-specific files in workspace directory
   - Track progress in plan document with timestamps
   - Remind about pre-merge checklist before merge attempts
   - Flag blockers or dependencies that require user input

   ## Working Protocol
   1. Always check plan document before starting new work
   2. Update plan with checkmarks as tasks complete
   3. Add entries to Progress Log for significant milestones
   4. Ask for clarification when requirements are ambiguous
   5. Run relevant tests after each implementation phase
   6. Suggest plan adjustments when scope changes

   ## Integration Points
   - Coordinate with /code-review before merge
   - Coordinate with /design-review before merge (for UI/frontend changes)
   - Use /smart-commit for commits following conventional format
   ```

   - Write agent config using Write tool
   - Report: "✓ Agent configuration created: @{branch-name}-agent"

3. **Plan update protocol:**
   - After completing Phase 4, add this instruction to user briefing:
   - "After completing each major task, update the detailed plan document's 'Active Work' section with current progress and mark completed tasks with [x] in the Implementation Plan"
   - Add context monitoring reminder: "Check remaining context regularly using the token count. If less than 10% context window remains (~20k tokens), run /reset-context before starting the next task"

4. **Check for existing helpful agents:**
   - Scan current custom agents (check .claude/agents/ directory if it exists)
   - List any agents that might assist with this branch's work
   - Suggest: "I found these existing agents that might help: {list if any, or 'none found'}"

### Phase 5: Activation & Handoff

1. **Create initial briefing:**
   - Display comprehensive summary:

   ```
   ✓ Branch workspace ready: .context/dev/{branch-name}/
   ✓ Agent context created ({branch-name}-agent.md)
   ✓ Detailed plan created ({branch-name}-detailed-plan.md)
   ✓ Session history initialized ({branch-name}-session-history.md)
   ✓ Branch guidelines documented (agent-config.md)

   Your development environment is now set up for: {branch focus summary}

   ## START OF EACH SESSION:

   **Option 1 (Recommended):**
   Run: `/load-context`

   This command will:
   - Load all three context files automatically
   - Check for existing todos to avoid duplicates
   - Verify context budget

   **Option 2 (Manual):**
   Load files in this order:
   1. @.context/dev/{branch-name}/{branch-name}-agent.md
   2. @.context/dev/{branch-name}/{branch-name}-detailed-plan.md
   3. @.context/dev/{branch-name}/{branch-name}-session-history.md

   ## Working on this branch:
   1. Reference the plan to see what to work on
   2. Update plan with checkmarks as you complete tasks
   3. Store all branch work in: .context/dev/{branch-name}/
   4. Use `/reset-context STATUS` to check if context reset recommended
   5. Use `/reset-context` to update all files before running `/clear`

   ## MCP Tools Available:
   - `check_context_budget` - Monitor context usage
   - `get_session_state` - View todos, git state, session info
   - `get_session_history` - Review session accomplishments
   - `sync_planning_doc` - Update plan programmatically
   - `should_reset_context` - Get reset recommendations

   ## Before merge:
   - Run /code-review (REQUIRED)
   - Run /design-review (REQUIRED for UI/frontend changes)
   - Use /smart-commit for conventional commits
   ```

2. **Create quick reference file:**
   - Create `.context/dev/{branch-name}/README.md` with:
     - Branch purpose summary
     - **Session startup instructions** (mention /load-context command)
     - Quick links to all three context files (agent, plan, history)
     - MCP tools reference
     - Common commands for this branch
     - Reminder about pre-merge requirements

## Error Handling

- **Branch already exists:** Check with `git branch --list {branch-name}`. If exists, report: "Branch '{branch-name}' already exists. Please use a different name or checkout the existing branch with: git checkout {branch-name}"
- **Git errors:** Display full error message and suggest resolution
- **Directory creation fails:** Check permissions, suggest alternative location
- **File write failures:** Report error and suggest manual creation with template

## Additional Notes

- Store all branch metadata in `.context/dev/{branch-name}/` for easy cleanup
- Plan document is living - should be updated throughout development
- Agent config serves as reference for specialized assistance
- Pre-merge checklist enforcement will be handled when user attempts merge operations
