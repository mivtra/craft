---
name: "design"
description: "Visual design authority for every {Brand} product — web (PHP / ASP.NET) and C# WPF. One identity modelled on the Craft web identity (`kit-web`): Cairo font, light AND dark themes, Arabic AND English with RTL/LTR, collapsible icon sidebar, the Craft login card, the compact About window, strict alignment, soft motion, strict responsive fit. Use for ANY screen, page, window, form, table, dialog, theme, XAML, CSS, color, size, icon, layout, animation or style work — even when the request sounds purely functional (\"add a suppliers screen\"). Part of the code · product · design set."
---

# Design — how every {Brand} product looks

`code` routes and owns code rules · `product` owns workflow, product layer, printing,
packaging · `design` owns every visual decision and wins on any visual value (report a conflict
in one line). Design never loads the other two.

**Never invent a value.** Not here and not in the live source → ask the owner.

| Read | When |
|---|---|
| `references/web.md` | Any web view, CSS or JS UI: tokens, components, motion, breakpoints, traps |
| `references/wpf.md` | Any XAML: the `Shared` theme, style keys, height grid, startup order, traps |
| `references/wpf-traps.md` | A WPF render looks wrong and the cause is not obvious |
| `references/ui-structure.md` | Menus, status bar, context actions, localization, accessibility — tags `[UI-n]` |

## [DS-0] Owner decisions — fixed

1. **Reference identity = the Craft web identity (`kit-web`)**; `kit-web` is the reference for motion and
   status display. Every product is a sibling: same font, shell, login, About, radii, shadows, icons.
2. **Light and dark themes, always.** Same token names, two value sets. Switch in the top bar
   (WPF: the View menu) and on the login card; the switch is **instant**, never "at the next
   start" [DS-7]. Saved per user [PRD-5].
3. **Arabic and English, always**, switched at run time; direction from the language.
4. **Cairo**, embedded/self-hosted, the only typeface; sizes from the platform ramp; never a setting.
5. **Alignment is a first-class rule** [DS-16].
6. **Delight, not decoration («دلع»)**: soft visible motion and finished details on every
   screen [DS-6] — the product must feel made with care, never a bare admin template.
7. **Color = identity, state = shape**; on a collision the state gives up its color.
8. **One primary button per view or dialog.**
9. **Original identity only**; no third-party logos or trade dress.
10. **No mixed identities.** A product on an older identity keeps it in TRACK B edits; moving
    it to this identity is its own planned change, then [DS-13] on every screen.
11. **No popup windows** once the main window is open: forms, confirmations and About appear
    inside it [DS-17]. **Cairo is the one thing that never changes**.

## [DS-1] Sources of truth

| Platform | Live source | Rule |
|---|---|---|
| Web | the product's `assets/css/tokens.css` (started from `kit-web`'s) | Colors and sizes only there; a literal elsewhere is a defect, enforced by a test |
| WPF | `Shared/{Brand}.Ui/Themes/Spectrum/AppTheme.xaml` + `Theming/*` | Merge `AppTheme.xaml` only; never copy a theme file |

A WPF token change is a `Shared` change: render in `{Brand}.Ui.Probe`, then build every sibling.

## [DS-2] Token roles (nearest equivalents across platforms)

| Role | Web var | WPF key |
|---|---|---|
| Page | `--bg` | `BgBase` |
| Card, dialog | `--surface` | `BgLayer2` |
| Bars, table head | `--surface-2` | `BgLayer1` |
| Lines | `--border` · `--border-strong` | `Divider` · `FieldBorder` |
| Text | `--text` · `--text-secondary` · `--text-muted` | `Text` · `TextSecondary` · `TextDisabled`/`Placeholder` |
| Accent | `--primary` · `-hover` · `-soft` | `Accent` · `AccentHover` · `Selection` |
| On accent | `--text-on-primary` | `OnAccent` |
| States | `--success` `--warning` `--danger` `--info` (+`-soft`, `-border`) | `Positive` `Notice` `Negative` `Informative` |

A new color = a role first, then a value in **both** themes (WPF: also a High Contrast role).

## [DS-3] Typography

Cairo Regular / SemiBold / Bold. Ramps in the platform file; no size outside them. **Line-box
law:** a fixed height holding text ≥ `1.874 × font size` + borders.

## [DS-4] App shell — every product with more than one screen

