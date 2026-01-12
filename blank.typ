/* Imports */

#import "/packages/packages-index.typ": *
#import "/modules/modules-index.typ": *
#import "/settings/settings-index.typ": *

/* Base variables and constants */

#let meta-data = yaml("/assets/data/meta.yml")
#let book-data = yaml("/assets/data/book.yml")

#let project = (
  lang: meta-data.at("language[ISO-639]"),
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

= #meta-data.title

*Автор:* #meta-data.author \ *Версия:* #meta-data.version

#Misc.place-copyright(meta-data.author, meta-data.year)

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

\
\


Самура́й (яп. #Ruby-Text.furigana(adjust-line-height: 10pt)[侍][さむらい], по-японски также используется слово «буси», #Ruby-Text.furigana[武士][ぶ|し]) — в феодальной Японии — светские феодалы-мужчины, начиная от крупных владетельных князей (даймё) и заканчивая мелкими дворянами; в узком и наиболее часто употребляемом значении — военно-феодальное сословие мелких дворян. Хотя слова «самурай» и «буси» очень близки по значению, всё же «бу» (воин) — более широкое понятие, и оно не всегда относится к самураю. Часто проводят аналогию между самураями и европейским средневековым рыцарством, но такое сравнение во многом неверно. Женщины самурайского сословия, владевшие оружием, именовались онна-бугэйся.
\
\

Даймё (яп. #Ruby-Text.furigana(adjust-line-height: 10pt)[大|名][だい|みょう], даймё:, букв. «большое имя») — крупнейшие военные феодалы средневековой Японии. Если считать, что класс самураев был элитой японского общества X—XIX веков, то даймё — элита среди самураев.
\
\

Это #Ruby-Text.tip[«Владыка»][(Повелитель Лун)]
\

а#Ruby-Text.furigana[漢字][かんじ]а
#Ruby-Text.furigana[諸具][Shōgun]
#Ruby-Text.furigana("諸|具", "Shō|Gun")
#Ruby-Text.furigana[諸|具][Shōasfasfsfaf|Gun]
#Ruby-Text.furigana[諸|具][Shō|Gun]
#Ruby-Text.gloss[諸|具][Shō|Gun]
\ \
#Ruby-Text.ruby()[東|京|工|業|大|学][とう|きょう|こう|ぎょう|だい|がく]

\
\

#let ruby = get-ruby(
  size: 0.45em,
  dy: 0pt,
  pos: top,
  alignment: "center",
  delimiter: "|",
  auto-spacing: true,
)
\
\
#ruby[Shōывывыв|Gun][諸|具]\
#ruby[ふりがな][振り仮名]\
#ruby[とう|きょう|こう|ぎょう|だい|がく][東|京|工|業|大|学]\
#ruby("漢字", "かんじ")
#ruby("美しい", "うつくしい")
\
\

*Библиографическая информация:*\
#book-data.at("Библиографическая информация") \ \ #book-data


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
  // pagebreak,
  "/include/part-glossary.typ",
)

#Utils.include-with-context(includable-pages, ..modules-export)
