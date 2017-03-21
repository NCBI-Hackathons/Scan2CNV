import sys
import os

scriptDir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(scriptDir + '/../BeadArrayFiles/module'))
from IlluminaBeadArrayFiles import GenotypeCalls, BeadPoolManifest, code2genotype






def getCR(GenoScores, genoThresh = 0.25):
    '''
    GenoScores = gtc.get_genotype_scores()
    '''
    c = 0
    for g in GenoScores:
        if g < genoThresh:
            c += 1
    return float(len(GenoScores) - c)/len(GenoScores)


##It looks like the no call cutoff defaults to genotype_score of .15.  I'll change it to 0.25 using the code above in getCR
def outputPennCnv(gtc_file, manifest_file, outFile):
    manifest = BeadPoolManifest(manifest_file)
    gtc = GenotypeCalls(gtc_file)
    genotypes = gtc.get_genotypes()
    LRR = gtc.get_logr_ratios()
    BAF = gtc.get_ballele_freqs()
    with open(outFile, 'w') as output:
        output.write('Name\tChr\tPos\tGtype\tLRR\tBAF\n')
        for (name, chrom, map_info, genotype, lrr, baf) in zip(manifest.names, manifest.chroms, manifest.map_infos, genotypes, LRR, BAF):
            if genotype == 1:
                geno = 'AA'
            elif genotype == 2:
                geno = 'AB'
            elif genotype == 3:
                geno = 'BB'
            else:
                geno = '--'
            output.write('\t'.join([name, chrom, str(map_info), geno, str(lrr), str(baf)]) + '\n')


def main():
    args = sys.argv[1:]
    if len(args) != 3:
        print ("error: usage: python gtc2plink.py /path/to/file.gtc /path/to/manifest.bpm /path/to/out/outFile.txt")
        sys.exit(1)
    else:
        outputPennCnv(args[0], args[1], args[2])


if __name__ == "__main__":
    main()

