// #let data = json("../dictionary.json")
// #import "../data/dictionary.typ": data

#import "utils.typ": makeDictCI
#import "text_locale.typ": apply as TextLocale

#let data = makeDictCI(yaml("../data/dictionary.yml"))


#let termHandle(key, text) = {
  show regex("<\#K>"): it => (data.key)(key)

  show regex("<\|\[([A-Z]{2,3})\](?:\[([^\]]+)\])?\|\{([^{}]*)\}>"): match => {
    let captures = match.text.match(regex("<\|\[([A-Z]{2,3})\](?:\[([^\]]+)\])?\|\{([^{}]*)\}>")).captures

    let lang = captures.at(0)
    let fontStr = captures.at(1)
    let content = captures.at(2)

    let font = if fontStr != none and fontStr != "" {
      // Убираем кавычки если есть
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
  }

  text
}

#let getTerm(termLabel) = {
  let searchKey = lower(termLabel)
  let termString = (data.get)(searchKey)

  if termString == none {
    return text(fill: red)[Term called “#termLabel” not found in dictionary.]
  }

  termString = termHandle(searchKey, termString)

  return termString
}


#getTerm("Сёгун")
