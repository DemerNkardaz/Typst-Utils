// #let data = json("../dictionary.json")
#import "../data/dictionary.typ": data

#let data = {
  let normalized = (:)
  for (key, value) in data {
    normalized.insert(lower(key), value)
  }
  normalized
}

#let getTerm(termLabel) = {
  let searchKey = lower(termLabel)
  let termString = data.at(searchKey, default: none)

  if termString == none {
    return text(fill: red)[Term called “#termLabel” not found in dictionary.]
  }

  return termString
}
