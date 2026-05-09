# 我的个人博客

这是一个 Hugo 静态博客项目。

## 常用命令

新建文章：

```bash
LD_LIBRARY_PATH=/home/ddxd/.local/hugo/usr/lib/x86_64-linux-gnu /home/ddxd/.local/hugo/usr/bin/hugo new posts/my-post.md
```

或者使用项目脚本：

```bash
./new-post.sh "文章标题" "文章摘要"
```

本地预览：

```bash
LD_LIBRARY_PATH=/home/ddxd/.local/hugo/usr/lib/x86_64-linux-gnu /home/ddxd/.local/hugo/usr/bin/hugo server --bind 0.0.0.0 --baseURL http://服务器IP:1313/
```

构建发布：

```bash
./deploy.sh
```

生成后的静态文件位于 `public/`。

## Git 同步

当前服务器环境中 `.git` 被占用，项目使用 `.git-store/` 保存 Git 数据。
请用项目脚本执行 Git 命令：

```bash
./git-blog.sh status
./git-blog.sh pull
./git-blog.sh push
```

## 启用 Nginx

当前账号没有 root 权限时，请用 root 或具备 sudo 权限的账号执行：

```bash
cd /home/ddxd/blog
sudo bash setup-nginx.sh
```

如果已经有域名解析到这台服务器，把 `nginx-blog.conf` 中的 `server_name _;` 改成你的域名，例如：

```nginx
server_name example.com www.example.com;
```

HTTPS 可在域名解析生效后安装 Certbot：

```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com
```
