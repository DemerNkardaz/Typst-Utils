#let __fontsList = (
  "ja": ("Noto Serif JP", "Noto Sans JP"),
  "zh": ("Noto Serif SC", "Noto Sans SC"),
)

#let __getFont(lang, index) = {
  let langFonts = __fontsList.at(lang, default: none)

  if langFonts != none {
    return langFonts.at(index, default: false)
  }

  false
}


#let textLocale(lang: "", fontIndex: 0, content) = {
  let fontValue = __getFont(lang, fontIndex)

  let args = (lang: lang)
  if fontValue != false {
    args.insert("font", fontValue)
  }

  text(..args, content)
}
