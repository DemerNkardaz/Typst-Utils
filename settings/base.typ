#import "/modules/layout.typ": get as layout-get

#let init(body) = {
  let page-paper = layout-get("page.paper")
  let page-size = layout-get("page.size")
  let page-width = layout-get("page.width")
  let page-height = layout-get("page.height")

  if page-width == none {
    page-width = page-size.at(0)
  }
  if page-height == none {
    page-height = page-size.at(1)
  }

  let page-params = if page-paper != "custom" {
    (paper: lower(page-paper))
  } else {
    (
      width: page-width,
      height: page-height,
    )
  }

  set page(
    ..page-params,
    margin: (
      top: layout-get("page.margin.top"),
      bottom: layout-get("page.margin.bottom"),
      inside: layout-get("page.margin.inside"),
      outside: layout-get("page.margin.outside"),
    ),
    footer: context [
      #set align(center)
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
    size: layout-get("font.size"),
    hyphenate: true,
    overhang: true,
    ligatures: true,
    historical-ligatures: true,
    number-type: "lining",
  )

  body
}
