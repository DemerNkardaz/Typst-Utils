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
  let output = ()

  if primaryFont != none {
    output.push(primaryFont)
  }

  for font in default-fonts.at(type) {
    output.push(font)
  }

  for font in default-fonts.at("single-style") {
    output.push(font)
  }

  return output
}
