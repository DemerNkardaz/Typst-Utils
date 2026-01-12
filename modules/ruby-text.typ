#let ruby(
  base,
  annotation: none,
  // Positioning
  pos: top, // top, bottom, or specific length
  alignment: "center", // center, start, end, between, around, justify
  // Sizing
  anno-size: 0.5em, // annotation text size
  base-size: none, // override base text size
  // Spacing
  gap: 0.15em, // vertical gap between base and annotation
  side-bearing: 0.05em, // extra space on sides when annotation is wider
  // Styling
  annotation-style: none, // function to apply to annotation (e.g., emph, text.with(fill: red))
  base-style: none, // function to apply to base text
  // Advanced features
  delimiter: "|", // delimiter for splitting text
  auto-split: true, // automatically split by delimiter
  distribute: true, // distribute annotation evenly over base
  overhang: false, // allow annotation to overhang base text
  adjust-line-height: none, // auto, specific length, or none
  // Edge cases
  min-width: none, // minimum width for the ruby box
  compress: true, // compress spacing when multiple rubies are adjacent
  ..sink, // capture extra positional arguments for [] syntax
) = {
  // Handle both syntaxes:
  // 1. ruby(base, annotation, ...) - traditional
  // 2. ruby[base][annotation] - content block syntax
  let (final-base, final-annotation) = if annotation == none {
    let args = sink.pos()
    if args.len() == 0 {
      panic("ruby requires either annotation parameter or content blocks: ruby[base][annotation]")
    }
    (base, args.at(0))
  } else {
    (base, annotation)
  }

  assert(
    ("center", "start", "end", "between", "around", "justify").contains(alignment),
    message: "alignment must be one of: center, start, end, between, around, justify",
  )

  let is-top = if type(pos) == length { true } else { pos == top }

  let extract-text(content) = {
    if type(content) == str {
      return content
    } else if type(content) == content {
      if content.has("text") {
        return content.text
      } else if content.has("children") {
        return content.children.map(extract-text).join()
      } else if content.has("body") {
        return extract-text(content.body)
      } else if content.has("child") {
        return extract-text(content.child)
      }

      let func = content.func()
      if func == [ ].func() {
        return content.children.map(extract-text).join()
      } else if func == smartquote {
        return if content.double { "\"" } else { "'" }
      } else if func == space {
        return " "
      } else if func == linebreak {
        return "\n"
      }
    }
    let r = repr(content)
    if r.starts-with("[") and r.ends-with("]") {
      return r.slice(1, -1)
    }
    return r
  }

  let split-content(content) = {
    if not auto-split { return (content,) }
    let text-str = extract-text(content)
    let parts = text-str.split(delimiter)
    if parts.len() > 1 {
      return parts
    } else {
      return (content,)
    }
  }

  let base-parts = split-content(final-base)
  let anno-parts = split-content(final-annotation)

  // If lengths don't match, treat as single unit
  if base-parts.len() != anno-parts.len() and distribute {
    base-parts = (final-base,)
    anno-parts = (final-annotation,)
  }

  // Apply styles if provided
  let styled-base(content-val) = {
    let body = if type(content-val) == str { text(content-val) } else { content-val }
    if base-style != none {
      base-style(body)
    } else {
      body
    }
  }

  let styled-anno(content-val) = {
    let body = if type(content-val) == str { text(content-val) } else { content-val }
    if annotation-style != none {
      annotation-style(body)
    } else {
      body
    }
  }

  // Main rendering using layout - MUST return inline content
  box(layout(size => {
    let sum-body = []
    let sum-width = 0pt

    for i in range(base-parts.len()) {
      let base-part = base-parts.at(i)
      let anno-part = anno-parts.at(i)

      // Extract text for measurement
      let base-text = if type(base-part) == str { base-part } else { extract-text(base-part) }
      let anno-text = if type(anno-part) == str { anno-part } else { extract-text(anno-part) }

      // Create styled content
      let base-styled = styled-base(base-text)
      let anno-styled = styled-anno(anno-text)

      // Measure both parts
      let base-measured = measure(base-styled)
      let anno-plain-width = measure(text(size: anno-size, anno-styled)).width

      // Determine final width
      let width = if overhang {
        base-measured.width
      } else {
        calc.max(base-measured.width, anno-plain-width)
      }

      if min-width != none {
        width = calc.max(width, min-width)
      }

      // Add side bearing if annotation is wider
      if anno-plain-width > base-measured.width {
        width += side-bearing * 2
      }

      // Create distributed annotation text
      let gutter = if alignment == "center" or alignment == "start" {
        h(0pt)
      } else if alignment == "between" {
        h(1fr)
      } else if alignment == "around" or alignment == "justify" {
        h(1fr)
      }

      let chars = if alignment == "around" {
        h(0.5fr) + anno-text.clusters().join(gutter) + h(0.5fr)
      } else if alignment == "justify" {
        let clusters = anno-text.clusters()
        if clusters.len() > 1 {
          clusters.join(gutter)
        } else {
          anno-text
        }
      } else {
        anno-text.clusters().join(gutter)
      }

      // Create annotation box
      let anno-box = box(
        width: width,
        align(
          if alignment == "start" { left } else { center },
          text(size: anno-size, chars),
        ),
      )

      // Measure annotation box
      let anno-measured = measure(anno-box)

      // Calculate horizontal offset adjustments
      let dx = anno-measured.width - base-measured.width
      let (t-dx, l-dx, r-dx) = if alignment == "start" {
        (0pt, 0pt, dx)
      } else {
        (-dx / 2, dx / 2, dx / 2)
      }

      let (l, r) = (i != 0, i != base-parts.len() - 1)

      // Adjust sum-width for first element
      sum-width += if l { 0pt } else { t-dx }

      // Calculate vertical offset
      let dy = if is-top {
        if type(pos) == length {
          -anno-measured.height - gap - pos
        } else {
          -1.5 * anno-measured.height - gap
        }
      } else {
        base-measured.height + anno-measured.height / 2 + gap
      }

      // Place annotation
      place(
        top + left,
        dx: sum-width,
        dy: dy,
        anno-box,
      )

      // Update sum-width and sum-body
      sum-width += width
      sum-body += if l { h(l-dx) } + base-styled + if r { h(r-dx) }
    }

    sum-body
  }))
}

