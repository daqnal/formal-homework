# formal-homework

`formal-homework` is a small [Typst](https://typst.app) package that provides an easy way to start writing formal homework documents.


## Usage

First, create a new `.typ` file and import this package at the top:

```typst
#import "@preview/formal-homework:0.1.0": hw, q, a, br
```

The entirety of the homework portion of your document will be contained in `hw()[]`, including the title page. Call it and pass the following parameters:

- `author` -> Your name
- `class` -> Name of the class/course that the homework is for
- `number` -> Number of the homework
- `due_date` -> Date that the homework is due

```typst
#hw(
  author: "George P. Burdell",
  class: "GT 1000",
  number: 1,
  due_date: "January 1, 1970"
)[rest of document goes here]
```

The content of the document is laid out with the remaining macros: `#q[]`, `#a[]`, and `#br()`

`#q[]` -> Contains the question, automatically enumerated
`#a[]` -> Contains the answer, bordered with a black box
`#br()` -> Shortcut for `#pagebreak()`, may be used to keep questions on their own page

Note that `#q[]`s may embed `#a[]`, which is often useful for multi-part questions; see the following example.

```typst
#q[
Let $f : NN -> NN $ such that $f(n) = 2 n^(2) - n $. Prove that $f $ is strictly increasing.
]

#a[]

#br()

#q[
Determine whether the following functions are real valued, integer valued, or neither.

    + $f : RR -> ZZ $ such that $f(x) = ceil.l 2 x^(2) + 1 ceil.r $.

    #a[]

    + $f : ZZ -> RR $ such that $f(n) = sqrt(n^(2) + 2 n)$.

    #a[]

    + $f : ZZ -> NN times NN $ such that $f(n) =(| n |, n^(2))$

    #a[]

    + $f : ZZ^(+) times RR -> RR $ such that $f(n,x) = x^(n)$

    #a[]

    + $f : B -> NN $ where $B $ is the set of all binary strings, such that $f(s)$ is the number of $1 $s in the binary string $s $.

    #a[]

    + $f : NN -> cal(P)(NN)$ such that $f(n) = { k exists a in ZZ(n = k a) } $

    #a[]

]

```

New Computer Modern is the default font, aiming for semblance to vanilla LaTeX, which professors likely prefer. To revert it, insert `#set text(font: "libertinus serif")` into the body of `#hw()[]`.
