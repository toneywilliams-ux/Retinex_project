# Reported result files

The subfolders contain the result tables, retained per-image data, and figures referenced by the current conference paper in `../paper/`.

- `paired/`: LOL-v1 retained per-image values and ranges, plus the paper tables for LOL-v1 and LOL-v2 Real.
- `no_reference/`: equal-dataset macro-average table for DICM, LIME, NPE, and VV, plus the paper's plot.
- `exdark/`: the same-sample six-method image-label predictions, class-balanced sample manifest (identifiers and labels only), confusion matrices, detector summary, and plot.
- `cost/`: raw CPU timing exports, benchmark metadata, trainable parameter counts, and an equal-dataset mean summary for LOL-v1 and LOL-v2 Real.

For the timing protocol and its limits, see [the computational-cost notes](../docs/COMPUTATIONAL_COST.md). For other interpretation and reproducibility limits, see [the reproducibility notes](../docs/REPRODUCIBILITY.md). The confusion-matrix results come from one frozen detector and are not enhancement-fidelity accuracy.
