# UI structure — tags `[UI-n]`

Structure only: which surfaces exist, which menus and bars they carry, how language and
accessibility are wired. Visual values come from Design SKILL.md and the platform file. Tag numbers
are frozen — code in the product repositories cites them. "WPF:" / "Web:" mark platform-only lines.

## Surface and stack

**[UI-1]** Minimum surface, every product, every tier: main screen + Settings + About [DS-11] +
confirmation dialogs + the domain screens from [0.4] + login when the product has users
[DS-15]. Settings tabs: [PRD-5].
**[UI-2]** WPF: C# on .NET latest LTS. Web: the stack fixed by the repository (PHP 8 no
framework, or ASP.NET Core Razor) — never switched unprompted.
**[UI-3]** Strict separation: no business logic in code-behind (WPF: MVVM) or in views (web:
controllers + services, views only render).
**[UI-4]** Views are binding/template driven and readable.

## Theme — delegated

**[UI-5]** Visual language → Design [DS-0]. **[UI-6]** Every color in a view is a token; a literal
is a defect. **[UI-7]** WPF entry point `AppTheme.xaml` from `Shared`; web entry point
`tokens.css` then `app.css` — never more theme files. **[UI-8]** Styles never inline (WPF:
`Themes`/`Shared` dictionaries; web: `app.css` classes, no `style=""`). **[UI-9]** Two themes,
light and dark, user-chosen [DS-7]; no OS-theme detection; WPF High Contrast overrides both.
**[UI-10]**–**[UI-12]** Palette, sizing tokens and patterns → Design.

## Typography

**[UI-13]** Font applied globally from tokens, never per control. **[UI-14]** Cairo embedded
(WPF `Resource`, web self-hosted woff2), license SIL OFL. **[UI-15]** No font-size setting:
system scaling (WPF `PerMonitorV2`, browser zoom) is the accessibility path; a per-app slider
scales text without the grid and clips. **[UI-16]** Equal space above and below a text block.
**[UI-17]** Content direction → [DS-12].

## Layout

**[UI-18]** ≥16px inner margin on all sides. **[UI-19]** Spacing from named tokens only.
**[UI-20]** Fluid layouts, no fixed-pixel primary containers. **[UI-21]** No vertical scrollbar
on fixed-content windows/dialogs; scroll only for unbounded content (tables, logs), declared in
the [0.5] blueprint. Web pages scroll vertically as documents; dialogs do not. A WPF side
sheet is as tall as the window: its body may scroll, its header and footer never do [DS-17]. **[UI-22]**
Worst case: WPF 1366×768 at 150% Arabic; web 360px Arabic [DS-14]. **[UI-23]** No horizontal
scroll on a window or page; only inside a wide table wrapper on desktop.

## Chrome

**[UI-24]** WPF main windows keep native chrome (`SingleBorderWindow`). Dialogs are in-window
sheets and cards, not windows [DS-17]; only a window shown before the main window exists
(first-run wizard, login) uses `DialogWindowStyle`. Never custom caption buttons. **[UI-25]** Every window/page: localized title
· app icon · WPF explicit `MinWidth`/`MinHeight`. **[UI-26]** Dialogs: modal inside the main window
over a dimmed layer (WPF: side sheet from the end edge for forms, centered card for confirm,
alert, About [DS-17]), Esc = cancel, Enter = primary; never `MessageBox.Show` / `alert`.

## Commands

**[UI-27]** Every [0.4] feature is reachable from the main navigation (WPF top menu or sidebar;
web sidebar) **and** from a context entry (right-click / row action / kebab menu). **[UI-28]** WPF
top menu File | Edit | View | Tools | Help (View: language, theme; Help: About, log folder, check
for updates); the menu bar always stays — top-bar icons never replace it, and
export/backup are not permanent top-bar icons (export: page header [DS-4.5]; backup: Settings). Web: sidebar groups + user menu (profile, language, theme, About, logout).
**[UI-29]** Menu items: localized, bound commands, shortcut text, disabled state from the model.

## Localization

**[UI-30]** Every user-visible string in `Lang/ar` + `Lang/en` (WPF `.xaml`, web `lang/*.php` or
`.resx`/`.json`) — messages, validation, tooltips, status, emails, PDFs included. **[UI-31]**
Language switches at run time on every open screen without restart, and persists. **[UI-32]**
Direction bound at window/`<html>` level from the language; verified per screen both ways.
**[UI-33]** Dates, numbers, currency, paths culture-correct in both languages; currency, tax and
geography are settings, never one market hard-coded. Number display per [DS-16] #9. Tax features
stay hidden until tax is enabled in Settings, and documents follow it: without tax an invoice
is titled «فاتورة نقدية / Cash invoice»; «فاتورة ضريبية / Tax invoice» appears only when tax is on.

## Context menus and status

**[UI-34]** Right-click (WPF) / row actions (web) on every element with actions; same command as
the menu entry. **[UI-35]** WPF status bar on every main window: state + last result at the
start; count · user · connection at the end; glyph + text, never a colored dot alone. Web: the
flash area and the pager count play this role.

## Controls

**[UI-36]**, **[UI-37]**, **[UI-37b]**, **[UI-38]**, **[UI-40]**, **[UI-42]** → Design grid and
styles. **[UI-39]** Fixed height ⇒ zero vertical padding; no inline padding on styled controls.
**[UI-41b]** Color = identity, state = shape [DS-0] #5. **[UI-41]** Tables → Design platform file.

## Branding

**[UI-43]** Original logo (WPF vector geometry, web inline SVG). **[UI-44]** WPF `App.ico` 16–256
on exe and every window; web favicon + apple-touch icon. **[UI-45]** One logo source reused in
login, sidebar, About. **[UI-46]** About → [DS-11].

## Accessibility

**[UI-47]** WCAG 2.1 AA in both themes. **[UI-48]** WPF `AutomationId` on interactive controls;
web labels/`aria-*` on every control. **[UI-49]** First paint < 1 s; heavy parts lazy-loaded.
**[UI-50]** Full keyboard path; visible focus; Esc closes, Enter confirms.
