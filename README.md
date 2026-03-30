# AgentScope Documentation

This repository contains the official documentation for [AgentScope](https://github.com/modelscope/agentscope), a production-ready, multi-agent framework for building LLM-empowered agent applications. The docs site is built with [Mintlify](https://mintlify.com).

## Overview

AgentScope provides a simple yet efficient way to build LLM-empowered agent applications, with built-in support for:

- Multi-agent orchestration
- Multiple model providers (DashScope, Gemini, OpenAI, Anthropic, Ollama)
- Memory (short-term and long-term)
- Tools and RAG
- Observability and evaluation

## Development

### Prerequisites

- Node.js version 19 or higher

### Local Preview

Install the [Mintlify CLI](https://www.npmjs.com/package/mint):

```bash
npm i -g mint
```

Start the local development server at the root of this repository (where `docs.json` is located):

```bash
mint dev
```

View your local preview at `http://localhost:3000`.

## Repository Structure

```
.
├── basic-concepts/       # Core AgentScope concepts (msg, agent, model, memory, tool)
├── building-blocks/      # Advanced building blocks
├── tutorial/             # Step-by-step tutorials
├── out-of-box-agents/    # Pre-built agents
├── api-reference/        # API documentation
├── observe-and-evaluate/ # Monitoring and evaluation
├── tune-agent/           # Agent tuning guides
├── deploy-and-serve/     # Deployment options
├── essentials/           # Documentation components
├── others/               # FAQ and additional resources
└── docs.json             # Mintlify navigation config
```

## Contributing

When adding or updating documentation:

1. Place `.mdx` files in the appropriate directory
2. Update `docs.json` to include new pages in the navigation
3. Start every page with YAML frontmatter (`title` and `description`)
4. Follow the [writing style guidelines](CLAUDE.md) in this repo
5. Preview changes locally before submitting a PR

## Troubleshooting

- **Dev server not running**: Run `mint update` to get the latest CLI version.
- **Page shows 404**: Ensure you are running in the folder containing `docs.json`.

## Resources

- [AgentScope GitHub](https://github.com/agentscope-ai/agentscope)
- [Mintlify Documentation](https://mintlify.com/docs)
