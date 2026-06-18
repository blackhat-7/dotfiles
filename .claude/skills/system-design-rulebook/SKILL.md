---
name: system-design-rulebook
description: A curated, high-signal reference of durable system-design rules covering distributed systems, state/concurrency, idempotency, sagas, messaging, APIs, data modeling, resilience, workers, security, observability, deployment, multi-tenancy, and anti-rules. Use this whenever designing a workflow, API, database change, queue, worker, integration, or production system — or when reviewing architecture decisions, code that crosses service boundaries, or operational safety of a change.
---

# System Design Rules Catalog

Last researched: 2026-06-13

A compact reference of durable system-design rules. The goal is not to memorize all of them. The goal is to scan the relevant section whenever you design a workflow, API, database change, queue, worker, integration, or production system.

No catalog can literally contain every good rule ever written. This is a curated, high-signal compilation from distributed-systems papers, SRE books, cloud architecture catalogs, API design guides, integration pattern catalogs, security guidance, and production case studies.

## Common system shapes

Most backend systems are some mix of:

- **State machine:** entity lifecycle with allowed transitions.
- **Workflow:** multi-step long-running process.
- **Saga:** cross-service workflow with compensations.
- **Queue worker:** async work with retries/leases.
- **Event-driven system:** publish facts, consumers react.
- **Reconciler/controller:** repair actual state toward desired state.
- **CRUD/resource service:** basic resource APIs and persistence.
- **Ledger:** append-only auditable records.
- **Materialized view/cache:** derived fast-read copy, rebuildable.
- **Scheduler/timer:** runs work at a time/interval; avoid overlap.
- **Request-response API:** synchronous REST/gRPC calls with deadlines/auth/idempotency.

## Legend

- **[Any]**: useful in almost every system.
- **[Distributed]**: use when there are multiple processes, services, machines, queues, webhooks, workers, or external APIs.
- **[Data]**: storage, consistency, schema, indexing, deletion, backfills.
- **[Async/Event]**: queues, streams, pub/sub, webhooks, event-driven workflows.
- **[API]**: HTTP/gRPC/public/internal API design.
- **[Workflow]**: multi-step or long-running business process.
- **[Scale]**: high traffic, multi-tenant, resource contention, cost, overload.
- **[Security]**: auth, secrets, isolation, abuse, audit.
- **[Ops]**: deployment, observability, incidents, recovery.
- **[Conditional]**: use only when the stated condition applies.

---

# 1. First principles

- **[Any] Design failure as normal:** network calls, disks, processes, clocks, queues, and dependencies can fail.
- **[Any] Own your invariants:** every important invariant must live in code, DB constraints, state machines, or reconciliation.
- **[Any] Make illegal states unrepresentable:** prefer explicit types/enums/state machines over scattered booleans.
- **[Any] Put tightly-coupled invariants together:** data that must change atomically should live in one transaction boundary.
- **[Any] Pick the consistency boundary first:** decide what must be strongly consistent before choosing services, queues, or databases.
- **[Any] Prefer local correctness over distributed coordination:** a single owner/partition/transaction is simpler than cross-service agreement.
- **[Any] Assume retries:** every operation that crosses a boundary may be attempted more than once.
- **[Distributed] Assume duplicates:** messages, webhooks, jobs, and client requests can be delivered or executed repeatedly.
- **[Distributed] Assume reordering:** events and webhooks may arrive out of order; use versions/state checks.
- **[Distributed] Assume partial success:** one side effect can succeed while the caller times out or another step fails.
- **[Any] Prefer explicit lifecycle state:** use `CREATING`, `ACTIVE`, `DELETING`, `DELETED`, `FAILED`, not only `is_active`.
- **[Any] Terminal states should be immutable:** after `SUCCEEDED`, `CANCELLED`, `FAILED`, or `DELETED`, only allowed explicit recovery transitions should change state.
- **[Any] Separate decision from side effect:** compute/validate the decision first, persist it, then call external systems.
- **[Any] Persist before acting when recovery matters:** if a crash after action would hurt, record the intent first.
- **[Distributed] Avoid hot-path global coordination:** global locks, global ordering, and global transactions limit scale and availability.
- **[Any] Minimize blast radius:** isolate by tenant, shard, region, queue, dependency, or feature.
- **[Distributed] Separate control plane from data plane:** cached config should let serving continue if control APIs fail.
- **[Any] Prefer boring durable storage over clever in-memory state:** memory is a cache, not workflow truth.
- **[Any] Design for known staleness:** expose freshness/version when data may lag.
- **[Any] Make decisions auditable:** record actor, input, decision, state transition, and causation/correlation IDs.
- **[Any] Optimize for recovery, not just prevention:** detection, repair, replay, and reconciliation are part of the design.
- **[Any] Backward compatibility is the default:** old clients, old messages, old workers, and old data may coexist with new code.
- **[Any] Prefer small reversible changes:** large atomic rewrites multiply risk.
- **[Any] Do not hide complexity behind names:** "exactly once", "lock", "cache", and "async" must have precise failure semantics.

---

# 2. State, concurrency, and correctness