1. **Sidebar** at the start edge, **full height**: brand mark + name + company (the logo links
   to the dashboard) · icon + label items · collapsible groups, one open at a time, a badge
   stays visible on a closed group · active item = accent icon tile + start-edge marker ·
   **collapse button** → icon rail with tooltips; state saved and applied before first paint.
   - **Group colors for identification** are allowed: each sidebar group may
     carry one hue, shown in its icon tile and active marker, and carried into the page header
     tile [DS-4.5] and the dialog header tile [DS-17] of every screen in that group. A hue is
     identity only, never a state [DS-0] #7; with no hue the accent is used. WPF values: `kit-wpf`
     `Themes/AppStyles.xaml` (`HueBlue` … `HueSlate`, `HueTile`) until they move to `Shared`;
     web: no hue tokens yet, ask the owner before adding them.
   - WPF accordion: the items of a collapsed `Expander` are outside the visual tree, so
     `RadioButton.GroupName` does **not** uncheck them. When navigation selects an item from
     outside the sidebar (dashboard, badge, theme rebuild), uncheck every other item by hand,
     check the target, then expand its group (wpf.md trap 16).
2. **Top bar**: search · language (other language written in itself) · theme (sun/moon) · user.
   WPF: the **menu bar (File · Tools · Help …) stays** above it [UI-28]; never replace it with
   icons. No permanent export or backup icons in the top bar: export lives in each page
   header [DS-4.5], backup in Settings [PRD-5].
3. `<1024px` sidebar = drawer with backdrop; `<768px` a bottom tab bar with the 4–5 main
   destinations + more.
4. **Tabs fold**: overflow goes into a "more" menu; never a second row, never sideways scroll.
5. **Page title** = section icon in a soft-accent tile (or its group hue) + name, identical on
   every screen. **Every page that shows a table has an `Excel` and a `PDF` button in its
   header**, at the end of the title row before the page actions; they export what the table
   shows (current filter). Pages without a table have none.
6. Bars and rails span the full window edge to edge; nothing floats short of its container.
7. WPF: same shell for navigation-heavy products; Workspace/Form layouts in `wpf.md` for tools.

## [DS-5] Controls

Contracts: `web.md` (classes), `wpf.md` (style keys). Both: rounded controls; hover, focus,
pressed, disabled from tokens; neutral buttons have a clearly visible edge; icon + field +
trailing action inside one frame; **every password field has the eye toggle**.
**Every form validates in place**: a required mark on required fields, the message directly
under its field in the danger color (from resources [UI-31]), the field's edge in danger, focus
moved to the first invalid field, and the primary button stays enabled so the check can run.
No message boxes for validation.

## [DS-6] Motion — soft, visible, never in the way

1. Tokens (web): `--t-fast 120ms` · `--t-base 180ms` · `--t-slow 260ms` · `--t-enter 480ms` ·
   `--ease-out cubic-bezier(.23,1,.32,1)` · `--ease-spring cubic-bezier(.34,1.45,.64,1)`.
   Interactions stay under 300ms; only first-entry sequences use `--t-enter`.
2. Vocabulary: page content **rises** in (opacity + 6–18px) · list rows and cards **stagger** ·
   menus and dialogs **pop** · cards and buttons **lift** 1–4px on hover with a deeper shadow ·
   press = `scale(.97)` · chevrons and theme icon **turn** · sidebar width and drawer **slide** ·
   progress and status marks **draw** in (the approval ladder climbs rung by rung) · skeleton
   shimmer while loading · page changes use View Transitions where supported.
3. Motion explains state (arrived, saved, opened, next step); it never delays input, loops only
   on a live "current" marker, and never moves layout the user is reading.
4. `prefers-reduced-motion` turns all of it off. Check end states with transitions disabled.
5. WPF: what `Shared` ships (popup fade, state transitions), plus the in-window dialog motion
   [DS-17] and the theme fade [DS-7.2]; no other per-product storyboards.
6. Focus ring always visible on keyboard focus: accent, 2px. Disabled = muted fill + text.

## [DS-7] Themes — mechanics

1. Web: `data-theme` on `<html>`, rendered server-side from the saved choice (user record after
   login, cookie before); instant toggle; hover and selected fills are checked in **both**
   themes (a dark hover on a light table was shipped once).
2. WPF: at start, `ThemePreference.Initialize` → `HighContrast.ApplyIfActive` → the saved
   palette applied before the first window. **A theme change applies instantly**: rebuild the app's resource dictionaries from their
   sources with the new palette (`Shared` `LightTheme.Palette` for light), then recreate the
   main window in place — same bounds, state and section — fading in over ~180ms, and close
   the old one. The Windows caption follows the theme both ways. No switch while High
   Contrast is on or a dialog is open. Reference: `kit-wpf` `Services/ThemeSwitcher.cs` +
   `App.SwitchTheme` (wpf.md § Theme switch).

