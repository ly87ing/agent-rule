# Frontend Verification

- **Mandatory:** Any frontend-related changes (UI, validation logic, user flows) **MUST** be verified using `playwright-cli`.
- **Headed Mode:** Always run in headed mode by default, i.e., always pass the `--headed` flag unless headless mode is explicitly requested.
- **Artifact Storage:** All playwright intermediate outputs (screenshots, snapshots, traces, videos, test results) **MUST** be written to the system temporary directory (`/tmp` on macOS/Linux, `%TEMP%` on Windows). Never write playwright output to the project directory to avoid polluting the codebase. Always resolve the temp path for the current OS before passing output flags explicitly.
- **Completion Criteria:** A `playwright-cli screenshot` or `snapshot` must be provided as evidence that the fix or implementation is working. The task is not considered complete without it.
- **Skill Synergy:** For specific execution strategies and best practices, strictly follow the `playwright-best-practices` skill.
