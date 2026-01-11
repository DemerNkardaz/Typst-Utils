#let default-fonts = (
  serif: (
    "Noto Serif",
    "Noto Serif JP",
    "Noto Serif TC",
    "Noto Serif SC",
    "Noto Serif HK",
  ),
  sans-serif: (
    "Noto Sans",
    "Noto Sans JP",
    "Noto Sans TC",
    "Noto Sans SC",
    "Noto Sans HK",
  ),
  single-style: (
    "Noto Serif Tangut",
  ),
)

#let localeFonts = (
  "ja": ("Noto Serif JP", "Noto Sans JP"),
  "zh": ("Noto Serif SC", "Noto Sans SC"),
)

#let get-fonts(type: "sans-serif", primaryFont: none) = {
  (
    if primaryFont != none { primaryFont },
    ..default-fonts.at(type, default: ()),
    ..default-fonts.at("single-style", default: ()),
  ).filter(it => it != none)
}
