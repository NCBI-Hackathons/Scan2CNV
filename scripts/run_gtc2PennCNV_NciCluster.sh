#!/bin/bash


module load python/2.7.5
cd /out/dir
python /DCEG/repo/scripts/gtc2plink.py /path/to/file.gtc /path/to/manifest.bpm out/outFile.txt
