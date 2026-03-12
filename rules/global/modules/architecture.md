# Architecture: Reuse & Isolation

Follow the "Vertical Isolation, Horizontal Reuse" strategy:

## 1. Business Logic (Vertical)
- **Isolation:** Keep distinct business features decoupled. Create new modules for new features.
- **Integration:** Connect via interfaces or events. Avoid modifying existing business flows unless necessary.

## 2. Common Infrastructure (Horizontal)
- **Joint Maintenance:** Common modules (`utils`, `shared`, `core`) are collective property.
- **Improvement:** If a generic function is needed, add it to the common module so everyone benefits.
- **Rule:** Changes to common code must remain backward-compatible and generic.
- **Safety:** Verify that existing callers are not broken when modifying common code.
- **No Duplication:** Never copy-paste common code. Fix it or extend it in place.
