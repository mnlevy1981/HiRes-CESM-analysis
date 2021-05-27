#!/bin/bash

usage () {
  echo "$0 CASE DIR YEAR"
  echo "Submit job(s) to run all plot_suite_maps on casper node"
  echo ""
  echo "For each specified file, the full call is:"
  echo "./gen_plot_suite_maps.py --case CASE --in-dir DIR --year YEAR"
  echo ""
  echo "Output from the pbs job is written in the logs/ directory,"
  echo "which will be created if it does not exist."
}

#########################

# Function that creates a temporary script
# that is submitted via qsub
submit_pbs_script () {

  jobname=`echo "plot_suite_maps_${CASE:(-3)}_${YEAR}"`
  IN_DIR=${DIR}/${CASE}/output
  cat > ${jobname}.sub << EOF
#!/bin/bash
#
#PBS -N ${jobname}
#PBS -A P93300606
#PBS -l select=1:ncpus=1:mem=100G
#PBS -l walltime=3:00:00
#PBS -q casper
#PBS -j oe
#PBS -m ea

${set_env}
./gen_plot_suite_maps.py --case ${CASE} --in-dir ${IN_DIR}  --year ${YEAR}
EOF

  echo "Submitting ${jobname} for year ${YEAR} of ${CASE}"
  echo "(data in ${IN_DIR})"
  qsub ${jobname}.sub
  rm -f ${jobname}.sub
}

########################

# Function that creates a temporary script
# that is submitted via sbatch
submit_slurm_script () {

  jobname=`echo "plot_suite_maps_${CASE:(-3)}_${YEAR}"`
  IN_DIR=${DIR}/${CASE}/output
  cat > ${jobname}.sub << EOF
#!/bin/bash
#
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH -t 3:00:00
#SBATCH -p dav
#SBATCH -J ${jobname}
#SBATCH --account=P93300606
#SBATCH --mem 100G
#SBATCH -e logs/${jobname}.err.%J
#SBATCH -o logs/${jobname}.out.%J
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${USER}@ucar.edu
#SBATCH -m block

${set_env}
./gen_plot_suite_maps.py --case ${CASE} --in-dir ${IN_DIR}  --year ${YEAR}
EOF

  echo "Submitting ${jobname} for year ${YEAR} of ${CASE}"
  echo "(data in ${IN_DIR})"
  sbatch ${jobname}.sub
  rm -f ${jobname}.sub
}

#########################

if [ $# == 0 ]; then
  usage
  exit 1
fi

for args in "$@"
do
  if [ "$args" == "-h" ] || [ "$args" == "--help" ]; then
    usage
    exit 0
  fi
done

if [ $# != 3 ]; then
  usage
  exit 1
fi

CASE=$1
DIR=$2
YEAR=$3

# not sure why conda activate doesn't work but source activate does...
set_env="export PATH=/glade/work/${USER}/miniconda3/bin/:$PATH ; source activate hires-marbl || exit -1"

# make sure log directory exists
mkdir -p logs

submit_pbs_script $CASE $DIR $YEAR
