#let COMPOSER = (
  TERMS: "terms",
  GRID: "grid",
  PAR: "par",
)

#let sxj-content-trim(body) = (
  if type(body) == content {
    if body.has("children") and body.children.first() in ([ ],) {
      body.children.slice(1).join()
    } else { body }
  } else { body }
)

#let sxj-get-composer-for(composer: auto, body) = if composer != auto {
  return composer
} else {
  if type(body) == content {
    if body.func() == grid {
      return COMPOSER.GRID
    }
    if body.fields().keys().contains("children") {
      if body.children.len() != 0 {
        if body.children.first().func() == grid {
          return COMPOSER.GRID
        }
      }
    }
  }
  return COMPOSER.TERMS
}

#let sxj-term(
  composer: COMPOSER.TERMS,
  hanging-indent: 1.5em,
  tag-align: right,
  tag,
  body,
  ..args,
) = {
  // Note: wrap the `tag` in two `box`es so that `set align(right)`
  //   won't compress `"."` if it is the last char of `tag`.
  let tag-in-box = box(
    width: hanging-indent,
    align(tag-align, box(
      width: auto,
      align(left, tag),
    )),
  )
  if composer == COMPOSER.TERMS {
    terms(
      indent: 0em,
      separator: none,
      tight: false,
      hanging-indent: hanging-indent,
      (
        tag-in-box,
        {
          let body-up = args.at("body-up", default: none)
          if body-up != none { v(body-up) }
          body
        },
      ),
    )
  } else if composer == COMPOSER.GRID {
    grid(
      gutter: 0em,
      columns: (hanging-indent, 1fr),
      {
        let tag-down = args.at("tag-down", default: none)
        if tag-down != none { v(tag-down) }
        tag-in-box
      },
      {
        let body-up = args.at("body-up", default: none)
        if body-up != none { v(body-up) }
        body
      },
    )
  } else if composer == COMPOSER.PAR {
    set par(hanging-indent: hanging-indent)
    [#tag-in-box#body]
  }
}
