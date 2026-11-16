# Cylinder tracking

Single-mouse tracking for the cylinder videos. DeepLabCut (DLC) estimates the **Head** and **TailBase** in each frame. The final notebook cleans the tail-base coordinates, fits a circle to the trajectory, and saves a plot per recording. The archive contains the analysis notebooks, training annotations, model configs, checkpoints, and training logs.

## Software environment

| Component | Recorded information |
| --- | --- |
| Python | **3.12.13** in the saved metadata of all four notebooks. The August 2025 training log does not identify its Python version. |
| Jupyter kernel | `DEEPLABCUT` (kernel name `python3`). |
| DeepLabCut | PyTorch engine with GUI support used by the cropping notebook. The exact DLC release is unverified. The archived log points to a historical Anaconda environment named `DEEPLABCUT`, and the archive has no package manifest. |
| Other runtime dependencies | PyTorch, pandas, NumPy, SciPy, Matplotlib, and FFmpeg on `PATH`. Package versions and the original GPU/CUDA environment are unrecorded in the archive. |

If the original environment is available, run these commands from it to identify the installed versions. Record the output alongside future analyses.

```powershell
python --version
python -m pip show deeplabcut torch torchvision pandas numpy scipy matplotlib
ffmpeg -version
```

## Folder contents

| Path | Contents |
| --- | --- |
| [config.yaml](config.yaml) | DLC project settings and per-video annotation crops. |
| [Cylinder_Processing_Codes/](Cylinder_Processing_Codes/) | Four Jupyter notebooks, numbered in execution order. The hidden `.DS_Store` is Finder metadata. |
| `training-datasets/iteration-0/UnaugmentedDataSet_Cylinder_Tracking_Single_AnimalAug8/` | `CollectedData_OF.csv` and `.h5` contain labels. `Cylinder_Tracking_Single_Animal_OF95shuffle1.mat` and `Documentation_data-Cylinder_Tracking_Single_Animal_95shuffle1.pickle` are DLC dataset artifacts. `metadata.yaml` registers the shuffle and engine. |
| `dlc-models-pytorch/iteration-0/Cylinder_Tracking_Single_AnimalAug8-trainset95shuffle1/` | `train/` holds the PyTorch config, trained weights, dated log, and metric CSVs. `test/pose_cfg.yaml` records HRNet-W32, the two joints, and global scale 1. |

Supply the raw videos separately. The archive also lacks the labeled frame images referenced by the dataset and any processed videos, inference CSVs, or trajectory outputs. The notebooks cover inference and downstream processing. Reproducing the training run also requires the labeled frames and the original pretrained weights or their equivalents.

## Running the notebooks

Set the kernel and fill the blank path cells before running. The top-level `config.yaml` has `project_path: D:\CODES\BOOTY_TRACKER`. Update it to the actual DLC project root containing the model tree. The video entries in `config.yaml`, dataset and project metadata in the model configs, and the pretrained weight paths refer to the original Windows setup. Update them as needed for the operation you are running. The archived pretrained paths are relevant to training.

1. **[Convert videos](Cylinder_Processing_Codes/0_Cylinder_Videos_Pre-Processing.ipynb).** Set `path` to the raw-video directory. FFmpeg processes MP4, MOV, AVI, and MKV files at the top level, rescales them to 480 pixels high with aspect ratio preserved and even output width, resamples to 10 fps, and strips audio. Outputs go to `DLC_Converted_Videos/<stem>_480p.mp4`.
2. **[Crop one mouse per video](Cylinder_Processing_Codes/1_Opening_DLC_GUI_For_Cropping.ipynb).** The notebook launches the DLC GUI. Load the project config, open the Video Editor, and manually crop one mouse at a time from the converted videos. Rename each crop with the animal number before producing the next crop and collect the crops in a dedicated folder. The project config lists per-source annotation crops and sets global inference cropping to `false`. The saved global bounds are `x=0:640`, `y=277:624` if that switch is enabled.
3. **[Analyze crops](Cylinder_Processing_Codes/2_Analyzing_Videos.ipynb).** Set `video_folder` and `config_path`. The notebook reports PyTorch CUDA availability and calls `deeplabcut.analyze_videos(..., save_as_csv=True)` on the same four video extensions. The per-frame prediction exports contain x, y, and likelihood for both landmarks. With `create_annotation_videos=True` (the saved default), it also renders marker overlays without skeleton lines or trails and moves the labeled MP4s into `Annotated_Videos/`. The project config sets pose and detector snapshot indices to `-1`. The notebook leaves checkpoint resolution to DLC and passes no explicit checkpoint names.
4. **[Clean and plot trajectories](Cylinder_Processing_Codes/3_Cylinder_DLC_PostProcessing.ipynb).** Set `path` to a folder containing only the DLC inference CSVs. The reader expects a three-row DLC header and seven columns in frame, Head x/y/likelihood, TailBase x/y/likelihood order. It uses the first five filename characters as the animal ID in the plot. At the saved setting `save_traces=True`, it writes `Traces/<CSV stem>_TRACE.png` at 300 dpi. With `False`, it displays plots inline. A notebook introduction mentions a summary CSV, but the code only prints cleaning counts and produces trajectory plots. It does not export cleaned coordinates or fit parameters.

### Tail-base cleaning and circle fit

