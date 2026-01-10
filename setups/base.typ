#import "/modules/layout.typ": get as layout-get

#let init(body) = {
  set page(
    width: layout-get("page.width"),
    height: layout-get("page.height"),
    margin: (
      top: layout-get("page.top-margin"),
      bottom: layout-get("page.bottom-margin"),
      inside: layout-get("page.inside-margin"),
      outside: layout-get("page.outside-margin"),
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
    first-line-indent: layout-get("first-line-indent"),
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
