#let glossary-state = state("glossary-entries", (:))
#let cited-state = state("cited-glossary", ())
#let glossary-config = state("glossary-config", (
  glossary-number-style-in-text: none,
  glossary-number-style: none,
))

#let key-aliases = (
  key: ("ключ",),
  title: ("заголовок", "загл", "название", "назв"),
  long: ("description", "описание", "длинное", "длин"),
  short: ("короткое", "кор", "краткое", "крат"),
  note: ("заметка", "зам"),
)

#let get-key-from-alias(alias) = {
  let alias-lower = lower(alias)
  let result = key-aliases
    .pairs()
    .find(pair => {
      alias-lower in pair.at(1).map(a => lower(a))
    })

  if result != none {
    return result.at(0)
  }
  return none
}

#let process-markup(text) = {
  if type(text) == str and text != "" {
    let parts = text.split("\n")

    if parts.len() == 1 {
      return eval(text, mode: "markup")
    }

    let result = []
    for (i, part) in parts.enumerate() {
      if part.trim() != "" or i == 0 {
        result += eval(part, mode: "markup")
      }
      if i < parts.len() - 1 {
        result += linebreak()
      }
    }
    result
  } else {
    text
  }
}

#let glossary-entry(key, title: "", note: none, long: "", short: "") = {
  glossary-state.update(entries => {
    entries.insert(key, (
      key: key,
      title: if title == "" { key } else { process-markup(title) },
      note: if note != none { process-markup(note) } else { none },
      long: process-markup(long),
      short: if short == "" { process-markup(long) } else { process-markup(short) },
    ))
    entries
  })
}

#let load(paths) = {
  let paths-array = if type(paths) == str {
    (paths,)
  } else if type(paths) == array {
    paths
  } else {
    panic("load() принимает строку (путь) или массив строк (пути)")
  }

  for path in paths-array {
    let data = yaml(path)

    for (key, entry) in data {
      if type(entry) == dictionary {
        // Нормализуем ключи через алиасы
        let normalized-entry = (:)

        for (entry-key, entry-value) in entry {
          let canonical-key = get-key-from-alias(entry-key)
          if canonical-key != none {
            normalized-entry.insert(canonical-key, entry-value)
          } else if entry-key in key-aliases.keys() {
            // Ключ уже канонический
            normalized-entry.insert(entry-key, entry-value)
          } else {
            // Неизвестный ключ - игнорируем или можно выдать предупреждение
            normalized-entry.insert(entry-key, entry-value)
          }
        }

        glossary-entry(
          key,
          title: normalized-entry.at("title", default: ""),
          note: normalized-entry.at("note", default: none),
          long: normalized-entry.at("long", default: ""),
          short: normalized-entry.at("short", default: ""),
        )
      } else if type(entry) == str {
        glossary-entry(key, long: entry)
      }
    }
  }
}

#let __has_entry(key) = {
  key in glossary-state.final().keys()
}

#let __get_entry_number(key, entries, cited) = {
  let cited-entries = cited.filter(k => k in entries).map(k => entries.at(k))
  let uncited-entries = entries.pairs().filter(((k, _)) => k not in cited).map(((_, entry)) => entry)

  let all-entries = cited-entries + uncited-entries

  let index = all-entries.position(e => e.key == key)
  if index != none {
    index + 1
  } else {
    0
  }
}

#let __format_number(number, pattern) = {
  if pattern == none {
    return str(number) + "."
  }

  let pattern-str = if type(pattern) == str {
    pattern
  } else {
    str(pattern)
  }

  let use-super = pattern-str.starts-with("^")
  let use-sub = pattern-str.starts-with("_")

  if use-super or use-sub {
    pattern-str = pattern-str.slice(1)
  }

  let result = ""
  for char in pattern-str.clusters() {
    if char.match(regex("\\d")) != none {
      result += str(number)
    } else {
      result += char
    }
  }

  if use-super {
    super(result)
  } else if use-sub {
    sub(result)
  } else {
    result
  }
}

#let glossary-ref(key) = {
  cited-state.update(cited => {
    if key not in cited {
      cited.push(key)
    }
    cited
  })

  context {
    let entries = glossary-state.get()
    let cited = cited-state.get()
    let config = glossary-config.get()

    if key in entries {
      let number = __get_entry_number(key, entries, cited)
      let formatted = __format_number(number, config.glossary-number-style-in-text)

      link(label(key), formatted)
    } else {
      text(fill: red, [@#key (не найдено)])
    }
  }
}

#let print() = context {
  let entries = glossary-state.get()
  let cited = cited-state.get()
  let config = glossary-config.get()

  let cited-entries = cited.filter(key => key in entries).map(key => entries.at(key))
  let uncited-entries = entries.pairs().filter(((key, _)) => key not in cited).map(((_, entry)) => entry)

  let all-entries = cited-entries + uncited-entries

  let max-num-width = all-entries
    .enumerate()
    .fold(0pt, (max-w, item) => {
      let (index, entry) = item
      let formatted-num = __format_number(index + 1, config.glossary-number-style)
      calc.max(max-w, measure(formatted-num).width)
    })

  for (index, entry) in all-entries.enumerate() {
    let number = index + 1
    let formatted-number = __format_number(number, config.glossary-number-style)

    [#metadata(entry.key)#label(entry.key)]

    block(
      width: 100%,
      inset: (left: 0pt),
      breakable: true,
      {
        grid(
          columns: (max-num-width + 1em, 1fr),
          align: (left + top, left),
          formatted-number,
          {
            set par(hanging-indent: 1em, first-line-indent: -1em)

            [#strong[#entry.title]]

            if entry.note != none {
              [ (#entry.note)]
            }

            if entry.long != "" and type(entry.long) != content {
              [ — #entry.long]
            } else if type(entry.long) == content {
              [ — ]
              entry.long
            }
          },
        )
      },
    )

    v(0.65em, weak: true)
  }
}

#let init(
  glossary-number-style-in-text: none,
  glossary-number-style: none,
  sources: none,
  body,
) = {
  if sources != none {
    load(sources)
  }

  glossary-config.update((
    glossary-number-style-in-text: glossary-number-style-in-text,
    glossary-number-style: glossary-number-style,
  ))

  show ref: r => {
    let key = str(r.target)
    if __has_entry(key) {
      glossary-ref(key)
    } else {
      r
    }
  }

  body
}
