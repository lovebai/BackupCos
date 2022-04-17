# 使用

安装 Python3.x 版本

安装腾讯云官方库

```
pip install -U cos-python-sdk-v5
```

或者

```
python3 -m pip install -U cos-python-sdk-v5
```

安装后之后 Clone 项目

```
git clone https://github.com/lovebai/BackupCos.git
```

下载完成后，为 backup.sh 添加执行权限

```
chmod 755 backup.sh
```

或者直接 `+x` Ubuntu 需要在前面加 sudo

修改 backup.py 文件，把里面相关内容改成自己的

参考链接：[https://www.xiaobaibk.com/1153/](https://www.xiaobaibk.com/1153/ "https://www.xiaobaibk.com/1153/")

运行./backup.sh 输出使用说明

配合 crontab 使用该脚本

```
crontab -e  # 添加定时任务
```

```
crontab -l  # 查看任务列表
```