- **[Any] State machine:** entities move only through allowed states; invalid transitions are rejected.
- **[API] Transition method, not direct state write:** expose `:cancel`, `:publish`, `:approve`, not arbitrary `state = X` updates.
- **[Data] Compare-and-swap transition:** update only when current state/version equals the expected value.
- **[Data] ETag/resource version:** clients must prove they updated the version they read when concurrent writes matter.
- **[Data] Unique constraint as correctness primitive:** use DB uniqueness for business identities and dedupe keys.
- **[Data] Business key over random key for dedupe:** `order_id + payment_attempt` beats a hidden UUID when intent is naturally unique.
- **[Data] Monotonic version number:** increment on each write so stale actors can be rejected.
- **[Distributed] Fencing token:** every lease acquisition gets a larger token; downstream rejects writes with old tokens.
- **[Distributed] Lock without fencing is only a hint:** a paused worker can resume after losing the lock.
- **[Distributed] Lease instead of permanent lock:** ownership expires if the worker crashes.
- **[Distributed] Heartbeat long work:** extend the lease only while the worker is healthy and still owns the job.
- **[Distributed] Validate ownership at write time:** do not trust that ownership from the start of work is still valid at the end.
- **[Data] Optimistic concurrency for low contention:** use version/CAS when conflicts are rare.
- **[Data] Pessimistic lock for short high-contention critical sections:** keep DB locks short and bounded.
- **[Any] One writer per entity when possible:** partition ownership to avoid write races.
- **[Distributed] Order by entity key, not globally:** per-order/per-user/per-tenant order is usually enough.
- **[Data] Store expected state with intent:** a pending action should record what state it expected to act on.
- **[Data] Use intermediate cleanup states:** `DELETING`, `CANCELLING`, `REFUNDING` allow safe retries.
- **[Any] Cancellation is a transition, not a thread kill:** record cancellation and let workers reach a safe point.
- **[Data] Tombstone before purge:** deletion events, replication, and dedupe may need a marker before permanent removal.
- **[Data] Generation number for recreated resources:** distinguish old `resource_id` ownership from a new resource with the same name.
- **[Any] Monotonic clock for durations:** use monotonic time for timeouts; wall clock can jump.
- **[Any] UTC timestamps for facts:** store instants in UTC; store timezone separately for human schedules.
- **[Data] DB constraints backstop app logic:** `NOT NULL`, `CHECK`, `UNIQUE`, foreign keys, and exclusion constraints prevent silent corruption.
- **[Data] Allocate quota atomically:** quota check and allocation must be one transaction or one serializable decision.
- **[Data] Counters under contention need atomic increment or ledger:** avoid read-modify-write races.
- **[Data] Money uses ledgers:** append immutable debit/credit entries; derive balances.
- **[Data] Inventory uses reservations:** reserve, expire, confirm, or release; do not just decrement blindly.
- **[Data] Derived totals need reconciliation:** cached balances, counts, and summaries must be rebuildable or checkable.
- **[Distributed] Last-write-wins only for low-value data:** preferences may tolerate it; money, inventory, permissions, and orders do not.
- **[Distributed] Use conflict metadata when humans/apps can merge:** vector clocks or versions help only if conflicts have a resolution policy.
- **[Conditional: offline/collaboration] Use CRDTs when merge semantics are acceptable:** choose data types whose concurrent updates converge without coordination.
- **[Distributed] Consensus is infrastructure, not app code:** if you need linearizable leadership or replicated logs, use a proven system.

---

# 3. Idempotency and external side effects

- **[Distributed] Idempotency key:** same key for same logical request/retry; new key for new intent.
- **[Distributed] Store the idempotency result:** replay the previous success/failure response, not just "seen".
- **[Distributed] Scope idempotency keys:** key space should include tenant/user/operation to avoid cross-user collisions.
- **[Distributed] Retain keys for the retry window:** expire only after clients/providers stop retrying.
- **[Distributed] Deduplicate at the receiver:** sender-side dedupe cannot protect against network retries or broker redelivery.
- **[Async/Event] Idempotent receiver:** handling a duplicate message must have the same effect as handling it once.
- **[Async/Event] Idempotent consumer:** a consumer can be invoked repeatedly by at-least-once delivery without duplicate side effects.
- **[Distributed] Provider idempotency key:** pass your stable key to payment, email, booking, or ticketing providers when supported.
- **[Conditional: harmful side effects] Never retry unsafe side effects without dedupe:** no duplicate charges, bookings, shipments, or emails.
- **[Distributed] Unknown outcome means query before retry:** if timeout happened after a request was sent, first check provider state.
- **[API] Client request ID for creates:** enables safe retry after timeout during resource creation.
- **[API] Client-chosen resource ID only when useful:** it makes create idempotent but exposes naming/collision concerns.
- **[Any] Prefer set-state over toggle/increment:** `set_status(ACTIVE)` is safer to retry than `toggle_status()`.
- **[Any] Notification dedupe:** emails, SMS, push, and Slack messages need stable notification IDs.
- **[Async/Event] Webhook dedupe:** verify signature, store event ID, handle duplicates, and return quickly.
- **[Async/Event] Webhook order is not guaranteed:** use object version/current provider state before applying changes.
- **[Distributed] Exactly-once is local, not end-to-end:** across boundaries, model as at-least-once + idempotency + transactions.
- **[Conditional: audit-heavy systems] Store idempotency attempt history:** useful for support, fraud, payment disputes, and RCA.
- **[Any] Idempotent does not mean no-op:** it means repeated attempts converge to the same intended result.

---

# 4. Transactions, sagas, and workflows

- **[Data] Use one DB transaction when it fits:** if all invariants are in one database, do not invent a saga.
- **[Distributed] Avoid distributed transactions across services:** prefer local transactions plus durable messages/workflows.
- **[Async/Event] Outbox pattern:** write business change and event in one DB transaction; publish later.
- **[Async/Event] Inbox pattern:** store consumed message IDs or source offsets to make processing idempotent.
- **[Async/Event] Polling publisher/log tailer:** a relay publishes outbox records; it may publish duplicates, so consumers must dedupe.
- **[Workflow] Saga:** split multi-service workflow into local transactions with compensations for later failures.
- **[Workflow] Compensation is not rollback:** it is a business undo action like refund, release, cancel, or credit.
- **[Workflow] Compensation must be idempotent:** failure recovery may run the undo step more than once.
- **[Workflow] Register compensation before doing the step:** if the process crashes after the side effect, recovery knows how to undo.
- **[Workflow] Orchestrated saga for visibility/control:** use when ordering, timeouts, compensation, and human steps need central tracking.
- **[Workflow] Choreography for simple event flows:** use when participants are loosely coupled and the flow is easy to reason about.
- **[Workflow] Durable workflow engine for long-running retries:** use when workflows span minutes to months, crashes, timers, and many side effects.
- **[Workflow] Persist progress after each successful side effect:** recovery resumes from the next safe step, not from the beginning.
- **[Workflow] Every step has timeout/deadline:** no workflow waits forever for a dependency or human.
- **[Workflow] Human approval is state:** approvals, rejections, timeouts, and escalations belong in the workflow model.
- **[Workflow] Semantic lock/reservation:** mark resources `PENDING` or `RESERVED` so competing workflows see the in-progress intent.
- **[Workflow] Reconciliation loop:** background job compares expected vs actual state and repairs mismatches.
- **[Workflow] Two-phase business state:** `PENDING -> ACTIVE` or `PENDING -> FAILED` is safer than acting invisibly.
- **[Workflow] Recovery must be data-driven:** persisted state should tell the worker the next safe action.
- **[Workflow] Parallel saga branches need compensation order:** undo dependent branches in reverse or dependency-aware order.
- **[Workflow] Do not mix delivery success with business success:** broker ack means "message handled," not "business completed."

