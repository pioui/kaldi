#!/bin/bash
source path.sh

# Train a unigram and a bigram language model.
build-lm.sh -i data/local/dict/lm_train.text -n 1 -o data/local/lm_tmp/uni_model.ilm.gz -l uni_logfile.log
build-lm.sh -i data/local/dict/lm_train.text -n 2 -o data/local/lm_tmp/bi_model.ilm.gz -l bi_logfile.log

# Save the compiled language model in ARPA format

compile-lm data/local/lm_tmp/uni_model.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_ug.arpa.gz
compile-lm data/local/lm_tmp/bi_model.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_bg.arpa.gz