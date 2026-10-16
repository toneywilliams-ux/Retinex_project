#!/usr/bin/env python3
"""Rebuild ExDark class-confusion CSVs, summary metrics, and the paper figure.

Input: results/exdark/exdark_predictions_six_methods_balanced240.csv
Output: results/exdark/exdark_confusion_*.csv,
        results/exdark/exdark_accuracy_macro_precision_balanced240.csv,
        results/exdark/exdark_confusion_six_methods_balanced240.png
"""
from __future__ import annotations

import csv
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "results" / "exdark"
PREDICTIONS = OUT / "exdark_predictions_six_methods_balanced240.csv"
CLASSES = ["Bicycle", "Boat", "Bottle", "Bus", "Car", "Cat", "Chair", "Cup", "Dog", "Motorbike", "People", "Table"]
PREDICTED = CLASSES + ["No detection"]
METHODS = ["PWL Retinex", "Retinex-DIP", "LiCENt", "EnlightenGAN", "KinD", "LIME"]


def read_predictions():
    with PREDICTIONS.open(newline="", encoding="utf-8-sig") as f:
        rows = list(csv.DictReader(f))
    required = {"method", "true_class", "predicted_class", "correct"}
    if not rows or not required.issubset(rows[0]):
        raise ValueError(f"Expected prediction CSV columns: {sorted(required)}")
    for row in rows:
        if row["method"] not in METHODS:
            raise ValueError(f"Unexpected method: {row['method']}")
        if row["true_class"] not in CLASSES or row["predicted_class"] not in PREDICTED:
            raise ValueError(f"Unexpected class in row: {row}")
    counts = {m: sum(r["method"] == m for r in rows) for m in METHODS}
    if len(set(counts.values())) != 1 or next(iter(counts.values())) != 240:
        raise ValueError(f"Expected 240 samples per method; got {counts}")
    return rows


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    rows = read_predictions()
    matrices = {}
    summary = []
    for method in METHODS:
        subset = [r for r in rows if r["method"] == method]
        cm = np.zeros((len(CLASSES), len(PREDICTED)), dtype=np.int64)
        for row in subset:
            cm[CLASSES.index(row["true_class"]), PREDICTED.index(row["predicted_class"])] += 1
        matrices[method] = cm
        accuracy = float(np.trace(cm[:, :len(CLASSES)]) / len(subset))
        precisions = []
        for i in range(len(CLASSES)):
            predicted_count = int(cm[:, i].sum())
            precisions.append(float(cm[i, i] / predicted_count) if predicted_count else 0.0)
        summary.append([method, len(subset), accuracy, float(np.mean(precisions))])
        safe = method.replace("-", "").replace(" ", "_")
        with (OUT / f"exdark_confusion_{safe}_240.csv").open("w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["true/pred", *PREDICTED])
            for label, values in zip(CLASSES, cm):
                writer.writerow([label, *values.tolist()])

    with (OUT / "exdark_accuracy_macro_precision_balanced240.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["method", "n_images", "image_label_accuracy", "macro_precision"])
        writer.writerows(summary)

    plt.rcParams.update({"font.family": "serif", "font.size": 7})
    fig = plt.figure(figsize=(14, 8.4))
    grid = fig.add_gridspec(2, 4, width_ratios=[1, 1, 1, .055], left=.055, right=.96,
                            top=.91, bottom=.14, hspace=.42, wspace=.36)
    axes = [fig.add_subplot(grid[r, c]) for r in range(2) for c in range(3)]
    colorbar_ax = fig.add_subplot(grid[:, 3])
    for ax, method in zip(axes, METHODS):
        cm = matrices[method].astype(float)
        row_totals = cm.sum(axis=1, keepdims=True)
        normalized = np.divide(cm, row_totals, out=np.zeros_like(cm), where=row_totals != 0)
        im = ax.imshow(normalized, cmap="Blues", vmin=0, vmax=1, aspect="auto")
        ax.set_title(method, fontsize=9)
        ax.set_xticks(range(len(PREDICTED)), PREDICTED, rotation=65, ha="right", fontsize=5)
        ax.set_yticks(range(len(CLASSES)), CLASSES, fontsize=5)
        ax.set_xlabel("Predicted class", fontsize=6)
        ax.set_ylabel("True class", fontsize=6)
    fig.colorbar(im, cax=colorbar_ax, label="Row-normalized proportion")
    fig.suptitle("ExDark image-label confusion matrices on the same balanced CPU sample", fontsize=12)
    fig.savefig(OUT / "exdark_confusion_six_methods_balanced240.png", dpi=300,
                bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"Wrote results under {OUT}")


if __name__ == "__main__":
    main()
