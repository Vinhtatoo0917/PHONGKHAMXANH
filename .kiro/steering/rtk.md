---
inclusion: always
---

# RTK usage

When running terminal commands, prefer RTK-wrapped commands to reduce token usage.

Use:
- `rtk git status` instead of `git status`
- `rtk git diff` instead of `git diff`
- `rtk ls .` instead of `ls .`
- `rtk grep "text" .` instead of raw grep/search commands
- `rtk npm test`, `rtk cargo test`, `rtk pytest` instead of raw test commands

If an RTK command fails or is unsupported, fall back to the normal command.