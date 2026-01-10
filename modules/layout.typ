#import "/modules/utils.typ": parse-parameters, regex-rules

#let data = yaml("/assets/data/layout.yml")
#let mode = data.at("mode")

#let get(key, section: mode) = {
  let keys = key.split(".")

  let value = data.at(section, default: data.default)

  for k in keys {
    if type(value) == dictionary and k in value {
      value = value.at(k)
      if type(value) != dictionary {
        break
      }
    } else {
      value = none
      break
    }
  }

  if value == none {
    value = data.default
    for k in keys {
      if type(value) == dictionary and k in value {
        value = value.at(k)
        if type(value) != dictionary {
          break
        }
      } else {
        value = none
        break
      }
    }
  }

  // Обработка строковых значений
  if value != none and type(value) == str {
    if value.match(regex(regex-rules.w-s-unit)) != none {
      return parse-parameters(value)
    }

    let starts-from-digit = value.match(regex("^\\d")) != none
    let has-units = value.match(regex("\\d+(pt|mm|cm|in|em|%|deg|rad|fr)")) != none
    let has-operators = value.match(regex("\\s[+\\-*/]\\s")) != none

    if starts-from-digit and (has-units or has-operators) {
      return eval(value)
    }
  }

  return value
}