## [DS-8] Icons

1. Wherever a user scans: nav items, page and section titles, toolbar and row actions, typed
   fields (user, lock, mail, search), tabs, empty states, status messages.
2. Web: inline SVG line icons, 24 grid, `currentColor`, one registry; unknown name renders
   nothing. WPF: Font Awesome keys in `Shared`. One meaning = one icon across products.
3. Monochrome; icon-only controls have a tooltip and accessible label.
4. Only directional icons mirror in RTL. An icon never overlaps its text: reserve its space.

## [DS-9] Interaction

1. Frequent commands have shortcuts shown in tooltips and menus.
2. Work over ~1 s shows non-blocking progress.
3. Empty state: icon + one line + one action.
4. Danger buttons live in confirmation dialogs only (WPF: the in-window card [DS-17]); no
   native `MessageBox` / `alert`.
5. Row actions in a fixed order — view · print · edit · delete — view (eye) first, with
   padding before and after; the same order in every list and attachment row.
6. Every list: search/filter row, count, pager or virtualization, empty state.
7. A notice disappears when its cause is gone (an "update available" badge after updating).

## [DS-10] Traps

With their platform: `web.md` § Traps, `wpf.md` § Traps (numbered as the code cites them).

## [DS-11] About — compact card + activation tabs

Width 380–420, no scrollbar; Help → About (WPF) or user menu / sidebar footer (web). Desktop:
a centered in-window card [DS-17] with the layout of `Shared` `{Brand}.Ui.Views.AboutWindow`
(reference: `kit-wpf` `Views/Dialogs/AboutWindow` on `DialogBase`).
1. **Developer card FIRST**, above everything. One centred column in its own soft panel: label «الدعم الفني والتطوير / برمجة وتطوير» ·
   {Brand} logo (light file on light theme, `-dark` file on dark — a dark logo on a dark
   theme is a defect; source `{LogoFolder}`; at least 56px high, never a thumbnail) ·
   «{BrandAr}» (bold) · `{Brand}` (muted, LTR) · `{BrandEmail}` as a mailto link (LTR). No copy box.
2. Header row: product mark tile · name + company · version badge; then License (state badge +
   until date). The client's own logo, when the product has one, sits under the developer card.
3. Footer: `© year · Terms · Privacy` at the start; `Manage license` + `Close` (primary) at the end.
4. When not activated, or on `Manage license`: tabs `About` · `Activation` · `System` (admins).
   Activation = installation ID (LTR mono, copy) + token box (LTR) + `Activate`. Data: [PRD-1], [PRD-2].

## [DS-12] Direction

1. **Every editable field inherits the UI direction** — login name, email, password, search,
   numbers. Never `dir="auto"`/`dir="ltr"` on an input, never a per-field `FlowDirection`.
2. Read-only Latin values (emails, codes, IDs, paths) sit in `<bdi>` / `dir="ltr"` spans or
   LTR read-only text.
3. Displayed user text in lists may follow its first strong character; labels never do.
4. Logical sides only (`inline-start`, `text-align:start`; WPF start = `Left`). Never branch a
   side per language.
5. **Tables, on screen and printed, center every column — header and cells alike**: one rule for both languages, so a header never sits on one side while its
   cells sit on the other. Long free text (notes, descriptions) is the only exception: it
   starts at the reading start.

## [DS-13] Verification — mandatory before delivery

1. Every changed screen × **AR and EN** × **light and dark**. Web at 360 / 768 / 1024 / 1440.
   WPF: run the product (theme changes: `{Brand}.Ui.Probe`), capture with
   `Shared/tools/capture-window.ps1`, read the `.txt` audit.
2. Arabic test text: «مجموعة تجريبية بحروف نازلة» and «حدّ وشدّة وهمزة أُولى».
3. **Fail on:** literal color/size outside the token file · second primary button · icon-only
   control without tooltip · text clipped or overlapping an icon · horizontal page scroll · an
   input with `dir` · a one-theme token · a hover/selected state unreadable in either theme ·
   anything in [DS-16] misaligned · a bar or rail short of full height/width · a password field
   without the eye · a screen not checked in both themes and languages · a popup window opened
   after the main window exists [DS-17] · a theme change that needs a restart · an export or
   backup icon in the top bar · a table page without Excel/PDF in its header · a multi-line
   field narrower than its form.
