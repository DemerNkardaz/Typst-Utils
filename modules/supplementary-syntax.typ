#import "/modules/text-locale.typ" as Text-Locale

#let auto-no-break-words = read("/assets/data/no-break-words.txt")

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
  no-break: (
    pattern: regex("\\|\\[([^\\]]+)\\]\\|"),
    replace: match => {
      let captures = match.text.match(regex("\\|\\[([^\\]]+)\\]\\|")).captures

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
