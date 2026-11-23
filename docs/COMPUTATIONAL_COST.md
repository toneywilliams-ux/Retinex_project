# Computational-cost measurements

The `results/cost/` directory contains the retained CPU benchmark outputs for the six enhancement methods on LOL-v1 and LOL-v2 Real. The hardware, software versions, and protocol are recorded in `benchmark_metadata.json`. `cost_summary.csv` is the arithmetic mean of each method's two dataset-level mean runtimes; the datasets are weighted equally. Rebuild it with:

```bash
python scripts/summarize_computational_cost.py
```

## Measurement protocol

- Hardware: AMD Ryzen AI 7 350 CPU; CPU-only execution. No GPU timings are reported.
- Inputs: official LOL-v1 test set (15 images) and LOL-v2 Real test set (100 images).
- Each image is resized once to 512 x 512 RGB with PIL bilinear interpolation before timing.
- Three warm-up runs are performed per method, followed by timing every image in each dataset. Means and sample standard deviations are in seconds per image.
- File decoding, common resizing, model/checkpoint loading, and (for TensorFlow methods) graph construction are excluded. Method preprocessing, inference, and Retinex-DIP's per-image optimization are included.
- Retinex-DIP uses 20 optimization steps per image in these measurements.
- Trainable parameters are reported for learned networks. PWL Retinex and LIME have no learned parameters.

These are software timings on a CPU, not FPGA latency or resource measurements. The image-quality results use the floating-point PWL software implementation, not bit-accurate RTL output. Dataset files, checkpoints, third-party model source, and runtime environments are not included; see [REPRODUCIBILITY.md](REPRODUCIBILITY.md).

The included summary script only recomputes the compact summary from retained CSVs; it does not rerun the enhancement methods. Re-running the original timings requires the datasets, checkpoints, method implementations, and corresponding framework environment, which are not bundled here.

The cost values in the separately shared manuscript draft differ from these retained benchmark records. Reconcile the manuscript cost table against `cost_summary.csv` before publishing or submitting it. The manuscript files in `paper/` are intentionally unchanged by this update.
