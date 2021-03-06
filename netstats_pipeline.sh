#!/bin/bash
R_BIN=/usr/bin/R

# command line options
while getopts :D:O:R:T:V: FLAG; do
  case $FLAG in
    D) # working directory
      REPODIR="$OPTARG"
      ;;
    O) # if you want to specifiy the results directory
      OUTDIR="$OPTARG"
      ;;
    R) # working directory
      R_BIN="$OPTARG"
      ;;
    T) # table file (a.k.a association file or GSE formatted file)
      TABLE="$OPTARG"
      ;;
    V) # if user submits a vcf
      VCF="$OPTARG"
      ;;
    \?) #exit on unrecognized
      echo -e
      exit 2
      ;;
  esac
done

shift $((OPTIND-1))

if [ -z $OUTDIR ] #then use default results directory in the repo
then
    OUTDIR=$REPODIR/results
done


if [ $VCF ] #then convert to TABLE
then
    python convert_vcf_to_table.py --vcf-in=$VCF --table-out=$VCF.table
done

# extract clusters from TABLE
# output should be N .clust files
# where N is the number of clusters we choose to subset
# where .clust is just a subset of the larger TABLE
python extract_clusters.py --in-table=$TABLE  #we still need to figure out how we're subsetting -- handle in the python script.

# call rFSA script on each cluster file
# Instead of a for loop use gnu parallel to spawn multiple jobs
for cluster in $REPODIR/tmp/*.clust; do
do
    Rscript $REPODIR/tools/rFSA.r --in=$cluster >>$OUTDIR/clust1.results # or whatever the output is.
done
