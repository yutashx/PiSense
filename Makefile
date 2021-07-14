CONFIG_PATH=./reconstruction/reconstruction_system/config/realsense.json
ADDRESS=224.0.0.1
REFERED_DIRECTORY_PATH=./reconstruction/reconstruction_system/dataset
SAVE_DATASET_PATH=./reconstruction/reconstruction_system/save_dataset
CURRENT_PATH=`pwd`
TAG=pisense_reconstruction

build_reconstruction:
	docker build -f ./reconstruction/Dockerfile -t ${TAG} ./reconstruction/

run_reconstruction:
	docker run -it --rm --name ${USER}_pisense_reconstruction --gpus all -v ${CURRENT_PATH}:/root/ ${TAG} bash -c \
	'python3 ./reconstruction/reconstruction_system/run_system.py --make --register --refine --integrate ${CONFIG_PATH}; \
	python3 ./reconstruction/pipelines/color_map_optimization_for_reconstruction_system.py  --config ${CONFIG_PATH};'

run_client:
	python3 ./realsense_client/EtherSenseClient.py ${ADDRESS}

run_server:
	python3 ./realsense_server/EtherSenseServer.py

mv_dataset:
	date "+%s" -r ${REFERED_DIRECTORY_PATH}
	$(eval DIRECTORY_NAME := $(shell date "+%s" -r ${REFERED_DIRECTORY_PATH}))
	mv ${REFERED_DIRECTORY_PATH} ${SAVE_DATASET_PATH}/$(DIRECTORY_NAME)
	mkdir -p ${REFERED_DIRECTORY_PATH}/color ${REFERED_DIRECTORY_PATH}/depth

mkdir_dataset:
	mkdir -p ${REFERED_DIRECTORY_PATH}/color ${REFERED_DIRECTORY_PATH}/depth
	mkdir -p ${SAVE_DATASET_PATH}
