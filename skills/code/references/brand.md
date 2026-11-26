# Brand settings — filled once, used by every Craft skill

Every value written in braces in the Craft skills (`{Brand}`, `{BrandEmail}` …) comes from the
owner's **brand file**. This page is only its template: never write values here, because plugin
updates replace this folder.

Where the brand file lives, first found wins:
1. `docs/brand.md` in the current project (a per-product override);
2. `~/.claude/mivtra-craft/brand.md` (the owner's default for every project).

No brand file yet → before the first value is needed, ask the owner for the missing values in
one set of questions [product WF-12], create `~/.claude/mivtra-craft/brand.md` from the table
below with the answers, and carry on. A value still unknown stays as its placeholder and is
listed in the delivery report.

| Placeholder | Meaning | Your value |
|---|---|---|
| `{Brand}` | Developer / company name in Latin letters; also the install root `{autopf}\{Brand}\` and the shared library prefix (`{Brand}.Ui`, `{Brand}.Licensing`, `{Brand}.Updates`) | |
| `{brand}` | The same name in lower case, for file names (`{brand}-logo.png`) | |
| `{BrandAr}` | The developer name in Arabic, shown in About | |
| `{BrandEmail}` | Support e-mail shown in About as a mailto link | |
| `{BrandSite}` | Web site, also the root of update channels `{BrandSite}/<product>/updates/` | |
| `{LogoFolder}` | Folder holding `{brand}-logo.png` and `{brand}-logo-dark.png` | |
| `{LicenseServer}` | Name of your licensing platform | |
| `{LicenseServerUrl}` | Its address | |
| `{OwnerLanguage}` | Language of every reply, question, plan and report to you (default: Arabic) | Arabic |
| `{AppName}` | The product being built (set per project, not here) | per project |

**«The owner»** in every Craft skill means you: the person Claude builds the product for. Your
requests are the spec, and every outward action (deploy, upload, push) waits for your yes.

## The shared library

The rules refer to a `Shared` folder beside each product with `{Brand}.Ui` (theme, About, dialogs),
`{Brand}.Licensing[.Wpf]` and `{Brand}.Updates`. The Craft Starter Kit ships it ready. Without the
kit, the first product builds it by following `product` [PRD-1], [PRD-2], [PRD-10] and `design`
[DS-1], and every later product reuses it.

## The Starter Kit repositories

Rules cite live code as a model to port, never to reinvent:
- `kit-wpf` — a complete WPF product (theme switch, in-window dialogs, About, printing, updates).
- `kit-web` — a complete PHP web product (tokens.css, shell partials, login, updater).
- `kit-lan` — an ASP.NET Core product installed on a customer PC (service, tray manager, printing).

They ship with the Craft Starter Kit. Without them, build the part from the rule text itself.

## The signing key

Updates are signed with **one** key made once for your brand. Keep its private part offline with
a backup. Never create a second key: installed products trust only the first.
