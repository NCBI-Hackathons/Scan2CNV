#!/usr/bin/python

import glob
import sys
import os
import math
import shutil
import codecs
from snakemake.utils import R

configfile: "config.yaml"

idat_dir_file = config['idat_dir_file']
samps_per_group = config['samps_per_group']
fail_idat_intensity = config['fail_idat_intensity']

def getIdatList(idatDirFile, col):
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

redIdats = getIdatList(idat_dir_file, 'Red')
greenIdats = getIdatList(idat_dir_file, 'Grn')


idatBaseDict = {}
for i in redIdats:
    idatBase = os.path.basename(i).rstrip('_Red.idat')
    idatBaseDict[idatBase] = {}
    idatBaseDict[idatBase]['Red'] = i
for i in greenIdats:
    idatBase = os.path.basename(i).rstrip('_Grn.idat')
    idatBaseDict[idatBase]['Grn'] = i


def getIdat(wildcards):
    idatBase = wildcards.idatBase
    col = wildcards.col
    return idatBaseDict[idatBase][col]

num_of_groups = math.ceil(len(idatBaseDict.keys())/float(samps_per_group))
GROUPS = []
for i in range(1, num_of_groups):
    GROUPS.append(str(i))


include: 'modules/Snakefile_idat_intensity'


rule all:
    input:
        expand('all_sample_idat_intensity/idat_intensity_{col}.csv', col = ['Red', 'Grn']),
        expand('{col}_normalization_groups/{group}.txt', col = ['Red', 'Grn'], group = GROUPS)
