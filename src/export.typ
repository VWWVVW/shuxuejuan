#import "env.typ"
#import "term.typ": *
#import "question.typ": *
#import "question-group.typ": *
#import "reference.typ": *
#import "answer.typ": *
#import "utils.typ": *

#let si = sxj-student-info
#let un = sxj-unit
#let op = sxj-options
#let br = sxj-bracket
#let bl = sxj-blank
#let ans = sxj-answer-jie
#let qst = sxj-question
#let qg = sxj-question-group
#let cr = sxj-counter-question-reset

#let shuxuejuan(
  font: (),
  font-bold: auto,
  font-size: (small: 10.5pt, medium: 12pt, large: 14pt),
  counter-with-acc-to-nums: sxj-counter-with-acc-to-nums-default,
  ans-shown: true,
  body,
) = {
  context env-upd(font-size: font-size, ans-shown: ans-shown)
  set text(font: font)
  // Note: when `font` can't be bold, use `font-bold` as a fallback.
  show text
    .where(weight: "semibold")
    .or(text.where(weight: "bold"))
    .or(
      text.where(weight: "extrabold"),
    ): set text(font: font-bold)
  show "。": "．"

  set page(
    width: 19.5cm,
    height: 27cm,
    margin: 37pt,
    footer: context sxj-footer(
      counter(page).get().first(),
      counter(page).final().first(),
    ),
  )

  show heading: it => {
    set text(
      size: env-get("font-size").small,
      weight: if it.level == 1 { "bold" } else { "medium" },
    )
    sxj-question(
      qst-style: env-get("qst-style"),
      level: it.level,
      hanging-indent: ((2, measure("10.").width), (3, measure(" () ").width))
        .filter(((level, _)) => level == it.level)
        .map(((_, val)) => val)
        .first(default: auto),
      counter-with-acc-to-num: (counter-got, level) => (
        sxj-numbering-numbers(
          counter-with-acc-to-nums(counter-got),
        ).at(level - 1)
          + if level in (2, 3) [ ]
      ),
      it.body,
    )
  }
  show ref: it => sxj-ref-to-question(
    ref-style: env-get("ref-style"),
    counter-with-acc-to-nums: counter-with-acc-to-nums,
    it,
  )
  show title: it => sxj-title(size: env-get("font-size").large, body: it)
  show math.equation: it => sxj-equ(spacing: .2em, it)

  body
}
