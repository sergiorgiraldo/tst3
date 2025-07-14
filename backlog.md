# Backlog.md

[https://github.com/MrLesk/Backlog.md](https://github.com/MrLesk/Backlog.md)

All data is saved under `backlog` folder as human‑readable Markdown with the following format `task-<task-id> - <task-title>.md` (e.g. `task-12 - Fix typo.md`).

---

## Web Interface

```bash
# Start the web server (opens browser automatically)
backlog browser

# Custom port
backlog browser --port 8080

# Don't open browser automatically
backlog browser --no-open
```

---

## CLI reference

### Project Setup

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Initialize project | `backlog init [project-name]` (creates backlog structure with interactive configuration) |
| Re-initialize | `backlog init` (preserves existing config, allows updates) |

The `backlog init` command provides comprehensive project setup with interactive prompts for:

- **Project name** - identifier for your backlog
- **Auto-commit** - whether to automatically commit task changes to git
- **Default editor** - editor command for opening tasks (detects from environment)
- **Remote operations** - enable/disable fetching tasks from remote branches
- **Web UI settings** - port and browser auto-open preferences

When re-initializing an existing project, all current configuration values are preserved and pre-populated in prompts, allowing you to update only what you need.

### Task Management

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Create task | `backlog task create "Add OAuth System"`                    |
| Create with description | `backlog task create "Feature" -d "Add authentication system"` |
| Create with assignee | `backlog task create "Feature" -a @sara`           |
| Create with status | `backlog task create "Feature" -s "In Progress"`    |
| Create with labels | `backlog task create "Feature" -l auth,backend`     |
| Create with priority | `backlog task create "Feature" --priority high`     |
| Create with plan | `backlog task create "Feature" --plan "1. Research\n2. Implement"`     |
| Create with AC | `backlog task create "Feature" --ac "Must work,Must be tested"` |
| Create with notes | `backlog task create "Feature" --notes "Started initial research"` |
| Create with deps | `backlog task create "Feature" --dep task-1,task-2` |
| Create sub task | `backlog task create -p 14 "Add Login with Google"`|
| Create (all options) | `backlog task create "Feature" -d "Description" -a @sara -s "To Do" -l auth --priority high --ac "Must work" --notes "Initial setup done" --dep task-1 -p 14` |
| List tasks  | `backlog task list [-s <status>] [-a <assignee>] [-p <parent>]` |
| List by parent | `backlog task list --parent 42` or `backlog task list -p task-42` |
| View detail | `backlog task 7` (interactive UI, press 'E' to edit in editor) |
| View (AI mode) | `backlog task 7 --plain`                           |
| Edit        | `backlog task edit 7 -a @sara -l auth,backend`       |
| Edit        | `backlog task edit 7 -s "In Progress"`       |
| Add plan    | `backlog task edit 7 --plan "Implementation approach"`    |
| Add AC      | `backlog task edit 7 --ac "New criterion,Another one"`    |
| Add notes   | `backlog task edit 7 --notes "Completed X, working on Y"` |
| Add deps    | `backlog task edit 7 --dep task-1 --dep task-2`     |
| Archive     | `backlog task archive 7`                             |

### Draft Workflow

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Create draft | `backlog task create "Feature" --draft`             |
| Draft flow  | `backlog draft create "Spike GraphQL"` → `backlog draft promote 3.1` |
| Demote to draft| `backlog task demote <id>` |

### Board Operations

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Kanban board      | `backlog board` (interactive UI, press 'E' to edit in editor) |
| Export board | `backlog board export [file]` (exports Kanban board to markdown) |

### Web Interface

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Web interface | `backlog browser` (launches web UI on port 6420) |
| Web custom port | `backlog browser --port 8080 --no-open` |

### Configuration

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Config editor | `backlog config set defaultEditor "code --wait"` |
| Enable auto-commit | `backlog config set autoCommit true` |
| View config | `backlog config list` |

### Documentation

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Create doc | `backlog doc create "API Guidelines"` |
| Create with path | `backlog doc create "Setup Guide" -p guides/setup` |
| Create with type | `backlog doc create "Architecture" -t technical` |
| List docs | `backlog doc list` |
| View doc | `backlog doc view doc-1` |

### Decisions

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Create decision | `backlog decision create "Use PostgreSQL for primary database"` |
| Create with status | `backlog decision create "Migrate to TypeScript" -s proposed` |

### Agent Instructions

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Update agent files | `backlog agents --update-instructions` (updates .cursorrules, CLAUDE.md, AGENTS.md, GEMINI.md, .github/copilot-instructions.md) |

### Maintenance

| Action      | Example                                              |
|-------------|------------------------------------------------------|
| Cleanup done tasks | `backlog cleanup` (move old completed tasks to completed folder) |

Full help: `backlog --help`

---

## Configuration

Backlog.md merges the following layers (highest → lowest):

1. CLI flags  
2. `backlog/config.yml` (per‑project)  
3. `~/backlog/user` (per‑user)  
4. Built‑ins  

Key options:

| Key               | Purpose            | Default                       |
|-------------------|--------------------|-------------------------------|
| `default_assignee`| Pre‑fill assignee  | `[]`                          |
| `default_status`  | First column       | `To Do`                       |
| `statuses`        | Board columns      | `[To Do, In Progress, Done]`  |
| `date_format`     | ISO or locale      | `yyyy-mm-dd`                  |
| `default_editor`  | Editor for 'E' key | Platform default (nano/notepad) |
| `default_port`    | Web UI port        | `6420`                        |
| `auto_open_browser`| Open browser automatically | `true`            |
| `remote_operations`| Enable remote git operations | `true`           |
| `auto_commit`     | Automatically commit task changes | `false`       |
| `zero_padded_ids` | Pad all IDs (tasks, docs, etc.) with leading zeros | `(disabled)`  |

> **Note**: Set `remote_operations: false` to work offline. This disables git fetch operations and loads tasks from local branches only, useful when working without network connectivity.
> **Git Control**: By default, `auto_commit` is set to `false`, giving you full control over your git history. Task operations will modify files but won't automatically commit changes. Set `auto_commit: true` if you prefer automatic commits for each task operation.

---

## Sharing & Export

### Board Export

Export your Kanban board to a clean, shareable markdown file:

```bash
# Export to default Backlog.md file
backlog board export

# Export to custom file
backlog board export project-status.md

# Force overwrite existing file
backlog board export --force
```

Perfect for sharing project status, creating reports, or storing snapshots in version control.
