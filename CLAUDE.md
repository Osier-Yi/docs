# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AgentScope is a production-ready, multi-agent framework for building LLM-empowered agent applications. This repository contains the documentation for the AgentScope framework, built with Mintlify. The documentation covers core concepts like agents, models, tools, memory, and orchestration, as well as tutorials and API references.

## Writing Style Guidelines

Follow these core principles when writing documentation:

### Language and Style
- Use clear, direct language appropriate for technical audiences
- Write in second person ("you") for instructions and procedures
- Use active voice over passive voice
- Employ present tense for current states, future tense for outcomes
- Maintain consistent terminology throughout all documentation
- Keep sentences concise while providing necessary context

### Content Organization
- Lead with the most important information (inverted pyramid structure)
- Use progressive disclosure: basic concepts before advanced ones
- Break complex procedures into numbered steps
- Include prerequisites and context before instructions
- Provide expected outcomes for each major step
- Always precede tables, images, diagrams, and code blocks with an explanatory sentence or paragraph that describes what the content shows or demonstrates

## Mintlify Component Usage

### Callout Components
- `<Note>` - Supplementary information that supports the main content
- `<Tip>` - Expert advice or best practices
- `<Warning>` - Critical information about potential issues
- `<Info>` - Background information or context
- `<Check>` - Success confirmations or positive indicators

### Code Components
- **Single code block**: Include language specification when possible
  ```javascript config.js
  const apiConfig = {
    baseURL: 'https://api.example.com',
    timeout: 5000
  };
  ```

- **Code groups**: Use `<CodeGroup>` for multiple implementation options
  ````
  <CodeGroup>
  ```javascript Node.js
  const response = await fetch('/api/endpoint');
  ```

  ```python Python
  import requests
  response = requests.get('/api/endpoint')
  ```
  </CodeGroup>
  ````

- **API examples**: Use `<RequestExample>` and `<ResponseExample>` for API documentation

### Structural Components
- **Steps**: Use `<Steps>` for sequential instructions
- **Tabs**: Use `<Tabs>` for platform-specific content
- **Accordions**: Use `<AccordionGroup>` for expandable content
- **Cards**: Use `<Card>` and `<CardGroup>` to highlight important information

### API Documentation
- **Parameters**: Use `<ParamField>` to document API parameters
- **Responses**: Use `<ResponseField>` to document API response properties
- **Nested objects**: Use `<Expandable>` for hierarchical information

## Page Structure

Every documentation page must begin with YAML frontmatter:
```yaml
---
title: "Clear, specific, keyword-rich title"
description: "Concise description explaining page purpose and value"
---
```

## Content Quality Standards

### Code Examples
- Include complete, runnable examples that users can copy and execute
- Use realistic data instead of placeholder values
- Include expected outputs when possible
- Specify language and include filename when relevant
- Never include real API keys or secrets

### Documentation Standards
- Include descriptive alt text for all images
- Use specific, actionable link text
- Ensure proper heading hierarchy starting with H2
- Write for scannability with clear headings and lists
- Focus on user goals and outcomes

## Important Project Context

- AgentScope is a multi-agent framework designed to provide a simple yet efficient way to build LLM-empowered agent applications
- AgentScope v1.0 uses a code-first development model (drag-and-drop Workstation UI from v0.x is no longer maintained)
- Supports multiple model providers: DashScope, Gemini, OpenAI, Anthropic, Ollama
- Has built-in support for memory (short-term and long-term), tools, RAG, and observability
- Built with Mintlify, a modern documentation platform

## Common Tasks

### Creating New Documentation Pages
- Add the new .mdx file in the appropriate directory
- Update the `docs.json` navigation configuration to include the new page
- Ensure the file starts with proper YAML frontmatter
- Apply appropriate Mintlify components to enhance readability

### Updating Existing Documentation
- Locate the appropriate .mdx file in the relevant directory
- Modify content following the established style guidelines
- Use appropriate Mintlify components for enhanced presentation
- Test changes by running `mint dev` locally
- Include callouts (Notes, Warnings, Tips) where appropriate

### API Documentation Updates
- Use the proper parameter and response field components
- Include realistic examples with proper code formatting
- Document all parameters, response fields, and error states
