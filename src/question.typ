#import "env.typ": *
#import "utils.typ": *
#import "answer.typ": *

#let question = heading

/// Reset all counters of question.
/// -> none
#let sxj-question-reset-num() = {
  counter(question).update(0)
  counter-question-l2.update(1)
}

#let _get-question-numbering(
  qst-style: ("一、", "1.", "(1)", "①"),
  level2-index: none,
  numbers: none,
) = {
  let fn-qst-style = if type(qst-style) == array {
    (level, index) => {
      if level < qst-style.len() {
        numbering(qst-style.at(level), index)
      } else {
        numbering("1.", index)
      }
    }
  } else if type(qst-style) == function {
    qst-style
  } else {
    (level, index) => return numbering("1.", index)
  }

  let level = numbers.len()
  if level2-index != none and level >= 2 {
    numbers.at(1) = level2-index
  }

  return range(level).map(i => fn-qst-style(i, numbers.at(i)))
}

#let _get-dist-txt-equ() = {
  let a = query(selector(math.equation).after(here()))
  if a.len() == 0 { return 0em }
  return (measure(a.first()).height - measure[test].height) * 0.45
}

#let id-question-updater(level, ..id-current) = {
  let id-new = id-current.pos()
  id-new.pop()
  if id-new.len() - 1 < level {
    id-new += (0,) * (level - id-new.len() + 1)
  }
  id-new.at(0) += 1
  id-new.at(level) += 1
  id-new.push(level)
  return id-new
}

#let sxj-question(level, body, qst-number-level2: none) = {
  id-question.update((..args) => id-question-updater(level, ..args))

  let num-l2 = none
  if qst-number-level2 == auto {
    if level == 2 {
      counter-question-l2.step()
    }
    num-l2 = counter-question-l2.get().first()
  }
  let qst-numbering = _get-question-numbering(
    level2-index: num-l2,
    numbers: counter(question).get(),
  )
  let num = qst-numbering.last()

  set text(
    size: font-size.small,
    weight: if level == 1 { "extrabold" } else { "medium" },
  )
  set grid(gutter: 0em)
  let qst-align-style = env-get("qst-align-number")
  if qst-align-style == "One-Lined-Compact" {
    set par(hanging-indent: measure[#num#h(0em)].width)
    grid(columns: 1fr, [#num#h(0em)#body])
  } else if qst-align-style == "One-Lined" {
    set grid(columns: 1fr)
    if level == 1 {
      set par(hanging-indent: measure[#num#h(-.65em)].width)
      grid([#num#body])
    } else {
      set par(hanging-indent: measure[#num#h(.18em)].width)
      grid([#num#h(.5em)#body])
    }
  } else {
    grid(
      columns: (auto, 1fr),
      if level == 1 [#num#sym.wj] else [#num#h(.5em)],
      [#v(if qst-align-style == auto { -_get-dist-txt-equ() } else { 0em })#body],
    )
  }
}
