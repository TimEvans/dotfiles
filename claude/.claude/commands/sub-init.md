---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite
description: Generate and maintain documentation files to improve codebase navigation efficiency across any programming language
---

# Sub-Init: Subdirectory Documentation Generator

Generate CLAUDE.md files in each subdirectory to improve codebase navigation and reduce token usage during searches.

## Command Arguments Parsing

Parse the command arguments to determine the mode:
- **Default mode** (no args): Generate CLAUDE.md files for subdirectories that don't have them
- **update mode** (`update` arg): Refresh all existing CLAUDE.md files
- **branch mode** (`branch` arg): Update only directories with changed files (git diff main..HEAD)
- **dry-run mode** (`--dry-run` flag): Preview without writing files (can combine with other modes)
- **Custom path** (`--path <dir>` flag): Override source directory detection

Arguments provided: {{ARGS}}

## Step 1: Initialize Todo List

Create a todo list to track progress through this multi-step process.

## Step 2: Detect Primary Source Directory

Check for common source directories in priority order:
1. `src/`
2. `app/`
3. `lib/`
4. `backend/`
5. `frontend/`
6. `packages/`
7. Current directory if none found

If `--path` flag provided, use that instead.

Use Bash to find potential source directories:
```bash
find . -maxdepth 2 -type d \( -name "src" -o -name "app" -o -name "lib" -o -name "backend" -o -name "frontend" -o -name "packages" \) 2>/dev/null | head -5
```

Select the most appropriate directory or use current directory as fallback.

## Step 3: Load Exclusion Patterns

Default exclusions (always skip):
- `__pycache__`, `node_modules`, `dist`, `build`, `target`, `.next`, `.pytest_cache`
- `tests`, `test`, `spec`, `__tests__`
- Hidden directories (starting with `.`)
- `vendor`, `venv`, `env`

Check if `.claudeignore` file exists and load custom exclusions if present.

## Step 4: Identify Target Directories

Based on the mode, identify directories to process.

### Default Mode
To find directories without CLAUDE.md files:
1. Use Glob to find all subdirectories: `<detected_source_dir>/**/`
2. Use Glob to find all existing CLAUDE.md files: `<detected_source_dir>/**/CLAUDE.md`
3. Compare the lists to identify directories without CLAUDE.md
4. Filter out excluded directories (node_modules, __pycache__, dist, build, .*, tests, test, target, .next, vendor, venv)

This approach uses the Glob tool which is already fully permitted and avoids complex bash scripts.

