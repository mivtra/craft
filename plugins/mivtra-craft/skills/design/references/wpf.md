# WPF — the `Shared` theme

Live source (values are read there, never restated here): `Shared/{Brand}.Ui/Themes/Spectrum/`
`AppTheme.xaml` (merges Tokens → Icons → Controls) · `Tokens.xaml` (dark values) ·
`Theming/LightTheme.cs` (light values, same keys) · `Theming/HighContrast.cs` (system-colour
roles) · `Theming/ThemePreference.cs` · `Theming/DarkCaption.cs` · `{Brand}.Ui.Probe/` ·
`tools/capture-window.ps1`.

The WPF accent is Spectrum blue (`#4069FD` dark / `#3B63FB` light); change it only in `Shared`.

## Wiring

```xml
<Application.Resources><ResourceDictionary><ResourceDictionary.MergedDictionaries>
  <ResourceDictionary Source="pack://application:,,,/{Brand}.Ui;component/Themes/Spectrum/AppTheme.xaml"/>
</ResourceDictionary.MergedDictionaries></ResourceDictionary></Application.Resources>
```

```csharp
protected override void OnStartup(StartupEventArgs e)
{
    base.OnStartup(e);
    var theme = ThemePreference.Initialize(settingsDir);      // same dir as LanguageManager
    bool hc = HighContrast.ApplyIfActive(this);               // wins over both themes
    ThemeSwitcher.Initialize(this, theme == AppTheme.Light);  // product class (`kit-wpf`); palette + caption
    // then LicenseGate, services, first window
}
```

Products that cannot switch at run time yet keep the older pair `LightTheme.Apply(this)` +
`DarkCaption.Register` here, and must move to the switch below [DS-7.2].

## Theme switch at run time [DS-7.2]

Styles read colours through `StaticResource` and seal on first use (trap 13), so swapping a
token is not enough. Reference: `kit-wpf` `Services/ThemeSwitcher.cs` + `App.SwitchTheme`
(`Shared` `LightTheme.Palette`).
1. `Switch(app, light)`: clear `Application.Resources.MergedDictionaries`, re-create each from
   its source (`AppTheme.xaml`, then the product's styles and brand dictionaries); for light,
   write `LightTheme.Palette` (`<Token>Color` + frozen `<Token>Brush`) over every key in the
   theme dictionary and the ones it merges; re-add the current `Lang/*` dictionary last; save
   with `ThemePreference.Select`.
2. Recreate the main window: new instance, same `RestoreBounds`, `WindowState` and current
   section, `Opacity` 0 → 1 over 180ms, set it as `MainWindow`, show it, close the old one;
   carry over transient state (an update badge).
3. Refuse while High Contrast is on or `SheetHost.IsOpen`. Paint the caption through DWM in
   both directions (dark: `BgLayer1` colour; light: system default) on every window's `Loaded`.

Every window: `Style="{StaticResource AppWindowStyle}"` (font, `BgBase`, `Text`,
`FlowDirection` bound to `L_FlowDirection`). Fonts stay in the product as `Resource`:
`Assets/Fonts/Cairo-Regular.ttf`, `Cairo-SemiBold.ttf`, `Cairo-Bold.ttf`, `fa-solid-900.otf`.
A new colour token = three places: `Tokens.xaml`, `LightTheme.Map`, `HighContrast` role.

## Ramp and grid

Type 11 badge · 12 label/table header/status/tooltip/small · 14 base/table/panel title · 16
section title · 18 dialog title · 20 page title. Heights **28 / 32 / 40** only; table rows 32 /
40; toast min 48; menu bar 32; options bar 40; status bar 28. Widths: inputs 96 / 208 / 360;
buttons 72–240; dialogs 288–480; panel column 260 (200–400); tool rail 56. Radii: 4 small · 8
control · 10 card · 16 modal · pills 14/16/20. Spacing 8 / 12 / 16 / 24.

## Style keys (implicit where marked *)

Buttons: `BtnPrimary` `BtnSecondary`* `BtnDanger` `BtnQuiet` (+ `Sm` at 28) · `IconButton`
`IconButtonDanger` (+ `Sm` 28 for rows in 32px tables) · `ToolButton` · Fields: `Input`*
`InputSm` `InputLg` `InputStretch` `InputMultiline` `PasswordInput`* `Select`* `SelectSm`
`SelectStretch` · `Check`* `Radio`* `Switch` Slider* · `Tabs`* · `MenuBar`* Popover/ContextMenu*
ToolTip* · `DataTable`* `ListItem`* TreeViewItem* ScrollBar* · `Section` `Panel`* (Expander) ·
`DialogWindowStyle` + `ModalShadow` + `Modal` (`ModalHeader/Title/Body/Footer`) — only for a
window before the main window exists; after it, `DialogShell` on `DialogBase` (`kit-wpf`
`Themes/AppStyles.xaml`, not in `Shared` yet) [DS-17] · `HueTile` (`kit-wpf`) · `Toast`
`ToastPositive/Negative/Informative` · `Badge` (+ semantic) · `AppStatusBar`* · ProgressBar* ·
Hyperlink* · layout `OptionsBar` `ToolRail` `PanelColumn` `PanelSplitter`.
Not styled yet: Calendar, DatePicker — do not use until added to `Shared` and verified.
`InputMultiline` spans the form's full width (`Grid.ColumnSpan` to the last column, no fixed
`Width`) [DS-16.7].

