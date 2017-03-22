#!/usr/bin/env python2.7
'''
Gwas QC Pipeline written by Eric Karlins
karlinser@mail.nih.gov
This script is a wrapper for Snakemake.  The pipeline is run through rules in the Snakefile.
'''


import sys
import math
import os
import subprocess
import shutil
import argparse
import time
import glob

def makeQsub(qsubFile, qsubText):
    '''
    Make a qsub file in the qsubDir
    '''
    with open(qsubFile, 'w') as output:
        output.write('#!/bin/bash\n\n')
        output.write(qsubText)


def runQsub(qsubFile, proj, queue):
    '''
    (str, int) -> None
    '''
    qsubHeader = qsubFile[:-3]
    user = subprocess.check_output('whoami').rstrip('\n')
    qsubCall = ['qsub', '-M', user + '@mail.nih.gov', '-m', 'beas', '-q', queue, '-o', qsubHeader + '.stdout', '-e', qsubHeader + '.stderr', '-N', 'GwasQC.' + proj, '-S', '/bin/sh', qsubFile]
    retcode = subprocess.call(qsubCall)




def getNumSamps(sampleSheet):
    samps = 0
    with open(sampleSheet) as f:
        head = f.readline()
        while 'SentrixBarcode_A' not in head and head != '':
            head = f.readline()
        if 'SentrixBarcode_A' not in head:
            print('Sample sheet not formatted correctly')
            sys.exit(1)
        line = f.readline()
        while line != '':
            samps += 1
            line = f.readline()
    return samps



def makeConfig(outDir, plink_genotype_file, snp_cr_1, samp_cr_1, snp_cr_2, samp_cr_2, ld_prune_r2, maf_for_ibd, sample_sheet,
               subject_id_to_use, ibd_pi_hat_cutoff, dup_concordance_cutoff, illumina_manifest_file, expected_sex_col_name, numSamps, lims_output_dir, contam_threshold):
    '''
    (str, str, str) -> None
    '''
    paths = os.listdir(outDir)
    shutil.copy2(sample_sheet, outDir + '/IlluminaSampleSheet.csv')
    if 'config.yaml' in paths:
        start = getStartTime(outDir + '/config.yaml')
    else:
        start = time.ctime()
    with open(outDir + '/config.yaml', 'w') as output:
        if plink_genotype_file:
            output.write('plink_genotype_file: ' + plink_genotype_file + '\n')
        else:
            output.write('illumina_manifest_file: ' + illumina_manifest_file + '\n')
        output.write('snp_cr_1: ' + str(snp_cr_1) + '\n')
        output.write('samp_cr_1: ' + str(samp_cr_1) + '\n')
        output.write('snp_cr_2: ' + str(snp_cr_2) + '\n')
        output.write('samp_cr_2: ' + str(samp_cr_2) + '\n')
        output.write('ld_prune_r2: ' + str(ld_prune_r2) + '\n')
        output.write('maf_for_ibd: ' + str(maf_for_ibd) + '\n')
        output.write('sample_sheet: ' + sample_sheet + '\n')
        output.write('subject_id_to_use: ' + subject_id_to_use + '\n')
        output.write('ibd_pi_hat_cutoff: ' + str(ibd_pi_hat_cutoff) + '\n')
        output.write('dup_concordance_cutoff: ' + str(dup_concordance_cutoff) + '\n')
        output.write('expected_sex_col_name: ' + expected_sex_col_name + '\n')
        output.write('num_samples: ' + str(numSamps) + '\n')
        output.write('lims_output_dir: ' + lims_output_dir + '\n')
        output.write('contam_threshold: ' + str(contam_threshold) + '\n')
        output.write('start_time: ' + start + '\n')


def getStartTime(configFile):
    with open(configFile) as f:
        line = f.readline()
        while not line.startswith('start_time'):
            line = f.readline()
        return line.rstrip('\n').split(': ')[1]
    return time.ctime()


