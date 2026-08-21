#!/usr/bin/env python3
"""Pull the stored figure outputs out of the exercise notebook into report/figures/.

The notebook is the report's appendix, so the figures in the PDF should be the
figures the notebook actually produced. Re-run this after re-executing the
notebook to refresh every plot in the report:

    python extract_figures.py

Cells are addressed by the section tag in the preceding markdown cell (A2, A3,
...), which is stable against inserting cells elsewhere in the notebook.
"""

from __future__ import annotations

import base64
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
NOTEBOOK = HERE.parent / "NEGB_Geothermal_Exercises_STUDENT.ipynb"
OUTDIR = HERE / "figures"

# section tag -> output file stem(s), in the order the figures appear in the cell
FIGURES: dict[str, list[str]] = {
    "A2": ["porosity_vs_lambda"],
    "A3": ["matrix_lambda_1to1"],
    "A4": ["heat_flow_intervals"],
    "B2": ["decision_tree"],
    "B4": ["kmeans_model_selection", "kmeans_clusters"],
}

SECTION_RE = re.compile(r"^#+\s*([AB]\d)\.", re.MULTILINE)


def main() -> None:
    nb = json.loads(NOTEBOOK.read_text())
    OUTDIR.mkdir(exist_ok=True)

    current_section = None
    written = 0

    for cell in nb["cells"]:
        source = "".join(cell["source"])

        if cell["cell_type"] == "markdown":
            match = SECTION_RE.search(source)
            if match:
                current_section = match.group(1)
            continue

        stems = FIGURES.get(current_section)
        if not stems:
            continue

        pngs = [
            out["data"]["image/png"]
            for out in cell.get("outputs", [])
            if "data" in out and "image/png" in out["data"]
        ]
        for stem, png in zip(stems, pngs):
            path = OUTDIR / f"{stem}.png"
            path.write_bytes(base64.b64decode(png))
            print(f"wrote {path.relative_to(HERE)}")
            written += 1

    missing = {
        stem
        for stems in FIGURES.values()
        for stem in stems
        if not (OUTDIR / f"{stem}.png").exists()
    }
    if missing:
        raise SystemExit(
            f"no stored output found for: {', '.join(sorted(missing))} — "
            "run the notebook and save it, then try again"
        )
    print(f"\n{written} figure(s) extracted to {OUTDIR}")


if __name__ == "__main__":
    main()