State rule: content on any Hover / Pressed / checked / Selection fill takes `OnState`; glyph
buttons and check boxes rest on `RestFill`; table cells inherit the row Foreground (a cell with
its own brush vanishes on a High Contrast highlight row).

## Layouts

A **Workspace** (central object): menu 32 → options bar 40 → tool rail 56 | content | splitter 4
| panel column 260 → status 28. B **Form** (records/settings): menu → `Section`s on `BgBase` →
status. C **Navigation shell** (many screens): menu 32 → [DS-4] sidebar with collapse to icon rail,
then B inside; a full-window overlay `Grid` on top hosts the in-window dialogs
(`SheetHost.Attach(overlay, content…)`) [DS-17]. Write the start side as `Left`; `DockPanel.Dock="Left"` lands on the right in Arabic.
Reference skeletons: `{Brand}.Ui.Probe/WorkspaceWindow.xaml`, `FormWindow.xaml`.

## Deviations from Spectrum 2 (measured, do not revert)

Small controls 28 not 24 (Cairo line box) · 1px border on every field · field border gray-500
(`#444` fails 3:1) · disabled text gray-500 · row actions 28 in 32 rows · Cairo not Adobe Clean
· Font Awesome not Spectrum icons.

## Verification

Probe: `--ar` `--en` `--light` `--menu` `--popups` `--hc-black` `--hc-white` `--hc`. Capture:
`powershell -NoProfile -ExecutionPolicy Bypass -File <Shared>\tools\capture-window.ps1 -Process <exe> -Out <png> -Which All`
(Products on the standard sizes pass `-ControlHeightSmall 30 -ControlHeight 35 -ControlHeightLarge 35
-ButtonMinWidthValue 112 -ButtonMaxWidth 112`). Fail on: control < 28 · text container below
the line-box law · button > 240 (shorten label, never trim) · literal hex/size/`Padding` in
`Views/` · control type without implicit style · theme file copied into a product.

## Traps (each fails silently or at run time)

1. TextBox caret is black → `CaretBrush`. 2. Selection uses system highlight → `SelectionBrush`
+ opacity .4. 3. ContextMenu, MenuItem, Separator, ToolTip, ScrollBar, ComboBox dropdown,
DataGrid header, GroupBox, Expander default to light templates → implicit style for every type
in use. 4. Disabled TextBox paints light gray → style it. 5. Hyperlink is `#0000FF` →
`AccentText`. 6. Window paints white before content → background in `AppWindowStyle`.
7. `Effect` on a text container kills ClearType → shadow on a sibling Border. 8.
`WindowStartupLocation` in a Style throws → set on each window. 9. `x:Name` in templates leaks
into UI Automation → name parts `PART_*`. 10. ScrollViewer corner paints light → template has
no corner. 11. Layered windows capture unmirrored, plain RTL windows mirrored → the capture
script handles it. 12. A dictionary merged on top never reaches `StaticResource` inside
`Controls.xaml` → remap in place (LightTheme / HighContrast). 13. Styles seal on first use →
any recolouring runs before the first window. 14. `SetProperty` skips equal values → never hang
a side effect on a property change alone. 15. Inline `Padding` on a fixed-height styled control
clips text at the call site only. 16. `RadioButton.GroupName` does not reach items inside a
collapsed `Expander` (outside the visual tree), so two nav items stay checked → uncheck the
others by hand when selecting in code, then expand the item's group. Deep explanations:
`wpf-traps.md`.
