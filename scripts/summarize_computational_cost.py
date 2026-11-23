"""Rebuild the compact computational-cost table from saved CPU benchmarks.

This script summarizes retained measurements; it does not rerun enhancement.
"""
from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COST = ROOT / "results" / "cost"


def read_rows(filename: str) -> list[dict[str, str]]:
    with (COST / filename).open(newline="", encoding="utf-8-sig") as stream:
        return list(csv.DictReader(stream))


def main() -> None:
    rows = read_rows("pytorch_cost_benchmark.csv") + read_rows("tensorflow_cost_benchmark.csv")
    expected = {"LOL-v1", "LOL-v2 Real"}
    by_method: dict[str, dict[str, dict[str, str]]] = {}
    for row in rows:
        dataset, method = row["dataset"], row["method"]
        if dataset not in expected:
            raise ValueError(f"Unexpected dataset: {dataset}")
        if dataset in by_method.setdefault(method, {}):
            raise ValueError(f"Duplicate result for {method} on {dataset}")
        by_method[method][dataset] = row

    if any(set(datasets) != expected for datasets in by_method.values()):
        raise ValueError("Each method must have one row for both paired datasets")

    fields = ["method", "parameters_M", "LOL-v1_mean_s", "LOL-v1_sd_s",
              "LOL-v1_images", "LOL-v2_Real_mean_s", "LOL-v2_Real_sd_s",
              "LOL-v2_Real_images", "equal_dataset_mean_s"]
    summary = []
    for method, datasets in sorted(by_method.items()):
        v1, v2 = datasets["LOL-v1"], datasets["LOL-v2 Real"]
        p1, p2 = v1.get("parameters_M", ""), v2.get("parameters_M", "")
        if p1 and p2 and abs(float(p1) - float(p2)) > 1e-9:
            raise ValueError(f"Parameter count changes across datasets for {method}")
        t1, t2 = float(v1["mean_seconds_per_image"]), float(v2["mean_seconds_per_image"])
        summary.append({
            "method": method,
            "parameters_M": p1 or p2 or "--",
            "LOL-v1_mean_s": f"{t1:.6f}",
            "LOL-v1_sd_s": f"{float(v1['sd_seconds_per_image']):.6f}",
            "LOL-v1_images": v1["timed_images"],
            "LOL-v2_Real_mean_s": f"{t2:.6f}",
            "LOL-v2_Real_sd_s": f"{float(v2['sd_seconds_per_image']):.6f}",
            "LOL-v2_Real_images": v2["timed_images"],
            "equal_dataset_mean_s": f"{(t1 + t2) / 2:.6f}",
        })

    with (COST / "cost_summary.csv").open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        writer.writerows(summary)


if __name__ == "__main__":
    main()
