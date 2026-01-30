# claude-search

A CLI tool to search through your [Claude Code](https://docs.anthropic.com/en/docs/claude-code) session history.

Find past conversations by searching titles, prompts, and full conversation content.

## Features

- **Full-text search** across session titles, first prompts, and complete conversations
- **Interactive mode** (`-i`) - select and resume sessions directly
- **Project filtering** - limit search to specific projects
- **Context display** - show surrounding lines for matches
- **Fast** - streams through JSONL files efficiently (~3s for 600MB+)
- **No dependencies** - uses only Python standard library

## Requirements

- Python 3.8+
- Claude Code installed (searches `~/.claude/projects/`)

## Installation

### Quick Install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/akariev/claude-search/main/install.sh | bash
```

### Manual Install

```bash
# Clone the repository
git clone https://github.com/akariev/claude-search.git
cd claude-search

# Run install script
./install.sh

# Or manually copy to your path
mkdir -p ~/.claude/bin
cp claude-search ~/.claude/bin/
chmod +x ~/.claude/bin/claude-search

# Add to PATH (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/.claude/bin:$PATH"
```

## Usage

### Basic Search

```bash
# Search for a term
claude-search "webhook"

# Search with more context lines
claude-search "error" --context 3

# Search only in metadata (faster)
claude-search "API" --metadata-only
```

### Interactive Mode

The killer feature! Search and directly resume a session:

```bash
claude-search "authentication" -i
```

```
Searching 47 sessions...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1] 📁 my-webapp | "Auth flow debugging"
    🕐 2025-01-28 | 42 messages

[2] 📁 api-server | "JWT token refresh issue"
    🕐 2025-01-25 | 28 messages
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Select session [1-2] or 'q' to quit: 1

▶ Starting: claude --resume 97369e45-a9f8-476a-bf32-1e9e58b23778
```

### Project Filtering

```bash
# Search only in a specific project
claude-search "migration" --project my-webapp
```

### All Options

```
usage: claude-search [-h] [-i] [-p PROJECT] [-c CONTEXT] [-m] [--max MAX] [--no-content] query

positional arguments:
  query                 Search term or phrase

optional arguments:
  -h, --help            Show help message
  -i, --interactive     Interactive mode - select and open session
  -p, --project PROJECT Filter by project name
  -c, --context CONTEXT Context lines around matches (default: 1)
  -m, --metadata-only   Only search in metadata (titles, first prompt)
  --max MAX             Maximum results to show (default: 10)
  --no-content          Don't show match content in output
```

## Uninstall

```bash
# If installed via curl, download and run uninstaller
curl -fsSL https://raw.githubusercontent.com/akariev/claude-search/main/install.sh | bash -s -- --uninstall

# Or if you have the repo cloned
./install.sh --uninstall
```

## How It Works

Claude Code stores session data in:
- `~/.claude/projects/*/sessions-index.json` - Session metadata (title, first prompt, timestamps)
- `~/.claude/projects/*/*.jsonl` - Full conversation history

This tool searches through both to find your past sessions.

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome! Please open an issue or PR.
