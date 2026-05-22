#import "env.typ": *
#import "term.typ": *

#let sxj-numbering-numbers(
  numbering-info: ("一、", "1.", "(1)", "①"),
  numbers,
) = {
  // Note: in `my-numbering`, `level` starts from 0.
  let my-numbering = if type(numbering-info) == array {
    (level, index) => {
      numbering(numbering-info.at(level, default: "1."), index)
    }
  } else if type(numbering-info) == function {
    numbering-info
  } else {
    (level, index) => numbering("1.", index)
  }
  return numbers.enumerate().map(((i, num)) => my-numbering(i, num))
}

#let sxj-question(
  composer: auto,
  level: 2,
  hanging-indent: auto,
  nums-to-num: (nums, level) => sxj-numbering-numbers(nums).at(level - 1),
  body,
) = {
  let body = sxj-content-trim(body)

  counter-question.update((..nums) => counter-with-acc-step(nums.pos(), level))
  counter-answer.update(0)
  context [#metadata((
    type: SXJ-BODY-TYPE.QST,
    counter-question: counter-question.get(),
  ))<sxj-label-question>]

  let num = context (
    nums-to-num(env-get("fn-number")(counter-question.get()), level) + sym.wj
  )
  context sxj-term(
    composer: sxj-get-composer-for(composer: composer, body),
    hanging-indent: if hanging-indent == auto {
      measure[#num].width
    } else { hanging-indent },
    num,
    body,
  )
}

#let sxj-question-zh(level: 2, body) = {
  set text(
    size: env-get("font-size").small,
    weight: if level == 1 { "bold" } else { "medium" },
  )
  sxj-question(
    composer: env-get("qst-style"),
    level: level,
    hanging-indent: ((2, measure("10.").width), (3, measure(" () ").width))
      .filter(((level, _)) => level == level)
      .map(((_, val)) => val)
      .first(default: auto),
    body,
  )
}
