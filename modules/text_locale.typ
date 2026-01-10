#import "font_utils.typ": localeFonts

#let get-font(lang, index) = {
  let langFonts = localeFonts.at(lang, default: none)

  if langFonts != none {
    return langFonts.at(index, default: false)
  }

  return false
}

#let apply(lang: "", font: 0, content) = {
  let fontValue = false

  if type(font) == str {
    fontValue = font
  } else if type(font) == int {
    fontValue = get-font(lang, font)
  }

  let args = (lang: lang)
  if fontValue != false {
    args.insert("font", fontValue)
  }

  text(..args, content)
}
