These are the analysis methods used for the article **Loss of Flcn in dopaminergic neurons is protective against alpha-synuclein toxicity and promotes lysosomal function.**

## Analysis workflows

| Folder | What it does |
| --- | --- |
| [Cellpose segmentation](Cellpose_segmentation/README.md) | Uses THFinder, a fine-tuned Cellpose model, to segment tyrosine hydroxylase-positive neurons in mouse midbrain images. |
| [Cylinder tracking](Cylinder_tracking/README.md) | Uses DeepLabCut to track the mouse's head and tail base in cylinder videos, then cleans and plots the tail-base trajectory. |
| [Fluorescence analysis](Fluorescence_analysis/README.md) | Measures mean fluorescence intensity and the area covered by target-positive pixels within a selected region and across the whole image. |

Start with the README for the workflow you want to run. Each one describes its setup, required inputs, and how to run the analysis.
