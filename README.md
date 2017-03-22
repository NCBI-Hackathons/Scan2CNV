## ![alt text](https://github.com/NCBI-Hackathons/Global_Screening_Arrays/blob/master/files/Logo.png "Logo")


## Synopsis

**This program is designed to generate CNV calls from raw SNP array data using the command line.**

## Workflow


![alt text](https://github.com/NCBI-Hackathons/Global_Screening_Arrays/blob/master/files/Workflow_updated.PNG "Workflow")


## Installation

Clone the repository 
```
git clone --recursive https://github.com/NCBI-Hackathons/Global_Screening_Arrays.git

```


## Usage
```
./Scan2CNV.py -h
usage: Scan2CNV.py [-h] -n NAME_OF_PROJECT -g PATH_TO_GTC_DIRECTORY -d
                   DIRECTORY_FOR_OUTPUT -b BPM_FILE [-p PFB_FILE] [-hmm HMM]
                   [-m] [-q QUEUE] [-u]

optional arguments:
  -h, --help            show this help message and exit
  -p PFB_FILE, --pfb_file PFB_FILE
                        Path to PennCNV PFB file. REQUIRED for CNV calling.
                        Use -m option to create.
  -hmm HMM, --hmm HMM   Path to PennCNV hmm file. Should be included with
                        PennCnv download.
  -m, --make_pfb        use flag to indicate to generate PFB file
  -q QUEUE, --queue QUEUE
                        OPTIONAL. Queue on cluster to use to submit jobs.
                        Defaults to all of the seq queues and all.q if not
                        supplied. default="all.q"
  -u, --unlock_snakemake
                        OPTIONAL. If pipeline was killed unexpectedly you may
                        need this flag to rerun

Required Arguments:
  -n NAME_OF_PROJECT, --name_of_project NAME_OF_PROJECT
                        Name to give to project for some output files
  -g PATH_TO_GTC_DIRECTORY, --path_to_gtc_directory PATH_TO_GTC_DIRECTORY
                        Full path to directory containing gtc files. It will
                        do a recursive search for gtc files.
  -d DIRECTORY_FOR_OUTPUT, --directory_for_output DIRECTORY_FOR_OUTPUT
                        REQUIRED. Full path to the base directory for the
                        ArrayScan2CNV pipeline output
  -b BPM_FILE, --bpm_file BPM_FILE
                        REQUIRED. Full path to Illumina .bpm manifest file.
```


## Dependencies

**R packages:** gsrc v1.1

**Python modules:** PennCNV v1.0.3

**Software:** python v2.7.5, R v3.3.1
  
