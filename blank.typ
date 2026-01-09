#import "modules/charlist.typ": *
#import "modules/font_utils.typ" as FontUtils
#import "modules/text_locale.typ" as TextLocale
#import "modules/typographics.typ"

#import "setups/base.typ"

#set page(paper: "a4", margin: 2cm)

#set text(
  lang: "ru",
  font: FontUtils.getFonts(
    type: "serif",
    primaryFont: "PlayFair Display",
  ),
  size: 13pt,
)
#set par(first-line-indent: 1.25cm, leading: 0.65em)

// #set text(
//   font: (
//     "PlayFair Display",
//     "Noto Serif JP",
//   ),
// )

#FontUtils.getFonts(type: "serif", primaryFont: "PlayFair Display")

#show: base.init


= Test

#text("")

This is Em-Space: «#chr.emsp» \

This is A with Breve and Acute: «#chr.a_with_breve_and_acute»


$
  №_(lambda^(4_0))
$



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
#TextLocale.apply(lang: "ja", fontIndex: 0)[こんにちは、世界！]


// Это пример текста с японским вставленным посреди него: こんにちは、世界！
