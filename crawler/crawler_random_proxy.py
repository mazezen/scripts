"""
https://proxylist.geonode.com/api/proxy-list?limit=500&page=1&sort_by=lastChecked&sort_type=desc
limit max 500, can't gt 500
page min 1, can't lt 1
随机返回一个代理, 支持 HTTP, HTTPS, SOCKS4, SOCKS5
"""
from random import choice

import requests


def get_random_http_proxy(limit, page, protocols):
    http_proxies = []
    https_proxies = []
    socks4_proxies = []
    socks5_proxies = []
    url = f"https://proxylist.geonode.com/api/proxy-list?limit={limit}&page={page}&sort_by=lastChecked&sort_type=desc"
    print(url)
    try:
        response = requests.get(url, timeout=10)
        if response.status_code != 200:
            print("[-] 获取代理 失败" + str(response.status_code))
            return None
        if response.status_code == 200:
            res_json = response.json()
            for row in res_json["data"]:
                if row["protocols"][0] == "http":
                   ip = row["ip"].strip()
                   port = row["port"]
                   http_proxies.append(f"http://{ip}:{port}")
                if row["protocols"][0] == "https":
                    ip = row["ip"].strip()
                    port = row["port"]
                    https_proxies.append(f"https://{ip}:{port}")
                if row["protocols"][0] == "socks4":
                    ip = row["ip"].strip()
                    port = row["port"]
                    socks4_proxies.append(f"socks4://{ip}:{port}")
                if row["protocols"][0] == "socks5":
                    ip = row["ip"].strip()
                    port = row["port"]
                    socks5_proxies.append(f"socks5://{ip}:{port}")
    except requests.exceptions.ConnectionError as e:
        print("[-] 获取代理失败" + str(e))
        return None

    if protocols == "http":
        if len(http_proxies) > 0:
            return choice(http_proxies)
        else:
            return None
    elif protocols == "https":
        if len(https_proxies) > 0:
            return choice(https_proxies)
        else:
            return None
    elif protocols == "socks4":
        if len(socks4_proxies) > 0:
            return choice(socks4_proxies)
        else:
            return None
    elif protocols == "socks5":
        if len(socks5_proxies) > 0:
            return choice(socks5_proxies)
        else:
            return None
    else:
        return None

if __name__ == '__main__':
    limit = input("请输入需要的每页数量: ")
    page = input("请输入对应的页码: ")
    protocols = input("请输入需要的代理protocols: ")
    proxy = get_random_http_proxy(limit, page, protocols)
    if proxy is not None:
        print(proxy)


