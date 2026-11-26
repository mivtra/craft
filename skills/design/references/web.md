# Web — the Craft web design system (`kit-web`)

Live reference: `kit-web/public/assets/css/tokens.css` + `app.css`, `app/Core/Icon.php`,
`app/Views/auth/login.php`, `partials/{auth_header,preferences,password_input,sidebar,topbar,tabbar}.php`.
A new web product starts from copies of `tokens.css` and the shell partials, changing only the
brand color if the owner asks for one.

## Tokens (`tokens.css`)

```css
:root {
  --bg:#f3f4f6; --surface:#ffffff; --surface-2:#f9fafb; --surface-sunken:#f3f4f6;
  --border:#e5e7eb; --border-strong:#d1d5db;
  --text:#1f2937; --text-secondary:#4b5563; --text-muted:#6b7280; --text-on-primary:#ffffff;
  --primary:#0f766e; --primary-hover:#115e59; --primary-soft:#ccfbf1; --primary-ink:#0f766e;
  --sidebar:#0f172a; --sidebar-sunken:#060d1a; --sidebar-text:#cbd5e1; --sidebar-text-strong:#ffffff;
  --sidebar-active:rgba(13,148,136,.22); --sidebar-marker:#2dd4bf;
  --success:#15803d; --success-soft:#f0fdf4; --success-border:#bbf7d0;
  --warning:#b45309; --warning-soft:#fffbeb; --warning-border:#fde68a;
  --danger:#b91c1c;  --danger-soft:#fef2f2;  --danger-border:#fecaca;
  --info:#0369a1;    --info-soft:#e0f2fe;    --info-border:#bae6fd;
  --shadow-sm:0 1px 2px rgba(16,24,40,.06); --shadow-md:0 4px 10px rgba(16,24,40,.08);
  --r-control:8px; --r-card:10px; --r-dialog:12px; --r-pill:999px;
  --sidebar-width:260px; --sidebar-collapsed:72px; --topbar-height:60px; --content-max:1440px; --touch:44px;
  --font:"Cairo","Segoe UI",Tahoma,system-ui,-apple-system,sans-serif;
}
:root[data-theme="dark"] {
  --bg:#0b1220; --surface:#111a2b; --surface-2:#0d1626; --surface-sunken:#070d18;
  --border:#1f2a3d; --border-strong:#334155;
  --text:#e5e7eb; --text-secondary:#cbd5e1; --text-muted:#94a3b8; --text-on-primary:#042f2e;
  --primary:#2dd4bf; --primary-hover:#5eead4; --primary-soft:rgba(13,148,136,.2); --primary-ink:#5eead4;
  --sidebar:#070d18; --sidebar-sunken:#040911; --sidebar-text:#94a3b8; --sidebar-text-strong:#ffffff;
  --success:#4ade80; --success-soft:rgba(22,163,74,.16);  --success-border:rgba(74,222,128,.35);
  --warning:#fbbf24; --warning-soft:rgba(234,88,12,.18);  --warning-border:rgba(251,191,36,.35);
  --danger:#fca5a5;  --danger-soft:rgba(220,38,38,.16);   --danger-border:rgba(252,165,165,.35);
  --info:#7dd3fc;    --info-soft:rgba(3,105,161,.2);      --info-border:rgba(125,211,252,.35);
  --shadow-sm:0 1px 2px rgba(0,0,0,.4); --shadow-md:0 4px 14px rgba(0,0,0,.5);
}
```

Shadows: `sm` and `md`, plus `--shadow-lg` for hover lift and dialogs when motion is on. Cairo is self-hosted as three `unicode-range` woff2 subsets (Arabic, Latin-ext,
Latin), weight axis 400–900, `font-display: swap`, preloaded — never a CDN.

Motion and edge tokens (from `kit-web`, same in both themes except the edge):

```css
--t-fast:120ms; --t-base:180ms; --t-slow:260ms; --t-enter:480ms;
--ease-out:cubic-bezier(.23,1,.32,1); --ease-spring:cubic-bezier(.34,1.45,.64,1);
--control-edge:#77839a;            /* dark theme: #66758f — border of neutral buttons, pagers */
```

