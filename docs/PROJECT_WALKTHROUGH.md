# Work completed so far

This page records the project's current sequence and points to the artifacts that correspond to each step. It describes what is present in this repository and avoids treating reported, unverified hardware figures as established results.

## 1. Set the algorithm and implementation target

The design follows the base-paper PWL Retinex flow: estimate illumination, preserve edges while refining it, recover reflectance, remap illumination, and reconstruct the enhanced RGB pixel. The FPGA implementation is a streaming Verilog pipeline.

## 2. Move to the current RTL snapshot

The root-level source files from the earlier repository version were superseded by the current source set copied from the working Vivado project. The active design is under `rtl/`, the image-stream testbench is under `sim/`, and the required reciprocal/remapping lookup tables accompany the RTL. The RTL source uses an 11 × 11 neighborhood and fixed-point operations, with the PWL approximation in `linear_approx_gamma.v`.

The current testbench comments describe warm-up and flush streaming and an end-to-end 40-cycle schedule. The top-level source also documents the 28-cycle guidance alignment and 38-cycle refined-illumination path. These values should be confirmed by running the current simulation; this repository update does not claim a fresh simulation or synthesis run.

## 3. Build the comparison set

The paper evaluates six named methods: PWL Retinex, Retinex-DIP, LiCENt, EnlightenGAN, KinD, and LIME. They were selected to cover a model-based Retinex pipeline, per-image deep prior, learned lightness/decomposition methods, unpaired GAN enhancement, and classical illumination estimation. Method details and citations are in the paper.

## 4. Evaluate on paired and unpaired data

Paired LOL-v1 and LOL-v2 Real data are scored against their corresponding normal-light references using PSNR, SSIM, RGB MAE, VIF, and CIEDE2000. The unpaired collections DICM, LIME, NPE, and VV use NIQE, BRISQUE, NIQMC, and BLIINDS-II. These scores answer different questions and are not merged into one accuracy value.

## 5. Add a downstream detector-response analysis

The ExDark experiment runs one fixed pretrained SSDLite320 MobileNetV3 detector on enhanced images. Its mapped top category is compared with the ExDark image label. The paper reports image-label accuracy, macro precision, and confusion matrices for all six methods on one shared balanced sample. This is not paired-reference enhancement accuracy. Retinex-DIP used a reduced 20-step per-image optimization budget for this CPU detector run, which is disclosed in the paper.

## 6. Prepare the conference-paper artifacts

The current LaTeX source, figures, PDF export, and editable Word export are under `paper/`. Report tables and plots are under `results/`. The ExDark matrices can be rebuilt from the retained predictions with `scripts/analyze_exdark_predictions.py`.

## 7. Keep the claims bounded by the available evidence

The PWL quality results in the paper come from the software implementation and are not bit-accurate RTL evaluation. No common measurement of latency, memory, energy, or FPGA resources for all six enhancement methods is included. Dataset images, third-party checkpoints, and third-party method source repositories are not bundled. See `docs/REPRODUCIBILITY.md` before reproducing or extending the comparisons.
