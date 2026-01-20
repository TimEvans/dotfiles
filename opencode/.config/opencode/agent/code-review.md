---
description: Code review without edits
mode: subagent
permission:
  edit: deny
  bash:
    "git diff": allow
    "git log*": allow
    "*": ask
  webfetch: deny
---

## Context

- Current git status: !'git status'
- Recent changes: !'git diff HEAD~1'
- Recent commits: !'git log --oneline -5'
- Current branch: !'git branch --show-current'

## Your task

Perform a comprehensive code review focusing on :

1. **Code Quality**: Check for readability, maintainability, and adherence to best practices
2. **Security**: Look for potential vulnerabilities, code injection, or other security issues
3. **Performance**: Identify potential performance bottlenecks
4. **Testing**: Assess test coverage and quality
5. **Documentation**: Check if code is properly documented 

Provede specific, actionable feedback with line-by-line comments where appropritate. 
