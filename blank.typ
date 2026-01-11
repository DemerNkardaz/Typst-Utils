/* Imports */

#import "/packages/packages-index.typ": *
#import "/modules/modules-index.typ": *
#import "/settings/settings-index.typ": *

/* Base variables and constants */

#let meta = yaml("/assets/data/meta.yml")
#let book = yaml("/assets/data/book.yml")

#let project = (
  lang: meta.at("language[ISO-639]"),
  base-font-size: 11pt,
  base-font: Fonts-Utils.get-fonts(type: "serif"),
)

/* Sets */

#set text(
  lang: project.lang,
  font: project.base-font,
  size: project.base-font-size,
)

#show: Base.init
#show: Supplementary-Syntax.apply
#show: Typographics.apply.with(lang: project.lang)

#show: Glossary.init.with(
  glossary-number-style-in-text: "^[1]",
  sources: "/assets/data/glossary.yml",
)

/* Document */

= #meta.title

*Автор:* #meta.author \ *Версия:* #meta.version

#Misc.place-copyright(meta.author, meta.year)

#include "/include/chapters/chapter-1.typ"

#Fonts-Utils.get-fonts(type: "serif", primaryFont: "PlayFair Display")

This is Em-Space: «#Chrs.list.emsp» \

This is A with Breve and Acute: «#Chrs.list.a-with-breve-and-acute»

#qr-code("https://typst.app/")

$
  №_(lambda^(4_0))
$

В период Эдо сёгун@Сёгун правил страной, опираясь на даймё@Даймё.
Военное сословие самураев@Самурай служило феодалам.

\

#Dict.get-term("Сёгун")

fi fl ffl VV 1234567890

#lorem(90)


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

Это пример текста с японским вставленным посреди него:
#Text-Locale.apply(lang: "ja")[こんにちは、世界！]

#sym.hat(Chrs.ligature("OE"))
#sym.grave(sym.caron(Chrs.ligature("ue")))
#sym.hat("О")иси Ёсио Кураносукэ

#let includable-pages = (
  pagebreak,
  "/include/chapters/chapter-1.typ",
  linebreak,
  "/include/chapters/chapter-1.typ",
  pagebreak,
  "/include/part-glossary.typ",
)

#Utils.include-with-context(includable-pages, ..modules-export)
