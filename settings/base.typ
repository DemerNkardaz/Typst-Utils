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
    justify: layout-get("paragraph.justification.enabled"),
    justification-limits: (
      spacing: (
        min: layout-get("paragraph.justification.spacing.min"),
        max: layout-get("paragraph.justification.spacing.max"),
      ),
      tracking: (
        min: layout-get("paragraph.justification.tracking.min"),
        max: layout-get("paragraph.justification.tracking.max"),
      ),
    ),
    leading: layout-get("paragraph.leading"),
    spacing: layout-get("paragraph.spacing"),
    first-line-indent: (
      amount: layout-get("paragraph.indent.first-line.amount"),
      all: layout-get("paragraph.indent.first-line.all"),
    ),
    hanging-indent: layout-get("paragraph.indent.hanging"),
    linebreaks: "optimized",
  )
  set text(
    size: layout-get("font.size"),
    hyphenate: layout-get("paragraph.hyphenation.enabled"),
    overhang: layout-get("paragraph.overhang"),
    ligatures: layout-get("text.ligatures"),
    // costs: (
    //   hyphenation: 100%,
    //   runt: 100%,
    //   widow: 100%,
    //   orphan: 100%,
    // ),
    historical-ligatures: true,
    kerning: layout-get("text.kerning"),
    number-type: layout-get("text.number-type"),
    number-width: layout-get("text.number-width"),
    top-edge: layout-get("text.edge.top"),
    bottom-edge: layout-get("text.edge.bottom"),
  )

  body
}
