"""
Simulated Login about 163 email
"""

from getpass import getpass
from selenium import webdriver
from selenium.common import TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


def login_163():
    account_email = input("Enter your 163 email: ")
    account_password = getpass("Enter your account password: ")

    driver = webdriver.Chrome()
    driver.maximize_window()

    wait = WebDriverWait(driver, 10)

    try:
        driver.get("https://mail.163.com/")

        driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => false});")

        print("等待登录框 iframe 出现...")
        iframe_el = wait.until(
            EC.presence_of_element_located((By.CSS_SELECTOR,"iframe[id^='x-URS-iframe']"))
        )
        driver.switch_to.frame(iframe_el)
        print("已切换到 iframe")

        print("自动填充邮箱账号...")
        email_input = wait.until(
            EC.element_to_be_clickable((By.NAME, "email"))
        )
        email_input.clear()
        email_input.send_keys(account_email)

        print("自动填充密码...")
        pwd_input = driver.find_element(By.NAME, "password")
        pwd_input.clear()
        pwd_input.send_keys(account_password)

        print("点击登录...")
        login_btn = wait.until(
            EC.element_to_be_clickable((By.ID, "dologin"))
        )
        login_btn.click()
        print("等待登录完成...")

        def login_successful(driver):
            current_url = driver.current_url
            if "mail.163.com" not in current_url:
                return False
            if any(keyword in current_url for keyword in ["verify", "error", "risk", "captcha", "vc"]):
                return False

            try:
                driver.find_element(By.XPATH,
                                    "//span[contains(text(),'写信')] | //a[contains(@href,'compose')] | //div[contains(text(),'收件箱')]")
                return True
            except:
                pass

            return "x-URS-iframe" not in driver.page_source

        print("等待登录成功（最长 30 秒）...")
        wait.until(login_successful)
        print("登录成功！当前页面：", driver.current_url)

        cookies = driver.get_cookies()
        return cookies

    except TimeoutException as e:
        print("超时错误, 请检查网络或页面是否加载完成")
        driver.save_screenshot("timeout_error.png")
        raise e
    except Exception as e:
        print(f"未知服务: {e}")
        driver.save_screenshot("unknown_error.png")
        raise e
    finally:
        keep = input("是否保持浏览器打开? (y/n): ")
        if keep.lower() != "y":
            driver.quit()



if __name__ == '__main__':
    cookies = login_163()
    print("\n=== 获取到的 Cookies ===")
    for c in cookies:
        print(f"{c['name']} = {c['value']}")

    cookies_dict = {c['name']: c['value'] for c in cookies}
    print("\nCookies dict（可直接用于 requests）:")
    print(cookies_dict)