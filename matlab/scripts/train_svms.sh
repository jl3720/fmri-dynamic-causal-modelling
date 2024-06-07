DISEASES=("pain" "schizophrenia")
SPARSE=(0 1)
LATENT_DIM=(8 16)
EXTRA=("standard" "reduced_connectivity" "reduced_noise")

module load matlab/R2022b

# matlab -singleCompThread -r "classification.svm_train('schizophrenia', 1, 0, 0, 8); exit"

for disease in "${DISEASES[@]}"; do

    for sparse in "${SPARSE[@]}"; do
        for latent_dim in "${LATENT_DIM[@]}"; do
            for extra in "${EXTRA[@]}"; do
                for p in "low" "high"; do
                    echo $p
                    matlab -singleCompThread -r "classification.svm_train('${disease}', ${sparse}, ${latent_dim}, '${extra}', '${p}'); exit"
                done
            done
        done
    done

done