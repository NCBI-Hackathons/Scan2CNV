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
illumina_csv = config['illumina_csv']


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


def getIdatFromGroup(wildcards):
    col = wildcards.col
    group = wildcards.group
    idats = []
    with open(col + '_normalization_groups/' + group + '.txt') as f:
        for line in f:
            idatBase = line.strip()
            i = idatBaseDict[idatBase][col]
            idats.append(i)
    return idats


num_of_groups = math.ceil(len(idatBaseDict.keys())/float(samps_per_group))
GROUPS = []
for i in range(1, num_of_groups):
    GROUPS.append(str(i))

beadSetDict = {}
probeToPosDict = {}

with open(illumina_csv) as f:
    head = f.readline()
    while 'AddressA_ID' not in head:
        head = f.readline()
        if head == '':
            print('malformatted Illumina csv file')
            sys.exit(1)
    head_list = head.rstrip().split(',')
    nameCol = None
    chromCol = None
    snpCol = None
    posCol = None
    addressCol = None
    beadSetCol = None
    for i in range(len(head_list)):
        if head_list[i] == 'Name':
            nameCol = i
        elif head_list[i] == 'SNP':
            snpCol = i
        elif head_list[i] == 'Chr':
            chromCol = i
        elif head_list[i] == 'MapInfo':
            posCol = i
        elif head_list[i] == 'AddressA_ID':
            addressCol = i
        elif head_list[i] == 'BeadSetID':
            beadSetCol = i
    if nameCol == None or chromCol == None or snpCol == None or posCol == None or addressCol == None or beadSetCol == None:
        print('malformatted Illumina csv file')
        sys.exit(1)
    line = f.readline()
    while line != '' and '[Controls]' not in line:
        line_list = line.rstrip().split(',')
        name = line_list[nameCol].strip('"')
        snp = line_list[snpCol].strip('"')
        chrom = line_list[chromCol].strip('"')
        pos = line_list[posCol].strip('"')
        address = str(int(line_list[addressCol].strip('"')))
        beadSet = line_list[beadSetCol].strip('"')
        snp_list = snp.split('/')
        a = snp_list[0].strip('[')
        b = snp_list[1].strip(']')
        probeToPosDict[address] = (chrom, pos, a , b)
        if not beadSetDict.get(beadSet):
            beadSetDict[beadSet] = [address]
        else:
            beadSetDict[beadSet].append(address)
        line = f.readline()

include: 'modules/Snakefile_idat_intensity'
include: 'modules/Snakefile_normalization'

rule all:
    input:
        expand('all_sample_idat_intensity/idat_intensity_{col}.csv', col = ['Red', 'Grn']),
        expand('{col}_normalization_groups/{group}.txt', col = ['Red', 'Grn'], group = GROUPS),
        expand('bead_set_probes/BeadSetID.{bead_set}.txt', bead_set = beadSetDict.keys()),
        expand('{col}_normalized_intensities/BeadSetID.{bead_set}.Group.{group}.csv', col = ['Red', 'Grn'], bead_set = beadSetDict.keys(), group = GROUPS)
