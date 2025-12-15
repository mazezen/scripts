"""
使用 Python 的快速、可靠且随机的 Web 代理请求应用程序。
"""

import requests
from bs4 import BeautifulSoup
from random import choice

def get_proxies():
    """
    :return: 返回一个随机 HTTPS 代理字典
    """
    url = "https://free-proxy-list.net/ssl-proxy.html"
    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"[-] 获取代理失败: {e}")
        return None
    soup = BeautifulSoup(response.text, "html.parser")
    # print(soup.prettify())

    proxies = []
    for row in soup.find("table").find_all("tr")[1:]:
        cols = row.find_all("td")
        # print(cols)
        if len(cols) > 7:
            ip = cols[0].text.strip()
            port = cols[1].text.strip()
            https = cols[6].text.strip()
            if https == "yes":
                proxies.append(f"{ip}:{port}")
    if not proxies:
        print("[-] 未找到 HTTPS 代理")
        return None

    proxy_url = choice(proxies)
    return {"https": f"https://{proxy_url}"}



def proxy_request(method, url, **kwargs):
    proxy = get_proxies()
    if not proxy:
        print("[-] 无法获取代理IP")
        return None
    # print(proxy)
    print(f"[+] 使用代理: {proxy['https']}")

    try:
        response = requests.request(
            method, url, proxies=proxy, timeout=10, **kwargs
        )
        print(f"[+] 状态码: {response.status_code}")
        return response
    except requests.exceptions.RequestException as e:
        print(f"[-] 请求失败: {e}")
        return None

if __name__ == '__main__':
    result = proxy_request('get', "https://www.youtube.com/IndianPythonista")
    print(result)

