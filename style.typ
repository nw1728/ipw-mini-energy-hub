// Shared styling for assignment2.typ and assignment2_tutor.typ.
// Keep visual changes here so the two documents cannot drift apart.

#let font_size = 10pt
#let repo_url = "https://github.com/nw1728/ipw-mini-energy-hub"

#let col_a = rgb("#2b6cb0") // track A, notes
#let col_b = rgb("#b7791f") // track B, assumptions
#let col_c = rgb("#2f855a") // track C, "fixed"
#let col_red = rgb("#c53030") // safety, congestion

#let setup(header_line, doc) = {
  set text(font: "Zed Sans Extended", size: font_size)
  set par(justify: true)
  set heading(numbering: "1.")
  set page(
    paper: "a4",
    margin: (x: 1.9cm, y: 1.9cm),
    numbering: "1",
    header: align(right, text(size: 8.5pt, fill: luma(110))[
      Mini Energy Hub #sym.dot.c #header_line
    ]),
  )
  show link: set text(blue)
  show link: underline
  show heading.where(level: 1): it => block(above: 1.4em, below: 0.7em, it)
  show heading.where(level: 2): it => block(above: 1.1em, below: 0.5em, it)
  show table: set par(justify: false)

  show raw.where(block: false): it => box(
    fill: rgb("#f2f3f5"),
    stroke: 0.5pt + luma(200),
    radius: 3pt,
    inset: (x: 3pt, y: 1pt),
    baseline: 10%,
    it,
  )

  show raw.where(block: true): it => block(
    fill: rgb("#f2f3f5"),
    stroke: 0.5pt + luma(200),
    radius: 4pt,
    inset: 9pt,
    width: 100%,
    text(size: 8.8pt, font: "JetBrainsMono NF", it),
  )

  doc
}

#let callout(title, body, color: col_a) = block(
  fill: color.lighten(92%),
  stroke: (left: 2.5pt + color),
  inset: (x: 9pt, y: 8pt),
  radius: (top-right: 3pt, bottom-right: 3pt),
  width: 100%,
  breakable: false,
  above: 1em,
  below: 1em,
  [
    #text(weight: "bold", fill: color.darken(20%))[#title]
    #v(-0.45em)
    #body
  ],
)

#let note(body) = callout("Note", body)
#let assumption(body) = callout("Assumption", body, color: col_b)
#let safety(body) = callout("Safety", body, color: col_red)
#let tutortip(body) = callout("For the tutor", body, color: col_c)

#let th(body) = table.cell(fill: luma(232))[*#body*]

#let tbl(..args) = table(
  stroke: 0.5pt + luma(200),
  inset: (x: 6pt, y: 6pt),
  ..args,
)

#let track(name, color, body) = block(
  fill: color.lighten(94%),
  stroke: 0.8pt + color,
  radius: 4pt,
  inset: 9pt,
  width: 100%,
  breakable: false,
  above: 0.9em,
  below: 0.9em,
  [#text(weight: "bold", size: 10.5pt, fill: color.darken(25%))[#name] #v(-0.25em) #body],
)

#let chk(body) = grid(
  columns: (1.2em, 1fr),
  align: (left + top, left + top),
  box(width: 0.9em, height: 0.9em, stroke: 0.6pt, radius: 1pt, baseline: 0.12em),
  body,
)

#let suggest(body) = callout("Our suggestion, not a requirement", body, color: col_c)

#let briefnote(body) = block(
  fill: luma(247),
  stroke: (left: 2.5pt + luma(170)),
  inset: (x: 9pt, y: 8pt),
  radius: (top-right: 3pt, bottom-right: 3pt),
  width: 100%,
  breakable: false,
  above: 1em,
  below: 1em,
  text(style: "italic", fill: luma(70), body),
)

#let partpage(label, title, body) = {
  pagebreak(weak: true)
  block(above: 2em, below: 1.2em)[
    #text(size: 9pt, weight: "bold", fill: luma(120), tracking: 1.5pt)[#upper(label)]
    #v(-0.5em)
    #text(size: 1.9 * font_size, weight: "bold")[#title]
    #v(-0.3em)
    #line(length: 100%, stroke: 1pt + luma(150))
    #v(0.2em)
    #body
  ]
}
