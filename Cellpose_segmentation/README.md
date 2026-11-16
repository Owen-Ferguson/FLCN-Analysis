# THFinder

THFinder uses a fine-tuned Cellpose model to segment individual tyrosine hydroxylase-positive (TH+) neurons in mouse midbrain images. The model was fine-tuned from Cellpose `cyto2` on 75 manually annotated image crops.

## Model weights

**Zenodo DOI** — '10.5281/zenodo.16853350'

Download the following checkpoint from the Zenodo record and place it in `data/cellpose/training/models/` relative to the directory containing `test.sh`. Keep the original filename.

```text
cellpose_residual_on_style_on_concatenation_off_training_2023_12_14_14_44_43.276555
```

## Run segmentation

The study inference run used Cellpose `2.2+computecanada`, Python `3.10.2`, and PyTorch `2.0.1` on Linux with a CUDA-enabled GPU. Activate the Cellpose environment before running the command below.

From the directory containing `test.sh` and `shuffle-labels.py`, run:

```bash
bash test.sh -p "/path/to/images" -d 15
```

The script writes TIFF segmentation masks to `segmentations/` inside the input folder, copies `test.sh` into the input folder, and runs `shuffle-labels.py` on that folder.

| Inference setting | Study run |
| --- | --- |
| Input channel | Grayscale (`--chan 0`), no secondary channel |
| Diameter | 15 pixels |
| Flow threshold | 0.5 |
| Cell probability threshold | −0.5 |
| Output | TIFF masks, with NumPy output disabled |

The inference run processed 48 images on Valeria on June 21, 2024 (job `778169`).

## Fine-tuning

`train.sh` records the training configuration. It expects training images and masks under `data/cellpose/training/` and validation data under `data/cellpose/validation/`. From the directory containing the scripts, run `bash train.sh` with those data in place and the Cellpose environment active.

| Training setting | Value |
| --- | --- |
| Starting model | `cyto2` |
| Training data | 75 manually annotated crops |
| Epochs | 250 |
| Learning rate | 0.05 |
| Channel argument | `--chan 0` |
| Diameter argument | `--diameter 0` |
| Mask filename filter | `--mask_filter _masks` |
| Minimum training masks per image | `--min_train_masks 1` |
| Additional flags | `--dir_above`, `--use_gpu` |
