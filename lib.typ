#let styles = ("1.", "(a)", "(i)")

#let enum-offset = state("offset", 0)

#let q-depth = state("q-depth", 0)
#let q-counter = counter("q")
#let q-mode = state("q-mode", "local")

#let q(body) = [
  #q-depth.update(d => d + 1)

  #context {
    let depth = q-depth.get()
    q-counter.step(level: depth)
  }

  #context {
    let depth = q-depth.get()
    let mode = q-mode.get()
    let nums = q-counter.get()

    let num = if mode == "hierarchical" {
      // Full path: 1, 1.1, 1.2, 2.1, …
      // (you can change the pattern string if you prefer 1.1. or 1-1 etc.)
      numbering("1.1", ..nums)
    } else {
      // Local style only (original behaviour)
      let style-idx = calc.min(depth - 1, styles.len() - 1)
      numbering(styles.at(style-idx), nums.at(depth - 1))
    }

    // Make any + lists inside this q start at the next style
    enum-offset.update(depth)

    // Slightly wider box when hierarchical numbers are longer
    let box-w = if mode == "hierarchical" { 2.2em } else { 1.2em }

    block(width: 100%, above: 0.75em, below: 1em)[
      #place(left)[
        #box(width: box-w, align(right, num))
      ]
      #pad(left: box-w + 0.6em, body)
    ]
  }

  #q-depth.update(d => d - 1)
  #context {
    enum-offset.update(q-depth.get())
  }
]


#let a(body) = [
  #block(
    breakable: true,
  )[
    #body
  ] <hw-answer>
]

#let br() = pagebreak()


#let hw(
  title-text: none,
  number: 1,
  author: none,
  class: none,
  institution: none,
  professor: none,
  due-date: none,
  answer-color: black,
  answer-background-fill: false,
  show-page-footer: true,
  show-problem-footer: true,
  q-numbering: "local",
  body,
) = {
  set page(
    paper: "us-letter",
    margin: 1in,
    footer: context {
      // Display page/problem counter after title page if enabled
      if counter(page).get().first() > 1 {
        grid(
          columns: (1fr, 1fr),
          if show-problem-footer {
            align(left)[
              Problem #context {
                let n = q-counter.get()
                if n.len() > 0 { numbering("1", n.first()) } else { "1." }
              }
            ]
          },
          if show-page-footer {
            align(right)[
              #counter(page).display()
            ]
          },
        )
      }
    },
  )

  let hr() = line(length: 100%, stroke: answer-color)

  set text(
    size: 12pt,
    lang: "en",
    font: "New Computer Modern",
  )

  set enum(
    full: true,
    numbering: (..nums) => context {
      let offset = enum-offset.get()
      let depth = nums.pos().len() + offset
      let style = styles.at(depth - 1)
      numbering(style, nums.pos().last())
    },
  )

  // Set the answer text and border to have answer-color
  show block.where(label: <hw-answer>): it => {
    block(
      width: 100%,
      inset: 10pt,
      stroke: 1pt + answer-color,
      fill: if answer-background-fill {
        answer-color.lighten(90%)
      } else {
        none
      },
      it,
    )
  }

  show label("hw-answer"): set text(fill: answer-color)

  // Style title page to (somewhat) follow APA style
  align(horizon + center, block[
    // If title-text is set, then use it instead of "Homework # Submission"
    #if title-text != none [
      #title[#title-text]
    ] else [
      #title[Homework #number Submission]
    ]

    #author

    #institution

    #class

    #professor

    #due-date
  ])

  q-mode.update(q-numbering)

  pagebreak()

  body
}
