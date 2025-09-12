<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See LICENSE.dual.md for full terms.
-->
## Proxy Generation and Navigation

### 🧠 Contributor Notes

* Navigation properties must be declared explicitly virtual in the proxy surface.
* Cacheability is opt-in—ambient resolution is never assumed.
* Providers interpret navigation flags independently, but orchestration remains consistent.
* Envelope metadata may include relationship freshness hints (e.g. `LastResolved`, `Version`, `ConsistencyLevel`).

---