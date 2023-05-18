import os
import re

#prelab (3)
#data core - file utt2spk
root = '/home/pigi/repos/kaldi/egs/usc2/data'
for subdir in os.scandir(root):
	if subdir.is_file(): #skip all the files
		continue
	#for each directory create utt2spk
	if (str(subdir) not in ["<DirEntry 'test'>", "<DirEntry 'dev'>", "<DirEntry 'train'>"]):
		continue
	f = open(os.path.join(subdir, "uttids"), "r") #read data from uttids file
	g = open(os.path.join(subdir, "utt2spk"), "w") #use the data for the utt2spk file
 	#read the lines from uttids
	for line in f:
		var = line.split("_")[0] #split before _
		g.write(line.strip("\n") + " " + var + "\n") #write only the first value

#data core - wav.scp
root = '/home/pigi/repos/kaldi/egs/usc2/data'
for subdir in os.scandir(root):
	if subdir.is_file():
		continue #skip all the files
	#for each directory create utt2spk
	if (str(subdir) not in ["<DirEntry 'test'>", "<DirEntry 'dev'>", "<DirEntry 'train'>"]):
		continue
	f = open(os.path.join(subdir, "uttids"), "r") #read data from uttids
	g = open(os.path.join(subdir, "wav.scp"), "w") #use the data for the wav.scp file
	#read the lines from wav.scp file
	for line in f:
		var = "/home/pigi/data/usc2/wav/" + line.strip("\n") + ".wav"
		g.write(line.strip("\n") + " " + var + "\n")

#data core - text
root = '/home/pigi/repos/kaldi/egs/usc2/data'
for subdir in os.scandir(root):
	if subdir.is_file():
		continue #skip all the files
	#for each directory create text file
	if (str(subdir) not in ["<DirEntry 'test'>", "<DirEntry 'dev'>", "<DirEntry 'train'>"]):
		continue
	f = open(os.path.join(subdir, "uttids"), "r") #read data from uttids
	g = open(os.path.join(subdir, "text"), "w") #use the data for the text file
	h = open("/home/pigi/data/usc2/transcriptions.txt","r") #read the data from transcriptions
	#read the lines from the files above
	lines = h.readlines()
	for line in f:
		for l in lines:
			if (line.strip('\n').split('_')[1] == l.split("\t")[0]):
				var = l.strip("\n").split("\t")[1]
				g.write(line.strip("\n") + " " + var + "\n")


root = '/home/pigi/repos/kaldi/egs/usc2/data'
for subdir in os.scandir(root):
	if subdir.is_file():
		continue #skip all the files
	#for each directory create text file
	if (str(subdir) not in ["<DirEntry 'test'>", "<DirEntry 'dev'>", "<DirEntry 'train'>"]):
		continue
	f = open(os.path.join(subdir, "text"), "r")
	g = open("/home/pigi/data/usc2/lexicon.txt", "r") #read data from lexicon
	lexicon = {}
	for line in g:
		lexicon[line.split("\t")[0]] = line.split("\t")[1]
	lines = f.readlines()
	output = ""
	for line in lines:
		new = ' '.join(line.split(" ")[1:]).upper()
		new2 = re.sub(r"[^A-Z\s\']", " ", new)
		output += line.split(" ")[0]
		output += " sil"
		for word in new2.strip(" \n").split(" "):
			if (word == ''):
				continue
			output += " " + lexicon[word].strip(' \n')
		output += " sil\n"
	f.close()
	g.close()
	n = open(os.path.join(subdir,"text"), "w")
	n.write(output)

#create nonsilence_phones.txt
f = open("/home/pigi/data/usc/lexicon.txt", "r")
se = set()
for line in f:
	new = line.split("\t")[1].strip("\n")
	for ab in new.split(" "):
		if (ab != ""):
			se.add(ab)
se = sorted(se)
se.remove("sil") #remove silence from phones
se.remove("<oov>") #remove oov from phones
f.close()
f = open("/home/pigi/repos/kaldi/egs/usc2/data/local/dict/nonsilence_phones.txt", "w")
output = ""
for word in se:
	output += word + "\n"
f.write(output)
f.close()

#modify train,dev,test/text by adding <s> in front and back of each sentence and save the result
f = open("/home/pigi/repos/kaldi/egs/usc2/data/local/dict/lexicon.txt", "w")
g = open("/home/pigi/repos/kaldi/egs/usc2/data/local/dict/nonsilence_phones.txt", "r")
output = "sil sil\n"
for line in g:
	output += line.strip("\n ") + " " + line.strip("\n ") + "\n"
f.write(output)
f.close()
g.close()

root = "/home/pigi/repos/kaldi/egs/usc2/data/"
for subdir in os.scandir(root):
	if (str(subdir) in ["<DirEntry 'test'>", "<DirEntry 'dev'>", "<DirEntry 'train'>"]):
		subdirn = str(subdir).split(" ")[1].strip("'>")
		f = open(os.path.join("/home/pigi/repos/kaldi/egs/usc2/data/local/dict", "lm_"+subdirn+".text"), "w")
		g = open(os.path.join(subdir, "text"), "r")
		for line in g:
			f.write(line.split(" ")[0] + " " + "<s> " +' '.join(line.strip('\n').split(" ")[1:]) + " </s>\n")
