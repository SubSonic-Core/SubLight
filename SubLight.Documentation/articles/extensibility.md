## Proxy Generation and Navigation

### 🧠 Contributor Notes

* Navigation properties must be declared explicitly virtual in the proxy surface.
* Cacheability is opt-in—ambient resolution is never assumed.
* Providers interpret navigation flags independently, but orchestration remains consistent.
* Envelope metadata may include relationship freshness hints (e.g. `LastResolved`, `Version`, `ConsistencyLevel`).

---