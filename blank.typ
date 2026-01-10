/* Imports */

#import "@preview/rustycure:0.2.0": qr-code

#import "modules/charlist.typ": *
#import "modules/misc.typ" as Misc
#import "modules/font_utils.typ" as FontUtils
#import "modules/text_locale.typ" as TextLocale
#import "modules/dictionary.typ" as Dict
#import "modules/typographics.typ" as Typographics

#import "setups/base.typ" as Base

/* Base variables and constants */

#let meta = yaml("data/meta.yml")
#let book = yaml("data/book.yml")

#let project = (
  lang: meta.at("language[ISO-639]"),
  baseFontSize: 13pt,
  baseFont: FontUtils.getFonts(
    type: "serif",
    primaryFont: "PlayFair Display",
  ),
)

/* Sets */

#set page(
  paper: "a4",
  margin: 2cm,
)

#set par(
  first-line-indent: 1.25cm,
  leading: 0.65em,
)

#set text(
  lang: project.lang,
  font: project.baseFont,
  size: project.baseFontSize,
)

#show: Base.init
#show: Dict.applyHandle
#show: Typographics.apply.with(lang: project.lang)
Сёгун#super([@Сёгун])


/* Document */

= #meta.title

*Автор:* #meta.author \ *Версия:* #meta.version

#Misc.placeCopyright(meta.author, meta.year)

#FontUtils.getFonts(type: "serif", primaryFont: "PlayFair Display")

This is Em-Space: «#chr.emsp» \

This is A with Breve and Acute: «#chr.a_with_breve_and_acute»

#qr-code("https://typst.app/")


$
  №_(lambda^(4_0))
$


#Dict.getTerm("Сёгун")


*Библиографическая информация:*\
#book.at("Библиографическая информация") \ \ #book


=== Проверка висячей пунктуации

Ниже представлен текстовый блок с видимыми границами (bounds). Обратите внимание, как точки, запятые и дефисы в правой части текста слегка выходят за серую линию рамки, создавая ровный оптический край.

#block(
  stroke: 0.5pt + gray,
  inset: 0pt,
  width: 100%,
  [
    В этом абзаце мы тестируем механизм, который позволяет знакам препинания висеть. Если строка заканчивается точкой, она должна выйти за границу. Если строка заканчивается запятой, мы увидим это наглядно. Вот длинное слово для проверки переноса: высокопревосходительство.
    Типографика — это искусство расположения букв так, чтобы текст выглядел гармонично. Когда точка стоит ровно по линии, визуально кажется, что в крае образовалась дыра. Висячая пунктуация решает эту проблему, вынося мелкие знаки за пределы основного массива букв. Проверим ещё раз на точке. И ещё раз на очень длинном предложении, которое обязательно должно закончиться точкой прямо у края.
  ],
)

#v(1em)

#text(overhang: false)[
  #block(stroke: 0.5pt + red, [
    А здесь `overhang` *выключен* (красная рамка). Заметьте, что точки и запятые теперь находятся строго внутри блока, из-за чего правый край текста визуально кажется менее ровным и "изъеденным".
  ])
]


Тестовый #text(fill: blue)[синий текст] и обычный текст.

// Это пример текста с японским вставленным посреди него: #text(font: "Noto Serif JP", lang: "ja")[こんにちは、世界！]
Это пример текста с японским вставленным посреди него:
#TextLocale.apply(lang: "ja", font: 0)[こんにちは、世界！]

\
\
\


// Это пример текста с японским вставленным посреди него: こんにちは、世界！
#bibliography("data/dictionary.yml", style: "glossary.csl", title: "Глоссарий")
