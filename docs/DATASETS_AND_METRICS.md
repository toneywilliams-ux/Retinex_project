# Datasets and metrics

## Paired-reference datasets

**LOL-v1** and **LOL-v2 Real** contain low-light inputs with corresponding normal-light reference images. Their aligned pairs support direct image-fidelity comparison. The repository contains reported summary tables and retained LOL-v1 per-image values; the image datasets themselves are not included.

## Unpaired datasets

**DICM**, the **LIME image collection**, **NPE**, and **VV** provide low-light scenes without aligned normal-light targets in this experiment. They are evaluated with no-reference quality predictors. The LIME image collection is a dataset and is distinct from the LIME enhancement algorithm.

## Detector-response dataset

**ExDark** supplies image-category labels for dark scenes. A fixed pretrained Torchvision SSDLite320 MobileNetV3 detector is run on enhanced images. Its top-confidence mapped category is compared to the ExDark image label; a missing mapped detection is counted as incorrect. The confusion matrices therefore describe one detector's response to enhanced images, not image reconstruction accuracy or general object-detection performance.

## Metric interpretation

- **PSNR (dB):** pixelwise error relative to a paired reference; higher is better.
- **SSIM:** local luminance, contrast, and structure similarity; higher is better.
- **RGB MAE:** mean absolute channel error on the 8-bit scale; lower is better.
- **VIF:** estimated visual information retained relative to the reference; higher is better.
- **CIEDE2000:** perceptual color difference in CIELAB; lower is better.
- **NIQE and BRISQUE:** blind quality predictors; conventionally lower is preferred.
- **NIQMC:** blind naturalness/contrast score; higher is preferred for the implementation used in this study.
- **BLIINDS-II:** blind transform-statistics quality score; lower is preferred.
- **Image-label accuracy and macro precision:** downstream detector measures, reported separately from enhancement-fidelity metrics.

No-reference values have unequal output coverage in the retained results and are treated as descriptive macro-averages. The scales of different metrics are not combined into one score.