def get_args():
    '''
    return the arguments from parser
    '''
    parser = argparse.ArgumentParser()
    requiredArgs = parser.add_argument_group('Required Arguments')
    oneOfTheseRequired = parser.add_argument_group('Exactly one of these arguments is required')
    requiredWithDefaults = parser.add_argument_group('Required arguments with default settings')
    oneOfTheseRequired.add_argument('-p', '--path_to_plink_file', type=str, required=False, help='Full path to either PLINK ped or bed to use as input.\n\
                        need either this or gtc file project directory -g')
    requiredArgs.add_argument('-d', '--directory_for_output', type=str, required=True, help='REQUIRED. Full path to the base directory for the Gwas QC pipeline output')
    requiredWithDefaults.add_argument('--snp_cr_1', type=float, default= 0.80, help='REQUIRED. SNP call rate filter 1.  default= 0.80')
    requiredWithDefaults.add_argument('--samp_cr_1', type=float, default= 0.80, help='REQUIRED. Sample call rate filter 1.  default= 0.80')
    requiredWithDefaults.add_argument('--snp_cr_2', type=float, default= 0.95, help='REQUIRED. SNP call rate filter 2.  default= 0.95')
    requiredWithDefaults.add_argument('--samp_cr_2', type=float, default= 0.95, help='REQUIRED. Sample call rate filter 2.  default= 0.95')
    requiredWithDefaults.add_argument('--ld_prune_r2', type=float, default= 0.10, help='REQUIRED. r-squared cutoff for ld pruning of SNPs to use for IBD and concordance.  default= 0.10')
    requiredWithDefaults.add_argument('--maf_for_ibd', type=float, default= 0.20, help='REQUIRED. MAF cutoff of SNPs to use for IBD and concordance.  default= 0.20')
    requiredArgs.add_argument('-s', '--sample_sheet', type=str, required=True, help='Full path to illimina style sample sheet csv file.')
    requiredArgs.add_argument('--subject_id_to_use', type=str, required=True, help='Name of column in sample sheet that corresponds to subject ID to use.')##I should be able to add a default once this is available
    requiredWithDefaults.add_argument('--ibd_pi_hat_cutoff', type=float, default= 0.95, help='REQUIRED. PI_HAT cutoff to call samples replicates.  default= 0.95')##this can be deleted if just using SNP concordance
    requiredWithDefaults.add_argument('--dup_concordance_cutoff', type=float, default= 0.95, help='REQUIRED. SNP concordance cutoff to call samples replicates.  default= 0.95')
    requiredWithDefaults.add_argument('--lims_output_dir', type = str, default = '/DCEG/CGF/Laboratory/LIMS/drop-box-prod/gwas_primaryqc', help='Directory to copy QC file to upload to LIMS')
    requiredWithDefaults.add_argument('--contam_threshold', type=float, default= 0.10, help='REQUIRED. Cutoff to call a sample contaminated.  default= 0.10')
    parser.add_argument('-i', '--illumina_manifest_file',type=str, help='Full path to illimina .bpm manifest file. Required for gtc files.')
    requiredArgs.add_argument('--expected_sex_col_name', type=str, required=True, help='Name of column in sample sheet that corresponds to expected sex of sample.')##I should be able to add a default once this is available
    requiredWithDefaults.add_argument('-q', '--queue', type=str, default='all.q,seq-alignment.q,seq-calling.q,seq-calling2.q,seq-gvcf.q', help='OPTIONAL. Queue on cgemsiii to use to submit jobs.  Defaults to all of the seq queues and all.q if not supplied.  default="all.q,seq-alignment.q,seq-calling.q,seq-calling2.q,seq-gvcf.q"')
    parser.add_argument('-u', '--unlock_snakemake', action='store_true', help='OPTIONAL. If pipeline was killed unexpectedly you may need this flag to rerun')
    args = parser.parse_args()
    return args




def main():
    scriptDir = os.path.dirname(os.path.abspath(__file__))
    args = get_args()
    outDir = args.directory_for_output
    if outDir[0] != '/':
        print('-d argument must be full path to working directory.  Relative paths will not work.')
        sys.exit(1)
    paths = os.listdir(outDir)
    if 'logs' not in paths:
        os.mkdir(outDir + '/logs')
    if not args.path_to_plink_file:
        if not args.illumina_manifest_file:
            print('--illumina_manifest_file is required for gtc files.')
            sys.exit(1)
        shutil.copy2(scriptDir + '/start_with_gtc/Snakefile', outDir + '/Snakefile')
        plinkPedOrFam = None
    else:
        plinkFile = args.path_to_plink_file
        if plinkFile[-4:] == '.ped':
            shutil.copy2(scriptDir + '/start_with_plink_ped/Snakefile', outDir + '/Snakefile')
            plinkPedOrFam = plinkFile
        elif plinkFile[-4:] == '.bed':
            shutil.copy2(scriptDir + '/start_with_plink_bed/Snakefile', outDir + '/Snakefile')
            plinkPedOrFam = plinkFile[:-4] + '.fam'
        else:
            print('Unrecognized PLINK file format.')
            sys.exit(1)
    numSamps = getNumSamps(args.sample_sheet)
    makeConfig(outDir, args.path_to_plink_file, args.snp_cr_1, args.samp_cr_1, args.snp_cr_2, args.samp_cr_2, args.ld_prune_r2, args.maf_for_ibd, args.sample_sheet,
               args.subject_id_to_use, args.ibd_pi_hat_cutoff, args.dup_concordance_cutoff, args.illumina_manifest_file, args.expected_sex_col_name, numSamps, args.lims_output_dir, args.contam_threshold)
    qsubTxt = 'cd ' + outDir + '\n'
    qsubTxt += 'module load sge\n'
    qsubTxt += 'module load python3/3.5.1\n'
    qsubTxt += 'module load R/3.3.0\n'
    if 'rule.dag.svg' not in paths:
       # qsubTxt += 'snakemake --dag | dot -Tsvg > dag.svg\n'
        qsubTxt += 'snakemake --rulegraph | dot -Tsvg > rule.dag.svg\n'
    if args.unlock_snakemake:
        qsubTxt += 'snakemake --unlock\n'
    qsubTxt += 'snakemake --rerun-incomplete --cluster "qsub -q ' + args.queue + ' -pe by_node {threads} '
    qsubTxt += '-o ' + outDir + '/logs/ -e ' + outDir + '/logs/" --jobs 4000 --latency-wait 300\n'
    makeQsub(outDir + '/GwasQcPipeline.sh', qsubTxt)
    runQsub(outDir + '/GwasQcPipeline.sh', os.path.basename(outDir), 'seq-alignment.q,seq-calling.q,seq-calling2.q,seq-gvcf.q')
    print('GWAS QC Pipeline submitted.  You should receive an email when the pipeline starts and when it completes.')
    print('Your input project has ' + str(numSamps) + ' samples.')


if __name__ == "__main__":
    main()
