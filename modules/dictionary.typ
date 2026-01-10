#let data = yaml("/assets/data/glossary.yml")

#let get-term(termLabel) = {
  let searchKey = lower(termLabel)
  let termString = data.at(searchKey, default: none)

  if termString == none {
    return text(fill: red)[Term called “#termLabel” not found in dictionary.]
  }

  let title = termString.at("title", default: searchKey)
  let note = termString.at("note", default: none)
  let abstract = termString.at("long")
  let abstractStart = [#sym.space.nobreak—]

  note = if note != none { " (" + note + ")" } else {}

  let output = [#title#note#abstractStart#abstract]

  return apply-handle()[#output]
}
