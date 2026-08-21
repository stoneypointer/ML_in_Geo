// ========================================================
//    RWTH short-report template (Typst)
//    Derived from the GIM thesis template, stripped down to
//    a <=10 page, Times New Roman 11 pt course report.
// ========================================================

// --- Design tokens -------------------------------------------------------
#let rwth-blue = rgb("#00549F")
#let accent-color = rwth-blue
#let muted-color = rgb("#6b7280")

// The course requires Times New Roman. The fallbacks keep the document
// renderable on machines where that exact font is not installed.
// (On Linux, install `fonts-liberation` — Liberation Serif is metric-compatible
// with Times New Roman. Typst logs a harmless warning for fallbacks it cannot find.)
#let body-font = ("Times New Roman", "Times", "Liberation Serif")
#let mono-font = ("Menlo", "DejaVu Sans Mono")
#let math-font = ("STIX Two Math", "New Computer Modern Math")

// Line spacing presets. Typst `leading` is the gap *between* lines, so these
// are tuned to visually match Word's "single" and "1.5 lines" at 11 pt.
#let leading-for(mode) = if mode == "onehalf" { 1.05em } else { 0.65em }
#let par-spacing-for(mode) = if mode == "onehalf" { 1.25em } else { 0.75em }

// Flipped by `front_matter()` once the numbered body begins. The page footer
// is defined once, globally, and consults this — a `set page(..)` issued from
// inside a function would be scoped to that function's own content.
#let body_started = state("body-started", false)

// Truncates a figure/table caption to its first sentence, for use in the
// List of Figures / List of Tables (ported from the GIM thesis template).
// A sentence boundary is a period followed by whitespace-then-uppercase-letter
// or end of string, which avoids false hits on abbreviations like "Fig. 5.1A".
#let sentence-boundary-re = regex("\.\s")
#let sentence-upper-re = regex("^[A-Z]")

#let first-sentence(node) = {
  if node.has("text") {
    let t = node.text
    let found = none
    for m in t.matches(sentence-boundary-re) {
      let after = t.at(m.end, default: "")
      if after == "" or after.match(sentence-upper-re) != none {
        found = m.start + 1
        break
      }
    }
    if found == none and t.ends-with(".") {
      found = t.len()
    }
    if found != none {
      (text(t.slice(0, found)), true)
    } else {
      (node, false)
    }
  } else if node.has("children") {
    let out = ()
    let done = false
    for child in node.children {
      if done { break }
      let (c, d) = first-sentence(child)
      out.push(c)
      done = d
    }
    (out.sum(default: [ ]), done)
  } else if node.func() == emph {
    let (c, d) = first-sentence(node.body)
    (emph(c), d)
  } else if node.func() == strong {
    let (c, d) = first-sentence(node.body)
    (strong(c), d)
  } else {
    (node, false)
  }
}

