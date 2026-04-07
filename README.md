# service-online-test

## 作用：利用Cloudflare的Workers项目测试服务是否能从外网访问

## 使用方法：

### cloudflare控制台上操作：

1、在openwrt中创建workers项目

2、添加变量：类型为纯文本，名称为TARGET_URL，值为需要检测的服务域名（例如：https://www.baidu.com）

3、添加自定义域（workers分配的域名在国内无法直连，需要代理）

### 服务端上操作：（以openwrt为例）

1、在/root目录下下载service-online-test.sh文件

2、添加测试域名：**URL="https://"**

3、添加执行权限

```
chmod +x /root/service-online-test.sh
```

4、设置每日定时启动

```
crontab -e
```

5、在文件内添加一行，每天 5 点执行检测脚本

```
0 5 * * * /root/service-online-test.sh
```

6、重启 cron

```
/etc/init.d/cron restart
```

7、手动执行一次来测试

```
/root/service-online-test.sh
```
