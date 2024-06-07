#!/bin/bash

# Does not scale well nicely on the cluster - matlabbatch requires a grpahical window in one script

# load matlab module
module load matlab/R2022b

projparentdir="$(dirname "$(pwd)")"
subdatadir="${projparentdir}/SRPBS_OPEN/data"
# create directory for log and error files
#mkdir -p ./logs
cond=""
echo "$subdatadir"

# loop over subjects
for sub in ${subdatadir}/*/
do
    # sub=${sub%*/}
    # sub=${sub##*/}
    sub=$(basename "$sub")
    if [[ "$sub" == "Brainnetome2016" ]]; then continue; fi
    mkdir -p ./logs/"${sub}"
    
	jobID_tmp=$(sbatch \
	    --parsable \
	    -n 1 \
	    --mem-per-cpu=4096 \
	    -J "prep_${sub}" \
	    -o "./logs/${sub}/log_prepro.txt" \
	    --open-mode=truncate \
	    --wrap="matlab -nodisplay -nojvm -singleCompThread -r \"sprbs_preprocess_pipeline('$sub',1,1)\"")
	cond+=",${jobID_tmp}"
    
done

# cond can be used if other jobs depend on the prepro step
cond=${cond:1} # remove the first comma

echo
echo "Finished submitting jobs."