---

# 5. Messaging, queues, and events

- **[Async/Event] Queue-based load leveling:** place a queue between bursty producers and finite consumers.
- **[Async/Event] Queue is not capacity:** a growing backlog is delayed failure unless producers slow or consumers scale.
- **[Async/Event] Message envelope:** include ID, type, schema version, producer, created time, correlation ID, causation ID, and tenant.
- **[Async/Event] Event is a fact:** name events in past tense, e.g. `OrderPaid`, not `PayOrder`.
- **[Async/Event] Command asks one owner to act:** commands are imperative and should have one logical handler.
- **[Async/Event] Publish facts, not database rows:** event payload should express domain meaning.
- **[Async/Event] Consumers own their read models:** producers should not know every consumer's query shape.
- **[Async/Event] At-least-once is the default assumption:** duplicates are normal.
- **[Async/Event] Ordering is usually per partition/key:** design around per-entity order, not global order.
- **[Async/Event] Partition by the ordering key:** use `order_id`, `account_id`, or tenant when order matters there.
- **[Async/Event] Dead letter queue:** after bounded retries, isolate poison messages for diagnosis/manual repair.
- **[Async/Event] Invalid message channel:** malformed or semantically invalid messages should not poison the main queue.
- **[Async/Event] Retry transient errors with backoff + jitter:** avoid synchronized retry storms.
- **[Async/Event] Do not retry permanent errors:** validation, authorization, and missing required data usually need fix/manual action.
- **[Async/Event] Delayed retries avoid head-of-line blocking:** move failed work out of the hot queue until retry time.
- **[Async/Event] Retry budget:** cap retries by request, consumer, dependency, and time window.
- **[Async/Event] Backpressure producers:** when queue age grows, slow or reject new work.
- **[Ops] Alert on queue age, not only depth:** age shows user-visible delay.
- **[Async/Event] Claim check for large payloads:** store the blob elsewhere; pass a reference in the message.
- **[Async/Event] Events are immutable:** publish corrections as new events, not edits to old events.
- **[Async/Event] Schema evolution must be compatible:** new fields optional, consumers tolerate unknown fields, old fields deprecated slowly.
- **[Conditional: audit/time travel] Event sourcing:** use when the event log is the source of truth and replay/audit matters.
- **[Conditional: simple CRUD] Avoid event sourcing:** it adds complexity if you only need current state.
- **[Async/Event] Snapshot long event streams:** prevent replay from becoming unbounded.
- **[Async/Event] Materialized view:** build query-optimized projections from events; make them rebuildable.
- **[Async/Event] Broker persistence is not business atomicity:** DB change and message publish still need outbox/transactional design.
- **[Async/Event] Poison pill isolation:** one bad message must not stop an entire partition forever.
- **[Async/Event] Consumer rebalancing needs leases/checkpoints:** assume in-flight work can move or repeat.

---

# 6. APIs and contracts

- **[API] Design around resources and actions:** resources model nouns; custom methods model meaningful verbs.
- **[API] Pagination from day one:** adding pagination later breaks existing clients that expected full results.
- **[API] Page tokens are opaque cursors:** clients must not parse them or treat them as authorization.
- **[API] Page token is not auth:** authorize the request again on every page.
- **[API] Long-running operation resource:** return an operation/job resource instead of holding a request open.
- **[API] `202 Accepted + Location/Retry-After`:** use for asynchronous HTTP request-reply.
- **[API] Consistent errors:** stable machine-readable code, human message, retryability, and correlation ID.
- **[API] Do not leak internals in errors:** no secrets, SQL, stack traces, or provider tokens.
- **[API] Unsafe methods need request ID/idempotency:** especially create, charge, reserve, cancel, refund.
- **[API] Update/delete need version/ETag when races matter:** reject stale updates.
- **[API] PATCH uses field masks:** avoid accidentally clearing fields the client did not intend to change.
- **[API] State is output-only:** clients request transitions; server owns lifecycle truth.
- **[API] Invalid transition returns precondition error:** not a generic 500.
- **[API] Stable resource ID, mutable display name:** users rename things; integrations depend on IDs.
- **[API] Public IDs are not secrets:** authorization must not rely on unguessability.
- **[API] Filtering/ordering only when needed:** adding is easy; removing breaks clients.
- **[API] Version only for breaking changes:** add fields and optional behavior compatibly when possible.
- **[API] Clients ignore unknown fields:** enables forward-compatible responses/events.
- **[API] Servers tolerate missing old fields:** enables old clients during rollout.
- **[API] Propagate deadlines:** downstream calls should know caller's remaining time budget.
- **[API] Propagate correlation/trace context:** every service should join the same request story.
- **[API] Validate at boundaries, enforce in core:** input validation is not a substitute for domain invariants.
- **[API] Batch APIs need per-item result:** partial success should be explicit.
- **[API] Idempotent GET/DELETE semantics:** do not attach mutation side effects to reads.
- **[API] Separate command and query models when needed:** CQRS is useful for complex reads/writes, not a default requirement.

---

# 7. Data modeling, storage, and consistency

