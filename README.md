
<p align="center">
  <img src="agents.png" alt="🤖">
</p>


# asw – Agent Switcher 🧠

## 1. About

`asw` (Agent Switcher) is a lightweight **Fish shell tool** that helps developers quickly switch between multiple AI or API agent configurations — for example, OpenRouter models, local inference endpoints, or private backends.

It provides a **unified interface** to load, save, and cycle through agent profiles, making it ideal for projects that depend on different model providers or tokens.

---

### ⚙️ How It Works

- All agent definitions live inside `~/.config/asw/config.yaml`.
- The active agent is stored in `~/.config/asw/agent`.

Each entry in your YAML file defines a unique agent with a set of connection variables:

```yaml
qwen/qwen3-coder-free:
  AGENT_PROTOCOL: https
  AGENT_URL: https://openrouter.ai/api/v1
  AGENT_KEY: sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  AGENT_MODEL: qwen/qwen3-coder:free
  AGENT_PROVIDER: openrouter
```

When you switch or load an agent, `asw` performs these steps:

1. Reads the YAML configuration using [`yq`](https://github.com/mikefarah/yq).
2. Loads the corresponding agent data.
3. Exports each property as a **Fish universal variable** (`set -Ux`).

This means that:

- Your active agent settings persist across all Fish sessions.
- They are globally available to your shell, scripts, and Neovim integrations.

---

### 🧩 Universal Variables

`asw` defines the following universal environment variables:

| Variable         | Description                                     |
| ---------------- | ----------------------------------------------- |
| `AGENT_PROTOCOL` | API protocol (e.g. `https`, `http`)             |
| `AGENT_URL`      | Base API URL                                    |
| `AGENT_KEY`      | API key or authentication token                 |
| `AGENT_MODEL`    | Model identifier (e.g. `qwen/qwen3-coder:free`) |
| `AGENT_PROVIDER` | Provider name or source (e.g. `openrouter`)     |

These variables can then be consumed by your scripts, prompts, or LLM client apps.

---

### 🧭 Commands Overview

```fish
asw            # Show current agent
asw next       # Switch to the next agent in config.yaml
asw prev       # Switch to the previous agent
```

When no current agent is found, `asw` automatically loads the **first entry** from your config file.


## 🧭 Installation

### 1. Prerequisites

Make sure you have:

- **Fish shell** installed (version 3.6+ recommended)
- **Fisher** plugin manager
- **yq** (YAML processor)

To check:

```fish
fish --version
fisher --version
yq --version
```

If something’s missing:

```fish
# Install fisher (plugin manager)
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

# Install yq
sudo dnf install yq    # Fedora / RHEL
# or
sudo apt install yq    # Ubuntu / Debian
# or
brew install yq        # macOS
```

---

### 2. Install `asw` via Fisher

Clone or install directly from your repository (replace with your actual GitHub URL):

```fish
fisher install dshibanov/asw
```

This will install:

- The main command `asw` in `~/.config/fish/functions/asw.fish`
- Default config directory: `~/.config/asw/config.yaml`
- Current agent state file: `~/.config/asw/agent`

---

### 3. Verify Installation

Run:

```fish
asw
```

If everything is correct, you’ll see something like:

```
🐚 AGENT_MODEL=qwen/qwen3-coder:free
   AGENT_PROVIDER=openrouter
   AGENT_URL=https://openrouter.ai/api/v1
   AGENT_PROTOCOL=https
```

---

### 4. Usage

Switch to the next configured agent:

```fish
asw next
```

Switch to the previous agent:

```fish
asw prev
```

Reload the currently saved agent:

```fish
load_asw_agent
```

All agent configuration and environment variables are stored and updated automatically via **universal variables** in Fish (`set -Ux`).


