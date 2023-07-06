#!/bin/bash
# Submission script for Lemaitre3
#SBATCH --job-name=fmriprep_trial
#SBATCH --time=30:00:00 # hh:mm:ss
#
# SBATCH --nodes=2
#SBATCH --ntasks=1
# SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=20000 # megabytes
#SBATCH --partition=batch,debug # batch,debug
#
#SBATCH --mail-user=filippo.cerpelloni@uclouvain.be
#SBATCH --mail-type=ALL
#
#SBATCH --comment=cpp_cluster_hackaton

module --force purge

export OMP_NUM_THREADS=4
export MKL_NUM_THREADS=4


singularity run --cleanenv \
   -B /scratch/users/f/c/fcerpe:/scratch \
   -B /home/ucl/irsp/fcerpe/fmriprep_trial:/trial \
   ~/containers/images/bids/bids-fmriprep--21.0.1.sing \
   /trial/raw /trial/fmriprep \
   participant --participant-label 011 \
   --work-dir /scratch/work-fmriprep \
   --fs-license-file /trial/freesurfer_lic.txt \
   --output-spaces MNI152NLin2009cAsym T1w \
   --notrack --stop-on-first-crash