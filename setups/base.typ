#import "/modules/layout.typ": get as layout-get

#let init(body) = {
  set page(
    width: layout-get("page.width"),
    height: layout-get("page.height"),
    margin: (
      top: layout-get("page.margin.top"),
      bottom: layout-get("page.margin.bottom"),
      inside: layout-get("page.margin.inside"),
      outside: layout-get("page.margin.outside"),
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
