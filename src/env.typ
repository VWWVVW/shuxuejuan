#let SXJ-BODY-TYPE = (
  QST: "question",
  ANS: (
    RAW: "answer raw",
    BL: "answer in blank",
    BR: "answer in bracket",
  ),
)

#let env = state(
  "env",
  (
    ans-shown: true,
    qst-style: auto,
    ref-style: auto,
    font-size: (small: 10.5pt, medium: 12pt, large: 14pt),
  ),
)
#let env-check(key) = assert(
  key in env.get().keys(),
  message: "No \"" + key + "\" in env.",
)
#let env-get(key, default: auto) = {
  env-check(key)
  return env.get().at(key, default: default)
}
#let env-copy(keys) = {
  return keys.map(k => (k, env-get(k))).to-dict()
}
#let _env-upd(key, val) = {
  env-check(key)
  let env-new = env.get()
  env-new.at(key) = val
  env.update(env-new)
}
#let env-upd(..dict) = {
  for (key, val) in dict.named() {
    _env-upd(key, val)
  }
}
#let with-env(..dict, body) = context {
  let env-old = env-copy(dict.named().keys())
  env-upd(..dict)
  body
  env-upd(..env-old)
}

#let counter-answer = counter("sxj-counter-answer")

#let counter-question = counter("sxj-counter-question")

#let counter-with-acc-next(current-counter, level, step: 1) = {
  let result = current-counter.chunks(2, exact: true)
  if result.len() <= level {
    result += ((0, 0),) * (level - result.len() + 1)
  }

  result.at(0).at(0) += 1
  result.at(0).at(1) = level
  result.at(level).at(0) += step
  result.at(level).at(1) += step
  return (
    result.slice(0, level + 1) + result.slice(level + 1).map(((acc, _)) => (acc, 0))
  ).flatten()
}

#let counter-with-acc-get(counter-got, level, acc-delta: 1) = counter-got.at(
  2 * level + acc-delta,
  default: none,
)

#let sxj-counter-with-acc-to-nums-default(counter-got) = (
  counter-got
    .slice(2, 2 * counter-got.at(1) + 2)
    .chunks(2, exact: true)
    .enumerate(start: 1)
    .map(((level, (acc, rec))) => if level == 2 { acc } else { rec })
)

#let sxj-counter-with-acc-to-nums-normal(counter-got) = (
  counter-got
    .slice(2, 2 * counter-got.at(1) + 2)
    .chunks(2, exact: true)
    .map(
      ((acc, rec)) => rec,
    )
)

#let counter-with-acc-reset(counter-got, level: 1, to: 0) = {
  let result = counter-got
  if result.len() < 2 * level {
    result += (0,) * (2 * level - result.len())
  }
  result.at(0) += 1
  result.at(1) = 0

  return (
    result.slice(0, 2 * level) + (to,).flatten().map(idx => (idx, idx)).flatten()
  )
}

#let sxj-counter-question-reset(level: 1, to: 0) = context counter-question.update(
  (..nums) => counter-with-acc-reset(nums.pos(), level: level, to: to),
)
