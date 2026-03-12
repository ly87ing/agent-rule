# Code Style & Integrity

## 1. Data & Config Integrity
- **No Hardcoding:** Secrets, URLs, and environment-specific configs must live in configuration files or environment variables. Replace magic strings or numbers with named constants or enums.
- **No Fake Data:** Mock or fake data is strictly limited to test files.
- **Missing Data Handling:** Production code must handle missing data via explicit errors or exceptions, typed optional or result patterns, or safe default values. Do not leave runtime-affecting TODO placeholders.

## 2. Naming & Language
- **Naming:** Use English (ASCII) for code identifiers, filenames, classes, methods, variables, and constants.
- **Comments:** Use Chinese (Simplified) for all new comments unless the surrounding file already uses an established non-Chinese comment style that should be preserved.
