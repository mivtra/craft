# ENGINEERING STANDARDS — WPF DESKTOP AND WEB

Tagged rules. Cite the tag; never restate. Rules apply to both platforms unless marked
**WPF:** or **Web:**. Web rules [ENG-W1]–[ENG-W8] close the file.

---

## DEFENSIVE PROGRAMMING & COMPLETENESS

**[ENG-1]** Validate every input at every system boundary — file contents, imported data, user entry, command-line arguments, database rows, network responses, registry/config values. External data is never trusted.
**[ENG-2]** Strict static typing everywhere. Nullable reference types enabled; no `dynamic` where a type exists.
**[ENG-3]** Assert invariants at critical checkpoints; fail loudly in Debug, degrade safely in Release.
**[ENG-4]** Every error is handled explicitly — no silent failure, no swallowed exception, no empty `catch`. A `catch` either recovers, translates, or rethrows, and always logs [ENG-21].
**[ENG-5]** Every resource is released on every path including failure — `using` / `try-finally` / `IDisposable` implemented where ownership exists.
**[ENG-6]** No stub, no placeholder, no commented-out code, and no `TODO` without a linked, concrete resolution plan. Anything that ships is finished — the update check included [PKG-24].

---

## CODE QUALITY

**[ENG-7]** One precisely defined responsibility per function, class, and module. Public interfaces enforce preconditions and postconditions.
**[ENG-8]** Abstractions are meaningful, stable, and non-speculative — an interface exists because two implementations or a test seam exist, not because it might be useful later.
**[ENG-9]** Naming is precise, unambiguous, and self-documenting. No clarity-reducing abbreviations.
**[ENG-10]** Minimize cyclomatic complexity — complex conditionals become named predicates or an explicit state machine.
**[ENG-11]** No magic numbers or strings. Constants named and centralized; UI text lives in localized resources [UI-30].
**[ENG-12]** XML DocComments on every public interface, class, and member — one line for simple, expanded for complex.
**[ENG-13]** `nameof` and `[CallerMemberName]` instead of string literals. No dead code — every line earns its place or is deleted.

---

## CONCURRENCY

**[ENG-14]** All shared state is protected by an appropriate synchronization primitive, chosen deliberately (`lock`, `SemaphoreSlim`, immutable snapshot, single-threaded dispatcher).
**[ENG-15]** Deadlock is impossible by construction, or proven safe by explicit lock-ordering analysis.
**[ENG-16]** Race conditions are eliminated by design, never by assumption or by "it hasn't happened yet".
**[ENG-17]** Async discipline: never block the UI thread (`.Result`, `.Wait` are defects); every async operation supports cancellation and carries an explicit timeout where it touches I/O; UI updates marshal through the dispatcher; long operations report progress [UI-35].
**[ENG-18]** Worker/pool sizing follows workload analysis, never an arbitrary default.

---

## PERFORMANCE & DESKTOP SCOPE

