# Security review and report — `[SEC]`

Read before a security review, before the first release of a sellable product, and in gate 6
[WF-11]. Rules are not restated: each line points at its rule and says how to **prove** it.

**[SEC-1] Scope.** Web products: every item. WPF: items marked `W` are replaced by the desktop
rules [ENG-22]–[ENG-29] and marked `⚠ لا ينطبق — WPF` in the report.

**[SEC-2] Checklist — 27 items, each tested, never assumed.**

| # | Control | Rule | Proof |
|---|---|---|---|
| 1 | Secure login, lockout, session regenerate | [ENG-W2], [PRD-6] | wrong password ×N → lockout; session id changes on login |
| 2 | API keys and secrets hidden | [ENG-W18], [ENG-24] | grep source, client JS, built output and config in Git |
| 3 | Database secured | [ENG-W18] | DB user rights listed; port not reachable from outside |
| 4 | HTTPS forced (W) | [ENG-W9] | `http://` request → 301 to `https://`; HSTS header present |
| 5 | Passwords hashed | [ENG-W2] | DB column holds bcrypt/PBKDF2 hashes, no plain text anywhere |
| 6 | Server-side validation | [ENG-W10], [ENG-1] | post invalid/oversized/foreign-id values directly → rejected |
| 7 | XSS | [ENG-W1], [ENG-W12] | `<script>` and `"><img onerror>` in every text field → shown as text; CSP present |
| 8 | Suspicious activity watched | [PRD-7], [ENG-W11] | failed logins, lockouts, permission and admin changes appear in the audit log |
| 9 | Admin pages locked | [ENG-W4], [ENG-W16] | admin URLs as a normal user and logged out → 403/redirect; setup route gone |
| 10 | Parameterized queries | [ENG-25] | grep for string-built SQL; `' OR 1=1 --` in search and ids |
| 11 | Environment / config reviewed | [ENG-W18], [ENG-W16] | production config: debug off, secrets present only there, `*.example` committed |
| 12 | Rate limiting (W) | [ENG-W11] | burst on login/reset/upload → 429 |
| 13 | CORS restricted (W) | [ENG-W13] | request with a foreign `Origin` → no `Access-Control-Allow-Origin` |
| 14 | Security headers (W) | [ENG-W12] | response headers listed against the rule |
| 15 | Secure cookies (W) | [ENG-W2] | `HttpOnly`, `Secure`, `SameSite` on every session/remember cookie |
| 16 | CSRF (W) | [ENG-W1] | POST without/with a stale token → 403/419 |
| 17 | Reset links expire | [ENG-W3] | reuse a used link and an expired link → refused |
| 18 | Upload type and size | [ENG-W14] | `.php`, renamed `.php.jpg`, oversized file → refused; stored file not reachable by URL |
| 19 | Prices and payments server-side | [ENG-W15] | tamper with price/total/quantity in the request → server value wins |
| 20 | Debug off in production | [ENG-W16] | force an error → generic page, no stack, path or SQL |
| 21 | Vulnerable libraries updated | [ENG-W19] | audit command output attached |
| 22 | Unused libraries removed | [ENG-W19] | dependency list vs actual use |
| 23 | No exposed files | [ENG-W17] | request each sensitive path → 403/404 |
| 24 | Git history scanned for keys | [ENG-W20] | `gitleaks detect` or `git log -p` search for key/token/password patterns |
| 25 | Exposed keys revoked and replaced | [ENG-W20] | each found key: revoked, replaced, purged — existing update signing key reported, not rotated |
| 26 | Full review | [ENG-22], [P5] | STRIDE pass per component, IDOR check on every object id |
| 27 | Protections tested, report given | [SEC-3] | this table filled from real runs |

**[SEC-3] Report — always this table, in Arabic, plus the commands that were run.**

`# | المشكلة | الخطورة (حرجة/عالية/متوسطة/منخفضة) | كيف حُلّت | نتيجة الاختبار`

1. One row per finding and one row per checklist item that passed (`لا مشكلة` + proof).
2. Severity by impact × reachability: data loss, takeover or code execution = حرجة.
3. "Fixed" requires a re-test after the fix; untestable here → `⚠ لم يُختبر — <السبب>` and the
   command to run [CORE-9].
4. Live systems are tested read-only unless the owner approves otherwise [WF-6]; attacks run
   against the local copy.
5. Every fixed finding gets a regression test in the suite [ENG-30].
6. The report is saved as `docs/security/YYYY-MM-DD-review.md` in the product repository.

**[SEC-4] Distribution risk (sellable products).** Shipping plain source to a customer lets
them disable licensing; state this risk in the report and the options the owner can choose
(encoding such as ionCube/SourceGuardian for PHP, obfuscation of the licensing assembly for
.NET [PKG-21], or hosting the product as a service).
