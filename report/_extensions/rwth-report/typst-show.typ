// Forwards Quarto/Pandoc metadata into `report_settings` from typst-template.typ.
// Custom keys used here (`students`, `course`, `supervisors`, `faculty`, ...)
// are plain YAML keys in the .qmd — Quarto passes them through untouched.
#show: report_settings.with(
  title: [$title$],
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(course)$
  course: [$course$],
$endif$
  // `name` is also used as the PDF author string; the other two are passed as
  // content so that Pandoc's markdown escaping stays valid Typst markup.
  students: (
$for(students)$
    (name: "$it.name$", display: [$it.name$], matrnr: [$it.matrnr$], email: [$it.email$]),
$endfor$
  ),
$if(supervisors)$
  supervisors: [$supervisors$],
$endif$
$if(faculty)$
  faculty: [$faculty$],
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(keywords)$
  keywords: ($for(keywords)$"$it$",$endfor$),
$endif$
$if(report_logo)$
  logo: "$report_logo$",
$endif$
  titlepage: $if(titlepage)$true$else$false$endif$,
  line_spacing: "$line_spacing$",
  color_links: $if(color_links)$true$else$false$endif$,
  lang: "$if(lang)$$lang$$else$en$endif$",
)
