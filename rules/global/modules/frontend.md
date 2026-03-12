# Frontend Verification

- **Mandatory:** Any frontend-related changes (UI, validation logic, user flows) **MUST** be verified using `playwright-cli`.
- **Headed Mode:** Always run in headed mode by default, i.e., always pass the `--headed` flag unless headless mode is explicitly requested.
- **Artifact Storage:** All playwright intermediate outputs (screenshots, snapshots, traces, videos, test results) **MUST** be written to the system temporary directory (`/tmp` on macOS/Linux, `%TEMP%` on Windows). Never write playwright output to the project directory to avoid polluting the codebase. Always resolve the temp path for the current OS before passing output flags explicitly.
- **Completion Criteria:** A `playwright-cli screenshot` or `snapshot` must be provided as evidence that the fix or implementation is working. The task is not considered complete without it.
- **Skill Synergy:** For specific execution strategies and best practices, strictly follow the `playwright-best-practices` skill.

### Preventing False Positives in Playwright
To prevent Playwright CLI from falsely reporting tests as "passed" (i.e., when tests pass but hidden errors exist or tests weren't fully executed), you **MUST** strictly adhere to the following rules when writing and running tests:

1. **Strictly Capture Console and Page Errors:** By default, unhandled exceptions (`pageerror`) and `console.error` inside the page do not fail the test. You MUST explicitly listen for these in your tests or global fixtures and convert them into test failures.
   - Example: `page.on('pageerror', error => { throw error; });`
   - Example: `page.on('console', msg => { if (msg.type() === 'error') throw new Error(msg.text()); });`
2. **Awaiting All Async Operations is Mandatory:** Missing the `await` keyword for assertions (e.g., `await expect()`) or page interactions (e.g., `click()`, `goto()`) causes them to return synchronously. This immediately ends the test, marking it as passed regardless of the actual outcome. All async calls must be rigorously reviewed.
3. **Verify Actual Output and Execution Count:** After running `playwright-cli`, it is strictly forbidden to claim success based merely on "no errors" or an "exit code 0". You MUST explicitly find `X passed` in the output logs and ensure that `X > 0`. If tests were skipped or 0 tests were executed due to unmatched files, it MUST be considered a verification failure.
4. **Reject Subjective Assumptions:** When acting as an AI Agent, after executing a test command, you must read the `stdout`/`stderr` entirely. You can only declare success after seeing clear, irrefutable evidence. Vague assertions like "it should be fixed now" or "it looks fine" are prohibited (refer to the `verification-before-completion` skill).
