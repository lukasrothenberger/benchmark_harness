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

# cleanup environment
echo "cleanup..."
rm -rf $WORKING_COPY_DIR
rm -rf $BUFFER_DIR
echo "  done."

# create working copy
cp -r $CLEAN_CODE_DIR $WORKING_COPY_DIR

# create discopop suggestions and save suggestions to buffer
cd $WORKING_COPY_DIR
make -f Makefile.discopop all_cpu
cp -r .discopop $CLEAN_BUFFER_DIR
cd $BENCHMARK_DIR

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
    cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .
    make -j15 1>> $LOGS_DIR/baseline/log.txt 2>> $LOGS_DIR/baseline/log.txt
    # execute
    COMMAND="timeout 60 ./prog"
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
    echo "PWD: $(pwd)"
    echo "LS: $(ls -a)"
    discopop_patch_applicator -v -a $(cat optimizer/evolutionary_optimum.txt)

    cd $WORKING_COPY_DIR
    # build
    cmake . -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_FLAGS="-fopenmp" -DCMAKE_CXX_FLAGS="-fopenmp"
    make -j15 1>> $LOGS_DIR/optimum/log.txt 2>> $LOGS_DIR/optimum/log.txt
    # execute
    COMMAND="timeout 60 ./prog"
    /usr/bin/time --format="optimum;%e;%x;" --append --output=$BENCHMARK_DIR/measurements.csv $COMMAND 1>> $LOGS_DIR/optimum/stdout.txt 2>> $LOGS_DIR/optimum/stderr.txt
    # clean environment
    cd $BENCHMARK_DIR
    rm -rf $WORKING_COPY_DIR

# get measurements for all identified suggestions
    # check prerequisites
    # check if .discopop/patch_generator folder exists
    if [ -d $CLEAN_BUFFER_DIR/patch_generator ]; then
        echo "Directory exists."
    else
        echo "Directory not found: ${CLEAN_BUFFER_DIR}/patch_generator"
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
        cmake . -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_FLAGS="-fopenmp" -DCMAKE_CXX_FLAGS="-fopenmp"
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


















































### SETTINGS ###
DISCOPOP_PATH=/home/lukasrothenberger/git/discopop
DISCOPOP_BUILD=$DISCOPOP_PATH/build
PROJECT_PATH=/home/lukasrothenberger/code/benchmarks/daxpy
PROJECT_BUILD_PATH=$PROJECT_PATH
################

### DEPENDENT SETTINGS
PROJECT_DP_FOLDER=$PROJECT_BUILD_PATH/.discopop
PATCH_GENERATOR_FOLDER=$PROJECT_DP_FOLDER/patch_generator
################





# Check prerequisites
# check if .discopop folder exists
if [ -d $PROJECT_DP_FOLDER ]; then
    echo "Directory exists."
else
    echo "Directory not found: ${PROJECT_DP_FOLDER}"
    exit 1
fi
# check if .discopop/patch_generator folder exists
if [ -d $PATCH_GENERATOR_FOLDER ]; then
    echo "Directory exists."
else
    echo "Directory not found: ${PATCH_GENERATOR_FOLDER}"
    exit 1
fi

# create code copy 
mkdir -p $BENCHMARK_DIR/code_copy
cp -r $PROJECT_PATH/* $BENCHMARK_DIR/code_copy

# for easier browsing of the results, copy the identified patches
mkdir -p $BENCHMARK_DIR/patch_generator_output
cp -r $PATCH_GENERATOR_FOLDER/* $BENCHMARK_DIR/patch_generator_output


# clean environment
rm -rf logs
mkdir logs
rm -f measurements.csv
echo "suggestion_id;time;exit_code;" >> measurements.csv

# get baseline measurement
# prepare output
    mkdir $BENCHMARK_DIR/logs/baseline
    # clean environment
    cd $PROJECT_BUILD_PATH
    make -f Makefile.discopop clean
    # compile program
    cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .
    make -j15 1>> $BENCHMARK_DIR/logs/baseline/log.txt 2>> $BENCHMARK_DIR/logs/baseline/log.txt
    # execute program
    COMMAND="timeout 120 ./prog"
    /usr/bin/time --format="baseline;%e;%x;" --append --output=$BENCHMARK_DIR/measurements.csv $COMMAND 1>> $BENCHMARK_DIR/logs/baseline/stdout.txt 2>> $BENCHMARK_DIR/logs/baseline/stderr.txt

    # restore original state
    rm -r $PROJECT_PATH/*
    cp -r $BENCHMARK_DIR/code_copy/* $PROJECT_PATH



# iterate over all identified suggestions
cd $PATCH_GENERATOR_FOLDER
for d in * ; do
    echo "CURRENT SUGGESTION: ${d}"
    # prepare output
    mkdir $BENCHMARK_DIR/logs/$d

    # clean environment
    cd $PROJECT_BUILD_PATH
    make -f Makefile.discopop clean

    # apply suggestion
    cd $PROJECT_DP_FOLDER
    discopop_patch_applicator -a ${d} -v >> $BENCHMARK_DIR/logs/$d/log.txt

    # compile program
    cd $PROJECT_BUILD_PATH
    cmake . -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_FLAGS="-fopenmp -fopenmp-targets=nvptx64" -DCMAKE_CXX_FLAGS="-fopenmp -fopenmp-targets=nvptx64"
    make -j 15 1>> $BENCHMARK_DIR/logs/$d/log.txt 2>> $BENCHMARK_DIR/logs/$d/log.txt

    # execute program
    /usr/bin/time --format="${d};%e;%x;" --append --output=$BENCHMARK_DIR/measurements.csv $COMMAND 1>> $BENCHMARK_DIR/logs/$d/stdout.txt 2>>$BENCHMARK_DIR/logs/$d/stderr.txt

    # rollback suggestions
    cd $PROJECT_DP_FOLDER
    discopop_patch_applicator -C -v >> $BENCHMARK_DIR/logs/$d/log.txt

    # restore original state
    rm -r $PROJECT_PATH/*
    cp -r $BENCHMARK_DIR/code_copy/* $PROJECT_PATH
done

# delete code copy 
#rm -r $BENCHMARK_DIR/code_copy

