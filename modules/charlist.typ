/*!
 * Character List Module
 * A collection of special characters for easy reference in Typst documents.
 */
#let chr = (
  c: (
    acute: "\u{0301}",
    breve: "\u{0306}",
    cedilla: "\u{0327}",
  ),
  tab: "\u{0009}", // Tab
  sp: "\u{0020}", // Space
  nbsp: "\u{00A0}", // No-Break Space
  enqd: "\u{2001}", // Em Quad
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
  a_with_breve_and_acute: "\u{1EAF}", // ấ
)
