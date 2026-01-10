#let data = yaml("/assets/data/layout.yml")
#let mode = data.at("mode")

#let get(key, section: mode) = {
  let keys = key.split(".")

  let value = data.at(section, default: data.default)

  for k in keys {
    if type(value) == dictionary and k in value {
      value = value.at(k)
    } else {
      // Если не нашли в секции, пробуем в default
      value = none
      break
    }
  }

  if value == none {
    value = data.default
    for k in keys {
      if type(value) == dictionary and k in value {
        value = value.at(k)
      } else {
        value = none
        break
      }
    }
  }

  if value != none and type(value) == str {
    return eval(value)
  }

  return value
}
