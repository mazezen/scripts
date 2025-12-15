import sys

def get_sys_info():
    """
    system info
    :return: system info
    """

    platform = sys.platform
    maxsize = sys.maxsize
    sys.meta_path.append(sys.executable)
    sys_info = {
        "platform": platform,
        "maxsize": maxsize,
    }
    return sys_info

if __name__ == '__main__':
    sys_info = get_sys_info()
    print(sys_info)