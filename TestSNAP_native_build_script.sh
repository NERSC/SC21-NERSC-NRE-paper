#!/bin/bash -l
module purge
module load dgx
module load nvhpc/21.7
module load cuda/11.2.1
module list
set -x
set -e

export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

cpus=${SLURM_CPUS_PER_TASK:-32}
RUN="srun -n 1 -c ${cpus} --cpu-bind=cores"

CPPFLAGS="-DREFDATA_TWOJ=14 -DOPENMP_TARGET"
CXXFLAGS="-fast -std=c++11 -mp=gpu -gpu=cc80"

# NOTE - The clone is not needed since the repo is added as a submodule.
#if [ ! -d TestSNAP-native ]; then
#    git clone --single-branch --branch OpenMP4.5 git@github.com:FitSNAP/TestSNAP.git TestSNAP-native
#fi
cd TestSNAP-native/src

nvc++ ${CPPFLAGS} ${CXXFLAGS} sna.cpp test_snap.cpp memory.cpp -o test_snap.exe

for i in {1..10}; do ${RUN} ./test_snap.exe -ns 100; done
rm -f *.o *.exe