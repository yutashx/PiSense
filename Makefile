CONFIG_PATH=./reconstruction/reconstruction_system/config/realsense.json
ADDRESS=224.0.0.1
REFERED_DIRECTORY_PATH=./reconstruction/reconstruction_system/dataset
SAVE_DATASET_PATH=./reconstruction/reconstruction_system/save_dataset
CURRENT_PATH=`pwd`
TAG_RECONSTRUCTION=pisense_reconstruction
TAG_SERVER=pisense_server
TAG_CLIENT=pisense_client
PORT=1024
WINDOW=False

build_reconstruction:
	docker build -f ./reconstruction/Dockerfile -t ${TAG_RECONSTRUCTION} ./reconstruction/

build_server:
	docker build -f ./realsense_server/Dockerfile -t ${TAG_SERVER} ./realsense_server/

build_client:
	docker build -f ./realsense_client/Dockerfile -t ${TAG_CLIENT} ./realsense_client/

run_reconstruction:
	docker run -it --rm --name ${USER}_pisense_reconstruction --gpus all -v ${CURRENT_PATH}:/root/ ${TAG_RECONSTRUCTION} bash -c \
	'python3 ./reconstruction/reconstruction_system/run_system.py --make --register --refine --integrate ${CONFIG_PATH}; \
	python3 ./reconstruction/pipelines/color_map_optimization_for_reconstruction_system.py  --config ${CONFIG_PATH};'

run_server:
	#$(eval DEVICELIST := $(shell v4l2-ctl --list-devices | awk 'BEGIN {FS="\n"; RS=""}  /RealSense/{print $0}' | tail +2 | sed 's/\t//g' | xargs -I{} echo "--device {}:{} "))
	#docker run -it --rm --name ${USER}_pisense_server -v ${CURRENT_PATH}:/root/ ${DEVICELIST} -p ${PORT}:${PORT}/udp ${TAG_SERVER} bash -c \
	#'python3 ./realsense_server/EtherSenseServer.py;'
	python3 ./realsense_server/EtherSenseServer.py

run_client:
	docker run -it --rm --name ${USER}_pisense_client -v ${CURRENT_PATH}:/root/ --net=host ${TAG_CLIENT} bash -c \
	'python3 ./realsense_client/EtherSenseClient.py --address=${ADDRESS} --port=${PORT}'

mv_dataset:
	date "+%s" -r ${REFERED_DIRECTORY_PATH}
	$(eval DIRECTORY_NAME := $(shell date "+%s" -r ${REFERED_DIRECTORY_PATH}))
	mv ${REFERED_DIRECTORY_PATH} ${SAVE_DATASET_PATH}/$(DIRECTORY_NAME)
	mkdir -p ${REFERED_DIRECTORY_PATH}/color ${REFERED_DIRECTORY_PATH}/depth

mkdir_dataset:
	mkdir -p ${REFERED_DIRECTORY_PATH}/color ${REFERED_DIRECTORY_PATH}/depth
	mkdir -p ${SAVE_DATASET_PATH}
