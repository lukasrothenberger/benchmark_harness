cd build
rm -r *
cmake -DCMAKE_CXX_COMPILER=discopop_hotspot_cxx -DCMAKE_CXX_FLAGS="-fopenmp" ..
make