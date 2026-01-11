#let regex-rules = (
  w-s-unit: "^(\\d+)\\s*[×*]\\s*(\\d+)\\s*in\\s*(.+)$",
)

#let make-ci-dict(dict) = {
  let lookup = (:)

  for (k, v) in dict {
    lookup.insert(lower(k), (key: k, value: v))
  }

  (
    get: key => {
      let entry = lookup.at(lower(key), default: none)
      if entry != none { entry.value } else { none }
    },
    key: key => {
      let entry = lookup.at(lower(key), default: none)
      if entry != none { entry.key } else { none }
    },
    entry: key => lookup.at(lower(key), default: none),
  )
}

#let parse-parameters(content) = {
  let match = content.match(regex(regex-rules.w-s-unit))

  if match != none {
    let captures = match.captures
    let first = captures.at(0)
    let second = captures.at(1)
    let unit = captures.at(2)

    return (
      eval(first + unit),
      eval(second + unit),
    )
  }

  return content
}

#let include-with-context(items, ..scopeContext) = {
  let scope = scopeContext.named()

  let item-list = if type(items) == array {
    items
  } else {
    (items,)
  }

  for item in item-list {
    if type(item) == str {
      eval(read(item), mode: "markup", scope: scope)
    } else if type(item) == function {
      item()
    } else {
      item
    }
  }
}
