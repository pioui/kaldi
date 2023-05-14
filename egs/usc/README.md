# Phone Recognition using Kaldi

### Preparing the USC-TIMIT speech recognition system 
All files needed are created in /data directory:
```
bash scripts/prepare_data.sh <USC DATA DIRECTORY> 
```
### Build the language model and calculate preplexities:

```
bash scripts/languege_model.sh
```

### Extract the MFCC features:

```
bash scripts/extract_mfcc.sh
```
