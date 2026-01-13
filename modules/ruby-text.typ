#let ruby(
  base,
  annotation: none,
  pos: top, // top, bottom, or specific length
  alignment: "center", // center, start, end, between, around, justify
  anno-size: 0.5em, // annotation text size
  base-size: none, // override base text size
  gap: 0.3em, // vertical gap between base and annotation
  side-bearing: 0.05em, // extra space on sides when annotation is wider
  auto-spacing: true, // automatically add spacing when annotation overflows
  annotation-style: none, // function to apply to annotation (e.g., emph, text.with(fill: red))
  base-style: none, // function to apply to base text
  wrapper: none, // wrapper for base text: "[ * ]" splits on " * "
  anno-wrapper: none, // wrapper for annotations (none=inherit wrapper, false=disable)
  wrap-anno-parts: false, // wrap each annotation part separately
  delimiter: "|", // delimiter for splitting text
  auto-split: true, // automatically split by delimiter
  distribute: true, // distribute annotation evenly over base
  overhang: false, // allow annotation to overhang base text
  adjust-line-height: none, // auto, specific length, or none
  min-width: none, // minimum width for the ruby box
  compress: true, // compress spacing when multiple rubies are adjacent
  ..sink, // capture extra positional arguments for [] syntax
) = {
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

  if base-parts.len() != anno-parts.len() and distribute {
    base-parts = (final-base,)
    anno-parts = (final-annotation,)
  }

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
      annotation-style(text(size: anno-size, body))
    } else {
      text(size: anno-size, body)
    }
  }

  box(layout(size => {
    let sum-body = []
    let sum-width = 0pt

    let part-info = ()

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

    if not wrap-anno-parts and actual-anno-wrapper != none {
      let all-anno-text = anno-parts
        .map(p => {
          if type(p) == str { p } else { extract-text(p) }
        })
        .join(delimiter)

      let wrapped = apply-wrapper(all-anno-text, actual-anno-wrapper)

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

        let new-width = measure(new-styled).width
        part-info.at(i).anno-plain-width = new-width

        if not overhang {
          part-info.at(i).width = calc.max(part-info.at(i).base-measured.width, new-width)
        }
      }
    }

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


    sum-width = wrapper-left-width

    for i in range(part-info.len()) {
      let info = part-info.at(i)

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

      let styled-chars = if annotation-style != none {
        annotation-style(text(size: anno-size, chars))
      } else {
        text(size: anno-size, chars)
      }

      let anno-box = box(
        width: info.width,
        align(
          if alignment == "start" { left } else { center },
          styled-chars,
        ),
      )

      let anno-measured = measure(anno-box)

      let dx = anno-measured.width - info.base-measured.width
      let (t-dx, l-dx, r-dx) = if alignment == "start" {
        (0pt, 0pt, dx)
      } else {
        (-dx / 2, dx / 2, dx / 2)
      }

      let (l, r) = (i != 0, i != part-info.len() - 1)

      sum-width += if l { 0pt } else { t-dx }

      let dy = if is-top {
        if type(pos) == length {
          -anno-measured.height - gap - pos
        } else {
          -1.5 * anno-measured.height - gap
        }
      } else {
        info.base-measured.height + anno-measured.height / 2 + gap
      }

      place(
        top + left,
        dx: sum-width + left-pad,
        dy: dy,
        anno-box,
      )

      sum-width += info.width
      sum-body += if l { h(l-dx) } + info.base-styled + if r { h(r-dx) }
    }

    let final-body = if base-wrapper != none {
      apply-wrapper(sum-body, base-wrapper)
    } else {
      sum-body
    }

    h(left-pad) + final-body + h(right-pad)
  }))
}

// Convenience presets
#let tip(base, reading, ..args) = ruby(
  base,
  reading,
  anno-size: 0.55em,
  gap: 0.25em,
  alignment: "center",
  auto-spacing: false,
  anno-wrapper: "( * )",
  ..args,
)

#let furigana(base, reading, ..args) = ruby(
  base,
  reading,
  anno-size: 0.6em,
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
