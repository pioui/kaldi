#!/bin/bash
source path.sh

# Train a unigram and a bigram language model.
build-lm.sh -i data/local/dict/lm_train.text -n 1 -o data/local/lm_tmp/uni_model.ilm.gz -l uni_logfile.log
build-lm.sh -i data/local/dict/lm_train.text -n 2 -o data/local/lm_tmp/bi_model.ilm.gz -l bi_logfile.log

# Save the compiled language model in ARPA format
compile-lm data/local/lm_tmp/uni_model.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_ug.arpa.gz
compile-lm data/local/lm_tmp/bi_model.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_bg.arpa.gz

# Create the lexicon FST 
prepare_lang.sh data/local/dict "<oov>" /tmp data/lang #create fst for language dictionary

# Sort the files wav.scp, text και utt2spk
sort -o data/train/wav.scp data/train/wav.scp
sort -o data/train/text data/train/text
sort -o data/train/utt2spk data/train/utt2spk

sort -o data/dev/wav.scp data/dev/wav.scp
sort -o data/dev/text data/dev/text
sort -o data/dev/utt2spk data/dev/utt2spk

sort -o data/test/wav.scp data/test/wav.scp
sort -o data/test/text data/test/text
sort -o data/test/utt2spk data/test/utt2spk

# Create a new file spk2utt
./utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
./utils/utt2spk_to_spk2utt.pl data/dev/utt2spk > data/dev/spk2utt
./utils/utt2spk_to_spk2utt.pl data/test/utt2spk > data/test/spk2utt

bash local/timit_format_data.sh 

# # Export mfcc
# ./steps/make_mfcc.sh data/train
# ./steps/make_mfcc.sh data/test
# ./steps/make_mfcc.sh data/dev
# #perform Cepstral Mean and Variance Normalization
# ./steps/compute_cmvn_stats.sh data/train
# ./steps/compute_cmvn_stats.sh data/test
# ./steps/compute_cmvn_stats.sh data/dev