// Convenience presets
#let tip(base, reading, ..args) = ruby(
  base,
  reading,
  anno-size: 0.5em,
  gap: 0.05em,
  alignment: "center",
  ..args,
)

#let furigana(base, reading, ..args) = ruby(
  base,
  reading,
  anno-size: 0.5em,
  alignment: "center",
  ..args,
)

#let phonetic(base, ipa, ..args) = ruby(
  base,
  ipa,
  anno-size: 0.6em,
  alignment: "center",
  annotation-style: text.with(style: "italic"),
  ..args,
)

#let gloss(base, translation, ..args) = ruby(
  base,
  translation,
  pos: bottom,
  anno-size: 0.55em,
  alignment: "center",
  annotation-style: text.with(style: "italic", fill: gray),
  ..args,
)

#let interlinear(base, morphemes, translation: none, ..args) = {
  let result = ruby(
    base,
    morphemes,
    pos: bottom,
    anno-size: 0.5em,
    alignment: "center",
    annotation-style: text.with(font: "Liberation Mono", size: 0.5em),
    ..args,
  )

  if translation != none {
    result + [ ] + text(style: "italic", size: 0.9em, translation)
  } else {
    result
  }
}

#let ruby-text(content, rules: (:)) = {
  let result = content
  for (base, anno) in rules {
    result = result.replace(base, ruby(base, anno))
  }
  result
}

#let ruby-lines(..lines) = {
  let pairs = lines.pos()
  stack(
    dir: ttb,
    spacing: 1.2em,
    ..pairs.map(pair => ruby(pair.at(0), pair.at(1))),
  )
}
