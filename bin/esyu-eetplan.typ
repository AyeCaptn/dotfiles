#let document-title = "$if(title)$$title$$else$$if(filename)$$filename$$else$Eetplan$endif$$endif$"
#let generated-on = datetime.today().display("[year]-[month padding:zero]-[day padding:zero]")
#let modified-on = "$if(modified)$$modified$$else$unknown$endif$"

#set page(
  paper: "a4",
  flipped: true,
  margin: (top: 20mm, bottom: 18mm, left: 15mm, right: 15mm),
  header-ascent: 8mm,
  footer-descent: 8mm,
  header: context [
    #set text(font: ("JetBrainsMono NFM", "JetBrains Mono", "Menlo"), size: 6.6pt, fill: rgb("5b6070"))
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      [#document-title],
      [WEEKPLAN · GENERATED #generated-on],
    )
    #v(2.5pt)
    #line(length: 100%, stroke: 0.45pt + rgb("d9dce5"))
  ],
  footer: context [
    #line(length: 100%, stroke: 0.45pt + rgb("d9dce5"))
    #v(4pt)
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      [#text(size: 7.2pt, fill: rgb("6b7080"))[MODIFIED #modified-on]],
      [#text(size: 7.2pt, fill: rgb("6b7080"))[© ESYU 2026]],
      [#text(size: 7.2pt, fill: rgb("6b7080"))[PAGE #counter(page).display("1/1", both: true)]],
    )
  ],
)

#set text(
  font: ("JetBrainsMono NFM", "JetBrains Mono", "Menlo"),
  size: 8.4pt,
  fill: rgb("343746"),
)
#set par(leading: 0.48em, justify: false, first-line-indent: 0pt)
#set heading(numbering: none)
#set table(
  rows: (10mm, 19mm, 19mm, 19mm, 19mm, 19mm, 19mm, 19mm),
  inset: (x: 8pt, y: 6pt),
  align: (x, y) => if y == 0 { center + horizon } else { left + top },
  fill: (x, y) => {
    if y == 0 { rgb("5b3fa8") }
    else if x == 0 { rgb("e9e5f5") }
    else if calc.odd(y) { rgb("f7f8fb") }
    else { white }
  },
  stroke: (x, y) => (
    top: if y == 0 { 0pt } else { 0.45pt + rgb("d9dce5") },
    bottom: 0.45pt + rgb("d9dce5"),
    left: if x == 0 { 0.45pt + rgb("d9dce5") } else { 0pt },
    right: 0.45pt + rgb("d9dce5"),
  ),
)

#show heading.where(level: 1): it => [
  #block(above: 0.3em, below: 0.65em, breakable: false)[
    #set text(size: 15pt, weight: "bold", fill: rgb("5b3fa8"))
    #it.body
  ]
]
#show table.cell.where(y: 0): it => text(weight: "bold", fill: white, it)
#show table.cell.where(x: 0): it => text(weight: "bold", fill: rgb("4b367c"), it)
#show link: it => text(fill: rgb("1f5fa8"), weight: "medium", it.body)
#show figure.where(kind: table): it => it.body

$body$
