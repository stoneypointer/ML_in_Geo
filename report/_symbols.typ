// List of Symbols — raw Typst, included by `front_matter()` in the .qmd.
// Keep this in sync with the notation actually used in the report.
#table(
  columns: (2.6cm, 1fr, 3.2cm),
  stroke: none,
  inset: (x: 0pt, y: 3pt),
  align: (left, left, right),
  table.header(
    strong[Symbol], strong[Description], strong[Units],
  ),

  // --- Latin symbols ---
  [$C$], [SVM regularisation (penalty) parameter], [--],
  [$k$], [Number of clusters in $k$-means], [--],
  [$n$], [Number of samples], [--],
  [$q$], [Conductive heat flow], [$"mW" thin "m"^(-2)$],
  [$R^2$], [Coefficient of determination], [--],
  [$T$], [Temperature], [°C],
  [$dif T slash dif z$], [Vertical temperature gradient], [°C km#super[--1]],
  [$z$], [Depth below surface], [m],

  // --- Greek symbols ---
  [$gamma$], [RBF-kernel width parameter (`gamma="scale"`)], [--],
  [$lambda$], [Thermal conductivity], [$"W" thin "m"^(-1) thin "K"^(-1)$],
  [$lambda_"bulk"$], [Bulk thermal conductivity, corrected to in-situ temperature], [$"W" thin "m"^(-1) thin "K"^(-1)$],
  [$lambda_"matrix"$], [Thermal conductivity of the mineral matrix], [$"W" thin "m"^(-1) thin "K"^(-1)$],
  [$lambda_"water"$], [Thermal conductivity of pore water ($= 0.6$)], [$"W" thin "m"^(-1) thin "K"^(-1)$],
  [$phi$], [Fractional (effective) porosity], [--],
  [$sigma$], [Standard deviation], [as quantity],

  // --- Abbreviations used in the text ---
  [MAE], [Mean absolute error], [--],
  [ML], [Machine learning], [--],
  [MLP], [Multi-layer perceptron], [--],
  [NEGB], [Northeast German Basin], [--],
  [RBF], [Radial basis function], [--],
  [RMSE], [Root-mean-square error], [--],
  [SVM], [Support-vector machine], [--],
)
