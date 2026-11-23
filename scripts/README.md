# Analysis scripts

`analyze_exdark_predictions.py` reads the committed six-method prediction CSV and recomputes the ExDark image-label accuracy, macro precision, per-method confusion matrices, and combined row-normalized figure. It does not run enhancement models or the detector.

`summarize_computational_cost.py` rebuilds the equal-dataset CPU runtime summary from the saved benchmark exports; it does not rerun enhancement. See the root README, `docs/COMPUTATIONAL_COST.md`, and `docs/REPRODUCIBILITY.md` for the protocols and limitations.
