# Mean Fluorescence Intensity and Area Coverage

[Mean_Intensity_and_Area_Coverage.ipynb](Mean_Intensity_and_Area_Coverage.ipynb) analyzes fluorescence microscopy images. Choose a **target channel** that contains the signal to quantify and a **mask channel** that defines the region to measure. The notebook reports the percentage of that region occupied by target-positive pixels and the mean fluorescence intensity of those pixels. It also reports both measurements across the whole image.

## Setup

Install the dependencies in the Python environment you use for Jupyter.

```bash
python -m pip install notebook tifffile numpy pandas matplotlib scikit-image scipy
```

Put the images in one folder as `.tif` or `.tiff` files. Use 2D images stored as **channels × height × width (C × Y × X)**, with the same channel order in every file. The batch measurement cell indexes channels along the first axis. If your images are channel-last, Z-stacks, or time series, convert them to channel-first 2D images before running the notebook, even if the preview can open them.

## Run the analysis

1. **Set the folder and channels.** In the first cell, set `path` to the image folder. Set `target` and `mask` to the channel indices, where `0` is the first channel. Fill in `target_name` and `mask_name` for plot labels and output filenames. For example, if the mask is in the second channel and the target is in the third, use `mask = 1` and `target = 2`.
2. **Define the analysis region.** Keep `invert_mask = False` to measure inside the mask. Set it to `True` to measure outside it. To add a second mask, set `second_mask` to its channel index and fill in `second_mask_name`. The analysis region is the intersection of the two masks after applying any inversion to each mask. Leave `second_mask = None` to use one mask.
3. **Review the suggested thresholds.** Run the next cell to calculate an Otsu threshold for each selected channel in each image. The notebook prints the median threshold for each channel and the image closest to that median. The preview defaults to the image closest to the **target** channel median.
4. **Set and preview the thresholds.** Enter `threshold_value_target`, `threshold_value_mask`, and, if enabled, `threshold_value_mask2`. The batch uses these manually entered thresholds for every image. Pixels with values strictly above the threshold are positive. The preview shows the original channels alongside their binary images. To inspect another image, set `img_to_show` to its full path.
5. **Measure and export.** Run the batch measurement cell to create `df_fin`, with one row per image. Run the final cell to save the CSV to the `Analysis Results` subfolder of the image folder.

The optional `blur_mask` and `blur_mask2` settings apply Gaussian smoothing to the binary masks, then keep pixels where the smoothed value exceeds 0.1. This changes the analysis region. Set either value to `None` to skip smoothing for that mask. The `display_percentile` setting changes preview brightness only.

## Measurements in the CSV

| Measurement | Calculation |
| --- | --- |
| Target-positive area (% of whole image) | 100 × target-positive pixels ÷ all image pixels |
| Mean target intensity above threshold (whole image) | Mean of the original target-channel values at all target-positive pixels |
| Target-positive area (% of masked region) | 100 × target-positive pixels inside the analysis region ÷ all pixels in that region |
| Mean target intensity above threshold in mask(s) | Mean of the original target-channel values at target-positive pixels inside the analysis region |

For example, if the mask contains 1,000 pixels and 250 are target-positive, the masked area coverage is **25%**. The masked mean intensity averages the original fluorescence values of those 250 pixels.

The CSV also records the image filename, thresholds, and mask inversion settings. The notebook returns a mean intensity of `0` when there are no target-positive pixels in the measured region. If the final mask is empty, it prints a warning and reports `0` for both masked measurements. Check the warnings before interpreting a masked zero as an absence of target signal.