4. What cannot be captured (hover, focus ring, open dropdown, motion) is checked by hand or
   reported `⚠ لم يُتحقق` with the reason.

## [DS-14] Responsive fit — strict

1. Web: complete from **360px to 1440px+**; no horizontal page scroll; tables become
   label/value cards below 768; grids 4 → 2 → 1; touch targets ≥ 44px.
2. WPF: fits **1366×768 at 150%, Arabic**, no clipping, no vertical scrollbar on fixed content.
3. Blocks fill their container's width; a layout that only fits the developer's monitor is a defect.

## [DS-15] Login — the Craft login card

Centered card, max 420, padding 24, dialog radius, `--shadow-md`.
1. Head: mark tile + product + company · language button + theme icon at the end · divider.
2. Title 24 Bold + one lead line.
3. "Login name or email" with a user icon · Password with lock icon and eye. Both inherit
   direction [DS-12]; label, text and icon start on the same edge.
4. `Remember me` at the start · `Forgot password?` at the end (web).
5. Full-width primary button with the login icon; disabled while submitting.
6. Errors as a danger flash above the fields; the typed name is kept.
7. Forgot/reset screens use the same card. Desktop products with users show it in its own
   window, since it comes before the main window exists [DS-17].

## [DS-16] Alignment and spacing — «المحاذاة من أهم القواعد»

1. Things of one kind form one column: **status pills share one width** (the widest label, per
   language) with centered text; table columns are centered [DS-12] #5; action icons share a grid.
2. A status and its indicator (progress ladder, dot, count) sit **side by side in the same
   order everywhere** that status appears — lists, cards, details, reports.
3. Labels, fields and buttons in a form share start edges and one row height; a row's controls
   are vertically centered on one line.
4. **Nothing touches an edge**: ≥16px to the window/card edge, ≥12px inside bars and table
   search rows, and visible padding before and after any icon or control at the start of a row.
5. Charts and stat cards: centered content, **full-strength series colors** (never washed-out
   tints), equal card heights in a row.
6. A fix to one element applies to every similar element in the product [WF-3].
7. **Multi-line fields (notes, address, description) stretch to the full width** of their form
   or sheet, at least two lines high (WPF `InputMultiline`, web `textarea` at 100%); never a
   narrow box beside empty space. Settings pages stay compact (several columns, side tabs), no
   large empty areas.
8. **Dialogs and sheets size to their content**: when space is free, content spreads to use it;
   a scrollbar appears only when the content truly exceeds the window (an «edit group» form with
   room to spare and a scrollbar is a defect).
9. **Numbers read like a receipt**: the currency or unit comes **after**
   the number (`1,250 ر.س`, `12 م`), decimals appear only when the value has them (`1,250` not
   `1,250.00`; `12.5` stays), one number formatter for screen, export and print.

## [DS-17] In-window dialogs — no popup windows

1. **Add / edit / details forms = side sheet** inside the main window: full window height,
   slides in from the **end edge** (left in Arabic, right in English) over a dimmed layer
   (`OverlayBrush`). Header: hue tile [DS-4.1] + title + one-line subtitle + close (×).
   Footer bar on `BgLayer1` holds the buttons, one primary [DS-0] #8. Only the body scrolls.
2. **Confirm, alert, About = centered card** inside the window: modal radius, full border,
   grows in from 96% with a fade.
3. Behavior: everything under the top layer is disabled (no click, Enter or Esc reaches it);
   Esc = cancel unless the dialog must be answered; Enter = primary; focus moves to the first
   field; sheets stack, each closing back to the one below. Motion [DS-6]: in 260ms ease-out,
   out 160ms ease-in.
4. **A real window only before the main window exists**: first-run wizard, login [DS-15], a
   message during startup. It uses the same shell (centered, `AppWindowStyle`, no resize).
5. WPF reference: `kit-wpf` `Views/Dialogs/DialogBase.cs` (same API as a window — `ShowDialog`,
   `DialogResult`, `Close`, `Title` — so callers do not change; it falls back to a small window
   when no host is attached), `Views/Dialogs/SheetHost.cs` (layers, dim, motion, keyboard), and
   the `DialogShell` style in `Themes/AppStyles.xaml`. Keep the shell's shadow on a sibling
   Border, not on the border that holds the text (wpf.md trap 7).
6. Web: dialogs are already in-page (`web.md`); this rule changes nothing there.
