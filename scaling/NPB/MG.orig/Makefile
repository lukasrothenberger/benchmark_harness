BENCHMARK_NAME=$$(basename ${CURDIR})
BENCHMARK_NAME_LOWERCASE=$$(echo ${BENCHMARK_NAME} | tr '[:upper:]' '[:lower:]')
BASEDIR=${CURDIR}
CC=clang
CFLAGS=-fopenmp
CFLAGS_SEQUENTIAL=

clean:
	cd ${BENCHMARK_NAME}_orig_with_metadata_* && rm -fr bin/* || true
	cd ${BENCHMARK_NAME}_orig_without_metadata_* && rm -rf bin/* || true
	cd sequential && rm -rf bin/* || true
	rm -f measurements_sequential.csv
	rm -f measurements_vanilla.csv
	rm -f measurements_extended.csv
	rm -f measurements_inputs.csv

veryclean: clean
	rm -rf ${BENCHMARK_NAME}_orig_with_metadata_* || true
	rm -rf ${BENCHMARK_NAME}_orig_without_metadata_* || true
	rm -rf sequential || true
	rm -f performance.png

get_code:
	cp -r ../../../auto_tuner_benchmarks/NPB/${BENCHMARK_NAME}/${BENCHMARK_NAME}_orig_with_metadata_* . || true
	cp -r ../../../auto_tuner_benchmarks/NPB/${BENCHMARK_NAME}/${BENCHMARK_NAME}_orig_without_metadata_* . || true
	cp -r ../../../clean_code/NPB-SER/ sequential || true

prepare:
	echo "Input;" >> measurements_inputs.csv
	echo "Sequential;" >> measurements_sequential.csv
	echo "Vanilla;" >> measurements_vanilla.csv
	echo "Extended;" >> measurements_extended.csv

compile: clean prepare
	echo "LOWER: ${BENCHMARK_NAME_LOWERCASE}"
	echo "BASEDIR: ${BASEDIR}"
	for INPUT in S A ; do \
		echo "INPUT: $${INPUT}" ; \
		echo "PWD1: $$(pwd)" ; \
		cd ${BASEDIR} && cd ${BENCHMARK_NAME}_orig_with_metadata_* && CC="clang++ -fopenmp" make ${BENCHMARK_NAME_LOWERCASE} CLASS=$${INPUT} && cd .. || true ; \
		echo "PWD2: $$(pwd)" ; \
		cd ${BASEDIR} && cd ${BENCHMARK_NAME}_orig_without_metadata_* && CC="clang++ -fopenmp" make ${BENCHMARK_NAME_LOWERCASE} CLASS=$${INPUT} && cd .. || true ; \
		echo "PWD3: $$(pwd)" ; \
		cd ${BASEDIR} && cd sequential && CC="clang++" make ${BENCHMARK_NAME_LOWERCASE} CLASS=$${INPUT} && cd .. ; \
	done

execute:
	for input in S A ; do \
		echo "$$input" >> measurements_inputs.csv ; \
		/usr/bin/time --append -o measurements_sequential.csv --format=";%e;" sequential/bin/${BENCHMARK_NAME_LOWERCASE}.$$input || true ; \
		/usr/bin/time --append -o measurements_vanilla.csv --format="%e;" ${BENCHMARK_NAME}_orig_without_metadata_*/bin/${BENCHMARK_NAME_LOWERCASE}.$$input || true  ; \
		/usr/bin/time --append -o measurements_extended.csv --format="%e;" ${BENCHMARK_NAME}_orig_with_metadata_*/bin/${BENCHMARK_NAME_LOWERCASE}.$$input || true ; \
    done

# 	correct formatting for google slides
#	sed -i -e 's/\./,/g' measurements_sequential.csv
#	sed -i -e 's/\./,/g' measurements_vanilla.csv
#	sed -i -e 's/\./,/g' measurements_extended.csv

plot:
	python ../../plot.py $$(pwd)
