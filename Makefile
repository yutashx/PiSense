# declare variables
CONFIG_PATH=./reconstruction/reconstruction_system/config/PiSense.json
ADDRESS=224.0.0.1
REFERED_DIRECTORY_PATH=./reconstruction/reconstruction_system/dataset
SAVE_DATASET_PATH=./reconstruction/reconstruction_system/save_dataset
CURRENT_PATH=`pwd`
TAG_RECONSTRUCTION=pisense_reconstruction
TAG_SERVER=pisense_server
TAG_CLIENT=pisense_client
PORT=1024
WINDOW=DISABLE #or ENABLE
GPU=DISABLE #or ENABLE
CHUNK_SIZE=4096
WIDTH=640
HEIGHT=480
FPS=6
DISTANCE=2.0
MESSAGE=EtherPing
VIDEO_TYPE=color

build_reconstruction:
	docker build -f ./reconstruction/Dockerfile -t ${TAG_RECONSTRUCTION} ./reconstruction/

build_server:
	docker build -f ./realsense_server/Dockerfile -t ${TAG_SERVER} ./realsense_server/

build_client:
	docker build -f ./realsense_client/Dockerfile -t ${TAG_CLIENT} ./realsense_client/

run_reconstruction:
ifeq ($(GPU), ENABLE)
	docker run -it --rm --name ${USER}_pisense_reconstruction --gpus all -v ${CURRENT_PATH}:/root/ -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -u $(id -u $USER):$(id -g $USER) ${TAG_RECONSTRUCTION} bash -c \
	'python3 ./reconstruction/reconstruction_system/run_system.py --make --register --refine --integrate ${CONFIG_PATH}; \
	python3 ./reconstruction/pipelines/color_map_optimization_for_reconstruction_system.py  --config ${CONFIG_PATH};'
else
	docker run -it --rm --name ${USER}_pisense_reconstruction -v ${CURRENT_PATH}:/root/ -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -u $(id -u $USER):$(id -g $USER) ${TAG_RECONSTRUCTION} bash -c \
	'python3 ./reconstruction/reconstruction_system/run_system.py --make --register --refine --integrate ${CONFIG_PATH}; \
	python3 ./reconstruction/pipelines/color_map_optimization_for_reconstruction_system.py  --config ${CONFIG_PATH};'
endif

run_server:
	python3 ./realsense_server/EtherSenseServer.py --port=${PORT} --chunk_size=${CHUNK_SIZE} --width=${WIDTH} --height=${HEIGHT} --fps=${FPS} --distance=${DISTANCE}

run_client:
ifeq ($(WINDOW), ENABLE)
	python3 ./realsense_client/EtherSenseClient.py --save_path=${REFERED_DIRECTORY_PATH} --address=${ADDRESS} --port=${PORT} --chunk_size=${CHUNK_SIZE} --window --message=${MESSAGE}
else
	docker run -it --rm --name ${USER}_pisense_client -v ${CURRENT_PATH}:/root/ -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -u $(id -u $USER):$(id -g $USER) --net=host ${TAG_CLIENT} bash -c \
	'python3 ./realsense_client/EtherSenseClient.py --save_path=${REFERED_DIRECTORY_PATH} --address=${ADDRESS} --port=${PORT} --chunk_size=${CHUNK_SIZE} --message=${MESSAGE}'
endif

run_capture:
	capture_type=imgs
	fps=30
	height=1280
	width=720
	distance=3
	python3 ./reconstruction/reconstruction_system/sensors/realsense_recorder.py --output_folder=${REFERED_DIRECTORY_PATH} --record_${capture_type} --fps=${fps} --color_width=${width} --color_height=${height} --depth_width=${width} --color_height=${height} --distance=${distance}
	#python3 ./reconstruction/reconstruction_system/sensors/realsense_recorder.py --output_folder=${REFERED_DIRECTORY_PATH} --record_${capture_type}


install_server:
	pip -r ./realsense_server/requirements.txt

mv_dataset:
	date "+%s" -r ${REFERED_DIRECTORY_PATH}
	$(eval DIRECTORY_NAME := $(shell date "+%s" -r ${REFERED_DIRECTORY_PATH}))
	mv ${REFERED_DIRECTORY_PATH} ${SAVE_DATASET_PATH}/$(DIRECTORY_NAME)
	mkdir -p ${REFERED_DIRECTORY_PATH}/color ${REFERED_DIRECTORY_PATH}/depth

mkdir_dataset:
	mkdir -p ${REFERED_DIRECTORY_PATH}/color ${REFERED_DIRECTORY_PATH}/depth
	mkdir -p ${SAVE_DATASET_PATH}

init_directories: mv_dataset mkdir_dataset

make_video:
ifeq ($(VIDEO_TYPE), color)
	ffmpeg  -pattern_type glob -i '${REFERED_DIRECTORY_PATH}/color/*.jpg' '${REFERED_DIRECTORY_PATH}/color.mp4'
endif

ifeq ($(VIDEO_TYPE), depth)
	ffmpeg  -pattern_type glob -i '${REFERED_DIRECTORY_PATH}/depth/*.png' '${REFERED_DIRECTORY_PATH}/depth.mp4'
endif
