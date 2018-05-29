#!/usr/bin/env python
"""Send get version"""
import array, fcntl, os, uuid, struct, sys
def open_dev(devnode):
   return os.open(devnode, os.O_RDWR)

def open_dev_default():
    try:
        fd = os.open("/dev/mei", os.O_RDWR)
    except OSError as e:
	if e.errno == 2:
            fd = os.open("/dev/mei0", os.O_RDWR)
	else:
            raise e

    return fd

def connect(fd, uustr) :
    IOCTL_MEI_CONNECT_CLIENT = 0xc0104801
    u = uuid.UUID(uustr)
    buf = array.array('c', u.get_bytes_le())
    fcntl.ioctl(fd, IOCTL_MEI_CONNECT_CLIENT, buf, 1)
    maxlen, vers = struct.unpack("<IB", buf.tostring () [:5])
    print "connected %s, maxlen %x, vers %x" % (uustr, maxlen , vers)
    return maxlen , vers

def req_ver(fd) :
    buf_write = struct.pack("I", 0x000002FF)
    return os.write(fd, buf_write)

def get_ver(fd) :
    buf_read = os.read(fd, 28)
    s = struct.unpack("4B12H", buf_read);
    print "ME Code Firmware Version: %d.%d.%d.%d" % (s[5], s[4], s[7], s[6])
    print "ME NFTP Firmware Version: %d.%d.%d.%d" % (s[9], s[8], s[11], s[10])
    print "ME FITC Firmware Version: %d.%d.%d.%d" % (s[13], s[12], s[15], s[14])

def connect_mkhi(fd) :
    mkhi = "8e6a6715-9abc-4043-88ef-9e39c6f63e0f"
    return connect(fd, mkhi)

def ver(fd):
    req_ver(fd)
    get_ver(fd)


