#!/bin.bash
	
	#step 4.1
source /home/pigi/repos/kaldi/egs/usc2/path.sh

#4.1.2 - create soft links in path ~/kaldi/egs/usc/data
ln -s ../../wsj/s5/steps steps
ln -s ../../wsj/s5/utils utils
#4.1.3 - create local directory
mkdir local; cd ./local #move to local dir
ln -s ../../../wsj/s5/steps/score_kaldi.sh score_kaldi.sh #create soft link in local dir
#4.1.4 - create directory ~/kaldi/egs/usc/data/conf
cd ..; mkdir conf; cd ./conf
cp ~/Downloads/mfcc.conf . #copy mfcc.conf file 
#4.1.5 - create certain directories
cd ..
mkdir data data/lang data/local/ data/local/dict data/local/lm_tmp data/local/nist_lm

	#step 4.2
#4.2.1 - create files: silence_phones.txt, optional_silence.txt, extra_questions.txt
cd ./data/local/dict
touch silence_phones.txt optional_silence.txt
echo "sil" > silence_phones.txt 
echo "sil" > optional_silence.txt
touch extra_questions.txt
#(lexicon.txt and lm_train.text are being created in file script.py) 
#4.2.2
cd ../lm_tmp #move to lm_tmp directory
build-lm.sh -i ../dict/lm_train.text -n 1 -o uni_train.ilm.gz #create unigram model
build-lm.sh -i ../dict/lm_train.text -n 2 -o bi_train.ilm.gz #create bigram model
#4.2.3
compile-lm uni_train.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > ../nist_lm/lm_phone_ug.arpa.gz #unigram language model in arpa form
compile-lm bi_train.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > ../nist_lm/lm_phone_bg.arpa.gz #bigram language model in arpa form
#4.2.4
cd ../../
prepare_lang.sh data/local/dict "<oov>" /tmp data/lang #create fst for language dictionary
#4.2.5 - sort files wav.scp and utt2spk
cd ./train
sort wav.scp -o wav.scp; sort test -o test; sort utt2spk -o utt2spk
cd ../test
sort wav.scp -o wav.scp; sort test -o test; sort utt2spk -o utt2spk     
cd ../dev
sort wav.scp -o wav.scp; sort test -o test; sort utt2spk -o utt2spk     
#4.2.6 - create in data/test, data/train, data/dev file spk2utt
cd ..
./utils/utt2spk_to_spk2utt.pl ./train/utt2spk > ./train/spk2utt
./utils/utt2spk_to_spk2utt.pl ./dev/utt2spk > ./dev/spk2utt
./utils/utt2spk_to_spk2utt.pl ./test/utt2spk > ./test/spk2utt
#4.2.7 - create G.fst. To execute the script we first need to change some parameters to suit
#our local directory structure. For example, we replace "data" with "." etc.
bash ./timit_format_data.sh 

# 	#step 4.3
# #export mfcc
# ./steps/make_mfcc.sh ./train
# ./steps/make_mfcc.sh ./test
# ./steps/make_mfcc.sh ./dev
# #perform Cepstral Mean and Variance Normalization
# ./steps/compute_cmvn_stats.sh ./train
# ./steps/compute_cmvn_stats.sh ./test
# ./steps/compute_cmvn_stats.sh ./dev

# 	#step 4.4
# cd home/pigi/repos/kaldi/egs/usc2/data
# #4.4.1 - Train GMM-HMM model over training data
# ./steps/train_mono.sh ./train ./lang_phones_ug ./exp/mono_ug
# ./steps/train_mono.sh ./train ./lang_phones_bg ./exp/mono_bg
# #4.4.2 - create HCLG graph
# ./utils/mkgraph.sh ./lang_phones_ug ./exp/mono_ug exp/mono_ug/graph
# ./utils/mkgraph.sh ./lang_phones_bg ./exp/mono_bg exp/mono_bg/graph
# #4.4.3 - use Viterbi algorithm to decode data
# ./steps/decode.sh exp/mono_ug/graph ./test exp/mono_ug/decode_test
# ./steps/decode.sh exp/mono_ug/graph ./dev exp/mono_ug/decode_dev
# ./steps/decode.sh exp/mono_bg/graph ./test exp/mono_bg/decode_test
# ./steps/decode.sh exp/mono_bg/graph ./dev exp/mono_bg/decode_dev
# #4.4.4 - score decoded data
# ./local/score_kaldi.sh ./test ./exp/mono_ug/graph ./exp/mono_ug/decode_test
# ./local/score_kaldi.sh ./dev ./exp/mono_ug/graph ./exp/mono_ug/decode_dev
# ./local/score_kaldi.sh ./test ./exp/mono_bg/graph ./exp/mono_bg/decode_test
# ./local/score_kaldi.sh ./dev ./exp/mono_bg/graph ./exp/mono_bg/decode_dev

