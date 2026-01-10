#let data = yaml("/assets/data/layout.yml")
#let mode = data.at("mode")

#let get(key, section: mode) = {
  let value = data.at(section, default: data.default).at(key, default: none)

  if value == none {
    value = data.default.at(key, default: none)
  }

  if type(value) == str {
    return eval(value)
  }

  return value
}
