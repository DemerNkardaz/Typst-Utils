/*!
 * Character List Module
 * A collection of special characters for easy reference in Typst documents.
 */
#let list = (
  c: (
    acute: "\u{0301}",
    breve: "\u{0306}",
    cedilla: "\u{0327}",
  ),
  lig: (
    AA: "\u{A732}",
    aa: "\u{A733}",
    AE: "\u{00C6}",
    ae: "\u{00E6}",
    AO: "\u{A734}",
    ao: "\u{A735}",
    AU: "\u{A736}",
    au: "\u{A737}",
    AV: "\u{A738}",
    av: "\u{A739}",
    AY: "\u{A73C}",
    ay: "\u{A73D}",
    db: "\u{0238}",
    ie: "\u{AB61}",
    ff: "\u{FB00}",
    fi: "\u{FB01}",
    fl: "\u{FB02}",
    ffi: "\u{FB04}",
    ffl: "\u{FB03}",
    IJ: "\u{0132}",
    ij: "\u{0133}",
    OE: "\u{0152}",
    oe: "\u{0153}",
    OO: "\u{A74E}",
    oo: "\u{A74F}",
    OU: "\u{0222}",
    ou: "\u{0223}",
    qp: "\u{0239}",
    ſt: "\u{FB05}",
    st: "\u{FB06}",
    ue: "\u{1D6B}",
    uo: "\u{AB63}",
    VY: "\u{A760}",
    vy: "\u{A761}",
  ),
  tab: "\u{0009}", // Tab
  sp: "\u{0020}", // Space
  nbsp: "\u{00A0}", // No-Break Space
  enqd: "\u{2000}", // Em Quad
  emqd: "\u{2001}", // Em Quad
  ensp: "\u{2002}", // En Space
  emsp: "\u{2003}", // Em Space
  emsp13: "\u{2004}", // Three-Per-Em Space
  emsp14: "\u{2005}", // Four-Per-Em Space
  emsp16: "\u{2006}", // Six-Per-Em Space
  figsp: "\u{2007}", // Figure Space
  punctsp: "\u{2008}", // Punctuation Space
  thinsp: "\u{2009}", // Thin Space
  hairsp: "\u{200A}", // Hair Space
  zwsp: "\u{200B}", // Zero Width Space
  nnbsp: "\u{202F}", // Narrow No-Break Space
  medmathsp: "\u{205F}", // Medium Mathematical Space
  zwnbsp: "\u{FEFF}", // Zero Width No-Break Space
  // ----
  wj: "\u{2060}", // Word Joiner
  zwj: "\u{200C}", // Zero Width Joiner
  zwnj: "\u{200D}", // Zero Width Non-Joiner
  // Just for test
  a-with-breve-and-acute: "\u{1EAF}", // ấ
)

#let ligature(content) = {
  list.lig.at(content, default: content)
}