### Update Mode
Same as default mode but include ALL directories (don't skip existing CLAUDE.md files).

### Branch Mode
Use git to get changed files:
```bash
git diff --name-only main..HEAD 2>/dev/null || git diff --name-only master..HEAD 2>/dev/null
```

Extract unique parent directories from the changed files list and process only those directories.

### Dry-Run Mode
For any mode above, show preview without writing files.

## Step 5: For Each Target Directory

Process each directory using the following approach:

### 5.1: List Files in Directory
Use Bash to list files in the current directory being processed:
```bash
ls -la <directory_path>
```

### 5.2: Analyze Each Source File

For common file extensions (.js, .ts, .py, .go, .rs, .java, .rb, .php, .cpp, .c, .h, .tsx, .jsx, .vue, .lua, .sh, etc.):

Read the file and extract:

#### For All Languages:
- **Purpose**: First comment block or infer from filename/code
- **Key Functions/Methods**: Pattern matching for:
  - JavaScript/TypeScript: `function name()`, `const name = ()`, `export function`, `async function`
  - Python: `def name(`, `async def name(`
  - Go: `func name(`, `func (receiver) name(`
  - Rust: `fn name(`, `pub fn name(`, `async fn`
  - Java/C#: `public/private/protected Type methodName(`
  - Ruby: `def name`, `def self.name`
  - PHP: `function name(`, `public function`
  - C/C++: `return_type function_name(`
  - Lua: `function name(`, `local function`
  - Shell: `function name()`, `name()`

#### Key Classes/Types/Components:
  - JavaScript/TypeScript: `class Name`, `interface Name`, `type Name`, `export default`, React components
  - Python: `class Name(`, `@dataclass`, `NamedTuple`
  - Go: `type Name struct`, `type Name interface`
  - Rust: `struct Name`, `enum Name`, `trait Name`, `impl`
  - Java/C#: `class Name`, `interface Name`, `enum Name`, `record Name`
  - Ruby: `class Name`, `module Name`
  - PHP: `class Name`, `interface Name`, `trait Name`
  - C/C++: `class Name`, `struct Name`, `enum Name`

#### Key Exports:
  - JavaScript/TypeScript: `export { }`, `export default`, `module.exports`
  - Python: `__all__ = []` or functions/classes at module level
  - Go: Uppercase function/type names (public exports)
  - Rust: `pub fn`, `pub struct`, `pub enum`
  - Others: public/exported symbols

#### Dependencies:
  - JavaScript/TypeScript: `import ... from`, `require()`
  - Python: `import`, `from ... import`
  - Go: `import ()`
  - Rust: `use`, `extern crate`
  - Java: `import`
  - Ruby: `require`, `require_relative`
  - PHP: `use`, `require`, `include`
  - C/C++: `#include`

**Keep all descriptions brief. This is for discoverability, not documentation.**

### 5.3: Generate CLAUDE.md Content

Use this template:

```markdown
# [Directory Name] - Module Index

**Last Updated:** [ISO 8601 timestamp]

## Files Overview

### filename.ext
**Purpose:** [Brief description]
**Key Functions/Methods:**
- `function_name(params)` - Brief description
- `another_function(params)` - Brief description

**Key Classes/Types/Components:**
- `ClassName` - Brief description

**Key Exports:** [What this file makes available]
**Dependencies:** [Major imports - list top 3-5 if many]

[Repeat for each file in directory]

---
*This file is auto-generated by `/sub-init`. Update with `/sub-init update`.*
```

### 5.4: Write or Preview File

**If NOT dry-run mode:**
- Write the content to `[DIRECTORY_PATH]/CLAUDE.md`
- Report: "✓ Created [DIRECTORY_PATH]/CLAUDE.md"

**If dry-run mode:**
- Show sample output for first 2-3 directories only
- Report: "Would create [DIRECTORY_PATH]/CLAUDE.md"

## Step 6: Update Root CLAUDE.md

After generation, update the root CLAUDE.md file if it exists in the current directory.

First, read the current CLAUDE.md file (if it exists).

### 6.1: Add or Update Index Section

Find the "## Subdirectory Documentation Index" section or create it near the end of the file.

Update it with:

```markdown
## Subdirectory Documentation Index

Detailed module indexes are maintained in each subdirectory:
- `[source-dir]/[folder]/CLAUDE.md` - Quick reference for module contents
- These files are auto-generated by `/sub-init` to reduce token usage during codebase searches

**Generated directories:**
[List each directory with CLAUDE.md, e.g.:]
- `src/components/` - UI components and layout
- `src/utils/` - Helper functions and utilities
- `src/api/` - API endpoints and handlers

**Usage:**
- Generate: `/sub-init` (skips existing files)
- Update all: `/sub-init update`
- Update changed: `/sub-init branch`
- Preview: `/sub-init --dry-run`

**Last synchronized:** [ISO 8601 timestamp]
**Total indexed directories:** [count]
```

### 6.2: Write Root CLAUDE.md Update

**If NOT dry-run mode:**
- Edit or append the section to CLAUDE.md
- Report: "✓ Updated root CLAUDE.md"

**If dry-run mode:**
- Show what would be added
- Report: "Would update root CLAUDE.md"

## Step 7: Final Report

Provide a summary:

```
Sub-Init Summary
================

Mode: [default/update/branch/dry-run]
Source Directory: [path]
Directories Processed: [count]
Files Created: [count]
Files Updated: [count]
Files Skipped: [count]

[List of all affected directories]

✓ Complete! Use these CLAUDE.md files for faster codebase navigation.
```

## Error Handling

- **Empty directories**: Skip with note "Skipped [dir] - no indexable files"
- **Unrecognized file types**: List file with line count only
- **No source directory found**: Warn and ask user to specify with `--path`
- **Parse errors**: Continue processing, note file couldn't be fully parsed
- **Not a git repo** (branch mode): Fall back to update mode with warning
- **No changes found** (branch mode): Report "No changes detected, nothing to update"

## Additional Notes

- **Token Optimization**: Keep all descriptions brief. This is for discoverability, not documentation.
- **Staleness Warning**: When Claude later reads a subdirectory CLAUDE.md, it should check if the timestamp is >7 days older than the newest source file in that directory and warn if stale.
- **Language Agnostic**: Handle any text-based source files by detecting patterns.
- **Concise Output**: Don't overwhelm - show progress but keep it minimal.

## Implementation Strategy

1. Use TodoWrite to track each major step
2. **PREFER Glob/Grep tools over bash loops** - They're fully permitted and more efficient
3. Use Read to analyze individual source files
4. Use simple Bash commands for git operations and file checks
5. Use Write/Edit to create/update CLAUDE.md files
6. Process directories in batches if many (e.g., 5-10 at a time)
7. For large codebases (>50 directories), ask user to confirm before proceeding

**Important:** Avoid complex bash scripts with loops/conditionals when possible. Use Glob to find files/directories and process them with built-in tools instead.

---

Now execute the appropriate mode based on the parsed arguments above.
