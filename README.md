# PiSense

## What is this?
The PiSense is a caturing and reconstructing system with Raspberry Pi and RealSense.
RealSense connected to Raspberry Pi is server side and powerful PC is client side.
You can capture depth and RGB images with server side and send them to the PC at the same time using network.
You can see the capturing scene in a window opening in the PC.
Finished capturing, you can run reconstruction pipeline, and you will get 3D data(ply format) using the captured images.
I prepared useful Makefile to command these operation.

This reposiotry is based on [EtherSense](https://github.com/yutashx/EtherSense) and [Open3d/examples/python](https://github.com/intel-isl/Open3D/tree/master/examples/python).

## Tips
`./realsense_server/archive.zip` is binary file of librealsense and pyrealsense2 built for Raspberry Pi.
If you unzip the file and install some other packages with `requirements.txt`, you can run the realsense_server now.

## License
MIT
