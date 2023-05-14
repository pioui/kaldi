#!/bin/bash

# Building the language model and calculate preplexities in the end
# Usage:
#   bash scripts/languege_model.sh

source path.sh

# Train a unigram and a bigram language model.
build-lm.sh -i data/local/dict/lm_train.text -n 1 -o data/local/lm_tmp/uni_model.ilm.gz
build-lm.sh -i data/local/dict/lm_train.text -n 2 -o data/local/lm_tmp/bi_model.ilm.gz

# Save the compiled language model in ARPA format
compile-lm data/local/lm_tmp/uni_model.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_ug.arpa.gz
compile-lm data/local/lm_tmp/bi_model.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_bg.arpa.gz

# Create the lexicon FST 
prepare_lang.sh data/local/dict "<oov>" /tmp data/lang #create fst for language dictionary

# Sort the files wav.scp, text και utt2spk
for x in train dev test; do
  sort -o data/$x/wav.scp data/$x/wav.scp
  sort -o data/$x/text data/$x/text
  sort -o data/$x/utt2spk data/$x/utt2spk
  ./utils/utt2spk_to_spk2utt.pl data/$x/utt2spk > data/$x/spk2utt
done

# Finally create the grammar FST (G.fst)
bash local/timit_format_data.sh 

# Calculate Preplexity
compile-lm data/local/lm_tmp/uni_model.ilm.gz -eval=data/local/dict/lm_dev.text
compile-lm data/local/lm_tmp/uni_model.ilm.gz -eval=data/local/dict/lm_test.text
compile-lm data/local/lm_tmp/bi_model.ilm.gz -eval=data/local/dict/lm_dev.text
compile-lm data/local/lm_tmp/bi_model.ilm.gz -eval=data/local/dict/lm_test.text

# # Export mfcc
# ./steps/make_mfcc.sh data/train
# ./steps/make_mfcc.sh data/test
# ./steps/make_mfcc.sh data/dev
# #perform Cepstral Mean and Variance Normalization
# ./steps/compute_cmvn_stats.sh data/train
# ./steps/compute_cmvn_stats.sh data/test
# ./steps/compute_cmvn_stats.sh data/dev