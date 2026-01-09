#import "font_utils.typ": localeFonts

#let getFont(lang, index) = {
  let langFonts = localeFonts.at(lang, default: none)

  if langFonts != none {
    return langFonts.at(index, default: false)
  }

  false
}

#let apply(lang: "", fontIndex: 0, content) = {
  let fontValue = getFont(lang, fontIndex)

  let args = (lang: lang)
  if fontValue != false {
    args.insert("font", fontValue)
  }

  text(..args, content)
}
