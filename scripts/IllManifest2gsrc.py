import sys



def outputGsrc(manifest, outDict, outChrPos):
    '''
    Read in an Illumina csv manifest and output two csv files for the R package gsrc:
    a dictionary file with IdatIds and SNP names, and
    a file with SNP names and chr and pos
    '''
    with open(manifest) as f, open(outDict, 'w') as output1, open(outChrPos, 'w') as output2:
        output1.write('idatID,name\n')
        output2.write('name,chromosome,position\n')
        head = f.readline()
        while 'AddressA_ID' not in head and head != '':
            head = f.readline()
        if head == '':
            print('ERROR: unrecognized manifest format')
            sys.exit(1)
        head_list = head.rstrip('\n').split(',')
        idatIdCol = None
        snpCol = None
        chromCol = None
        posCol = None
        for i in range(len(head_list)):
            a = head_list[i].strip('"')
            if a == 'AddressA_ID':
                idatIdCol = i
            elif a == 'Name':
                snpCol = i
            elif a == 'Chr':
                chromCol = i
            elif a == 'MapInfo':
                posCol = i
        if idatIdCol == None or snpCol == None or chromCol == None or posCol == None:
            print('ERROR:  all required columns not in manifest.')
            sys.exit(1)
        line = f.readline()
        while line != '' and '[Controls]' not in line:
            line_list = line.rstrip('\n').split(',')
            idatId = line_list[idatIdCol].strip('"')
            snp = line_list[snpCol].strip('"')
            chrom = line_list[chromCol].strip('"')
            pos = line_list[posCol].strip('"')
            output1.write(idatId + ',' + snp + '\n')
            output2.write(','.join([snp, chrom, pos]) + '\n')
            line = f.readline()




def main():
    args = sys.argv[1:]
    if len(args) != 3:
        print ("error: usage: python IllManifest2gsrc.py /path/to/IlluminaManifest.csv /path/to/out_dictionary.csv /path/to/out/out_chrPos.csv")
        sys.exit(1)
    else:
        outputGsrc(args[0], args[1], args[2])


if __name__ == "__main__":
    main()
