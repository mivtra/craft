# Mivtra Craft — مهاراة ميفترا

Arabic-first skills for building complete products with Claude: WPF desktop and web
(PHP / ASP.NET Core), one design identity with RTL and light + dark themes, sound code and
security rules, and Arabic social content.

مهارات تبني مع Claude برامج عربية كاملة: سطح المكتب والويب، هوية تصميم واحدة باتجاه من
اليمين وثيم فاتح وداكن، قواعد كود وأمان، ومحتوى عربي للتواصل الاجتماعي.

## Install — التثبيت

```
/plugin marketplace add mivtra/craft
/plugin install mivtra-craft@mivtra
```

## Free core — النسخة المجانية (MIT)

| Skill | Use |
|---|---|
| `mivtra-craft:code` | Entry point: routes the request, code and security rules · المدخل وقواعد الكود والأمان |
| `mivtra-craft:design` | Visual identity, RTL, light + dark, screens · التصميم والاتجاه والثيمان |
| `mivtra-craft:studio` | Arabic posts, ads, designs, short video · منشورات وإعلانات وتصاميم وفيديو عربي |

## Mivtra Craft Pro — الحزمة الكاملة

Adds `product` (plan and project memory, About + licensing, backups, demo data, login and
roles, installer, signed updates, printing, packaging), `audit`, `api`, `tests`, `office` and
`it`. Details: https://mivtra.com/craft

تضيف طبقة المنتج كاملة والتحديثات الموقّعة والطباعة والفحص والاختبارات وملفات الأوفيس.

## First step — أول خطوة

On the first product Claude asks for your brand (name, e-mail, site, logo, licensing) and saves
it in `~/.claude/mivtra-craft/brand.md`; a project can override it in `docs/brand.md`.

في أول برنامج يسألك Claude عن بيانات علامتك ويحفظها في `~/.claude/mivtra-craft/brand.md`،
ويمكن لكل مشروع أن يغيّرها في `docs/brand.md`.

Licence: MIT (`LICENSE`). Third-party parts: `THIRD-PARTY-NOTICES.md`.
