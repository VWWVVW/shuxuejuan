#import "env.typ": *
#import "term.typ": *

// Note: `QST-STYLE` should be compatable with `COMPOSER`
#let QST-STYLE = (
  NORMAL: COMPOSER.TERMS,
  COMPLEX: COMPOSER.GRID,
  COMPACT: COMPOSER.PAR,
)

#let sxj-numbering-numbers(
  numbering-info: ("一、", "1.", "(1)", "①"),
  numbers,
) = {
  let my-numbering = if type(numbering-info) == array {
    (level, index) => {
      numbering(numbering-info.at(level, default: "1."), index)
    }
  } else if type(numbering-info) == function {
    numbering-info
  } else {
    (level, index) => numbering("1.", index)
  } // Note: `level` starts from 0 in `fn numbers-numbering`
  return numbers.enumerate().map(((i, num)) => my-numbering(i, num))
}

#let sxj-question(
  qst-style: auto,
  level: 2,
  hanging-indent: auto,
  counter-with-acc-to-num: (counter-got, level) => sxj-numbering-numbers(
    sxj-counter-with-acc-to-nums-default(counter-got),
  ).at(level - 1),
  body,
) = {
  counter-question.update((..nums) => counter-with-acc-next(nums.pos(), level))
  counter-answer.update(0)
  context [#metadata((
    type: SXJ-BODY-TYPE.QST,
    counter-question: counter-question.get(),
  ))<sxj-label-question>]

  let num = context counter-with-acc-to-num(counter-question.get(), level) + sym.wj
  context sxj-term(
    composer: sxj-get-composer-for(composer: qst-style, body),
    hanging-indent: if hanging-indent == auto {
      measure[#num].width
    } else { hanging-indent },
    num,
    body,
  )
}