**[ENG-19]** WPF: this is a single-user local application. Web: a small multi-user app on one
shared host or plant PC — the same restraint applies. Server-scale machinery does not enter the product: no horizontal-scaling design, no distributed tracing, no metric dashboards, no service mesh concerns (web rate limiting and the updater's health check are security and safety controls, not scale machinery: [ENG-W11], [PRD-10]). Adding them violates YAGNI [CORE-4]. What replaces them: [ENG-20], [ENG-21].
Performance discipline that does apply:
1. Document the complexity of every critical algorithm and the memory profile of every major data structure.
2. Eliminate unnecessary allocations in hot paths (rendering, large imports, tight loops).
3. UI virtualization for any list or grid that can exceed a few hundred rows.
4. Every cache declares an explicit invalidation policy.
5. Database access: indexed queries, batched writes, no N+1 access in a loop.
6. Startup budget: window visible in under 1 second [UI-49]; heavy work happens after first paint.

---

## FAILURE HANDLING & OBSERVABILITY (DESKTOP)

**[ENG-20]** Design for failure. Every operation that can fail declares what happens when it does: recover | retry | roll back | inform the user. Destructive operations are confirmable and reversible where feasible. Data writes are atomic (write temp → flush → replace) so an interruption never leaves a half-written file or database. A global handler (`DispatcherUnhandledException`, `AppDomain.UnhandledException`, `TaskScheduler.UnobservedTaskException`) catches what escapes: logs the full detail, shows one localized, non-blaming message, and keeps the app alive when it safely can [0.5.7].
**[ENG-21]** Logging, self-contained:
1. Rolling file log — WPF `%AppData%\<AppNameLatin>\logs\`; web `storage/logs/` outside the public root, denied by the server — size-capped, oldest deleted, never in the install or public folder [PKG-16].
2. Levels: DEBUG (internal state) | INFO (operational) | WARN (recoverable) | ERROR (needs attention).
3. Each entry: UTC timestamp | level | component | operation | message | exception detail with stack | operation correlation id for multi-step work.
4. A log viewer reachable from Help → open the log folder or an in-app viewer window, so the user can send a diagnostic without hunting for files.
5. Startup logs version, runtime, OS, culture, and DPI — the first questions any support case asks.
6. Logs are sanitized [ENG-27]. No network telemetry is sent without an explicit, documented user opt-in.

---

## SECURITY — DESKTOP THREAT SURFACE

**[ENG-22]** Threat pass per component using STRIDE as a checklist, restricted to threats reachable in a local desktop context; classify every data element (public | internal | confidential | secret). Web/cloud-only threats are declared skipped, not silently ignored.
**[ENG-23]** Least privilege: the application never requires administrator rights to run. Elevation belongs to the installer alone. It writes only to `%AppData%` and user-chosen paths — never to its install folder [PKG-16].
**[ENG-24]** Confidential data at rest is protected: DPAPI (`ProtectedData`, CurrentUser scope) for credentials, tokens, and connection secrets; encrypted or access-restricted storage for sensitive records. Plaintext secrets in config, database, or source are defects.
**[ENG-25]** All SQL is parameterized. String-concatenated SQL is a defect regardless of the input's apparent source.
**[ENG-26]** Outbound network calls (update check, activation) use HTTPS with certificate validation intact, an explicit timeout, and graceful offline behavior with a localized message. Never disable certificate validation.
**[ENG-27]** Log sanitization: passwords, tokens, license keys, and personal data never reach a log line. Redact at the call site, not in a post-processing pass.
**[ENG-28]** Critical operations (delete, bulk edit, permission change, license activation, data export) produce an audit record: who | what | when | outcome — stored where the user cannot silently rewrite it.
**[ENG-29]** Output sanitization: exported CSV/Excel cells starting with `= + - @` are neutralized (formula injection); file names and paths built from user data are sanitized against traversal and invalid characters; imported HTML/XML is never rendered raw.

---

## TESTING

**[ENG-30]** Every product ships tests, every tier — .NET: an xUnit project (`<AppNameLatin>.Tests`); PHP: the repository's own runner under `tests/`.
1. Test cases are defined before the implementation of each unit.
2. Every failure mode from [P1.6] has a covering test.
3. ViewModels and services are tested; Views are not automated — UI is verified through the manual matrix in [P6.7].
4. Tests are deterministic: no real clock, no real file system where a temp path or fake will do, no network.
5. The whole suite runs green before any delivery claim; the result is reported as it is, failures included.
6. A defect the owner reports gets a test that fails without the fix [WF-8].

---

## PROJECT STRUCTURE

**[ENG-31]** **Every product is its own Git repository, laid out the same way — no product
deviates, at any tier.** The repository root *is* the product root. The parent folder differs
per computer (it differs from one computer to another) and is never written into any file;
the one requirement is that `Shared` sits beside every product, because each resolves
`$(SharedRoot)` as `..\Shared\`.

```
<parent>/
├── Shared/                      ONE repository beside the products
│   ├── Common.props  Publish.props  Installer.common.iss
│   ├── {Brand}.Licensing[.Wpf]/  licensing bound to {LicenseServer}
│   ├── {Brand}.Ui/               shared views, theme, theming
│   └── {Brand}.Updates/          signed update manifests
└── <AppNameLatin>/              one repository per product
    ├── .github/workflows/build.yml  .gitattributes  .gitignore
    ├── AGENTS.md  README.md     where everything goes; read before the first edit
    ├── Directory.Build.props    ProjectRoot + SharedRoot; fails loudly when Shared is missing
    ├── <AppNameLatin>.slnx
    ├── assets/                  source art
    ├── deployment/              installer/<App>.iss · publish/ (ignored) · packages/ (ignored)
    ├── docs/                    plans/ · CHANGELOG.md · ADR.md · EULA.txt · user/ · technical/
    ├── src/<AppNameLatin>/      App.xaml · app.manifest · Views/ ViewModels/ Models/ Services/
    │                            Helpers/ Lang/ Assets/ (App.ico, Fonts/) — no Themes/ copy [DS-1]
    ├── tests/<AppNameLatin>.Tests/
    └── tools/publish.ps1        publish, and -Installer to compile the setup
```

Web products keep the same root folders (`docs\plans\`, `tests\`, `tools\`) around their own
app layout (PHP: `app\ config\ lang\ public\ storage\`; ASP.NET: `src\<App>\` with `wwwroot\`).

Rules that follow from it:
1. `src\` holds source only — no build output, no publish output, no scripts, no documents.
   `bin\` and `obj\` are never created by hand and never committed.
2. **`Directory.Build.props` anchors both roots.** `ProjectRoot` keeps every published artifact
   inside the product's own repository; `SharedRoot` points at `..\Shared\` and is overridable
   with `-p:SharedRoot=<path>`. Never reach `Shared` by counting `..\` — one added folder level
   silently breaks every project that does.
3. **A missing `Shared` must fail with an explicit message, not silently.** Without that guard
   `restore` skips the Shared references with a single "not found" line, then compilation collapses
   into undefined-type errors that point nowhere near the cause.
4. Publish policy lives in `Shared\Publish.props` and is imported by one line per product. Never
   restate `RuntimeIdentifier`, `SelfContained`, `PublishReadyToRun` or `PublishDir` in a `.csproj`
   — a second source of truth drifts silently and ships an untested build.
5. `deployment\packages\` is append-only across releases; rollback means running the previous
   installer [P7.5]. Both `publish\` and `packages\` stay out of Git.
6. `tools\publish.ps1` is the one release path. Publish first, compile the installer second —
   never the reverse, or the installer packages the previous build.
7. Paths are relative — no absolute or personal path in any script or project file [PKG-23].
8. User data lives in `%AppData%\<AppNameLatin>`, never inside the repository [PKG-16].
9. **Empty folders that are part of the structure carry a `.gitkeep`** — Git does not track empty
   directories, so the layout otherwise arrives incomplete to whoever clones it.
10. On an existing repository with a different layout, do not restructure it unprompted [TRACK-B]
    — state the deviation in one line and offer migration as a suggestion.

**[ENG-31b]** Within the application project:
1. Folders: `Views/` `ViewModels/` `Models/` `Services/` `Lang/` `Assets/` `Helpers/`.
2. One public type per file; file name = type name.
3. File names short, precise, PascalCase, ideally ≤20 characters excluding the extension — `MainVM.cs`, not `MainWindowViewModelImplementation.cs`.
4. Size guidance is a **target, not a hard limit**: ~300 lines for C#, ~400 for XAML. The number triggers a review, not a split. Split only along a real responsibility seam (extract a service, a partial class, a reusable UserControl). A cohesive unit that exceeds the target stays whole with a one-line justification — mechanical splitting that scatters one responsibility across files is the worse defect.
5. Styles never inline — `Shared` theme keys only [UI-8], [DS-1].

---

## DOCUMENTATION

**[ENG-32]** ADR per architectural decision, one line: `[Decision] → [Reason] → [Rejected alternative]`.
**[ENG-33]** `CHANGELOG.md` per release: version | date | added / changed / fixed | user-visible impact [PKG-19]. Public API surfaces documented via XML DocComments [ENG-12].

---

## WEB

**[ENG-W1]** Every form posts with a CSRF token; every state change is POST; every output is
escaped at render (`e` / Razor encoding) — raw HTML from data is a defect.
**[ENG-W2]** Passwords hashed with the platform's password hasher (PHP `password_hash`, ASP.NET
`PasswordHasher`); login attempts throttled per account and IP; sessions regenerated on login,
`HttpOnly` + `SameSite=Lax` + `Secure` cookies.
**[ENG-W3]** Password reset by email: single-use, hashed, time-limited token (≤60 min); the
response never reveals whether an account exists [PRD-6].
**[ENG-W4]** Permissions checked on the server for every action and every row, never only by
hiding a button; a permission change applies on the next request, not the next login.
**[ENG-W5]** Config and secrets outside the public root; `storage/` (logs, backups, uploads)
denied by the web server and verified with a request that must return 403.
**[ENG-W6]** Migrations are versioned files run by a runner and recorded; never hand-edited SQL on
production. Quote identifiers that may be reserved words (`rank`, `order`) in generated SQL.
**[ENG-W7]** Server time and timezone are explicit settings; dates stored UTC or with zone.
**[ENG-W8]** Deploys: back up first, upload, verify every file by hash against the local tree,
delete one-shot helper scripts — and only with the owner's explicit approval [WF-6]. Once a
product has its updater, releases go only through it [PRD-10]; never patch live files by hand
while a channel release is in flight.
**[ENG-W9]** HTTPS everywhere: HTTP redirects to HTTPS, HSTS once the certificate is stable;
installed LAN products ship a certificate path in the manager. Mixed content is a defect.
**[ENG-W10]** Validate every input on the server — type, range, length, allowed values, ownership
— whatever the browser already checked. Client checks are comfort, never protection.
**[ENG-W11]** Rate limits on login, password reset, contact/mail-sending forms, uploads and any
API; a limit answers 429 with a localized message and is logged.
**[ENG-W12]** Security headers on every response: `Content-Security-Policy` (no inline script
where it can be avoided), `X-Content-Type-Options: nosniff`, `Referrer-Policy:
strict-origin-when-cross-origin`, `frame-ancestors 'none'` (or `X-Frame-Options: DENY`),
`Permissions-Policy` limited to what is used; server version headers removed.
**[ENG-W13]** CORS closed by default (same origin). An endpoint opened to another origin names
that origin exactly; never `*` with credentials.
**[ENG-W14]** Uploads: allow-list of extensions **and** MIME checked by content, size limit per
type, random stored name, stored outside the public root, served only through a permission check
with `Content-Disposition`; executable and script types refused.
**[ENG-W15]** Money and quantities are computed on the server from stored prices; a price, total,
discount or quantity posted by the client is never trusted.
**[ENG-W16]** Production runs without debug: PHP `display_errors=0` with errors logged;
ASP.NET `Production` environment; generic localized error pages that never show a stack, query
or path. The installer/setup route is removed or locked after first run.
**[ENG-W17]** Nothing sensitive is reachable by URL: `.git`, `.env`, config, `storage/`,
backups, dumps, logs, `composer.*`, `vendor` internals, installers, `phpinfo`, one-shot scripts.
Each is checked with a real request that must return 403/404.
**[ENG-W18]** Secrets: never in source, client code or Git; config files holding them are
git-ignored with a committed `*.example`; the DB account has only the rights the app needs and the
database port is not reachable from outside the host.
**[ENG-W19]** Dependencies: no unused package; known-vulnerable packages updated before release
(`composer audit`, `dotnet list package --vulnerable`, `npm audit` where used).
**[ENG-W20]** Leaked secret = rotate it: on a key found in history or a public place, revoke and
replace it, then purge it from history. **Exception: the update existing update signing key** — never rotated
or replaced by Claude; report to the owner immediately, because installed clients trust only it.
