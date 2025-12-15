"""
https://free-proxy-list.net/ssl-proxy.html
随机获取一个 HTTPS 代理
"""

import requests
from bs4 import BeautifulSoup
from random import choice

def get_random_https_proxy():
    """
    :return: 返回一个随机 HTTPS 代理
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

if __name__ == '__main__':
    proxy = get_random_https_proxy()
    print(proxy)