Keyframes in `app.css`: `rise` (opacity + translateY 6px) for dialogs and page content ·
`arrive` (18px + scale .985) for first entry · `row` (10px) staggered by `--i * 40ms` ·
`pop` (−4px + scale .98) for menus · `settle` for opened nav groups · `turn` for icon swaps ·
`shimmer` for skeletons. Hover: cards `translateY(-2px)` + `--shadow-md` (pointer devices:
−4px), buttons −1px; press `scale(.97)`. Everything sits inside
`@media (prefers-reduced-motion: no-preference)`.

## Type ramp

Body 16 / line-height 1.6 · inputs 16 (stops iOS zoom) · buttons, nav 15 · table 15 · labels 14
Bold · hints, meta 13 · badges, captions 12 · section/card title 16 Bold · page title 22 Bold ·
login title 24 Bold · KPI value 28 Bold.

## Components (class contract)

| Class | Spec |
|---|---|
| `.btn` | min-height `--touch`, padding 0 18, `--r-control`, 1px `--border-strong`, `--surface`, 15px, icon gap 8 |
| `.btn--primary` | `--primary` fill, `--text-on-primary`, Bold; one per view |
| `.btn--ghost` `.btn--danger` `.btn--icon` `.btn--block` `.btn--lg` | variants; danger only inside confirm dialog |
| `.field` `.field__label` `.field__input/select/textarea` | label 14 Bold mb 8; input min-height 44, 1px `--border-strong`, `--r-control`, padding 0 12; focus 2px `--primary` outline, offset 1 |
| `.control--lead` `.control__icon` `.control--trail` `.control__action` | leading icon at `inset-inline-start:12px` (input padding-start 42); trailing action 44 wide (padding-end 48) |
| `.field__error` `.field__hint` | 13px danger / muted |
| `.card` `.card__head` `.card__body` | `--surface`, 1px `--border`, `--r-card`, `--shadow-sm`; head padding 14 16 with bottom divider |
| `.badge--{primary,success,warning,danger,muted}` | pill, 12 Bold, soft fill + strong text |
| `.status-pill` | fixed width = widest status label (`em`, one value per language), centered; its indicator beside it in one partial reused everywhere [DS-16] |
| password field | always the `password_input` partial (lock + eye), in every form |
| `.flash--{success,error,warning,info}` | soft fill + border + strong text, `--r-control` |
| `.m-table` | header `--surface-2`, 500 weight muted, `text-align:start`; cells 12 14 with top border; row hover `--surface-2`; `<768px` becomes cards using `data-label` |
| `.page-title` | 22 Bold, 38px soft-accent icon tile |
| `.empty` | centered icon + line + action |
| `.sidebar` … `.sidebar-collapsed` | see [DS-4]; collapse class on `<html>` set by an inline head script before paint |
| `.topbar` | sticky, `--surface`, bottom border, search grows, `.prefs` (language + theme) at end |
| `.tabbar` | phone only: fixed bottom grid of 5 icon+label links |
| `.auth` `.auth__card` `.auth__head` | login card [DS-15] |
| `.kv` | icon + label / value rows — About and license tab |

## Breakpoints

`≥1024` sidebar fixed + collapsible · `<1024` drawer · `<768` bottom tab bar, tables → cards,
grids 2 columns, hide secondary columns (`.hide-phone`), FAB for the main create action ·
`≤400` grids 1 column. Content max 1440, padding 24 desktop / 16 phone.

## Theme and language switching

`/theme/{light|dark}` and `/language/{ar|en}` routes save the choice (session + user record)
and redirect back; `<html lang dir data-theme>` rendered server-side. Language link text is the
other language written in itself with its own `lang`/`dir`.

## Traps

1. `dir="auto"` on inputs breaks [DS-12] #1 — a real login defect. Remove it; keep `<bdi>` for
   read-only Latin values.
2. Physical properties (`left`, `margin-right`, `text-align:left`) break RTL — logical only.
3. A literal color in a view or a second CSS file escapes the theme switch — test that only
   `tokens.css` holds colors.
4. The theme toggled in JS only flashes the wrong theme on load — render `data-theme` server-side.
5. CSS transitions are frozen in the browser preview pane; measure end states with transitions off.
6. `display:none` tabs/menus must still be reachable by keyboard when opened (`aria-expanded`).
7. A hover/selected color written for one theme (dark fill on a light table) — use tokens only.
8. A sidebar or bottom bar sized by content stops short — size by the viewport (`inset-block:0`).
9. Search and filter inputs flush against a card edge — the wrapper carries the padding.
