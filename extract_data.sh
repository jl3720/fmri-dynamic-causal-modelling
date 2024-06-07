#!/bin/bash

subc=($(seq 698 1 714)) # 75 left
#subc=($(seq 715 1 739))

for subci in "${subc[@]}"
do
    #if [[ "$subci" == "1374" ]]; then continue; fi
    echo "Starting 0$subci"
    cd /d/zurich_spring24/tn/
    # Uncomment following line to perform extraction from tar.gz folder as well
    tar -zxf SRPBS_OPEN.tar.gz SRPBS_OPEN/data/sub-0${subci}/
    cd project4
    echo "Finished extracting, modifying file structure"
    
    cp -a /d/zurich_spring24/tn/SRPBS_OPEN/data/sub-0${subci}/ /d/zurich_spring24/tn/project4/SRPBS_OPEN/data
    # mkdir -p /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-${subci}/func
    # mkdir -p /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-${subci}/anat
    mkdir -p /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-0${subci}/glm

    cd /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-0${subci}/rsfmri
    find . -type f -not -name "*.*" -exec mv "{}" "{}".nii \;

    cd ..
    # cp -a /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-${subci}/rsfmri/. /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-${subci}/func/
    # cp -a /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-${subci}/t1/. /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-${subci}/anat/
    mv /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-0${subci}/rsfmri/ /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-0${subci}/func/
    mv /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-0${subci}/t1/ /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-0${subci}/anat/

    # rm -r /d/zurich_spring24/tn/SRPBS_OPEN/data/sub-${subci}
    # Comment following lines to prevent deleting rsfmri and t1 subfolders (needed for cp -a)
    # rm -r /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-${subci}/rsfmri/
    # rm -r /d/zurich_spring24/tn/project4/SRPBS_OPEN/data/sub-${subci}/t1/

    echo "0$subci done"
done

echo "Data migrated to project repository"