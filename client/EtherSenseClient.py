#!/usr/bin/python
import sys, getopt
import asyncore
import numpy as np
import pickle
import socket
import struct
import cv2
import open3d as o3d


print("Number of arguments:", len(sys.argv), "arguments.")
print("Argument List:", str(sys.argv))
save_path = "./dataset"
port = 1024
chunk_size = 4096


def main(argv):
    mc_ip_address = argv[0] if len(argv) else "224.0.0.1"
    multi_cast_message(mc_ip_address, port, "EtherSensePing")


#UDP client for each camera server
class ImageClient(asyncore.dispatcher):
    def __init__(self, server, source):
        asyncore.dispatcher.__init__(self, server)
        self.address = server.getsockname()[0]
        self.port = source[1]
        self.buffer = bytearray()
        self.windowName = self.port
        # open cv window which is unique to the port 
        cv2.namedWindow("window"+str(self.windowName))
        #self.vis = o3d.visualization.Visualizer()
        self.remainingBytes = 0
        self.frame_id = 0

    def handle_read(self):
        if self.remainingBytes == 0:
            # get the expected frame size
            self.frame_length = struct.unpack("<I", self.recv(4))[0]
            # get the timestamp of the current frame
            self.timestamp = struct.unpack("<d", self.recv(8))
            self.remainingBytes = self.frame_length

        # request the frame data until the frame is completely in buffer
        data = self.recv(self.remainingBytes)
        self.buffer += data
        self.remainingBytes -= len(data)
        if len(self.buffer) == self.frame_length:
            self.handle_frame()

    def handle_frame(self):
        # convert the frame from string to numerical data
        imdata = pickle.loads(self.buffer)
        timestamp = str(self.timestamp[0]).replace(".", "_")
        color_data, depth_data, intr = imdata[0], imdata[1], list(imdata[2])

        color_image = o3d.geometry.Image(cv2.cvtColor(color_data, cv2.COLOR_BGR2RGB))
        depth_image = o3d.geometry.Image(depth_data)

        if self.frame_id > 12:
            # need time for autofocusing on the environment
            o3d.io.write_image(f"{save_path}/color/{timestamp}.jpg", color_image)
            o3d.io.write_image(f"{save_path}/depth/{timestamp}.png", depth_image)
            print("save color and depth image")

        # for saving pcd
        #rgbd = o3d.geometry.RGBDImage.create_from_color_and_depth(color_image, depth_image, convert_rgb_to_intensity=False, depth_scale=200, depth_trunc=200)
        #intr = [int(intr[0]), int(intr[1]), *intr[2:]]
        #pcd = o3d.geometry.PointCloud.create_from_rgbd_image(rgbd, o3d.camera.PinholeCameraIntrinsic(*intr))
        #rotation = np.array([[1,0,0], [0,-1,0], [0,0,-1]])
        #pcd.rotate(rotation)
        #o3d.io.write_point_cloud(save_path + f"{timestamp}.pcd", pcd)
        #print(f"save {timestamp}.pcd")

        depth_colormap = cv2.applyColorMap(cv2.convertScaleAbs(depth_data, alpha=0.03), cv2.COLORMAP_JET)
        cv2.putText(color_data, timestamp, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (65536), 2, cv2.LINE_AA)
        images = np.concatenate((color_data, depth_colormap), axis=1)
        cv2.imshow("window"+str(self.windowName), images)
        cv2.waitKey(1)

        self.buffer = bytearray()
        self.frame_id += 1

    def readable(self):
        return True


class EtherSenseClient(asyncore.dispatcher):
    def __init__(self):
        asyncore.dispatcher.__init__(self)
        self.server_address = ("", 1024)
        # create a socket for TCP connection between the client and server
        self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.settimeout(5)

        self.bind(self.server_address)
        self.listen(10)

    def writable(self): 
        return False # don"t want write notifies

    def readable(self):
        return True

    def handle_connect(self):
        print("connection recvied")

    def handle_accept(self):
        pair = self.accept()
        #print(self.recv(10))
        if pair is not None:
            sock, addr = pair
            print ("Incoming connection from %s" % repr(addr))
            # when a connection is attempted, delegate image receival to the ImageClient 
            handler = ImageClient(sock, addr)

def multi_cast_message(ip_address, port, message):
    # send the multicast message
    multicast_group = (ip_address, port)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    connections = {}
    try:
        # Send data to the multicast group
        print(f"sending {message} {str(multicast_group)}")
        sent = sock.sendto(message.encode(), multicast_group)

        # defer waiting for a response using Asyncore
        client = EtherSenseClient()
        asyncore.loop()

        # Look for responses from all recipients

    except socket.timeout:
        print("timed out, no more responses")
    finally:
        print(sys.stderr, "closing socket")
        sock.close()

if __name__ == "__main__":
    main(sys.argv[1:])
