#let kdl(filepath, to-dict: true) = {
  let content = read(filepath)

  // 1. Предварительная очистка блочных комментариев /* ... */
  // Используем жадное регулярное выражение для удаления всего между /* и */
  let clean_content = content.replace(regex("/\*[\s\S]*?\*/"), "")

  // 2. Очистка строк от // и фильтрация пустых строк
  let lines = clean_content.split("\n").map(line => line.split("//").at(0).trim()).filter(line => line != "")

  let cast_value(val) = {
    let v = val.trim().trim("\"").trim("'").trim(",").trim("[").trim("]")
    if v == "" { return none }
    if v == "true" { return true }
    if v == "false" { return false }
    if v == "null" or v == "none" { return none }
    if v == "auto" { return auto }
    if v.match(regex("^-?\d+$")) != none { return int(v) }
    if v.match(regex("^-?\d+\.\d+$")) != none { return float(v) }
    let has-units = v.match(regex("^-?\d+(\.\d+)?(pt|mm|cm|in|em|%|deg|rad|fr)$")) != none
    if has-units { return eval(v) }
    return v
  }

  let parse_node(lines_slice) = {
    let nodes = (:)
    let i = 0

    while i < lines_slice.len() {
      let line = lines_slice.at(i)

      // Пропуск узлов с префиксом /-
      if line.starts-with("/-") {
        i += 1
        if line.ends-with("{") {
          let depth = 1
          while depth > 0 and i < lines_slice.len() {
            if lines_slice.at(i).ends-with("{") { depth += 1 }
            if lines_slice.at(i) == "}" { depth -= 1 }
            i += 1
          }
        }
        continue
      }

      if line == "}" or line == "]" { return (nodes, i) }

      let main_match = line.match(regex("^([\w-]+)\s*(.*?)\s*([\{\[]?)$"))
      if main_match != none {
        let name = main_match.captures.at(0)
        let rest = main_match.captures.at(1)
        let opener = main_match.captures.at(2)

        let node_data = (values: (), props: (:), children: (:))

        let tokens = rest.matches(
          regex("(/-)?\s*([\w-]+)=((?:\"[^\"]*\"|'[^']*'|[^\s{}]+))|(/-)?\s*(\"[^\"]*\"|'[^']*'|[^\s{}\[\]]+)"),
        )

        for token in tokens {
          if token.captures.at(0) != none or token.captures.at(3) != none { continue }

          if token.captures.at(1) != none {
            node_data.props.insert(token.captures.at(1), cast_value(token.captures.at(2)))
          } else {
            node_data.values.push(cast_value(token.captures.at(4)))
          }
        }

        if opener == "[" {
          let j = i + 1
          while j < lines_slice.len() and lines_slice.at(j) != "]" {
            let val = cast_value(lines_slice.at(j))
            if val != none { node_data.values.push(val) }
            j += 1
          }
          i = j
        } else if opener == "{" {
          let (child_nodes, offset) = parse_node(lines_slice.slice(i + 1))
          node_data.children = child_nodes
          i += offset + 1
        }

        let final_entry = node_data
        if to-dict {
          let has_props = node_data.props.len() > 0
          let has_children = node_data.children.len() > 0

          if not has_props and not has_children {
            if node_data.values.len() == 1 {
              final_entry = node_data.values.at(0)
            } else {
              final_entry = node_data.values
            }
          } else {
            final_entry = (:)
            for (k, v) in node_data.props { final_entry.insert(k, v) }
            for (k, v) in node_data.children { final_entry.insert(k, v) }

            if node_data.values.len() == 1 {
              final_entry.insert("_value", node_data.values.at(0))
            } else if node_data.values.len() > 1 {
              final_entry.insert("_values", node_data.values)
            }
          }
        }

        if name in nodes {
          if type(nodes.at(name)) != array {
            nodes.at(name) = (nodes.at(name), final_entry)
          } else {
            nodes.at(name).push(final_entry)
          }
        } else {
          nodes.insert(name, final_entry)
        }
      }
      i += 1
    }
    return (nodes, i)
  }

  let (result, _) = parse_node(lines)
  return result
}
