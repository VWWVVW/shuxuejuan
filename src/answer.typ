#import "env.typ": *

#let sxj-answer(
  ans-type: SXJ-BODY-TYPE.ANS.RAW,
  shown: auto,
  fill: color.maroon,
  body,
) = {
  context counter-answer.step()

  set text(fill: fill)
  context {
    let shown = if shown == auto {
      env-get("ans-shown")
    } else { shown }
    if shown { body } else { hide(body) }
    [#metadata((
      type: ans-type,
      counter-question: counter-question.get(),
      counter-answer: counter-answer.get(),
      body: body,
    ))<sxj-label-answer>]
  }
}

#let sxj-bracket(
  shown: auto,
  fill: color.maroon,
  answer,
) = context (
  [（]
    + box(
      align(center, sxj-answer(
        ans-type: SXJ-BODY-TYPE.ANS.BR,
        shown: shown,
        fill: fill,
        answer,
      )),
      width: if measure(answer).width < .7em.to-absolute() {
        1em
      } else { 1.7em },
    )
    + [）]
)

#let sxj-blank(
  shown: auto,
  fill: color.maroon,
  answer,
  scale: auto,
) = context {
  let body = []
  let len
  if type(answer) == content or type(answer) == str {
    body = answer
    len = measure(body).width.to-absolute()
    if len == 0pt { len = 1em }
  } else if type(answer) == int or type(answer) == float {
    body = []
    len = (answer * 1em).to-absolute()
  } else if type(answer) == length {
    body = []
    len = answer.to-absolute()
  }

  box(
    width: if type(scale) == length {
      scale
    } else if scale == auto { len * 1.7 } else { len * scale },
    height: 1em,
    stroke: (bottom: .7pt + color.black),
    outset: (bottom: .1em),
    align(center + horizon, sxj-answer(
      ans-type: SXJ-BODY-TYPE.ANS.BL,
      shown: shown,
      fill: fill,
      body,
    )),
  )
}
