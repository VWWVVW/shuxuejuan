#import "question.typ": *

#let sxj-qg-get-level(envs) = if envs.level != auto { envs.level } else {
  calc.min(
    query(
      selector(<sxj-label-question>).before(here()),
    )
      .map(x => x.value.counter-question.at(1, default: 2))
      .last(default: 2)
      + 1,
    3,
  )
}

#let sxj-qg-get-rows(envs, cnts) = {
  let num-qst = int(cnts.len() / 2)
  let num-row = calc.ceil(num-qst / envs.col)
  (auto, envs.gutter) * num-row
}

#let sxj-qg-ins-ans-empty(envs, cnts) = (
  cnts.map(qst => (qst, [])).flatten()
)

#let sxj-qg-add-br-empty(envs, cnts) = (
  // DNF: `（ ）` should be a func.
  cnts.chunks(2).map(((qst, ans)) => ([（ ）#qst], ans)).flatten()
)

#let sxj-qg-add-punc(envs, cnts) = (
  cnts.chunks(2).map(((qst, ans)) => (qst + [；], ans)).flatten()
)

#let sxj-qg-add-auto-punc(envs, cnts) = {
  let levels = query(
    selector(<sxj-label-question>).after(here()),
  ).map(x => x.value.at(1))
  let num-to-last = levels.position(level => level != envs.level)
  if num-to-last == none { num-to-last = levels.len() }

  let grouped = cnts.chunks(2)
  let (last-qst, last-ans) = grouped.pop()
  (
    grouped.map(((qst, ans)) => (qst + [；], ans))
      + (last-qst + if num-to-last == grouped.len() + 1 [。] else [；], last-ans)
  ).flatten()
}

#let sxj-qg-to-question(envs, cnts) = (
  cnts.chunks(2).map(((qst, ans)) => (sxj-question(level: envs.level, qst), ans)).flatten()
)

#let sxj-qg-rearrange(envs, cnts) = (
  cnts
    .chunks(2 * envs.col)
    .map(it => it
      .enumerate()
      .sorted(
        key: ((i, _)) => (calc.odd(i), i),
      )
      .map(((idx, cnt)) => cnt))
    .flatten()
)

#let sxj-qg-pcs-basic = (sxj-qg-to-question, sxj-qg-rearrange)
#let sxj-qg-pcs-std = (sxj-qg-ins-ans-empty, sxj-qg-add-punc) + sxj-qg-pcs-basic
#let sxj-qg-pcs-tf = (sxj-qg-ins-ans-empty, sxj-qg-add-punc, sxj-qg-add-br-empty) + sxj-qg-pcs-basic

#let sxj-question-group(
  qst-style: auto,
  col: 2,
  gutter: none,
  level: auto,
  preprocessor: sxj-qg-pcs-std,
  ..contents,
) = context {
  let envs = (
    col: col,
    gutter: if gutter == none { 1em } else { gutter },
    level: sxj-qg-get-level((level: level)),
  )
  let cnts = preprocessor.fold(contents.pos(), (acc, pcs) => pcs(envs, acc))

  v(.5em)
  grid(
    gutter: 0em,
    columns: (1fr,) * envs.col,
    rows: sxj-qg-get-rows(envs, cnts),
    ..cnts
  )
  v(-1.5em)
}
