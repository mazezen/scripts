import os

def get_os_cpu_counts():
    """
    Return the number of os and cpu counts.
    :return:
    """
    return os.cpu_count()
def get_os_uname():
    """
    Return the name of the operating system.
    :return:
    """
    return os.uname()


if __name__ == "__main__":
    print(get_os_cpu_counts())
    print(get_os_uname())
    print(os.getpid())
    print(os.getlogin())
    print(os.getcwd())
    print(os.get_exec_path())
    print(os.getenv("HOME"))
