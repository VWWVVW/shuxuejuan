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
#let ans = sxj-answer-sol
#let qst(..args) = context sxj-question-zh(..args)
#let qg = sxj-question-group
#let cu = sxj-counter-question-update

#let shuxuejuan(
  font-size: (small: 10.5pt, medium: 12pt, large: 14pt),
  counter-with-acc-to-nums: sxj-counter-with-acc-to-nums-default,
  ans-shown: true,
  body,
) = {
  // DNF: Updating `env`s in one `env-upd` is buggy, e.g. one
  //   of `env-upd(font-size: font-size, ans-shown: ans-shown)`
  //   and `env-upd(ans-shown: ans-shown, font-size: font-size)`
  //   would not update `ans-shown`.
  context env-upd(font-size: font-size)
  context env-upd(ans-shown: ans-shown)
  context env-upd(fn-number: counter-with-acc-to-nums)
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

  show heading: it => sxj-question-zh(level: it.level, it.body)
  show ref: it => sxj-ref-to-question(
    ref-style: env-get("ref-style"),
    it,
  )
  show title: it => sxj-title(size: env-get("font-size").large, body: it)
  show math.equation: it => sxj-equ(spacing: .2em, it)

  body
}
