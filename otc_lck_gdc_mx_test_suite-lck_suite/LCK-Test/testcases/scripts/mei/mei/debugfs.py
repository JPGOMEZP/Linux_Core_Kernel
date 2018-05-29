#!/usr/bin/python

import codecs
import glob
import os
import re
import sys

def open_file_read(path, encoding='UTF-8'):
    '''Open specified file read-only'''
    try:
        orig = codecs.open(path, 'r', encoding)
    except Exception:
        raise

    return orig

def valid_path(path):
    '''Valid path'''
    # No relative paths
    m = "Invalid path: %s" % (path)
    if not path.startswith('/'):
        debug("%s (relative)" % (m))
        return False

    if '"' in path:  # We double quote elsewhere
        debug("%s (contains quote)" % (m))
        return False

    try:
        os.path.normpath(path)
    except Exception:
        debug("%s (could not normalize)" % (m))
        return False

    return os.path.exists(path)

def check_for_debugfs(device):
    """Finds and returns the mointpoint for mei None otherwise"""

    filesystem = '/proc/filesystems'
    mounts = '/proc/mounts'
    support_debugfs = False
    regex_debugfs = re.compile('^\S+\s+(\S+)\s+debugfs\s')
    mei_dir = None

    if valid_path(filesystem):
        with open_file_read(filesystem) as f_in:
            for line in f_in:
                if 'debugfs' in line:
                    support_debugfs = True

    if not support_debugfs:
        return False

    if valid_path(mounts):
        with open_file_read(mounts) as f_in:
            for line in f_in:
                match = regex_debugfs.search(line)
                if match:
                    mountpoint = match.groups()[0] + '/' +  device
                    if not valid_path(mountpoint):
                        return False
                    mei_dir = mountpoint

    # Check if meclients are present 
    if not valid_path(mei_dir + '/meclients'):
        mei_dir = None
    return mei_dir

def mei_clients(device):

   meclients=[]
   mei_dir = check_for_debugfs(device)
   if not mei_dir:
       return None
   
   with open_file_read(mei_dir + '/meclients') as f_in:
       for line in f_in:
          print line.split('|')[3]
          meclients.append(line.split('|')[3])

mei_clients('mei0')
