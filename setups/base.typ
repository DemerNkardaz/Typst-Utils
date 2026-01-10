#import "/modules/layout.typ": get as layout-get

#let init(body) = {
  set page(
    margin: (
      top: layout-get("top-margin"),
      bottom: layout-get("bottom-margin"),
      inside: layout-get("inside-margin"),
      outside: layout-get("outside-margin"),
    ),
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
