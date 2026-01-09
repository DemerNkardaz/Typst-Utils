#import "font_utils.typ": localeFonts

#let getFont(lang, index) = {
  let langFonts = localeFonts.at(lang, default: none)

  if langFonts != none {
    return langFonts.at(index, default: false)
  }

  return false
}

#let apply(lang: "", font: 0, content) = {
  let fontValue = false

  // Определяем тип: строка (имя) или число (индекс)
  if type(font) == str {
    // Прямое имя шрифта
    fontValue = font
  } else if type(font) == int {
    // Индекс шрифта
    fontValue = getFont(lang, font)
  }

  let args = (lang: lang)
  if fontValue != false {
    args.insert("font", fontValue)
  }

  text(..args, content)
}
