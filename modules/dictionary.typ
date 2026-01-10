#import "utils.typ": makeDictCI
#import "text_locale.typ": apply as TextLocale

#let data = makeDictCI(yaml("../assets/data/dictionary.yml"))

#let rules = (
  (
    pattern: regex("<\|\[([A-Z]{2,3})\](?:\[([^\]]+)\])?\|\[\'([^{}]*?)\'\]>"),
    replace: match => {
      let captures = match.text.match(regex("<\|\[([A-Z]{2,3})\](?:\[([^\]]+)\])?\|\[\'([^{}]*?)\'\]>")).captures

      let lang = captures.at(0)
      let fontStr = captures.at(1)
      let content = captures.at(2)

      let font = if fontStr != none and fontStr != "" {
        let cleaned = fontStr.trim("\"").trim("'")
        if cleaned.match(regex("^\d+$")) != none {
          int(cleaned)
        } else {
          cleaned
        }
      } else {
        0
      }

      TextLocale(lang: lower(lang), font: font)[#content]
    },
  ),
)

#let applyHandle(content) = {
  let result = content

  for rule in rules.rev() {
    result = {
      show rule.pattern: match => (rule.replace)(match)
      result
    }
  }

  result
}

#let getTerm(termLabel) = {
  let searchKey = lower(termLabel)
  let termString = (data.get)(searchKey)

  if termString == none {
    return text(fill: red)[Term called “#termLabel” not found in dictionary.]
  }

  let title = termString.at("title", default: searchKey)
  let note = termString.at("note", default: none)
  let abstract = termString.at("long")
  let abstractStart = [#sym.space.nobreak—]

  note = if note != none { " (" + note + ")" } else {}

  let output = [#title#note#abstractStart#abstract]

  return applyHandle()[#output]
}
