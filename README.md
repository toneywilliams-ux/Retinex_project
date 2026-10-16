# Retinex-Based Low-Light Image Enhancement on FPGA

This repository contains the Verilog implementation of a Retinex-inspired low-light enhancement pipeline and the accompanying software comparative study. The comparison evaluates the PWL Retinex method against five established methods using paired-reference image-quality metrics, blind no-reference metrics, and a separate detector-response experiment.

## Repository contents

```text
.
├── 0_retinex_top.v … 6_reconstruction.v   # Existing RTL pipeline modules
├── tb_retinex.v                            # Existing Verilog testbench
├── paper/                                  # Current conference-paper files
│   ├── pwl_retinex_comparison.tex
│   ├── pwl_retinex_comparison.pdf
│   ├── pwl_retinex_comparison.docx
│   └── latex_figures/                      # Figures used by the LaTeX source
├── results/
│   ├── paired/                             # LOL-v1 and LOL-v2 Real results
│   ├── no_reference/                       # DICM, LIME, NPE, and VV results
│   └── exdark/                             # Six-method detector-response results
├── scripts/
│   └── analyze_exdark_predictions.py       # Rebuild detector summary and matrices
├── docs/
│   ├── DATASETS_AND_METRICS.md
│   └── REPRODUCIBILITY.md
└── requirements-analysis.txt
```

## Compared enhancement methods

The study includes the base-paper PWL Retinex method, Retinex-DIP, LiCENt, EnlightenGAN, KinD, and LIME. The methods cover a fixed model-based Retinex pipeline, an image-specific deep prior, learned Retinex/lightness models, an unpaired GAN, and classical illumination-map estimation.

## Evaluations and results

- **Paired-reference quality:** LOL-v1 and LOL-v2 Real; PSNR, SSIM, RGB MAE, VIF, and CIEDE2000.
- **Blind no-reference quality:** DICM, the LIME image collection, NPE, and VV; NIQE, BRISQUE, NIQMC, and BLIINDS-II.
- **Downstream detector response:** ExDark; image-label accuracy, macro precision, and row-normalized confusion matrices from one fixed pretrained SSDLite320 MobileNetV3 detector.

The paper and `results/` directory contain the reported tables, per-image LOL-v1 scores/ranges, figures, confusion matrices, and the balanced ExDark sample predictions. For the six-method ExDark comparison, all methods use the same balanced 240-image sample. Retinex-DIP used 20 per-image optimization steps for that CPU detector run. Detector accuracy measures agreement between a frozen detector's mapped top prediction and the ExDark image label; it is not enhancement accuracy against a bright reference.

The comparison's PWL results come from the floating-point software implementation. They are not bit-accurate outputs from the Verilog design. Accordingly, this paper does not use its image-quality tables to claim FPGA resource, latency, or energy advantages.

## Quick start: regenerate ExDark matrices

Python 3.10 or newer is recommended. Install the small analysis dependencies and run:

```bash
python -m pip install -r requirements-analysis.txt
python scripts/analyze_exdark_predictions.py
```

The script reads `results/exdark/exdark_predictions_six_methods_balanced240.csv` and regenerates the per-method confusion-matrix CSVs, summary CSV, and combined figure. It does not download or process ExDark images.

See [docs/REPRODUCIBILITY.md](docs/REPRODUCIBILITY.md) for data/checkpoint requirements and methodological notes.
