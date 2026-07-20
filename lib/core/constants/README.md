# Constants

Shared, framework-agnostic status/category enums that mirror the exact string
literals used in `docs/05_FIRESTORE_DATABASE.md`. Every enum exposes `.value`
(or `.valueOrNull`) for writing to Firestore and a `.fromValue(String?)`
static parser for reading — this is the single place a status string is ever
spelled out, so no feature hand-rolls `"vacant"` / `"pending_approval"` /
etc. as a raw literal.

Reusable as-is in the future Resident App (copy this folder over first).
