/*
 * Case-Insensitive Dictionary
 */
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