- **[Data] One owner per table/entity:** only one service/module writes a given business entity.
- **[Data] Shared database is okay inside a monolith:** avoid it across independently deployed services.
- **[Data] Database-per-service when independent evolution matters:** use sagas/API composition/CQRS for cross-service data.
- **[Data] Keep invariant data together:** split data only when you can tolerate eventual consistency.
- **[Data] Normalize for write integrity:** prevent contradictory facts.
- **[Data] Denormalize for read performance:** but keep a rebuild path for derived views.
- **[Data] Choose shard key from access pattern:** high cardinality, even distribution, low hotspot risk, useful query locality.
- **[Data] Avoid unbounded partitions:** per-user/per-tenant/per-status lists need limits, pagination, or bucketing.
- **[Data] Every production query needs an index strategy:** indexes speed reads but tax writes/storage.
- **[Data] Append audit for important facts:** changes to money, permissions, orders, and admin actions need history.
- **[Data] Soft delete when recovery matters:** mark deleted and allow undelete within a retention window.
- **[Data] Hard delete when policy requires it:** privacy/legal retention can override undo convenience.
- **[Data] Tombstone then purge:** tombstone supports dedupe/replication; purge enforces retention.
- **[Data] Backfills are resumable jobs:** batch, checkpoint, throttle, and make them idempotent.
- **[Data] Dual writes are unsafe by default:** prefer outbox, CDC, or single-writer migration patterns.
- **[Data] Read-your-writes only where UX requires:** otherwise document/handle eventual consistency.
- **[Data] Cache is not source of truth:** it can disappear, be stale, or contain poison.
- **[Data] TTLs need jitter:** avoid synchronized cache expiry and stampedes.
- **[Data] Singleflight hot misses:** coalesce concurrent cache fills for the same key.
- **[Data] Negative cache briefly:** cache misses/errors with short TTL to avoid amplifying repeated failures.
- **[Security] Permission cache TTL <= acceptable revocation delay:** stale auth can become a security bug.
- **[Data] Use blob store for large binaries:** DB stores metadata and pointer; object store stores payload.
- **[Data] Store monetary values as integer minor units or decimal:** never floating point.
- **[Data] Store units with quantities:** bytes, milliseconds, cents, percentage points, currency.
- **[Data] Analytics should not overload OLTP:** replicate/export to analytical stores.
- **[Data] Data retention is a design field:** every data class needs purpose, owner, retention, deletion policy.
- **[Data] Backups are design, not ops magic:** schema, retention, encryption, restore time, and restore tests matter.

---

# 8. Resilience, overload, and performance

- **[Distributed] Timeout every network call:** no unbounded waits.
- **[Distributed] Timeout includes all phases:** DNS, connect, TLS, request, response, and pool acquisition.
- **[Distributed] Retry only transient failures:** persistent failures need fail-fast, fallback, or repair.
- **[Distributed] Exponential backoff + jitter:** avoid synchronized retry storms.
- **[Distributed] One layer owns retries:** retries at every layer multiply load.
- **[Distributed] Retry budget/token bucket:** cap retry traffic so recovery attempts do not become the outage.
- **[Distributed] Circuit breaker:** stop calling a dependency that is failing or overloaded.
- **[Distributed] Bulkhead:** isolate dependency/tenant/workload resources so one failure does not consume all capacity.
- **[Scale] Admission control:** reject before expensive work when the system is saturated.
- **[Scale] Load shedding:** serve errors or drop low-priority work before collapse.
- **[Scale] Rate limit per tenant/user/key:** global limits do not prevent noisy neighbors.
- **[Scale] Backpressure:** tell producers to slow down instead of only buffering.
- **[Scale] Graceful degradation:** serve stale/reduced/partial results for non-critical paths.
- **[Scale] Fallbacks must be safe:** stale data can be okay for catalog pages, dangerous for permissions or money.
- **[Distributed] Fail fast for optional dependencies:** do not block checkout because recommendations are down.
- **[Scale] Autoscaling is not overload protection:** scaling lags; admission control works immediately.
- **[Scale] Cell-based architecture:** isolate groups of tenants/resources so failures stay inside a cell.
- **[Scale] Shuffle sharding:** assign tenants to small overlapping backend subsets to reduce correlated impact.
- **[Distributed] Static stability:** service should survive control-plane/config/dependency outage using cached last-known-good state.
- **[Distributed] Avoid correlated failure triggers:** randomize cron, retries, TTLs, and rollout waves.
- **[Conditional: idempotent reads] Hedged requests:** race duplicate reads only when safe and capped.
- **[Scale] Measure tail latency:** p95/p99 matter more than averages for user experience.
- **[Scale] Capacity test past expected load:** learn the failure mode before production does.
- **[Scale] Test overload behavior:** verify shedding, throttling, retry caps, and degraded modes.
- **[Ops] Monitor saturation:** CPU, memory, DB connections, queue age, thread pools, retry rate, shed rate.
- **[Ops] Health checks should avoid mass false positives:** do not evict an entire fleet because a shared dependency is down.
- **[Ops] Graceful shutdown:** stop accepting, finish or release leases, flush telemetry, close cleanly.
- **[Ops] Fast startup:** recovery and scaling depend on startup time.
- **[Distributed] Prefer fewer synchronous hops:** each hop adds latency, failure probability, and operational coupling.

---

# 9. Workers, schedulers, and controllers

- **[Distributed] Workers are stateless:** durable state lives in DB, queue, log, or workflow history.
- **[Distributed] Durable job claim:** `QUEUED -> RUNNING` with CAS, worker ID, lease expiry, and attempt number.
- **[Distributed] Requeue expired work:** if `RUNNING` lease expires, another worker can safely retry.
- **[Distributed] Work item state machine:** `QUEUED`, `RUNNING`, `SUCCEEDED`, `FAILED`, `RETRY_WAIT`, `CANCELLED`.
- **[Distributed] Attempt counter:** record attempts to control retries and diagnose poison work.
- **[Distributed] Not-before timestamp:** schedule delayed retries without sleeping a worker.
- **[Distributed] Cron overlap protection:** cron handlers must be idempotent and guarded by lease/CAS.
- **[Scale] Shard scans:** never have every worker scan the whole table forever.
- **[Data] Long scans need checkpoints:** store cursor/progress so backfills resume.
- **[Distributed] Controller reconcile loop:** compare desired vs actual state and move actual toward desired.
- **[Distributed] Reconcile is level-triggered:** repeated reconcile should be safe even if no event arrives.
- **[Workflow] Finalizer:** block deletion while cleanup can be retried safely.
- **[Ops] Finalizers need an escape hatch:** broken/deleted controllers can leave resources stuck.
- **[Distributed] Manual edits need ownership rules:** controller-owned fields may be overwritten; unmanaged fields should be explicit.
- **[Distributed] Leader election is high blast radius:** prefer partitioned ownership if possible.
- **[Distributed] Leader election still needs fencing:** old leaders can be paused and resume.
- **[Ops] Supervisor restarts are not correctness:** restarted code must still be idempotent and resumable.