- Convert frame, coordinate, and likelihood fields to numeric values. Drop rows missing the frame number or TailBase y.
- Inspect the first 600 retained rows (60 s at 10 fps). If any TailBase likelihood is strictly below `0`, drop all rows through the last such point. With ordinary nonnegative likelihoods this step removes zero rows.
- Linearly interpolate TailBase x/y for runs with likelihood below `0.7` when there are bracketing rows on both sides. This step leaves unbracketed runs as-is and keeps the original likelihood values. DLC's separate project visualization cutoff is `0.6`.
- Flag a row if either coordinate is more than 3 standard deviations from its coordinate mean. Make both coordinates missing there, then linearly interpolate and fill remaining endpoints.
- Use SciPy `leastsq` to fit the circle center by minimizing deviations of the point-to-center distances from their mean. The mean distance gives the fitted radius. The plot colors the trajectory by frame and shows the center and fitted circle. Coordinates and radius are in cropped-video pixels. The code does not convert to physical units or score behavioral events.

## Training dataset

Project `Cylinder_Tracking_Single_Animal`, scorer `OF`, dated August 8, 2025. Single-animal mode, iteration 0, PyTorch shuffle 1 / split 1, nominal 95% training fraction. Annotation extraction was configured across the full video duration with up to 20 frames requested per video. The annotation CSV contains **488 labeled frame rows across 25 source videos**. The saved split metadata contains **463 training indices and 25 test indices**. The labeled body parts are `Head` and `TailBase`.

## Models and hyperparameters

The trained shuffle is a top-down (`td`) pipeline. The detector locates the mouse, then the pose network estimates its two landmarks in the region of interest. The model-specific YAML and training log identify the trained pose net as **HRNet-W32**. The root config also contains the project default `resnet_50` for shuffle setup.

| Setting | Detector | Pose estimation |
| --- | --- | --- |
| Architecture | Faster R-CNN, `fasterrcnn_mobilenet_v3_large_fpn` | `hrnet_w32`, 32 backbone output channels, two heatmaps and four x/y refinement channels. Both heads end in 1×1 convolutions. |
| Initialization | SuperAnimal TopViewMouse corresponding detector weights | SuperAnimal TopViewMouse HRNet-W32 weights, `with_decoder: false`, `memory_replay: false`, head initialization `normal` |
| Batch size | 1 | 8 |
| Epochs reached in log | 200. The last logged session resumed at epoch 151, and the archived YAML lists 250. | 200 |
| Optimizer | AdamW, initial LR `1e-4` | AdamW, initial LR `1e-4` |
| LR schedule | `1e-5` at epoch 160 | `1e-5` at epoch 160, `1e-6` at epoch 190 |
| Evaluation | Every 10 epochs, maximize `test.mAP@50:95` | Every 10 epochs, maximize `test.mAP` |
| Loss | Log reports box regression, classifier, objectness, and RPN box regression terms | Weighted MSE heatmap loss × 1.0, weighted Huber location-refinement loss × 0.05 |
| Batch normalization | Statistics frozen, weights trainable | Statistics frozen, weights trainable |

The archived config sets automatic device selection, zero data-loader workers and no pinned memory for both stages, with display interval 500 and pose seed 42. Each stage is configured to keep up to five snapshots without optimizer state. The archived YAML lists a 25-epoch save interval, while logged training configs list 50 epochs and the retained periodic snapshots are at 50-epoch steps.

**Pose preprocessing and targets.** Normalized RGB, a bounding-box margin of 20 pixels, 256 × 256 top-down crops, and padding to multiples of 32 in both dimensions. Training uses affine augmentation with probability 0.5, rotation setting 30°, scale fixed at 1.0, and zero translation, plus Gaussian noise setting 12.75 and motion blur. The Gaussian keypoint targets use positive-distance threshold 17, gradient masking, background weight 0.0, and location-refinement standard deviation 7.2801. The predictor clips scores, disables sigmoid, and enables location refinement.

**Detector preprocessing.** Normalized RGB with horizontal flips during training. Affine probability 0.5, rotation setting 30°, fixed scale 1.0, and translation setting 40. Training collation uses resize scale bounds 0.4–1.0, short-side bounds 128–1152 pixels, and dimensions constrained to multiples of 32 without forcing a square.

## Saved checkpoints and evaluation

The training directory contains nine `.pt` files. DLC's `best` filenames mark the checkpoints selected by the respective training metrics.

| Stage | Retained checkpoints | Logged test metrics for best checkpoint |
| --- | --- | --- |
| Detector | `snapshot-detector-{050,100,150,200}.pt`, `snapshot-detector-best-190.pt` | Epoch 190, mAP@50:95 **83.94**, mAP@50 **100.00**, mAP@75 **87.46**. Epoch 200 mAP@50:95 was **83.61**. |
| Pose | `snapshot-{050,100,150}.pt`, `snapshot-best-200.pt` | Epoch 200, mAP **91.24**, mAR **92.80**, RMSE **1.25 px**, RMSE at project likelihood cutoff **1.25 px**. |

`train.txt` records the training sessions and periodic evaluations. `learning_stats.csv` covers pose epochs 1–200, and `learning_stats_detector.csv` covers the final detector segment, epochs 151–200. These are DLC metrics from the archived shuffle's held-out split. The archive contains no separate test results on unseen animals or behavioral scoring.
