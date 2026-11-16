
import numpy
import os
import glob
import tifffile

from tqdm.auto import tqdm

def shuffle_labels(ary, relabel=True):
    numpy.random.seed(42)
    ids = numpy.unique(ary)[1:]
    perm_ids = numpy.random.permutation(ids)
    copy_ = numpy.zeros_like(ary)
    for perm_idx, idx in zip(perm_ids, ids):
        copy_[ary == idx] = perm_idx
    if relabel:
        return relabel_labels(copy_)
    return copy_

def relabel_labels(ary):
    ids = numpy.unique(ary)[1:]
    perm_ids = numpy.arange(len(ids)) + 1
    copy_ = numpy.zeros_like(ary)
    for perm_idx, idx in zip(perm_ids, ids):
        copy_[ary == idx] = perm_idx
    return copy_

if __name__ == "__main__":

    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--folder", type=str,
                        help="The name of the folder containing the labels")
    args = parser.parse_args()

    files = glob.glob(os.path.join(args.folder, "segmentations", "*.tif"))

    for file in tqdm(files, desc="Images"):

        label = tifffile.imread(file)
        label = shuffle_labels(label)

        tifffile.imwrite(file, label.astype(numpy.uint16))
