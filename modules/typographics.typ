#let rules = (
  ru: (
    (
      pattern: regex("([а-яёА-ЯЁ]) "),
      replace: it => it.text.clusters().first() + sym.space.nobreak,
    ),
    (
      pattern: regex("([а-яёА-ЯЁ]{2}) "),
      replace: it => it.text.clusters().slice(0, 2).join() + sym.space.nobreak,
    ),
    (
      pattern: regex("([А-ЯЁ])\. "),
      replace: it => it.text.clusters().first() + "." + sym.space.nobreak,
    ),
    (
      pattern: regex("(\d+) "),
      replace: it => it.text.slice(0, -1) + sym.space.nobreak,
    ),
    (
      pattern: " — ",
      replace: sym.space.nobreak + "—" + sym.space.nobreak,
    ),
    (
      pattern: " – ",
      replace: sym.space.nobreak + "–" + sym.space.nobreak,
    ),
  ),
  en: (),
)

#let apply(lang: "ru", content) = {
  let lang-rules = rules.at(lang, default: ())

  let result = content
  for rule in lang-rules.rev() {
    result = {
      show rule.pattern: rule.replace
      result
    }
  }

  result
}
