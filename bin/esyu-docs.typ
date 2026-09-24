#let document-title = "$if(title)$$title$$else$$if(filename)$$filename$$else$Untitled document$endif$$endif$"
#let generated-on = datetime.today().display("[year]-[month padding:zero]-[day padding:zero]")
#let modified-on = "$if(modified)$$modified$$else$unknown$endif$"

#set page(
  paper: "a4",
  margin: (top: 25mm, bottom: 23mm, left: 20mm, right: 20mm),
  header-ascent: 11mm,
  footer-descent: 10mm,
  header: context [
    #set text(font: ("JetBrainsMono NFM", "JetBrains Mono", "Menlo"), size: 6.6pt, fill: rgb("5b6070"))
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      [#document-title],
      [GENERATED #generated-on],
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
  size: 9.2pt,
  fill: rgb("343746"),
)
#set par(leading: 0.52em, justify: false, first-line-indent: 0pt)
#set heading(numbering: none)
#set list(marker: [#text(fill: rgb("5b3fa8"))[›]])

#show heading.where(level: 1): it => [
  #block(above: 1.35em, below: 0.55em, breakable: false)[
    #set text(size: 14pt, weight: "bold", fill: rgb("5b3fa8"))
    #it.body
  ]
]
#show heading.where(level: 2): it => [
  #block(above: 1.05em, below: 0.4em, breakable: false)[
    #set text(size: 10.8pt, weight: "bold", fill: rgb("1f5fa8"))
    #it.body
  ]
]
#show heading.where(level: 3): it => [
  #block(above: 0.85em, below: 0.3em, breakable: false)[
    #set text(size: 9.6pt, weight: "bold", fill: rgb("4d5364"))
    #it.body
  ]
]
#show link: it => text(fill: rgb("1f5fa8"), underline(offset: 1.5pt, stroke: 0.5pt + rgb("9bbbe9"), it))
#show emph: it => text(style: "italic", fill: rgb("5d6171"), it)
#show strong: it => text(weight: "bold", fill: rgb("303341"), it)
#show raw.where(block: true): it => block(
  fill: rgb("f2f4f8"),
  stroke: 0.5pt + rgb("d9dce5"),
  inset: 9pt,
  radius: 3pt,
  text(fill: rgb("343746"), it),
)
#show quote: it => block(
  inset: (left: 10pt),
  stroke: (left: 2pt + rgb("5b3fa8")),
  text(fill: rgb("5b6070"), it),
)

$body$
