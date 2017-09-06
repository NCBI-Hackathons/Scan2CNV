#!/usr/bin/python

import glob
import sys
import os
import shutil
import codecs
from snakemake.utils import R

configfile: "config.yaml"

idat_dir_file = config['idat_dir_file']



def getIdats(idatDirFile, col):
    '''
    return a list of all idats of that channel (color)
    '''
    idats = []
    with open(idatDirFile) as f:
        for line in f:
            if line.strip():
                idatDir = line.rstrip()
                for filename in glob.iglob(idatDir + '/**/*_' + col + '.idat', recursive=True):
                    idats.append(filename)
    return idats

redIdats = getIdats(idat_dir_file, 'Red')
greenIdats = getIdats(idat_dir_file, 'Grn')

include: 'modules/Snakefile_idat_intensity'


rule all:
    input:
        'all_sample_idat_intensity/idat_intensity.csv'


