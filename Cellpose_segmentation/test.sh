#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo
   echo "Runs Cellpose mode in testing mode on the specified folder."
   echo
   echo "Syntax: test.sh [-p|-d|h]"
   echo "options:"
   echo "p     Specifies the folder path"
   echo "d     Specifies the diameter of cells"
   echo "h     Print this Help."
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

# Set variables
path="./data/cellpose/testing"
diameter=0

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts "hp:d:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      p) # Enter a name
         path=$OPTARG;;
      d) # Enter a diameter
         diameter=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

python -m cellpose --dir "${path}" --use_gpu --chan 0 \
	--savedir "${path}/segmentations" --save_tif --no_npy \
	--diameter ${diameter} \
	--flow_threshold 0.5 \
	--cellprob_threshold -0.5 \
	--verbose \
    --pretrained_model ./data/cellpose/training/models/cellpose_residual_on_style_on_concatenation_off_training_2023_12_14_14_44_43.276555
    # --pretrained_model ./data/cellpose/training/models/cellpose_residual_on_style_on_concatenation_off_training_2023_09_06_06_41_53.187847    
    # --pretrained_model nuclei
   # --pretrained_model ./data/cellpose/training/models/cellpose_residual_on_style_on_concatenation_off_training_2023_08_08_10_37_16.868268
   # --pretrained_model ./data/cellpose/training/models/cellpose_residual_on_style_on_concatenation_off_training_2023_02_15_08_49_58.519633   

current_file=$(basename -- "${BASH_SOURCE}")
cp "${current_file}" "${path}"

python shuffle-labels.py --folder "${path}"
