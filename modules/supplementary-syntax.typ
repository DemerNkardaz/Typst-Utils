#import "/modules/text-locale.typ" as Text-Locale
#import "/modules/ruby-text.typ" as Ruby-Text

#let auto-no-break-words = read("/assets/data/no-break-words.txt")

#let rules = (
  text-locale: (
    pattern: regex("tl'([A-Z]{2,3})'([^']*)'(?:([^']*)')?"),
    replace: match => {
      let captures = match.text.match(regex("tl'([A-Z]{2,3})'([^']*)'(?:([^']*)')?")).captures

      let lang = captures.at(0)
      let second = captures.at(1)
      let third = captures.at(2)

      let (font-str, content) = if third != none and third != "" {
        (second, third)
      } else {
        (none, second)
      }

      let font = if font-str != none and font-str != "" {
        if font-str.match(regex("^\\d+$")) != none {
          int(font-str)
        } else {
          font-str
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
  // furigana: (
  // ),
  rotate: (
    pattern: regex("(\\d+deg)\\s@\\s([^\\]]+)"),
    replace: match => {
      let captures = match.text.match(regex("(\\d+deg)\\s@\\s([^\\]]+)")).captures

      let degree-value = captures.at(0)
      let content = captures.at(1)

      rotate(eval(degree-value))[#content]
    },
  ),
  no-break: (
    pattern: regex("\\|\\[\\s((?:[^\\[\\]|]|\\[[^\\]]*\\])*)\\s\\]\\|"),
    replace: match => {
      let captures = match.text.match(regex("\\|\\[\\s((?:[^\\[\\]|]|\\[[^\\]]*\\])*)\\s\\]\\|")).captures

      let content = captures.at(0)

      box[#content]
    },
  ),
)

#let create-auto-no-break-rules(text-content) = {
  let words = text-content.split("\n").map(line => line.trim()).filter(line => line.len() > 0)

  if words.len() == 0 {
    return (:)
  }

  let escaped-words = words.map(word => {
    word
      .replace("\\", "\\\\")
      .replace(".", "\\.")
      .replace("*", "\\*")
      .replace("+", "\\+")
      .replace("?", "\\?")
      .replace("(", "\\(")
      .replace(")", "\\)")
      .replace("[", "\\[")
      .replace("]", "\\]")
      .replace("{", "\\{")
      .replace("}", "\\}")
      .replace("^", "\\^")
      .replace("$", "\\$")
      .replace("|", "\\|")
  })

  let pattern-str = "(?i)\\b(" + escaped-words.join("|") + ")\\w*"
  let pattern = regex(pattern-str)

  let auto-rules = (:)
  auto-rules.insert(
    "auto-no-break",
    (
      pattern: pattern,
      replace: match => {
        box[#match.text]
      },
    ),
  )

  auto-rules
}

#let all-rules = {
  let auto-rules = create-auto-no-break-rules(auto-no-break-words)
  rules + auto-rules
}

#let apply(content) = {
  let result = content

  for rule in all-rules.values().rev() {
    result = {
      show rule.pattern: match => (rule.replace)(match)
      result
    }
  }

  result
}
