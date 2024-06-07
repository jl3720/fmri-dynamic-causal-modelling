#!/bin/bash

# load matlab module
module load julia

projparentdir="$(dirname "$(pwd)")"
subdatadir="${projparentdir}/SRPBS_OPEN/data"
#subdatadir="/cluster/scratch/spruthi/project4/oos/oos-schizos"
# create directory for log and error files
#mkdir -p ./logs
cond=""
echo "$subdatadir"

#declare -a sub_schiz=("sub-0089" "sub-0091" "sub-0094" "sub-0095" "sub-0097" "sub-0098" "sub-0099" "sub-0100" "sub-0102" "sub-0103" "sub-0167" "sub-0191" "sub-0230")
#declare -a sub_hc=("sub-0020" "sub-0021" "sub-0022" "sub-0023" "sub-0025" "sub-0026" "sub-0027" "sub-0030" "sub-0031" "sub-0032" "sub-0033" "sub-0034" "sub-0036" "sub-0037" "sub-0038" "sub-0039" "sub-0040")
# loop over subjects
for sub in ${subdatadir}/*
#for sub in "${sub_schiz[@]}"
do
    sub="$(basename "$sub")"
    echo "$sub"
    if [[ "$sub" == "Brainnetome2016" ]]; then continue; fi
    #if [[ "$sub" == "sub-0001" || "$sub" == "sub-1363" || "$sub" == "sub-1364" || "$sub" == "sub-1365" || "$sub" == "sub-1366" || "$sub" == "sub-1368" || "$sub" == "sub-1369" || "$sub" == "sub-1370" || "$sub" == "sub-1371" || "$sub" == "sub-1372" || "$sub" == "sub-1373" || "$sub" == "sub-1374" || "$sub" == "sub-1375" || "$sub" == "sub-1376" || "$sub" == "sub-1377" || "$sub" == "sub-1379" || "$sub" == "sub-1381" || "$sub" == "sub-1382" || "$sub" == "sub-1383" || "$sub" == "sub-1384" || "$sub" == "sub-1386" || "$sub" == "sub-1387" || "$sub" == "sub-1388" || "$sub" == "sub-1389" || "$sub" == "sub-1390" || "$sub" == "sub-1391" || "$sub" == "sub-1393" || "$sub" == "sub-1394" || "$sub" == "sub-1395" || "$sub" == "sub-1396" || "$sub" == "sub-1397" || "$sub" == "sub-1398" || "$sub" == "sub-1399" || "$sub" == "sub-1400" || "$sub" == "sub-1401" || "$sub" == "sub-1403" || "$sub" == "sub-1405" || "$sub" == "sub-1407" || "$sub" == "sub-1408" || "$sub" == "sub-1409" || "$sub" == "sub-1410" ]]; then #continue; fi
        #["sub-1390", "sub-1391", "sub-1393", "sub-1400", "sub-1401", "sub-1403", "sub-1405", "sub-1408"]
     #if [[ "$sub" == "sub-0001" || "$sub" == "sub-1363" || "$sub" == "sub-1365" || "$sub" == "sub-1366" || "$sub" == "sub-1368" || "$sub" == "sub-1370" || "$sub" == "sub-1371" || "$sub" == "sub-1372" || "$sub" == "sub-1373" || "$sub" == "sub-1374" || "$sub" == "sub-1375" || "$sub" == "sub-1377" ]]; then #continue; fi
     #if [[ "$sub" == "sub-1363" || "$sub" == "sub-1364" || "$sub" == "sub-1365" || "$sub" == "sub-1366" || "$sub" == "sub-1368" || "$sub" == "sub-1369" || "$sub" == "sub-1370" || "$sub" == "sub-1371" || "$sub" == "sub-1372" || "$sub" == "sub-1373" || "$sub" == "sub-1374" || "$sub" == "sub-1375" || "$sub" == "sub-1376" || "$sub" == "sub-1377" || "$sub" == "sub-1381" || "$sub" == "sub-1382" || "$sub" == "sub-1383" || "$sub" == "sub-1384" || "$sub" == "sub-1385" || "$sub" == "sub-1386" || "$sub" == "sub-1387" || "$sub" == "sub-1388" || "$sub" == "sub-1389" || "$sub" == "sub-1391" || "$sub" == "sub-1392" || "$sub" == "sub-1394" || "$sub" == "sub-1395" || "$sub" == "sub-1396" || "$sub" == "sub-1397" || "$sub" == "sub-1398" || "$sub" == "sub-1399" || "$sub" == "sub-1401" || "$sub" == "sub-1403" || "$sub" == "sub-1405" || "$sub" == "sub-1408" || "$sub" == "sub-1409" || "$sub" == "sub-1410" ]]; then #continue; fi
      #if [[ "$sub" == "sub-0089" || "$sub" == "sub-0091" || "$sub" == "sub-0094" || "$sub" == "sub-0095" || "$sub" == "sub-0097" || "$sub" == "sub-0098" || "$sub" == "sub-0099" || "$sub" == "sub-0100" || "$sub" == "sub-0102" || "$sub" == "sub-0103" || "$sub" == "sub-0167" || "$sub" == "sub-0191" || "$sub" == "sub-0230" ]]; then #continue; fi
      #if [[ "$sub" == "sub-0020" || "$sub" == "sub-0021" || "$sub" == "sub-0022" || "$sub" == "sub-0023" || "$sub" == "sub-0025" || "$sub" == "sub-0026" || "$sub" == "sub-0027" || "$sub" == "sub-0030" || "$sub" == "sub-0031" || "$sub" == "sub-0032" || "$sub" == "sub-0033" || "$sub" == "sub-0034" || "$sub" == "sub-0036" || "$sub" == "sub-0037" || "$sub" == "sub-0038" || "$sub" == "sub-0039" || "$sub" == "sub-0040" ]]; then #continue; fi
        echo "$sub"
        mkdir -p /cluster/scratch/spruthi/project4/julia/logs/"${sub}"
        jobID_tmp=$(sbatch \
                  --parsable \
                  -n 1 \
                  --mem-per-cpu=4096 \
                  -J "${sub}_inv" \
                  --time="03:00:00" \
                  -o "/cluster/scratch/spruthi/project4/julia/logs/${sub}/log_prepro.txt" \
                  --open-mode=truncate \
                  --wrap="julia --project=. dcm_to_srdcm.jl "$sub"")
        cond+=",${jobID_tmp}"
    #fi
    done

    # cond can be used if other jobs depend on the prepro step
cond=${cond:1} # remove the first comma
echo
echo "Finished submitting jobs."
