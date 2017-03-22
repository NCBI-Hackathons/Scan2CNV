# ArrayScan2CNV

## Synopsis
This program is designed to generate CNV calls from raw Microarray data using the command line.

![alt text](https://github.com/NCBI-Hackathons/Global_Screening_Arrays/blob/master/Workflow.PNG "Workflow")


## Installation

1. Clone the repository 
```
git clone --recursive https://github.com/NCBI-Hackathons/Global_Screening_Arrays.git

```

```
 Install code here.

```

## Usage
```
./ArrayScan2CNV.py -h
usage: ArrayScan2CNV.py [-h] -n NAME_OF_PROJECT -g PATH_TO_GTC_DIRECTORY -d
                        DIRECTORY_FOR_OUTPUT -b BPM_FILE [-p PFB_FILE] [-m]
                        [-q QUEUE]

optional arguments:
  -h, --help            show this help message and exit
  -p PFB_FILE, --pfb_file PFB_FILE
                        Path to PennCNV PFB file. REQUIRED for CNV calling.
                        Use -m option to create.
  -m, --make_pfb        use flag to indicate to generate PFB file
  -q QUEUE, --queue QUEUE
                        OPTIONAL. Queue on cgemsiii to use to submit jobs.
                        Defaults to all of the seq queues and all.q if not
                        supplied. default="all.q"

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

```
No language indicated, no syntax highlighting. Insert other code here.

```
## Dependencies

Package | Version
--- | ---
PennCNV |
gsrc |

  