---

# 10. Security and abuse resistance

- **[Security] Deny by default:** access is blocked unless explicitly allowed.
- **[Security] Least privilege:** users, services, jobs, and CI tokens get only permissions needed.
- **[Security] Authenticate and authorize every request:** internal traffic is not automatically trusted.
- **[Security] Object-level authorization:** check ownership/permission for the specific resource, not just the route.
- **[Security] Authn is not authz:** knowing identity is separate from allowing action.
- **[Security] Never rely on network location:** "inside VPC" is not authorization.
- **[Security] Complete mediation:** every access path enforces the policy.
- **[Security] Validate and normalize input at boundaries:** reject invalid shape, size, encoding, and type early.
- **[Security] Parameterized queries:** never build SQL by concatenating untrusted input.
- **[Security] Secrets never live in source code:** use a secrets manager or equivalent runtime injection.
- **[Security] Rotate secrets:** stolen credentials should have a bounded useful lifetime.
- **[Security] Prefer short-lived credentials:** dynamic tokens beat long-lived static keys.
- **[Security] Scope secrets by environment and service:** dev should not open prod.
- **[Security] Audit secret access:** know who/what read sensitive credentials.
- **[Security] TLS for credentials and sensitive data:** protect in transit.
- **[Security] mTLS for privileged service-to-service paths:** use when service identity matters strongly.
- **[Security] Passwords are hashed, not encrypted:** use password hashing algorithms, salts, and work factors.
- **[Security] Encrypt sensitive data at rest:** especially backups, object stores, and replicated exports.
- **[Security] Minimize PII:** do not collect or retain data without purpose.
- **[Security] Logs must not leak secrets:** redact tokens, passwords, API keys, cookies, and sensitive PII.
- **[Security] Log security events:** auth failures, permission denials, admin actions, suspicious validation failures.
- **[Security] Rate-limit sensitive endpoints:** login, signup, OTP, password reset, token exchange, search, export.
- **[Security] Signed webhooks:** verify signature, timestamp/replay window, and event source.
- **[Security] Break-glass access is audited:** emergency admin paths need approval, reason, and post-review.
- **[Security] CI/CD identities are production identities:** least privilege and deny-by-default apply to pipelines too.
- **[Security] Immutable build artifacts:** build once, promote the same artifact, and record provenance.
- **[Security] Dependency pinning and scanning:** supply chain risk is production risk.

---

# 11. Observability, SLOs, and operations

- **[Ops] Define SLIs from user-visible behavior:** availability, latency, correctness, freshness, durability.
- **[Ops] SLO before alert:** decide acceptable user pain before paging humans.
- **[Ops] Alert on symptoms:** page on user impact, not every internal cause.
- **[Ops] Every alert has an owner and runbook:** unactionable alerts become noise.
- **[Ops] Error budget guides risk:** if reliability budget is burned, slow risky releases.
- **[Ops] Golden signals:** latency, traffic, errors, saturation.
- **[Ops] Structured logs:** stable fields beat free-text archaeology.
- **[Ops] Correlation ID everywhere:** API request, job, message, workflow, log, metric exemplar, trace.
- **[Ops] Propagate trace context:** HTTP, RPC, and async messages should preserve request lineage.
- **[Ops] Logs, metrics, and traces share naming:** common semantic fields make debugging faster.
- **[Ops] Instrument all boundaries:** inbound requests, outbound calls, DB, cache, queue, external providers.
- **[Ops] Log state transitions:** include entity, old state, new state, actor, reason, request ID.
- **[Ops] Business metrics are first-class:** orders stuck, payments pending, jobs aging, reconciliation mismatches.
- **[Ops] Bound metric cardinality:** unbounded user IDs/order IDs as labels can break metrics systems.
- **[Ops] Sample traces but keep errors/slow paths:** sampling must not hide rare failures.
- **[Ops] Dashboards should answer "what changed?"** deploys, flags, config, traffic, dependency health.
- **[Ops] Postmortems are blameless and specific:** focus on mechanisms, not people.
- **[Ops] Incident actions become tests/alerts/runbooks:** learning loop must change the system.
- **[Ops] Backups are unproven until restored:** regularly test restore time and data integrity.
- **[Ops] Reconciliation dashboards:** track expected vs actual for critical external integrations.
- **[Ops] Separate audit logs from debug logs:** audit logs need integrity, retention, and access control.
- **[Ops] Retention policy per telemetry class:** debug, audit, security, billing, and PII logs differ.
- **[Ops] Load-test telemetry volume:** logging/metrics/tracing can become the bottleneck during incidents.
- **[Ops] Run chaos/failure injection with small blast radius:** verify assumptions before real outages.

---

# 12. Deployment, migration, and evolution

- **[Ops] Small frequent deploys:** smaller diff means easier rollback and RCA.
- **[Ops] Canary/one-box first:** expose new code to a small slice before global rollout.
- **[Ops] Roll out in waves:** avoid correlated fleet-wide failure.
- **[Ops] Automated rollback on clear symptoms:** rollback should not wait for a meeting.
- **[Ops] Feature flag risky behavior:** deploy code separately from releasing behavior.
- **[Ops] Kill switch:** expensive or unsafe features need a fast off path.
- **[Ops] Remove stale flags:** old flags become hidden complexity.
- **[Ops] Backward-compatible rollout:** old and new code must coexist during deploy.
- **[Data] Expand-migrate-contract:** add new shape, migrate/backfill, switch reads/writes, then remove old shape.
- **[Data] Never rename/drop in the same release:** old code may still reference old fields.
- **[Data] Backfill idempotently:** each row/batch can be safely retried.
- **[Data] Throttle migrations:** production migrations must respect live workload.
- **[Data] Migration pause/resume/abort:** long migrations need operational controls.
- **[Ops] Shadow traffic/reads:** compare new path with old before serving users.
- **[Ops] Dark launch:** exercise load without changing user-visible behavior.
- **[API] Contract tests:** producers and consumers should verify compatible expectations.
- **[API] Version schemas/messages:** consumers tolerate extra fields and missing optional fields.
- **[Ops] Rollback and roll-forward plan:** some data migrations cannot be simply rolled back.
- **[Ops] Branch by abstraction:** route callers through an abstraction, replace internals gradually.
- **[Ops] Strangler fig:** incrementally replace legacy by moving traffic/functionality around it.
- **[Ops] Hermetic builds:** build should not depend on undeclared machine state.
- **[Ops] Immutable artifacts:** build once, promote through environments.
- **[Ops] Separate build, release, run:** code artifact, config, and running process are distinct.
- **[Ops] Config outside code, validated at startup:** environment differs; invalid config should fail early.
- **[Ops] Keep environment parity:** dev/staging/prod should differ less than you think.
- **[Ops] Graceful deprecation window:** public contracts need notice, metrics, and removal dates.

