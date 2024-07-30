// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.8em )
  #align(right, block(inset: (right: 5em, top: 0.2em, bottom: 0.2em))[#body])
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}

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
// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: doc => article(
  title: [Título do Relatório],
  
  authors: (
    ( name: [Nome e Sobrenome Completo],
      affiliation: [MS],
      role: [Autor],
      email: [nome.sobrenomeh\@saude.gov.br] ),
    ),
  date: [2024-07-29],
  contract: [Nome do Contrato],
  product: [Produto 1],
  lang: "pt",
  region: "BR",
  abstract: [Resumo opcional do relatório ("abstract"). O Resumo oferece uma visão geral concisa e clara dos principais pontos do trabalho, permitindo ao leitor compreender rapidamente o conteúdo e os objetivos da pesquisa sem precisar ler o documento inteiro. Um bom resumo deve conter informações suficientes para que o leitor possa avaliar a relevância do estudo para seus próprios interesses e determinar se deve ler o trabalho completo.

],
  abstract-title: "Resumo",
  toc_title: [Índice],
  toc_depth: 3,
  cols: 1,
  doc,
)


= Introdução
<introdução>
#emph[TODO] Create an example file that demonstrates the formatting and features of your format.

= Mais informações
<mais-informações>
You can learn more about creating custom Typst templates here:

#link("https://quarto.org/docs/prerelease/1.4/typst.html#custom-formats")