// --- Cover page ----------------------------------------------------------
#let cover_page(
  title: [],
  subtitle: none,
  course: none,
  students: (),
  supervisors: none,
  date: none,
  logo: none,
  faculty: none,
) = {
  set page(margin: (x: 25mm, top: 30mm, bottom: 25mm), numbering: none, footer: none)
  set par(justify: false, first-line-indent: 0pt)

  if logo != none {
    place(top + right, dy: -14mm, image(logo, width: 58mm))
  }

  v(38mm)

  align(center, text(size: 18pt, weight: "bold", title))

  if subtitle != none and subtitle != [] {
    v(3mm)
    align(center, text(size: 13pt, style: "italic", fill: muted-color, subtitle))
  }

  v(6mm)
  align(center, line(length: 45%, stroke: 0.8pt + accent-color))

  if course != none and course != [] {
    v(5mm)
    align(center, text(size: 12pt, weight: "bold", course))
  }

  v(18mm)

  // Authors: name, matriculation number, e-mail — one block per student,
  // stacked vertically.
  grid(
    columns: (1fr,),   // full-width column so `align(center)` centres on the page
    row-gutter: 8mm,
    ..students.map(s => align(center, {
      text(size: 12pt, weight: "bold", s.display)
      if s.matrnr != [] {
        linebreak()
        text(size: 10.5pt)[Matriculation no. #s.matrnr]
      }
      if s.email != [] {
        linebreak()
        text(size: 10.5pt, fill: muted-color, s.email)
      }
    }))
  )

  place(bottom + center, dy: -6mm, {
    if supervisors != none and supervisors != [] {
      text(size: 11pt)[*Supervisors:* #supervisors]
      v(5mm)
    }
    if faculty != none and faculty != [] {
      text(size: 10.5pt, fill: muted-color, align(center, faculty))
      v(5mm)
    }
    if date != none and date != [] {
      text(size: 11pt)[Submitted #date]
    }
  })

  pagebreak()
}

// --- Front matter: TOC, lists, and the switch to arabic numbering --------
//
// Called from a raw-typst block in the .qmd, immediately after the abstract:
//
//     ```{=typst}
//     #front_matter(symbols: include "_symbols.typ")
//     ```
//
// Everything before this point (cover, abstract, and the lists themselves) is
// unnumbered front matter, following the GIM thesis convention; the page
// counter restarts at 1 in arabic on the page after, i.e. the Introduction.
#let front_matter(
  toc: true,
  list_of_figures: true,
  list_of_tables: true,
  symbols: none,
  symbols_title: "List of Symbols",
  // Mirror the YAML `color_links` here if you turn it off for printing;
  // set rules cannot reach across the raw-typst block that calls this.
  color_links: true,
) = {
  let link-color = if color_links { accent-color } else { black }

  let front_heading(title) = {
    pagebreak(weak: true)
    block(above: 0em, below: 0.7em, text(size: 13pt, weight: "bold", title))
  }

  // --- Table of contents ------------------------------------------------
  // Unnumbered headings (Appendix, and the auto-generated References) must not
  // inherit the section counter, which would repeat the last number used.
  let entry_number(el, level) = if el.numbering == none { none } else {
    counter(heading).at(el.location()).slice(0, count: level).map(str).join(".") + " "
  }

  if toc {
    show outline.entry.where(level: 1): it => block(above: 1.1em, below: 0.4em, context {
      let loc = it.element.location()
      let pg = str(counter(page).at(loc).first())
      link(loc)[
        #text(size: 11.5pt, weight: "bold", fill: black)[#entry_number(it.element, 1)#it.element.body]
        #h(1fr)
        #text(size: 11.5pt, weight: "bold", fill: link-color)[#pg]
      ]
    })
    show outline.entry.where(level: 2): it => block(above: 0.4em, below: 0.4em, context {
      let loc = it.element.location()
      let pg = str(counter(page).at(loc).first())
      link(loc)[
        #text(fill: black)[#entry_number(it.element, 2)#it.element.body]
        #box(width: 1fr, align(bottom, line(length: 100%, stroke: 0.4pt + luma(180))))
        #text(fill: link-color)[#pg]
      ]
    })
    front_heading("Table of Contents")
    outline(title: none, indent: 2em, depth: 2)
  }

  // Renders a figure/table outline entry using only the caption's first
  // sentence, keeping the prefix + dot-leader + page-number layout.
  let short-caption-entry(it) = {
    let (short, _) = first-sentence(it.element.caption.body)
    let inner = (
      text(fill: black)[#short]
      + box(width: 1fr, repeat[#text(fill: black)[.]])
      + h(0.35em)
      + text(fill: link-color)[#it.page()]
    )
    link(it.element.location(), it.indented(text(fill: black)[#it.prefix()], inner))
  }

  if list_of_figures {
    front_heading("List of Figures")
    show outline.entry: short-caption-entry
    outline(title: none, target: figure.where(kind: "quarto-float-fig"))
  }

  if list_of_tables {
    front_heading("List of Tables")
    show outline.entry: short-caption-entry
    outline(title: none, target: figure.where(kind: "quarto-float-tbl"))
  }

  if symbols != none {
    front_heading(symbols_title)
    symbols
  }

  // --- Hand over to the numbered body -----------------------------------
  pagebreak(weak: true)
  body_started.update(true)
  counter(page).update(1)
}

// --- Compact title banner (used when titlepage: false) -------------------
#let title_banner(
  title: [],
  subtitle: none,
  course: none,
  students: (),
  date: none,
  logo: none,
) = {
  set par(justify: false, first-line-indent: 0pt)

  if logo != none {
    place(top + right, dy: -6mm, image(logo, width: 42mm))
  }

  v(10mm)
  text(size: 15pt, weight: "bold", title)
  if subtitle != none and subtitle != [] {
    linebreak()
    text(size: 12pt, style: "italic", fill: muted-color, subtitle)
  }
  v(3mm)
  text(size: 10.5pt, students.map(s => s.display).join([, ]))
  if course != none and course != [] {
    linebreak()
    text(size: 10.5pt, fill: muted-color, course)
  }
  if date != none and date != [] {
    linebreak()
    text(size: 10.5pt, fill: muted-color, date)
  }
  v(2mm)
  line(length: 100%, stroke: 0.8pt + accent-color)
  v(4mm)
}

// --- Main configuration --------------------------------------------------
#let report_settings(
  title: [],
  subtitle: none,
  course: none,
  students: (),
  supervisors: none,
  faculty: none,
  date: none,
  keywords: none,
  logo: none,
  titlepage: true,
  line_spacing: "single",
  color_links: true,
  lang: "en",
  body,
) = {
  // `logo: none` / `logo: ""` in the YAML arrives here as a string.
  let logo = if logo in (none, "", "none", "false") { none } else { logo }

  set document(
    title: title,
    author: students.map(s => s.name),
    keywords: if keywords == none { () } else { keywords },
  )

  // Front matter (cover, abstract, TOC and lists) carries no visible page
  // number, as in the GIM thesis. `front_matter()` switches the footer on and
  // restarts the counter at 1 for the Introduction.
  set page(
    paper: "a4",
    // 22.5 mm is a normal report margin and buys roughly one page of text
    // against the 10-page limit. Widen to 25 mm if you have room to spare.
    margin: (x: 22.5mm, top: 22.5mm, bottom: 22.5mm),
    numbering: "1",
    number-align: center,
    footer: context {
      if body_started.get() {
        align(center, text(size: 10pt, counter(page).display("1")))
      }
    },
  )

  set text(font: body-font, size: 11pt, lang: lang)
  show math.equation: set text(font: math-font, weight: 400)
  show raw: set text(font: mono-font, size: 9.5pt)
  show link: set text(fill: if color_links { accent-color } else { black })
  show cite: it => if color_links { text(fill: accent-color.darken(15%))[#it] } else { it }

  // --- Front page -------------------------------------------------------
  if titlepage {
    cover_page(
      title: title, subtitle: subtitle, course: course, students: students,
      supervisors: supervisors, date: date, logo: logo, faculty: faculty,
    )
  } else {
    title_banner(
      title: title, subtitle: subtitle, course: course,
      students: students, date: date, logo: logo,
    )
  }

  // --- Headings ---------------------------------------------------------
  set heading(numbering: "1.1", bookmarked: true)
  show heading: set text(font: body-font)
  show heading.where(level: 1): set text(size: 13pt, weight: "bold")
  show heading.where(level: 1): set block(above: 1.4em, below: 0.7em)
  show heading.where(level: 2): set text(size: 11.5pt, weight: "bold")
  show heading.where(level: 2): set block(above: 1.1em, below: 0.55em)
  show heading.where(level: 3): set text(size: 11pt, weight: "regular", style: "italic")
  show heading.where(level: 3): set block(above: 0.9em, below: 0.45em)

  // --- Paragraphs -------------------------------------------------------
  set par(
    leading: leading-for(line_spacing),
    spacing: par-spacing-for(line_spacing),
    first-line-indent: 0pt,
    justify: true,
  )

  // --- Figures and tables ----------------------------------------------
  set figure(gap: 0.7em)
  show figure: set block(inset: (y: 0.35em))
  show figure.caption: it => text(size: 9.5pt)[
    #text(weight: "bold")[#it.supplement~#it.counter.display()#it.separator]#it.body
  ]
  // Tables carry long scikit-learn class names; shrink the monospace a little
  // further inside them so `LinearRegression` does not overrun its column.
  show table: set text(size: 9.5pt)
  show table: it => {
    set par(justify: false)   // justification looks bad in narrow cells
    show raw: set text(size: 8pt)
    it
  }
  // Let long tables split across a page boundary instead of being pushed
  // wholesale onto the next page and leaving half a page blank.
  show figure.where(kind: "quarto-float-tbl"): set block(breakable: true)

  // Pandoc emits a bare `#bibliography(...)` at the very end of the document;
  // this is the only hook for renaming its heading and sizing its entries.
  set bibliography(title: [References])
  show bibliography: set text(size: 10pt)
  show bibliography: set par(leading: 0.5em, spacing: 0.6em)

  set table(stroke: (x, y) => (
    top: if y == 0 { 0.8pt } else if y == 1 { 0.5pt } else { 0pt },
    bottom: 0pt,
  ))

  // --- Body -------------------------------------------------------------
  body
}