---

# 13. Multi-tenancy, cost, and fairness

- **[Scale] Tenant quota at ingress:** reject or queue before shared resources are consumed.
- **[Scale] Fair queueing:** one tenant should not starve others.
- **[Scale] Noisy-neighbor isolation:** isolate pools, shards, queues, or cells by tenant class.
- **[Scale] Per-tenant metrics:** you cannot enforce fairness if you cannot see usage.
- **[Scale] Internal rate limits:** protect downstream services, not just public APIs.
- **[Scale] Limit fan-out:** one request spawning thousands of calls needs caps and budgets.
- **[Scale] Collapse duplicate work:** coalesce identical concurrent requests/jobs.
- **[Scale] Degrade low-priority work first:** analytics, recommendations, exports, and backfills lose before checkout/auth.
- **[Scale] Cost budgets are guardrails:** expensive loops, queries, and jobs need hard limits.
- **[Scale] Tag resource ownership:** every cloud resource/job/table/export should have owner and purpose.
- **[Scale] Hot/cold data separation:** keep hot paths small and fast; archive cold data cheaply.
- **[Scale] Pagination and bounds on expensive operations:** every list/export/search must have limits.
- **[Scale] Async for expensive long work:** return a job/operation and process with controlled concurrency.
- **[Scale] Billable actions ledger:** billing must be append-only, auditable, and reconcilable.
- **[Scale] Per-tenant deletion/retention:** multi-tenant systems need tenant-level data lifecycle controls.

---

# 14. Anti-rules: avoid these defaults

- **[Any] Do not use microservices when one transaction/one team/one deploy fits:** modular monolith first.
- **[Data] Do not use event sourcing for simple CRUD:** use it for audit/replay/time-travel/domain event needs.
- **[Distributed] Do not trust distributed locks without fencing:** old workers can still write.
- **[Workflow] Do not use sagas when one transaction works:** sagas add partial failure and compensation complexity.
- **[Async/Event] Do not require global event order unless truly necessary:** it is costly and fragile.
- **[Data] Do not make cache source of truth:** persistence belongs elsewhere.
- **[Distributed] Do not use retries to hide persistent failures:** they amplify load.
- **[Distributed] Do not put circuit breakers around fast local code:** use them for remote/fragile dependencies.
- **[Async/Event] Do not use a queue to hide overload:** it turns failure into latency unless bounded.
- **[Distributed] Do not use last-write-wins for critical data:** conflicts must be explicit for money/inventory/permissions.
- **[Data] Do not soft-delete when legal hard deletion is required:** retention policy wins.
- **[Ops] Do not leave feature flags forever:** stale flags create untested combinations.
- **[Security] Do not model auth as `is_admin`:** use explicit permissions/scopes/policies.
- **[Distributed] Do not build your own consensus, crypto, queue, or lock service casually:** use proven primitives.
- **[Ops] Do not page on non-actionable alerts:** alerts without action train people to ignore alerts.

---

# Brief examples

## Payment retry

Use idempotency key `customer_id + cart_id + payment_attempt`. Store the provider charge ID and final response. If the client times out, it retries with the same key. If your service timed out after sending the charge request, query the provider before sending another charge.

Rules used: idempotency key, stored idempotency result, provider idempotency, unknown outcome reconciliation, immutable ledger.

## Worker lease with fencing

A worker claims a job by `UPDATE jobs SET state='RUNNING', worker_id=?, lease_until=?, fencing_token=fencing_token+1 WHERE id=? AND state='QUEUED'`. Every later write includes the token. If the worker pauses and another worker takes over, stale writes with the old token are rejected.

Rules used: lease, CAS transition, fencing token, heartbeat, requeue expired work.

## Outbox event publish

Inside the order transaction, update `orders.status='PAID'` and insert `outbox(OrderPaid, order_id, event_id)`. A relay later publishes the outbox row. If the relay crashes after publish but before marking sent, it may publish again, so consumers dedupe by `event_id`.

Rules used: outbox, idempotent consumer, at-least-once assumption, event envelope.

## Saga with compensation

Trip booking: reserve flight, reserve hotel, charge card. If hotel reservation fails after flight succeeds, cancel flight. If charge fails after both succeeded, cancel both reservations. Each cancel operation is idempotent.

Rules used: saga, compensation, reservation, step timeout, durable progress.

## Webhook handling

On Stripe/GitHub/provider webhook: verify signature and timestamp, insert `event_id` into a unique table, enqueue processing, return 2xx quickly. Processor fetches current provider object if event order matters.

Rules used: signed webhooks, dedupe, return fast, out-of-order handling, reconciliation.

## Reconciliation loop

Every 10 minutes, compare local `payments` in `PENDING` with provider status. Mark succeeded/failed, enqueue refunds if needed, and alert if pending age exceeds SLO.

Rules used: reconciliation loop, external source of truth check, queue age/SLO, data repair.

## API state transition

Instead of `PATCH /invoice {state: PAID}`, expose `POST /invoices/{id}:markPaid`. Server accepts only `SENT -> PAID`, rejects `CANCELLED -> PAID`, and records actor/reason.

Rules used: state machine, transition method, precondition error, audit trail.

## Expand-migrate-contract

