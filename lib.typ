#let styles = ("1.", "(a)", "(i)")

#let enum-offset = state("offset", 0)

#let q-depth = state("q-depth", 0)
#let q-counter = counter("q")
#let q-mode = state("q-mode", "local")

#let answer-color-state = state("answer-color", black)

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
      if nums.len() == 1 {
        numbering("1.", ..nums)
      } else {
        numbering("1.1", ..nums)
      }
    } else {
      let style-idx = calc.min(depth - 1, styles.len() - 1)
      numbering(styles.at(style-idx), nums.at(depth - 1))
    }

    enum-offset.update(depth)

    let nest = (depth - 1) * 1.5em
    let num-w = measure(num).width

    set par(first-line-indent: 0pt, hanging-indent: num-w + nest + 0.35em)

    h(nest)
    num

    body
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

#let hr() = context { line(length: 100%, stroke: answer-color-state.get()) }


#let hw(
  show-title-page: true,
  title-text: none,
  number: 1,
  author: none,
  class: none,
  institution: none,
  professor: none,
  due-date: none,
  answer-color: black,
  answer-background-fill: false,
  show-page-number: true,
  show-problem-footer: true,
  q-numbering: "local",
  body,
) = {
  answer-color-state.update(answer-color)

  set page(
    paper: "us-letter",
    margin: 1in,
    footer: context {
      // Display page/problem counter after title page if enabled
      if (counter(page).get().first() > 1) or (not show-title-page) {
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
          if show-page-number {
            align(right)[
              #counter(page).display()
            ]
          },
        )
      }
    },
  )

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
  show block.where(label: <hw-answer>): it => context {
    let depth = q-depth.get()
    let indent = (depth - 1) * 1.5em

    pad(left: indent, block(
      width: 100%,
      inset: 10pt,
      stroke: 1pt + answer-color,
      fill: if answer-background-fill {
        answer-color.lighten(90%)
      } else {
        none
      },
      it,
    ))
  }

  show label("hw-answer"): set text(fill: answer-color)

  if (show-title-page) {
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
  }

  body
}
