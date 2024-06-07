# TEST_DIR=/cluster/scratch/spruthi/project4/all_outputs_oos
# ADJ_MAT_PATH=/cluster/scratch/spruthi/project4/SRPBS_OPEN/data/Brainnetome2016/StructConn.mat
# for mat_path in checkpoints/*; do
#     echo "Evaluating $mat_path"
#     matlab -nodisplay -nosplash -singleCompThread -r "classification.evaluate('${mat_path}', '${TEST_DIR}', '${ADJ_MAT_PATH}'); exit"
# done

# SPARSE=(0 1)
# LATENT_DIM=(8 16)
# EXTRA=("standard" "reduced_connectivity" "reduced_noise")

# module load matlab/R2022b

# for sparse in "${SPARSE[@]}"; do
#     for latent_dim in "${LATENT_DIM[@]}"; do
#         for extra in "${EXTRA[@]}"; do
#             for p in "low" "high"; do
#                 echo $p
#                 matlab -r "classification.evaluate(${sparse}, ${latent_dim}, '${extra}', '${p}'); exit"
#             done
#         done
#     done
# done

module load matlab/R2022b

matlab -nodisplay -nojvm -singleCompThread -r "classification.sweep_evaluate;exit;"


# sbatch --parsable -n 1 -o ./logs/oos_testing/$j --mem-per-cpu=4096 --open-mode=truncate --wrap="matlab -nodisplay -nojvm -singleCompThread -r \"classification.evaluate(0, 8, 'reduced_connectivity')\""
# sbatch --parsable -n 1 -o ./logs/oos_testing/$j --mem-per-cpu=4096 --open-mode=truncate --wrap="matlab -nodisplay -nojvm -singleCompThread -r \"classification.evaluate(0, 8, 'standard')\""
# sbatch --parsable -n 1 -o ./logs/oos_testing/$j --mem-per-cpu=4096 --open-mode=truncate --wrap="matlab -nodisplay -nojvm -singleCompThread -r \"classification.evaluate(1, 8, 'standard', 'low')\""
# sbatch --parsable -n 1 -o ./logs/oos_testing/$j --mem-per-cpu=4096 --open-mode=truncate --wrap="matlab -nodisplay -nojvm -singleCompThread -r \"classification.evaluate(1, 8, 'standard', 'high')\""

# matlab -nodisplay -nojvm -singleCompThread -r "classification.evaluate(0, 8, 'reduced_connectivity');exit;"
# matlab -nodisplay -nojvm -singleCompThread -r "classification.evaluate(0, 8, 'standard');exit;"
# matlab -nodisplay -nojvm -singleCompThread -r "classification.evaluate(0, 16, 'standard');exit;"
# matlab -nodisplay -nojvm -singleCompThread -r "classification.evaluate(1, 8, 'standard', 'low');exit;"
# matlab -nodisplay -nojvm -singleCompThread -r "classification.evaluate(1, 16, 'standard', 'low');exit;"
# matlab -nodisplay -nojvm -singleCompThread -r "classification.evaluate(1, 8, 'standard', 'high')exit;"
# matlab -nodisplay -nojvm -singleCompThread -r "classification.evaluate(1, 16, 'standard', 'high')exit;"
