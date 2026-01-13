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
  auto-spacing: true, // automatically add spacing when annotation overflows
  // Styling
  annotation-style: none, // function to apply to annotation (e.g., emph, text.with(fill: red))
  base-style: none, // function to apply to base text
  // Wrappers
  wrapper: none, // wrapper for base text: "[ * ]" splits on " * "
  anno-wrapper: none, // wrapper for annotations (none=inherit wrapper, false=disable)
  wrap-anno-parts: false, // wrap each annotation part separately
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

  // Parse wrapper strings
  let parse-wrapper(w) = {
    if w == none or w == false { return none }
    if type(w) != str { return none }
    let parts = w.split(" * ")
    if parts.len() != 2 { return none }
    return (left: parts.at(0), right: parts.at(1))
  }

  let base-wrapper = parse-wrapper(wrapper)
  let actual-anno-wrapper = if anno-wrapper == none {
    base-wrapper
  } else if anno-wrapper == false {
    none
  } else {
    parse-wrapper(anno-wrapper)
  }

  // Apply wrapper to content
  let apply-wrapper(content, wrap) = {
    if wrap == none { return content }
    wrap.left + content + wrap.right
  }

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
    let body = if type(content-val) == str { content-val } else { content-val }
    if annotation-style != none {
      // Apply both size and style together
      annotation-style(text(size: anno-size, body))
    } else {
      text(size: anno-size, body)
    }
  }

  // Main rendering using layout - MUST return inline content
  box(layout(size => {
    let sum-body = []
    let sum-width = 0pt

    // Pre-calculate parts and measure with wrapper
    let part-info = ()

    // First, build the complete wrapped base to measure wrapper widths
    let all-base-styled = base-parts
      .map(p => {
        let text-val = if type(p) == str { p } else { extract-text(p) }
        styled-base(text-val)
      })
      .join()

    let wrapped-base-styled = if base-wrapper != none {
      apply-wrapper(all-base-styled, base-wrapper)
    } else {
      all-base-styled
    }

    // Measure wrapper overhead
    let wrapper-left-width = 0pt
    let wrapper-right-width = 0pt
    if base-wrapper != none {
      let total-wrapped = measure(wrapped-base-styled).width
      let total-unwrapped = measure(all-base-styled).width
      let wrapper-overhead = total-wrapped - total-unwrapped

      let left-part = measure(text(base-wrapper.left)).width
      let right-part = measure(text(base-wrapper.right)).width

      wrapper-left-width = left-part
      wrapper-right-width = right-part
    }

    for i in range(base-parts.len()) {
      let base-part = base-parts.at(i)
      let anno-part = anno-parts.at(i)

      let base-text = if type(base-part) == str { base-part } else { extract-text(base-part) }
      let anno-text = if type(anno-part) == str { anno-part } else { extract-text(anno-part) }

      let base-styled = styled-base(base-text)

      // For annotation: apply wrapper per part ONLY if wrap-anno-parts is true
      let wrapped-anno = if wrap-anno-parts and actual-anno-wrapper != none {
        apply-wrapper(anno-text, actual-anno-wrapper)
      } else {
        anno-text
      }
      let anno-styled = styled-anno(wrapped-anno)

      let base-measured = measure(base-styled)
      let anno-plain-width = measure(anno-styled).width

      let width = if overhang {
        base-measured.width
      } else {
        calc.max(base-measured.width, anno-plain-width)
      }

      if min-width != none {
        width = calc.max(width, min-width)
      }

      let extra-bearing = 0pt
      if anno-plain-width > base-measured.width {
        extra-bearing = side-bearing * 2
        width += extra-bearing
      }

      part-info.push((
        base-text: base-text,
        anno-text: wrapped-anno,
        base-styled: base-styled,
        anno-styled: anno-styled,
        base-measured: base-measured,
        anno-plain-width: anno-plain-width,
        width: width,
        extra-bearing: extra-bearing,
      ))
    }

    // Wrap all annotations together if wrap-anno-parts is false
    if not wrap-anno-parts and actual-anno-wrapper != none {
      // Collect all annotation parts
      let all-anno-text = anno-parts
        .map(p => {
          if type(p) == str { p } else { extract-text(p) }
        })
        .join(delimiter)

      let wrapped = apply-wrapper(all-anno-text, actual-anno-wrapper)

      // Re-split the wrapped annotation
      let wrapped-parts = wrapped.split(delimiter)

      for i in range(part-info.len()) {
        let wrapped-part = if i < wrapped-parts.len() {
          wrapped-parts.at(i)
        } else {
          part-info.at(i).anno-text
        }

        let new-styled = styled-anno(wrapped-part)
        part-info.at(i).anno-text = wrapped-part
        part-info.at(i).anno-styled = new-styled

        // Recalculate width with wrapper
        let new-width = measure(new-styled).width
        part-info.at(i).anno-plain-width = new-width

        if not overhang {
          part-info.at(i).width = calc.max(part-info.at(i).base-measured.width, new-width)
        }
      }
    }

    // Calculate left and right padding based on first and last parts
    let left-pad = 0pt
    let right-pad = 0pt

    if part-info.len() > 0 and auto-spacing {
      let first = part-info.at(0)
      let last = part-info.at(-1)

      if not overhang {
        if first.anno-plain-width > first.base-measured.width {
          left-pad = (first.anno-plain-width - first.base-measured.width) / 2 + side-bearing
        }

        if last.anno-plain-width > last.base-measured.width {
          right-pad = (last.anno-plain-width - last.base-measured.width) / 2 + side-bearing
        }
      }
    }

    // Add wrapper left width to initial sum-width before rendering parts
    sum-width = wrapper-left-width

    // Render each part with wrapper offset consideration
    for i in range(part-info.len()) {
      let info = part-info.at(i)

      // Create distributed annotation text
      let gutter = if alignment == "center" or alignment == "start" {
        h(0pt)
      } else if alignment == "between" {
        h(1fr)
      } else if alignment == "around" or alignment == "justify" {
        h(1fr)
      }

      let chars = if alignment == "around" {
        h(0.5fr) + info.anno-text.clusters().join(gutter) + h(0.5fr)
      } else if alignment == "justify" {
        let clusters = info.anno-text.clusters()
        if clusters.len() > 1 {
          clusters.join(gutter)
        } else {
          info.anno-text
        }
      } else {
        info.anno-text.clusters().join(gutter)
      }

      // Apply styling to the distributed characters
      let styled-chars = if annotation-style != none {
        annotation-style(text(size: anno-size, chars))
      } else {
        text(size: anno-size, chars)
      }

      // Create annotation box
      let anno-box = box(
        width: info.width,
        align(
          if alignment == "start" { left } else { center },
          styled-chars,
        ),
      )

      let anno-measured = measure(anno-box)

      // Calculate horizontal offset adjustments
      let dx = anno-measured.width - info.base-measured.width
      let (t-dx, l-dx, r-dx) = if alignment == "start" {
        (0pt, 0pt, dx)
      } else {
        (-dx / 2, dx / 2, dx / 2)
      }

      let (l, r) = (i != 0, i != part-info.len() - 1)

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
        info.base-measured.height + anno-measured.height / 2 + gap
      }

      // Place annotation (wrapper offset already in sum-width)
      place(
        top + left,
        dx: sum-width + left-pad,
        dy: dy,
        anno-box,
      )

      // Update sum-width and sum-body
      sum-width += info.width
      sum-body += if l { h(l-dx) } + info.base-styled + if r { h(r-dx) }
    }

    // Apply wrapper to the ENTIRE base text once at the end
    let final-body = if base-wrapper != none {
      apply-wrapper(sum-body, base-wrapper)
    } else {
      sum-body
    }

    // Return content with proper padding
    h(left-pad) + final-body + h(right-pad)
  }))
}

// Convenience presets
#let tip(base, reading, ..args) = ruby(
  base,
  reading,
  anno-size: 0.5em,
  gap: 0.05em,
  alignment: "center",
  auto-spacing: false,
  anno-wrapper: "( * )",
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
  auto-spacing: false,
  ..args,
)

#let gloss(base, translation, ..args) = ruby(
  base,
  translation,
  pos: bottom,
  anno-size: 0.55em,
  alignment: "center",
  annotation-style: text.with(style: "italic", fill: gray),
  auto-spacing: false,
  anno-wrapper: "[ * ]",
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
    auto-spacing: false,
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
