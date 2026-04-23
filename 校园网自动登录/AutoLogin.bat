@echo off
chcp 65001 >nul
title 开机自动网络认证

:: ====================== 请修改这里的信息 ======================
set "LOGIN_URL=http://10.254.7.4/"
:: ===默认重庆大学网络连接url===
set "USERNAME=你的用户名"
:: ===覆盖填写你的用户名===
set "PASSWORD=密码"
:: ===覆盖填写你的密码===
:: =============================================================

:WAIT_UNLOCK
rem 检查锁屏进程是否存在
tasklist /fi "imagename eq LogonUI.exe" 2>nul | find /i "LogonUI.exe" >nul
if not errorlevel 1 (
    rem 锁屏中，等待1秒后重试
    timeout /t 1 /nobreak >nul
    goto WAIT_UNLOCK
)
rem 解锁后，等待资源管理器就绪
powershell -noprofile -c "exit !(gps explorer -ea 0)"
if errorlevel 1 (
    timeout /t 1 /nobreak >nul
    goto WAIT_UNLOCK
)
echo 已解锁，桌面已就绪

ping 180.76.76.76 -n 1 -w 200 >nul
if not errorlevel 1 (
    echo 网络已连接
    exit
)

echo 开始认证...

:: 打开认证页面
start msedge.exe "%LOGIN_URL%"

:: 最小必要延迟，如果提前关闭edge了，就把3调大
timeout /t 3 /nobreak >nul

:: 自动填写账号密码
powershell -noprofile -c "$wshell=New-Object -Com WScript.Shell;$wshell.AppActivate('Edge');sleep -m 100;$wshell.SendKeys('{TAB 3}');sleep -m 50;$wshell.SendKeys('%USERNAME%');sleep -m 50;$wshell.SendKeys('{TAB}');sleep -m 50;$wshell.SendKeys('%PASSWORD%');sleep -m 50;$wshell.SendKeys('{ENTER}')"
:: TAB 3中的3是针对重庆大学网络登录页面设计的，其他登录要根据tab按的次数x修改。按x次tab之后对应到账号栏
:: 关闭浏览器
taskkill /F /IM msedge.exe >nul 2>&1

echo 认证完成
exit