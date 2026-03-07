# Global User Preferences

**IMPORTANT: These are hard rules. If a user request conflicts with these preferences, push back and clarify before proceeding.**

## Code Style

- **NEVER use emojis in code, comments, or commit messages** - If asked to add emojis, refuse or suggest alternatives
- **Always prefer composition over inheritance** when designing systems
- **Code should be as readable as possible** - Good code should be self-documenting; clarity over cleverness
- **Use descriptive names** - Variables, functions, and types should clearly indicate their purpose
- **Prefer simple, readable solutions** over clever or overly complex ones

## Git & Commits

- **Never commit changes without explicit user permission** - Always ask before creating commits
- **Never commit `.env` files or other secrets** (`.env*`, `credentials.json`, private keys, etc.)
- **Always use conventional commits format**: `type(scope): description`
  - Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`, `perf`
  - Example: `feat(auth): add login validation`
  - Example: `fix(api): resolve timeout issue in user endpoint`

## Workflow & Approach

- **Always read existing code before making changes** - Understand patterns, naming conventions, and architecture first
- **Search before creating** - Check if functionality already exists before implementing new code
- **Ask clarifying questions** when requirements are ambiguous or multiple approaches exist
- **Follow existing project patterns** - Match the codebase's style, structure, and conventions
- **Prefer editing existing files over creating new ones**
- **Follow superpowers skill workflows for all non-trivial tasks:**
  - Use `superpowers:brainstorming` before creating new features or adding functionality
  - Use `superpowers:test-driven-development` when implementing features or bugfixes
  - Use `superpowers:systematic-debugging` when investigating bugs or unexpected behavior
  - Use `superpowers:verification-before-completion` before claiming work is done or committing
  - Use `superpowers:requesting-code-review` when completing major features
  - Use `superpowers:dispatching-parallel-agents` when facing 2+ independent tasks

## Code Quality

- **Handle errors properly** - Don't silently fail, provide useful error messages
- **Consider edge cases** - Think about null/undefined, empty arrays, boundary conditions
- **Run tests after changes** - Verify nothing broke, fix any failing tests before marking work complete
- **Fix tests properly** - Don't just make tests pass, ensure they're testing the right thing

## Communication

- **Be concise but complete** - Match verbosity to task complexity
- **Explain non-obvious decisions** - Why you chose an approach, especially for complex changes
- **Reference code locations** - Use `file:line` format when discussing specific code

## Testing

- **Write tests for new features** - Unit tests for functions, integration tests for workflows
- **Ensure tests validate correctness** - Tests should verify behavior, not just pass
