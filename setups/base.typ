#let init(body) = {
  set page(
    margin: 2cm,
    footer: context [
      #set align(right)
      #set text(8pt)
      #counter(page).display(
        "1 | 1",
        both: true,
      )
    ],
  )
  set par(
    justify: true,
    leading: 0.65em,
    spacing: 0.65em,
    linebreaks: "optimized",
  )
  set text(
    hyphenate: true,
    overhang: true,
    ligatures: true,
    historical-ligatures: true,
    number-type: "lining",
  )
  body
}