To rename `users.name` to `users.full_name`: add `full_name`, write both, backfill, read from new field, stop writing old, wait until old code is gone, drop old field.

Rules used: backward-compatible rollout, expand-migrate-contract, resumable backfill.

## Cache stampede

For a hot product page, use TTL with jitter and singleflight so only one request recomputes a missing key while others wait or get stale data.

Rules used: cache not source of truth, jittered TTL, request coalescing, graceful stale fallback.

## Kubernetes-style controller

Desired state says "3 replicas". Actual state has "2 running". Controller reconciliation creates 1 more. If a watch event is missed, the next periodic reconcile still fixes it.

Rules used: desired vs actual, level-triggered reconcile, idempotent controller.

## Finalizer cleanup

A database resource enters `DELETING`. The controller deletes cloud backup/snapshot resources, then removes the finalizer. If cleanup fails, the resource remains visible and cleanup retries.

Rules used: finalizer, cleanup state, retryable deletion, escape hatch.

## Retry storm prevention

A service calls a dependency with timeout, 2 retries, exponential backoff, jitter, and retry token bucket. Only the top-level client retries; lower layers do not.

Rules used: timeout, one retry layer, backoff+jitter, retry budget.

## Circuit breaker + bulkhead

Recommendation service is slow. Checkout has a separate connection/thread pool for recommendations and a circuit breaker. Checkout skips recommendations instead of exhausting its own capacity.

Rules used: bulkhead, circuit breaker, optional dependency fail-fast, graceful degradation.

## Observability for an order

`request_id`, `trace_id`, `order_id`, `customer_id_hash`, and `event_id` appear in API logs, queue messages, worker logs, traces, and state transition audit rows.

Rules used: correlation ID, trace context, structured logs, state transition logging.

## Security object authorization

`GET /users/{id}/invoices/{invoice_id}` checks both that the user is authenticated and that the specific invoice belongs to that account or permission scope. Guessing IDs does not bypass access.

Rules used: authn vs authz, object-level authorization, public IDs are not secrets, deny by default.

## Ledger balance

Instead of updating `wallet.balance` directly, append `credit/debit` rows with unique external reference IDs. Balance is computed or materialized from entries and reconciled regularly.

Rules used: immutable ledger, unique dedupe, derived total reconciliation, audit.

## Offline collaborative field

For a shared note edited offline by multiple clients, use a CRDT designed for text/list merging. For a bank balance, do not use CRDT merge; require serialized authoritative writes.

Rules used: CRDT when merge semantics fit, no last-write-wins for critical data.

---

# Source map

These are the main sources used to compile and cross-check the rules. Forums and informal posts were used only as supporting signal; durable rules were grounded in primary docs, papers, or established architecture catalogs.

## Architecture and cloud pattern catalogs

- Microsoft Azure Architecture Center, Cloud Design Patterns: https://learn.microsoft.com/azure/architecture/patterns/
- Azure Anti-Corruption Layer pattern: https://learn.microsoft.com/azure/architecture/patterns/anti-corruption-layer
- Azure Bulkhead pattern: https://learn.microsoft.com/azure/architecture/patterns/bulkhead
- Azure Circuit Breaker pattern: https://learn.microsoft.com/azure/architecture/patterns/circuit-breaker
- Azure Retry pattern: https://learn.microsoft.com/azure/architecture/patterns/retry
- Azure Queue-Based Load Leveling pattern: https://learn.microsoft.com/azure/architecture/patterns/queue-based-load-leveling
- Azure Compensating Transaction pattern: https://learn.microsoft.com/azure/architecture/patterns/compensating-transaction
- Azure Saga / Choreography patterns: https://learn.microsoft.com/azure/architecture/patterns/saga and https://learn.microsoft.com/azure/architecture/patterns/choreography
- Azure Event Sourcing pattern: https://learn.microsoft.com/azure/architecture/patterns/event-sourcing
- Azure Sharding pattern: https://learn.microsoft.com/azure/architecture/patterns/sharding
- Azure Gatekeeper / Valet Key / Async Request-Reply patterns: https://learn.microsoft.com/azure/architecture/patterns/

## AWS Builders' Library and AWS architecture

- Making retries safe with idempotent APIs: https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/
- Timeouts, retries, and backoff with jitter: https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/
- Using load shedding to avoid overload: https://aws.amazon.com/builders-library/using-load-shedding-to-avoid-overload/
- Avoiding overload in distributed systems by putting the smaller service in control: https://aws.amazon.com/builders-library/avoiding-overload-in-distributed-systems-by-putting-the-smaller-service-in-control/
- Using dependency isolation to contain failures: https://aws.amazon.com/builders-library/using-dependency-isolation-to-contain-failures/
- Implementing health checks: https://aws.amazon.com/builders-library/implementing-health-checks/
- Automating safe, hands-off deployments: https://aws.amazon.com/builders-library/automating-safe-hands-off-deployments/
- Workload isolation using shuffle-sharding: https://aws.amazon.com/builders-library/workload-isolation-using-shuffle-sharding/
- AWS Well-Architected Reliability / fault isolation: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
- AWS Architecture Blog, Shuffle Sharding: https://aws.amazon.com/blogs/architecture/shuffle-sharding-massive-and-magical-fault-isolation/

## Google SRE and Google API design

- Google SRE Book, Service Level Objectives: https://sre.google/sre-book/service-level-objectives/
- Google SRE Book, Handling Overload: https://sre.google/sre-book/handling-overload/
- Google SRE Book, Addressing Cascading Failures: https://sre.google/sre-book/addressing-cascading-failures/
- Google SRE Book, Monitoring Distributed Systems: https://sre.google/sre-book/monitoring-distributed-systems/
- Google SRE Book, Postmortem Culture: https://sre.google/sre-book/postmortem-culture/
- Google SRE Workbook, Canarying Releases: https://sre.google/workbook/canarying-releases/
- Google Cloud API Design Guide: https://cloud.google.com/apis/design
- Google AIP-155 Request identification: https://google.aip.dev/155
- Google AIP-158 Pagination: https://google.aip.dev/158
- Google AIP-154 Resource freshness validation: https://google.aip.dev/154
- Google AIP-164 Soft delete: https://google.aip.dev/164
- Google AIP-216 States: https://google.aip.dev/216

