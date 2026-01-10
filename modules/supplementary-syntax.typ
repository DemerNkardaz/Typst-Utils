#import "/modules/text_locale.typ" as Text-Locale

#let rules = (
  text-locale: (
    pattern: regex("<\\|\\[([A-Z]{2,3})\\](?:\\[([^\\]]+)\\])?\\|\\[\\'([^{}]*?)\\'\\]>"),
    replace: match => {
      let captures = match
        .text
        .match(regex("<\\|\\[([A-Z]{2,3})\\](?:\\[([^\\]]+)\\])?\\|\\[\\'([^{}]*?)\\'\\]>"))
        .captures

      let lang = captures.at(0)
      let font-str = captures.at(1)
      let content = captures.at(2)

      let font = if font-str != none and font-str != "" {
        let cleaned = font-str.trim("\"").trim("'")
        if cleaned.match(regex("^\\d+$")) != none {
          int(cleaned)
        } else {
          cleaned
        }
      } else {
        0
      }

      Text-Locale.apply(
        lang: lower(lang),
        font: font,
      )[#content]
    },
  ),
)



#let apply(content) = {
  let result = content

  for rule in rules.values().rev() {
    result = {
      show rule.pattern: match => (rule.replace)(match)
      result
    }
  }

  result
}
