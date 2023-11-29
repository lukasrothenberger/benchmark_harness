 BENCHMARK_DIR=$(pwd)
 CLEAN_CODE_DIR=$BENCHMARK_DIR/clean_code
 WORKING_COPY_DIR=$BENCHMARK_DIR/working_copy
 CLEAN_BUFFER_DIR=$BENCHMARK_DIR/clean_buffer
 BUFFER_DIR=$BENCHMARK_DIR/buffer
 PATCH_GENERATOR_FOLDER=$BUFFER_DIR/patch_generator
 LOGS_DIR=$BENCHMARK_DIR/logs


 echo "BENCHMARK: $BENCHMARK_DIR"
 echo "  CLEAN_CODE: $CLEAN_CODE_DIR"
 echo "  WORKING_COPY: $WORKING_COPY_DIR"
 echo "  CLEAN_BUFFER: $CLEAN_BUFFER_DIR"
 echo "  BUFFER: $BUFFER_DIR"

exit 0

# cleanup environment
echo "cleanup..."
rm -rf $WORKING_COPY_DIR
rm -rf $BUFFER_DIR
echo "  done."

# create working copy
cp -r $CLEAN_CODE_DIR $WORKING_COPY_DIR

# create discopop suggestions and save suggestions to buffer
if false; then  # reset discopop suggestions
    rm -rf $CLEAN_BUFFER_DIR
    cd $WORKING_COPY_DIR
    mkdir build
    cd build
    discopop_cmake -DWITH_OPENMP=Off -DWITH_MPI=Off ..
    make
    ./lulesh2.0 -s 5
    cd .discopop
    discopop_explorer
    discopop_patch_generator
    discopop_optimizer
    cd ..
    cp -r .discopop $CLEAN_BUFFER_DIR
    cd $BENCHMARK_DIR
fi

# prepare logging environment
rm -rf $LOGS_DIR
mkdir -p $LOGS_DIR
rm -f $BENCHMARK_DIR/measurements.csv
echo "suggestion_id;time;exit_code;" >> $BENCHMARK_DIR/measurements.csv

# get baseline measurement
    # prepare a clean environment
    mkdir -p $LOGS_DIR/baseline
    rm -rf $WORKING_COPY_DIR
    cp -r $CLEAN_CODE_DIR $WORKING_COPY_DIR
    cd $WORKING_COPY_DIR
    # build
    mkdir build
    cd build
    cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DWITH_OPENMP=Off -DWITH_MPI=Off ..
    make -j15 1>> $LOGS_DIR/baseline/log.txt 2>> $LOGS_DIR/baseline/log.txt
    # execute
    COMMAND="timeout 60 ./lulesh2.0 -s 5"
    /usr/bin/time --format="baseline;%e;%x;" --append --output=$BENCHMARK_DIR/measurements.csv $COMMAND 1>> $LOGS_DIR/baseline/stdout.txt 2>> $LOGS_DIR/baseline/stderr.txt
    # clean environment
    cd $BENCHMARK_DIR
    rm -rf $WORKING_COPY_DIR

# get best option measurement
    # prepare a clean environment
    mkdir -p $LOGS_DIR/optimum
    rm -rf $WORKING_COPY_DIR
    rm -rf $BUFFER_DIR
    cp -r $CLEAN_CODE_DIR $WORKING_COPY_DIR
    cp -r $CLEAN_BUFFER_DIR $BUFFER_DIR

    # apply modifications
    cd $BUFFER_DIR
    discopop_patch_applicator -v -a $(cat optimizer/evolutionary_optimum.txt)

    cd $WORKING_COPY_DIR
    # build
    cd $WORKING_COPY_DIR
    mkdir build
    cd build 
    cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DWITH_OPENMP=Off -DWITH_MPI=Off -DCMAKE_C_FLAGS="-fopenmp -fopenmp-targets=nvptx64" -DCMAKE_CXX_FLAGS="-fopenmp -fopenmp-targets=nvptx64"
    make -j 15 1>> $LOGS_DIR/optimum/log.txt 2>> $LOGS_DIR/optimum/log.txt
    # execute
    /usr/bin/time --format="optimum;%e;%x;" --append --output=$BENCHMARK_DIR/measurements.csv $COMMAND 1>> $LOGS_DIR/optimum/stdout.txt 2>>$LOGS_DIR/optimum/stderr.txt

    # clean environment
    cd $BENCHMARK_DIR
    rm -rf $WORKING_COPY_DIR

# get measurements for all identified suggestions
    # check prerequisites
    # check if .discopop/patch_generator folder exists
    if [ -d $CLEAN_BUFFER_DIR/patch_generator ]; then
        echo "Directory exists."
    else
        echo "Directory not found: $CLEAN_BUFFER_DIR/patch_generator"
        exit 1
    fi

    # iterate over suggestions
    cd $CLEAN_BUFFER_DIR/patch_generator
    for d in * ; do
        echo "CURRENT SUGGESTION: ${d}"
        # prepare output
        mkdir -p $LOGS_DIR/$d

        # prepare a clean environment
        rm -rf $WORKING_COPY_DIR
        rm -rf $BUFFER_DIR
        cp -r $CLEAN_CODE_DIR $WORKING_COPY_DIR
        cp -r $CLEAN_BUFFER_DIR $BUFFER_DIR


        # apply suggestion
        cd $BUFFER_DIR
        discopop_patch_applicator -a ${d} -v >> $LOGS_DIR/$d/log.txt

        # compile program
        cd $WORKING_COPY_DIR
        mkdir build
        cd build 
        cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DWITH_OPENMP=Off -DWITH_MPI=Off -DCMAKE_C_FLAGS="-fopenmp -fopenmp-targets=nvptx64" -DCMAKE_CXX_FLAGS="-fopenmp -fopenmp-targets=nvptx64"
        make -j 15 1>> $LOGS_DIR/$d/log.txt 2>> $LOGS_DIR/$d/log.txt

        # execute program
        /usr/bin/time --format="${d};%e;%x;" --append --output=$BENCHMARK_DIR/measurements.csv $COMMAND 1>> $LOGS_DIR/$d/stdout.txt 2>>$LOGS_DIR/$d/stderr.txt

        # rollback suggestions
        cd $BUFFER_DIR
        discopop_patch_applicator -C -v >> $LOGS_DIR/$d/log.txt

        # clean environment
        cd $BENCHMARK_DIR
        rm -rf $WORKING_COPY_DIR
        rm -rf $BUFFER_DIR
    done

exit 0