## Integration, microservices, and events

- Enterprise Integration Patterns: https://www.enterpriseintegrationpatterns.com/
- EIP Idempotent Receiver: https://www.enterpriseintegrationpatterns.com/patterns/messaging/IdempotentReceiver.html
- EIP Dead Letter Channel: https://www.enterpriseintegrationpatterns.com/patterns/messaging/DeadLetterChannel.html
- EIP Invalid Message Channel: https://www.enterpriseintegrationpatterns.com/patterns/messaging/InvalidMessageChannel.html
- EIP Competing Consumers: https://www.enterpriseintegrationpatterns.com/patterns/messaging/CompetingConsumers.html
- EIP Guaranteed Delivery: https://www.enterpriseintegrationpatterns.com/patterns/messaging/GuaranteedMessaging.html
- EIP Claim Check: https://www.enterpriseintegrationpatterns.com/patterns/messaging/StoreInLibrary.html
- microservices.io Transactional Outbox: https://microservices.io/patterns/data/transactional-outbox.html
- microservices.io Idempotent Consumer: https://microservices.io/patterns/communication-style/idempotent-consumer.html
- microservices.io Saga: https://microservices.io/patterns/data/saga.html
- microservices.io Database per Service: https://microservices.io/patterns/data/database-per-service.html
- microservices.io Shared Database: https://microservices.io/patterns/data/shared-database.html
- Martin Fowler, Event Sourcing: https://martinfowler.com/eaaDev/EventSourcing.html
- Martin Fowler, CQRS: https://martinfowler.com/bliki/CQRS.html
- Martin Fowler, Feature Toggles: https://martinfowler.com/articles/feature-toggles.html
- Martin Fowler, Parallel Change / Expand-Contract: https://martinfowler.com/bliki/ParallelChange.html
- Strangler Fig pattern: https://martinfowler.com/bliki/StranglerFigApplication.html

## Distributed systems papers and reliability case studies

- Martin Kleppmann, How to do distributed locking: https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html
- Chubby lock service paper: https://research.google/pubs/the-chubby-lock-service-for-loosely-coupled-distributed-systems/
- Raft paper: https://raft.github.io/raft.pdf
- Pat Helland, Life Beyond Distributed Transactions: https://queue.acm.org/detail.cfm?id=3025012
- Dynamo: Amazon's Highly Available Key-value Store: https://www.amazon.science/publications/dynamo-amazons-highly-available-key-value-store
- Spanner paper / TrueTime: https://research.google/pubs/spanner-googles-globally-distributed-database/
- Lamport, Time, Clocks, and the Ordering of Events: https://lamport.azurewebsites.net/pubs/time-clocks.pdf
- CRDT paper, Shapiro et al.: https://hal.inria.fr/inria-00609399/document
- Jepsen analyses: https://jepsen.io/analyses
- Fallacies of Distributed Computing: https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing and Peter Deutsch discussions

## Workflows, controllers, and operations

- Kubernetes Controllers: https://kubernetes.io/docs/concepts/architecture/controller/
- Kubernetes Finalizers: https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/
- Kubernetes blog, Using Finalizers to Control Deletion: https://kubernetes.io/blog/2021/05/14/using-finalizers-to-control-deletion/
- Temporal Durable Execution docs: https://docs.temporal.io/temporal
- Temporal Activity idempotency docs: https://docs.temporal.io/activity-definition
- Temporal Event History docs: https://docs.temporal.io/workflow-execution/event
- Temporal Saga pattern article: https://temporal.io/blog/saga-pattern-made-easy

## APIs, idempotency, webhooks, and schema evolution

- Stripe Idempotent Requests: https://docs.stripe.com/api/idempotent_requests
- Stripe Webhooks: https://docs.stripe.com/webhooks
- Stripe undelivered webhook event processing: https://docs.stripe.com/webhooks/process-undelivered-events
- Confluent Schema Evolution and Compatibility: https://docs.confluent.io/platform/current/schema-registry/fundamentals/schema-evolution.html
- W3C Trace Context: https://www.w3.org/TR/trace-context/
- OpenTelemetry docs: https://opentelemetry.io/docs/
- Google Cloud Trace Context: https://cloud.google.com/trace/docs/trace-context

## Security and application architecture

- OWASP Authorization Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html
- OWASP Access Control / Broken Access Control: https://owasp.org/Top10/A01_2021-Broken_Access_Control/
- OWASP Secrets Management Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html
- OWASP Logging Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html
- OWASP REST Security Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html
- OWASP Zero Trust Architecture Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Zero_Trust_Architecture_Cheat_Sheet.html
- NIST SP 800-207 Zero Trust Architecture: https://doi.org/10.6028/NIST.SP.800-207
- The Twelve-Factor App: https://12factor.net/

## Migration and production evolution

- PlanetScale, Backward compatible database changes: https://planetscale.com/blog/backward-compatible-databases-changes
- Prisma Data Guide, Expand and Contract Pattern: https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern
- GitHub gh-ost: https://github.com/github/gh-ost
- GitHub blog, gh-ost online schema migrations: https://github.blog/news-insights/company-news/gh-ost-githubs-online-migration-tool-for-mysql/
- Branch by Abstraction: https://martinfowler.com/bliki/BranchByAbstraction.html

---

# Fast checklist before designing a new system

1. What is the consistency boundary?
2. What are the states and allowed transitions?
3. What can be retried, duplicated, reordered, or partially completed?
4. What is the idempotency key for every unsafe operation?
5. What side effects happen outside the DB transaction?
6. How are missed events/webhooks reconciled?
7. What happens if a worker crashes halfway?
8. What happens if the dependency is slow, down, or returns after timeout?
9. What is the queue age/backlog failure mode?
10. What is the blast radius by tenant, shard, region, and dependency?
11. What data is source of truth vs derived/cache?
12. What is the migration path with old and new code running together?
13. What must be authorized at object level?
14. What logs/metrics/traces prove the system is working?
15. What alert pages a human, and what action should they take?
16. What backup/restore/reconciliation proves data can be repaired?
17. What feature flag, kill switch, or rollback stops a bad release?
18. What is the simplest design that satisfies the invariants?
