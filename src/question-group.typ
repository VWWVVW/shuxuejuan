#import "env.typ": *
#import "utils.typ": *
#import "question.typ": *

#let sxj-qg-get-level(envs: (:)) = {
  if envs.level == auto {
    let qst-before-here = query(selector(question).before(here()))
    if qst-before-here.len() != 0 {
      calc.min(qst-before-here.last().level + 1, 3)
    } else { 1 }
  } else { envs.level }
}

#let sxj-qg-get-rows(envs: (:), contents) = {
  let num-qst = int(contents.pos().len() / 2)
  let num-row = calc.ceil(num-qst / envs.col)
  return (auto, auto) * num-row
}

#let sxj-qg-ins-answer-empty(envs: (:), contents) = {
  arguments(..contents.pos().map(it => (it, box(height: envs.gutter, []))).flatten())
}

#let sxj-qg-add-bracket-empty(envs: (:), contents) = {
  arguments(..contents
    .pos()
    .enumerate()
    .map(((i, x)) => {
      if calc.even(i) {
        [#sxj-bracket[]#x]
      } else { x }
    }))
}

#let sxj-qg-add-punc(envs: (:), contents) = {
  let qst-after-here = query(selector(question).after(here())).map(x => x.level)
  let num-to-last-qst = qst-after-here.position(x => x < qst-after-here.first())
  if num-to-last-qst == none { num-to-last-qst = qst-after-here.len() }
  num-to-last-qst = num-to-last-qst * 2 - 2

  arguments(..contents
    .pos()
    .enumerate()
    .map(((i, x)) => {
      if calc.even(i) {
        [#x] + if i != num-to-last-qst [；] else [。]
      } else { x }
    }))
}

#let sxj-qg-to-question(envs: (:), contents) = {
  arguments(..contents
    .pos()
    .enumerate()
    .map(((i, x)) => {
      if calc.even(i) {
        question(level: sxj-qg-get-level(envs: envs), x)
      } else { x }
    }))
}

#let sxj-qg-rearrange(envs: (:), contents) = {
  arguments(
    ..contents
      .pos()
      .chunks(2 * envs.col)
      .map(it => it.enumerate().sorted(key: ((i, _)) => (calc.odd(i), i)).map(it => it.last()))
      .flatten(),
  )
}

#let sxj-qg-pcs-basic = (sxj-qg-to-question, sxj-qg-rearrange)
#let sxj-qg-pcs-std = (sxj-qg-ins-answer-empty, sxj-qg-add-punc) + sxj-qg-pcs-basic
#let sxj-qg-pcs-tf = (sxj-qg-ins-answer-empty, sxj-qg-add-punc, sxj-qg-add-bracket-empty) + sxj-qg-pcs-basic

/// Grab questions into one group;
/// - gutter (length):
///   When `sxj-qg-ins-answer-empty` is in `preprocessor`,
///   it's the gutter between two rows of questions;
///   Otherwise it's the gutter between two rows of content.
///   TODO/DNF: need to be made clearer in the future,
///   probably seperated into `row-gutter` and `ans-height`.
/// - col (int): The number of columns you want for this group of question
/// - level (int, auto):
///   The level for each question,
///   when set to auto, it would be the next level of current question level.
/// - preprocessor (array):
///   A array of funcs to process contents,
///   each func's args and return should be (envs, contents)=>arguments,
///   where envs is a named parameter, a dictionary of necessary parameters given to sxj-question-group like level, col etc.
///   and contents would be arguments of contents.
///   Pre-defined funcs would be named like `sxj-qg-*()`,
///   pre-defined preprocessor would be named like `sxj-qg-pcs-*`.
/// - contents (arguments): arguments of questions' contents
/// -> content
#let sxj-question-group(
  qst-align-number: "One-Lined-Compact",
  gutter: auto,
  col: 2,
  level: auto,
  preprocessor: sxj-qg-pcs-std,
  ..contents,
) = {
  v(.5em)
  context {
    let envs = (gutter: gutter, col: col, level: level)
    let cnts = preprocessor.fold(contents, (acc, pcs) => pcs(envs: envs, acc))
    with-env(qst-align-number: qst-align-number)[
      #grid(
        column-gutter: 0em,
        gutter: if preprocessor.contains(sxj-qg-ins-answer-empty) { 0em } else { gutter },
        columns: col,
        rows: sxj-qg-get-rows(envs: envs, cnts),
        align: (x, y) => {
          if calc.even(y) { return left + horizon }
          return auto
        },
        ..cnts
      )
    ]
  }
  v(-1em)
}
