#!/bin/bash

# Extract the MFCC features for all 3 sets, using the Kaldi scripts
# Usage:
#   bash scripts/extract_mfcc.sh

source path.sh

for x in train dev test; do
  # Extract the MFCC features
  ./steps/make_mfcc.sh data/$x
  # Perform Cepstral Mean and Variance Normalization
  ./steps/compute_cmvn_stats.sh data/$x
  echo "Number of features extracted for $x set:"
  feat-to-dim scp:data/train/feats.scp - 
done



