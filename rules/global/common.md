# Agent Behavior Guidelines

> This file is centrally maintained in `ly87ing/agent-rule` and synchronized to local agent rule paths. Do not edit synced copies directly.

## 1. Default Language and Output Style

- **MANDATORY:** The agent **MUST** use Chinese (Simplified) for **ALL** interactions, outputs, and generated content.
- This includes, but is not limited to:
  - Conversational responses.
  - Explanations of code or logic.
  - Code comments, unless editing an existing English-comment code path and preserving the established style is safer.
  - Summaries, reports, reviews, and analysis results.
- **EXCEPTION:** Professional technical terms can remain in English when translation would reduce clarity.

## 2. Tool Strategy

- **Primary Semantic Search:** Use the `codebase-retrieval` tool from Augment Context Engine as the default tool for code search, symbol discovery, cross-file relationships, and architecture understanding.
- **Retrieval Entry Point:** Use `codebase-retrieval` first whenever file locations are unclear, when high-level codebase context is needed, or before making non-trivial edits.
- **Workspace Targeting:** When the tool exposes a workspace or `directory_path` parameter, pass the active project or repository as an absolute path.
- **Query Quality:** Prefer one detailed retrieval request that names the relevant symbols, call paths, config, tests, and callers over many shallow requests.
- **Exact Match Search:** Use local file tools or `rg` only for exact string matches, config keys, logs, generated files, or other non-semantic searches.
- **Indexing Model & Fallback:** For local MCP usage, treat `codebase-retrieval` as real-time over the working directory. Augment documentation also describes broader context such as commit history and codebase patterns, so do not assume retrieval is limited to plain file text. If indexing is unavailable, state that clearly and fall back to direct file reads, exact-match search, and local verification.

## 3. Workflow

- **Explore First:** Start with `codebase-retrieval`, then inspect only the returned files that are actually needed.
- **Plan Before Editing:** Analyze context and impact before editing instead of guessing file locations or dependencies.
- **Shared Code Changes:** When modifying common or shared code, explicitly inspect both implementations and existing callers.
- **Verify:** **CRITICAL**. Run tests, lint, build checks, or other local verification after modification when applicable.
- **Conventions:** Rigorously mimic existing code patterns, naming styles, and structure. Do not introduce new frameworks without clear justification.

## 4. Architecture: Reuse & Isolation

Follow the "Vertical Isolation, Horizontal Reuse" strategy:

1. **Business Logic (Vertical)**
   - **Isolation:** Keep distinct business features decoupled. Create new modules for new features.
   - **Integration:** Connect via interfaces or events. Avoid modifying existing business flows unless necessary.
2. **Common Infrastructure (Horizontal)**
   - **Joint Maintenance:** Common modules (`utils`, `shared`, `core`) are collective property.
   - **Improvement:** If a generic function is needed, add it to the common module so everyone benefits.
   - **Rule:** Changes to common code must remain backward-compatible and generic.
   - **Safety:** Verify that existing callers are not broken when modifying common code.
   - **No Duplication:** Never copy-paste common code. Fix it or extend it in place.

## 5. Code Style & Integrity

- **Data & Config Integrity**
  - **No Hardcoding:** Secrets, URLs, and environment-specific configs must live in configuration files or environment variables. Replace magic strings or numbers with named constants or enums.
  - **No Fake Data:** Mock or fake data is strictly limited to test files.
  - **Missing Data Handling:** Production code must handle missing data via explicit errors or exceptions, typed optional or result patterns, or safe default values. Do not leave runtime-affecting TODO placeholders.
- **Naming:** Use English (ASCII) for code identifiers, filenames, classes, methods, variables, and constants.
- **Comments:** Use Chinese (Simplified) for new comments unless the surrounding file already uses an established English comment style that should be preserved.
