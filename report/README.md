# End-of-term report — Quarto source

Quarto → Typst source for the *Machine Learning in Geosciences 2026* end-of-term
report. The PDF is built from a single `.qmd`; no LaTeX is needed.

```
report/
├── Vass_Coauthor_ML_2026.qmd   ← the report (rename once author 2 is known)
├── _symbols.typ                ← List of Symbols table (raw Typst)
├── references.bib              ← bibliography
├── extract_figures.py          ← pulls figures out of the notebook
├── figures/                    ← generated PNGs (do not edit by hand)
├── img/rwth-logo.svg           ← RWTH Aachen logo for the cover
└── _extensions/rwth-report/    ← the Typst template
```

## Structure and page numbering

The thesis-template convention: cover, abstract, table of contents, list of
figures, list of tables and list of symbols are **unnumbered front matter**; the
page counter restarts at **1 in arabic on the Introduction**, so the 10-page
limit applies to the body only.

The front matter is emitted by one raw-Typst block in the `.qmd`, sitting between
the abstract and the Introduction:

```` markdown
```{=typst}
#front_matter(symbols: include "_symbols.typ")
```
````

Arguments: `toc`, `list_of_figures`, `list_of_tables` (all `true` by default —
pass `false` to drop one), `symbols` (omit for no symbol list), `symbols_title`,
and `color_links` (mirror the YAML value here if you turn it off for printing).
Edit the symbol/abbreviation table in `_symbols.typ`.

Entries in the lists of figures and tables are truncated to the caption's first
sentence, as in the thesis, so write captions as "short sentence. Longer
explanation."

## Build

```sh
quarto render Vass_Coauthor_ML_2026.qmd
```

Typst logs `warning: unknown font family: liberation serif` on macOS — harmless,
it is only a fallback for Linux machines without Times New Roman.

## Figures

The figures in the report are the ones the notebook actually produced. After
re-running and saving `NEGB_Geothermal_Exercises_STUDENT.ipynb`, refresh them with

```sh
python extract_figures.py
```

The script maps notebook sections (`A2`, `A3`, `A4`, `B2`, `B4`) to files in
`figures/`; add an entry to its `FIGURES` dict to export a new plot.

## Assignment requirements and how they are met

| Requirement | Where |
|---|---|
| Max. 10 pages | body only — front matter is unnumbered; see the note below |
| Times New Roman, 11 pt | `body-font` / `size` in `typst-template.typ` |
| Single or 1.5 spacing | `line_spacing: single` in the `.qmd` YAML (`onehalf` also available) |
| `Lastname1_Lastname2_ML_2026.pdf` | rename the `.qmd`; the PDF inherits the name |
| Notebook as digital appendix | submitted separately, referenced in the Appendix section |

**Page budget.** The current draft runs to 10 numbered pages: Introduction through
Conclusions on pages 1–9, Appendix on 9 and References on 10. The `[TODO: ...]`
markers will add text, so if you go over, trim in this order: (1) the Conclusions
section — it is not in the required structure; (2) the figure widths in the `.qmd`
(`{... width=NN%}`); (3) Table 3 or Table 5, which duplicate numbers already given
in the text. The section weights in the rubric are a page-budget guide too:
Discussion is worth 33 % and should stay the longest section.

## Template options

Set these in the `.qmd` YAML:

| Key | Values | Effect |
|---|---|---|
| `titlepage` | `true` / `false` | separate cover page, or a compact title banner (saves a page) |
| `line_spacing` | `single` / `onehalf` | body line spacing |
| `report_logo` | path / `none` | cover logo |
| `color_links` | `true` / `false` | blue links and citations, or all black for printing |
| `students` | list of `name` / `matrnr` / `email` | author blocks on the cover; any number of authors |
| `bibliographystyle` | e.g. `apa`, `american-geophysical-union` | citation style (default `apa`) |

The template is a stripped-down adaptation of the GIM thesis template
(`~/Desktop/MASTERS/4-Thesis/thesis/docs/thesis_doc/_extensions/gim-thesis/`).
The GIM group logo has been removed from the cover as this is a course report,
not group work; `img/rwth-logo.svg` is the RWTH half of the original combined
lockup, cropped via its `viewBox`.
