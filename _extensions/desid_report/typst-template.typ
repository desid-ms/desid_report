
// margin notes
#import "@preview/drafting:0.2.0"


#let article(
  title: none,
  subtitle: none,
  authors: none,
  contract: none,
  project: none,
  product: none,
  citation: none,
  date: none,
  abstract: none,
  abstract-title: none,
  margin: (left: 1cm, top: 1.5cm, right: 7cm, bottom: 1.5cm),
  paper: "a4",
  lang: "pt",
  region: "BR",
  font: (),
  fontsize: 11pt,
  sectionnumbering: "1.1.a",
  cols: 1,
  toc: true,
  toc_depth: 1,
  toc_title: "Sumário",
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: "a4",
    margin: (left: 1cm, top: 1.5cm, right: 7cm, bottom: 1.5cm),
    numbering: "1",
    header-ascent: .5cm,
    footer-descent: .5cm, 
    header: locate(loc => {
      if (loc.page() != 1) {
        block(
          width: 19cm,
          stroke: (bottom: 1pt + gray),
          inset: (bottom: 8pt, right: 2pt, left: 2pt),
          [ #set text(font: "Lato", size: 8pt, fill: gray.darken(50%))
            #grid(
              columns: (1fr, 1fr),
              align(left, []),
              align(right, text(weight: "bold", upper[Relatório])),
            ) ],
        )
      }
    }),
    
    footer: block(
      width: 19cm,
      stroke: (top: 1pt + gray),
      inset: (top: 8pt, right: 2pt),
      [
        #set text(font: "Lato", size: 8pt, fill: gray.darken(50%))
        #grid(
          columns: (75%, 25%),
          align(left)[#date - #title],
          align(
            right
          )[#counter(page).display() de #locate((loc) => { counter(page).final(loc).first() })],
        )
      ],
    )
  )
  set par(justify: true, linebreaks: "optimized")
  set text(lang: lang,
           region: region,
           historical-ligatures: true,
           ligatures: true,
           font: "Merriweather",
           size: 10pt, 
           fractions: true)
  set heading(numbering: sectionnumbering)
  
  show heading: it => {
    set par(leading: 2em)
    // set block(spacing: 2em)
    set text(font:"Lato", weight: "semibold", fractions: true)
    smallcaps(it)
    v(.54em)
}
  


  if title != none {
    block(width:19cm)[
    #text(font: "Lato", fill: gray.lighten(60%), upper[Relatório])
    #v(.2cm)
    #text(font: "Merriweather", size: 20pt, weight: "black", title)
    #if subtitle != none {
      v(-.3cm)
      text(font: "Merriweather", size: 16pt, weight: "regular", subtitle)
    }
    #if abstract != none {
      block(inset: 1.5em)[
      #text(weight: "semibold", font:"Lato")[#abstract-title] #h(1em) #text(size: 8pt)[#abstract]
    ]
    } else {v(.5cm)}
    #line(length: 100%, stroke: 3pt + rgb("#316E6B"))
    #v(.25cm)
    ]
    
  }
  if authors != none {
      place(dx:7cm, right, block(width: 7cm,inset: 1em,)[
        #set align(left)
        #block(width: 5.65cm, inset:1em, fill: rgb("#316E6B").lighten(95%), radius: 6pt)[
        #set text(font:"Lato", size: 8pt)
        #for (author) in authors [
          #if author.role != none [#text(weight: "bold", author.role) \ ]
          #h(1em)#author.name #if author.affiliation!=none {text(font: "SF Mono")[(#author.affiliation)]}
          #if author.email != none [#v(-.5em)#h(1em)#text(size: 7pt, font: "SF Mono", author.email)]
        ]

        #if contract != none [ *Contrato* #h(1em)#text(size: 7pt, font: "SF Mono", contract) ]

        #if project != none [ *Projeto*  #h(1em)#text(size: 7pt, font: "SF Mono", project) ]

        #if product != none [ *Produto* #h(1em)#text(size: 7pt, font: "SF Mono", product) ]
        
        #if date != none [ *Publicação*  #h(1em)#text(size: 7pt, font: "SF Mono", date) ]
        
        
        ]

        #if toc {
          v(1cm)
          set text(size:.6em, font: "Lato")
          block(above: 0em, below: 2em)[
          #outline(
            title: "Sumário",
            depth: 2,
            indent: 1em
          );
          ]
        }
        
        ]
      )
  }
  
  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
  
}
#set table(
  inset: 6pt,
  stroke: none
)
