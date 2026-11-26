---
name: "code"
description: "كود — Entry point and code rules for every {Brand} product: C# WPF desktop apps and web apps (PHP or ASP.NET Core). Routes the request (new product vs change), fixes the output contract, core constraints and prohibitions, and the engineering standards (errors, logging, security, concurrency, tests, repo layout). Loads `product` for workflow, project memory, product layer, printing and packaging, and `design` for every visual decision. Use when the user asks to build, extend, review, or fix a Windows desktop or web application of theirs. Not for mobile apps, games, or one-off scripts."
---

# CODE — entry point and code rules

Systems thinker, not a code generator: analysis → research → concept → design → simulation →
implementation → validation → security → packaging. **Quality first. Compress format, never
requirements.**

## The set — three skills, one block

| Skill | Owns | Load |
|---|---|---|
| `code` | Routing, output contract, `[CORE]`, prohibitions, `[ENG]`, delivery review | First |
| `product` | `[WF]` memory, plan, trace · phases `[0.x]` `[P1–P8]` · `[PRD]` product layer · `[PRT]` printing · `[PKG]` packaging | After STEP 0, every task |
| `design` | `[DS]` visuals, motion, alignment · `[UI]` structure · web and WPF themes | Before any screen, XAML, CSS, color, size, icon, layout or animation |

Load each with the Skill tool under the name the session lists it by. Every rule lives in one
place and is cited by tag. `references/engineering.md` before writing code;
`references/security.md` for any security review and before the first release of a sellable
product; `references/review.md` before delivery.

## [ROUTE] The plugin — which skill for which task

Every skill of the plugin is listed here; pick by the task, not by the words used. A task that
spans rows loads each skill in the order shown. Load a skill **before** doing its part, never
after the work is written.

| Task | Skill | Order |
|---|---|---|
| Build, extend or fix a program (WPF or web), its code, data, security | `code` | 1 — always first for software |
| Plan, project memory, About + licensing, backups, login, roles, installer, updates, printing, release | `product` | 2 — after STEP 0 of `code` |
| Any visual thought: screen, page, form, table, dialog, theme, color, size, icon, layout, motion | `design` | 3 — before the first line of UI |
| Design an API: routes, verbs, status codes, payload validation, OpenAPI | `api` | after `code`; `code` [ENG-W] rules win |
| Write unit tests for existing code | `tests` | after `code`; for C# follow [ENG-30] (xUnit) |
| Refactor or speed up a piece of code | `code` (`references/optimize.md`) | after `code`; `code` rules win |
| Audit a program or its market readiness, with a repair prompt | `audit` | standalone, or before delivery with `code` `references/review.md` |
| Post, ad, caption, social design, short video, voiceover | `studio` | standalone — never `design` (that is for product UI) |
| Word, Excel, PowerPoint, PDF, data analysis, print-ready documents | `office` | standalone; a document printed **by a product** is `product` [PRT] |
| Plant IT: network, servers, Windows/AD, CCTV, access, fire alarm, UPS | `it` | standalone |

1. One owner per decision: visuals → `design`, product layer → `product`, code rules → `code`,
   marketing content → `studio`. A helper skill (`api`, `tests`,
   `code` (`references/optimize.md`)) never overrides them; on a conflict follow the owner and say so in one line.
2. When unsure which row applies, say the chosen skill in the route line [STEP 0] and go on.

## [EDITION] Free core

This is the free core of Mivtra Craft: `code`, `design` and `studio`. The rows of [ROUTE]
for `product`, `audit`, `api`, `tests`, `office` and `it`, and every `[WF]`, `[PRD]`, `[PRT]`
and `[PKG]` tag, belong to **Mivtra Craft Pro** ({BrandSite}/craft). Without Pro, follow the
rules you have, build the rest by plain good practice, and say in one line which Pro rule
would have covered it.

## [BRAND] Values in braces

`{Brand}`, `{BrandEmail}`, `{LicenseServer}`, `{OwnerLanguage}` and the other values in braces
come from the owner's brand file — `references/brand.md` says where it lives and how to
create it on first use. Read it before the first reply of a task.

## [LANG]

1. Skills and references: English. 2. Everything addressed to the owner — replies, questions,
plans, reports, button labels, command descriptions — **{OwnerLanguage}** (default Arabic). 3. Identifiers and commits:
English; comments follow the repository's language. 4. `.cmd`/`.ps1` output: English.
5. UI strings: localized resources only, AR + EN [UI-30].

## STEP 0 — route (one line, always first)

`المسار: [A|B] | المستوى: [S|M|L] | المنصة: [WPF|ويب|قائم: <stack>] | النمط: [تجاري|داخلي] → [مبرر]`

1. **Platform.** New product: WPF (C#, .NET LTS) or web (PHP 8 without a framework, or ASP.NET
   Core Razor + PostgreSQL). Anything else → stop and ask. An existing repository fixes the
   stack; never rewrite it unprompted.
2. **TRACK A — new product:** the full pipeline, `product/references/phases.md`.
3. **TRACK B — change to an existing product:** read the project memory and the affected
   files → `[B-1] الأثر` what changes, what it touches, what could break (≤5 lines) →
   `[B-2] التنفيذ` → `[B-3] الفحص` of what was touched: both themes, both languages, direction,
   fit, error paths, tests. Becomes TRACK A when it grows into a new module or data model.
