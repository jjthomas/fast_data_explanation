#!/bin/bash
CC=g++
python3 -c 'import pyarrow; pyarrow.create_library_symlinks()'
PA_INC=$(python3 -c 'import pyarrow; print(pyarrow.get_include())')
PA_LIB=$(python3 -c 'import pyarrow; print(pyarrow.get_library_dirs()[0])')
PA_LIB="-L$PA_LIB"
PY_INC=$(python3 -c "from sysconfig import get_paths as gp; print(gp()['include'])")
if [[ "$OSTYPE" == "darwin"* ]]; then
  PY_LIB_NAME=$(basename $PY_INC)
  PY_LIB_NAME="-l$PY_LIB_NAME"
  PY_LIB=$(dirname $(python3 -c "from sysconfig import get_paths as gp; print(gp()['stdlib'])"))
  PY_LIB="-L$PY_LIB"
  CC=/usr/local/opt/llvm/bin/clang++
  OMP_LIB="-L/usr/local/opt/llvm/lib"
fi
if [[ "$SIM" == "1" || "$GPU" == "1" || "$FPGA" == 1 ]]; then
  DEFINES="-DACC"
fi
if [[ "$SIM" == "1" ]]; then
  $CC -std=c++11 -fopenmp -c sim.cpp -o sim.o
  EXTRA_FILES="sim.o"
fi
$CC -std=c++11 -fopenmp $DEFINES -I$PA_INC -I$PY_INC -fPIC cube.cpp $EXTRA_FILES -shared -o libcube $PA_LIB $PY_LIB $OMP_LIB -larrow -larrow_python $PY_LIB_NAME

