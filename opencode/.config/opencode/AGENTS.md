# AGENTS.md - Advanced OpenCode Agent Development

## Repository Overview
Advanced agent configuration repository managing specialized agents, subagents, and automation workflows for OpenCode. Uses markdown-based agent definitions with comprehensive tool permissions and specialized focus areas.

## Agent Configuration Structure
```
.config/opencode/
├── opencode.json              # Main MCP configuration  
├── agent/                     # Agent definitions
│   ├── code-review.md         # Code review without edits
│   ├── research.md            # Web research and analysis
│   ├── context-snapshot.md    # Context state capture
│   ├── context-continue.md    # Context restoration
│   ├── project-architect.md   # System architecture analysis
│   ├── test-engineer.md       # Test suite generation
│   └── perf-auditor.md        # Performance optimization
└── subagents/                 # Subagent definitions (future)
```

## Context Management Workflow

### Session Continuity Solution
- **context-snapshot**: Captures comprehensive session state at key progress points
- **context-continue**: Restores context from snapshots to continue interrupted workflows
- **Workflow**: Save state → continue from earlier context → maintain continuity without performance degradation

```bash
# Usage pattern
@context-snapshot: "Save current progress on user authentication feature"
# Later...
@context-continue: "Load snapshot from authentication work session"
```

## Core Agent Arsenal

### 1. Code Review Agent (`code-review.md`)
- **Mode**: Subagent (read-only analysis)
- **Focus**: Security, performance, testing, documentation quality
- **Permissions**: Limited bash (git operations only), no write/edit
- **Usage**: `@code-review: "Review the new authentication implementation"`

### 2. Research Agent (`research.md`)
- **Mode**: Primary agent for complex research tasks
- **Tools**: Web automation, browser interaction, comprehensive source analysis
- **Focus**: Multi-source research, citation management, systematic analysis
- **Usage**: `@research: "Research PostgreSQL vs MongoDB for time-series data"`

### 3. Context Management Agents
- **context-snapshot**: State preservation with todo recreation
- **context-continue**: Context restoration and progress continuity

### 4. Architecture Agent (`project-architect.md`)
- **Mode**: Subagent for system design and refactoring
- **Focus**: Architecture assessment, strategic planning, technology integration
- **Tools**: Full read/write access, web research for patterns
- **Usage**: `@project-architect: "Analyze current system for scalability improvements"`

### 5. Testing Agent (`test-engineer.md`)
- **Mode**: Subagent for comprehensive testing strategies
- **Focus**: TDD/BDD patterns, test automation, coverage optimization
- **Permissions**: Full bash/write/edit for test creation
- **Usage**: `@test-engineer: "Generate comprehensive test suite for user service"`

### 6. Performance Agent (`perf-auditor.md`)
- **Mode**: Subagent for performance analysis and optimization
- **Focus**: Bottleneck identification, algorithmic optimization, monitoring
- **Tools**: Performance profiling, load testing, system analysis
- **Usage**: `@perf-auditor: "Identify performance bottlenecks in user search"`

## Agent Usage Patterns

### Multi-Agent Workflows
```bash
# Development workflow example
@project-architect: "Design authentication system architecture"
@context-snapshot: "Save architectural decisions"

@test-engineer: "Create test strategy for auth system"
@context-continue: "Continue with testing implementation"

@perf-auditor: "Optimize auth system performance"
@code-review: "Final security review of auth implementation"

@context-snapshot: "Complete auth feature development"
```

### Specialized Focus Areas
- **Security**: Code-review agent for vulnerability assessment
- **Performance**: Perf-auditor for optimization and monitoring
- **Architecture**: Project-architect for system design decisions
- **Quality Assurance**: Test-engineer for comprehensive testing
- **Research**: Research agent for external information gathering
- **Continuity**: Context agents for workflow management

## Configuration Best Practices

### Agent Design Patterns
- **Specialized Function**: Each agent has a specific, well-defined focus
- **Permission Granularity**: Minimal permissions required for each agent's function
- **Tool Access Control**: Explicit permissions for bash, webfetch, file operations
- **Temperature Tuning**: Lower temperatures for analysis (0.1-0.3), higher for creative tasks (0.7+)

### Markdown Format Requirements
- **ALWAYS use markdown** for agent commands, configurations, and subagent definitions
- **YAML Frontmatter**: Metadata for agent configuration (mode, tools, permissions)
- **Structured Prompts**: Clear sections for capabilities, usage, and guidelines
- **Example Integration**: Concrete usage patterns and workflow examples

### Tool Permission Strategy
- **Minimal Access**: Grant only the tools needed for each agent's function
- **Read-Only Preference**: Default to read-only for analysis agents
- **Write Protection**: Explicit permission for agents that modify files
- **Bash Restrictions**: Granular control over system commands per agent

## Workflow Integration

### Development Lifecycle Integration
1. **Planning**: Use project-architect for system design and architecture
2. **Implementation**: Multi-agent development with specialized focus areas
3. **Testing**: Test-engineer for comprehensive test suite creation
4. **Review**: Code-review agent for security and quality assessment
5. **Optimization**: Perf-auditor for performance analysis and improvements
6. **Documentation**: Research agent for external documentation and examples

### Context Management Strategy
- **Progress Points**: Snapshot at key milestones and feature completion
- **Continuity**: Use context agents to avoid context compaction performance issues
- **Session Recovery**: Restore full context when returning to earlier decision points
- **Progress Tracking**: Automatic todo list recreation from snapshots

### Best Practices
- **Markdown Consistency**: All configurations and documentation in markdown format
- **Modular Design**: Separate specialized agents rather than monolithic general agents
- **Permission Minimization**: Grant only necessary permissions to each agent
- **Documentation Focus**: Comprehensive usage examples and capability descriptions
- **Context Preservation**: Regular snapshots for complex, multi-session workflows

This agent ecosystem enables sophisticated, specialized development workflows while maintaining security through granular permissions and providing robust context management for complex, long-term projects.