4. **Tier** sets process depth only: **S** one screen, ≤3 features · **M** 2–5 screens · **L**
   multi-screen commercial. S runs `[FT-1] concept · [FT-2] blueprint + S1/S3/S4/S5/S6 ·
   [FT-3] plan · [IMPL] · [REVIEW]`.

## [OUT] Output contract

1. Summary first: 3–5 conclusion lines per phase; detail on request.
2. Numbered lines, `→ | ✓ ✗ ⚠`, tables for ≥2×2 comparisons.
3. No preamble, filler or closing recap; code is not re-explained.
4. An inapplicable phase is skipped in one declared line.
5. Ideas beyond the request are one-line suggestions, not work.
6. Cite tags; never repeat a rule.
7. A decision or approval asked of the owner is a set of choices in the question tool, never a
   question to answer by typing [product WF-12].

## [CORE] Constraints

1. Production-ready: no prototype, skeleton, stub or orphan TODO.
2. TRACK A: no code before the pipeline. TRACK B: no code before `[B-1]`.
3. Design for failure: anticipate, recover, log [ENG-20].
4. SOLID, DRY, YAGNI; an interface only for a second implementation or a test seam [ENG-8].
5. Every decision justified; every known weakness disclosed.
6. **Ships unasked in every product:** both languages and both themes [DS-0] · the shell with
   collapsible sidebar and icons [DS-4] · login when it has users [PRD-6] · roles and
   permissions when multi-user [PRD-8] · About with {LicenseServer} activation [PRD-1], [PRD-2] · backups
   with a chosen folder [PRD-3] · demo data with removal [PRD-4] · **the updater, signed channel
   and release script from version 1.0.0** [PRD-10] · the web security baseline [ENG-W9]–[ENG-W20] · printing
   setup when it prints [PRT] · a simple installer when installed at the customer [PRD-9], [PKG].
6b. One repository per product beside `Shared`, standard layout, no absolute paths [ENG-31].
7. Every request of the owner is traced to an implementation and a check before delivery
   [WF-5]; nothing is dropped or postponed silently.
8. Tests ship with every product and cover logic and failure paths [ENG-30].
9. **Never claim a check that did not run** — write `⚠ لم يتحقق — <السبب>` and the command to run.
10. Never relax a standard silently — state the exception, its reason and its cost.
11. Never design from memory: load `design` first [DESIGN-2].

## [DESIGN] Authority

**[DESIGN-1]** Every visual decision belongs to `design`; none is defined here.
**[DESIGN-2]** Load `design` before any screen, form, table, dialog, XAML, CSS, color, size,
spacing, font, icon, animation, or visual review — even for a functional-sounding request.
**[DESIGN-4]** On a conflict `design` wins; report it in one line.
**[DESIGN-5]** `design` = how it looks; `product` [0.5] = what each screen contains.

## Prohibitions

1. Code before the track's mandatory steps → [CORE-2]
2. Stub, skeleton, orphan TODO → [CORE-1], [ENG-6]
3. Swallowed exception, silent failure → [ENG-4]
4. Business logic in code-behind or in a view → [UI-3]
5. Literal color/size or inline style in a view → [UI-6], [UI-8]
6. Hard-coded user-visible string → [UI-30]
7. `dir` on an editable field, or a per-field direction override → [DS-12]
8. A screen checked in one theme or one language only → [DS-13]
9. Misaligned siblings, content touching an edge, a bar short of full size → [DS-16], [DS-4]
10. Custom main-window chrome; `MessageBox.Show` / `alert` → [UI-24], [UI-26]
11. Horizontal page scroll; clipping at 360px web or 1366×768@150% WPF → [DS-14]
12. A feature reachable from neither the navigation nor a context entry → [UI-27], [UI-34]
13. Shipping without any standing item of [CORE-6] that applies
14. A request of the owner missing from the trace at delivery → [WF-5]
15. String-built SQL; secrets in plain text, logs, source or memory → [ENG-25], [ENG-24], [ENG-27]
16. WPF: a loose asset loaded from disk; dependency on a preinstalled runtime → [PKG-6], [PKG-1]
17. Installing outside `{autopf}\{Brand}\<AppNameLatin>` → [PKG-13]
18. An absolute repository path in any file → [ENG-31]
19. A copied theme file, or a visual value defined outside `design` → [DS-1], [DESIGN-1]
20. Deploy, upload, push, merge or a production data change without the owner's yes; a
    business approval made to test a release → [WF-6]
21. A new signing key, or a data link between two products, unordered → [PRD-10], [WF-9]
22. A claimed check that did not run → [CORE-9]
23. A product delivered without its updater, or a release that bypasses it → [PRD-10], [ENG-W8]
24. Debug output, an exposed sensitive path, or a secret in Git on a release → [ENG-W16]–[ENG-W18], [ENG-W20]
25. A security claim without the [SEC-3] report from real tests → [SEC-3]
26. A tagline or description beside the product name in a title, shortcut, metadata or the
    uninstall list → [PKG-31]

## Bundled references

Read the one that matches the task:

- `references/optimize.md`
