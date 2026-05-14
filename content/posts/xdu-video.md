---
title: "教室画面查看器"
date: 2026-05-14T16:58:44+08:00
draft: false
summary: "远程查看xdu教室画面的工具网站"
---

点击前往：[教室画面查看器](https://ddxd.com.cn/classroom/)

项目地址：[GitHub](https://github.com/ddxd001/xdu-video.git)

在浏览器里按 **设备号** 或 **楼栋 + 门牌** 查看教室直播流（HLS / m3u8）。数据来自本地 `urlCache.json`，不依赖外网接口；播放页通过 CDN 加载 [hls.js](https://github.com/video-dev/hls.js/)。

## 环境要求

- Python 3.9+（使用标准库 `http.server`，无 pip 依赖）
- 能访问流媒体地址的网络（多为校园网或内网）
- 浏览器需能访问 `cdn.jsdelivr.net`（加载 hls.js）；若被拦截，可改用「复制地址」后用 VLC 等播放

## 快速开始

```
cd /path/to/abc
python3 classroom_stream_viewer.py
```

启动后默认打开 **http://127.0.0.1:8765/**。若 8765 已被占用，程序会自动尝试 8766、8767…（最多 32 个端口），并在终端提示实际端口。

### 指定监听地址与端口

默认只监听本机 `127.0.0.1`。部署到服务器供他人访问时，需监听所有网卡：

```
export CLASSROOM_STREAM_VIEWER_HOST=0.0.0.0
export CLASSROOM_STREAM_VIEWER_PORT=8765
python3 classroom_stream_viewer.py
```

一行写法：

```
CLASSROOM_STREAM_VIEWER_HOST=0.0.0.0 CLASSROOM_STREAM_VIEWER_PORT=8765 python3 classroom_stream_viewer.py
```

## 服务器部署

### 1. 准备文件

将以下文件拷到服务器同一目录（路径可自定，例如 `/opt/classroom-viewer/`）：

- `classroom_stream_viewer.py`
- `urlCache.json`
- `room/`（仅作维护参考时可一并拷贝；运行不依赖）

服务器需安装 **Python 3**，无需 `pip install`。

### 2. 放行防火墙与安全组

在云主机安全组或本机防火墙中放行所选 TCP 端口（示例 8765），例如 Ubuntu 上使用 `ufw allow 8765/tcp`。

### 3. 长期运行（systemd 示例）

创建 `/etc/systemd/system/classroom-viewer.service`（路径与 `User` 请按实际修改）：

```
[Unit]
Description=Classroom stream viewer
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/classroom-viewer
Environment=CLASSROOM_STREAM_VIEWER_HOST=0.0.0.0
Environment=CLASSROOM_STREAM_VIEWER_PORT=8765
ExecStart=/usr/bin/python3 /opt/classroom-viewer/classroom_stream_viewer.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```



然后：

```
sudo systemctl daemon-reload
sudo systemctl enable --now classroom-viewer
sudo systemctl status classroom-viewer
```

浏览器访问：`http://服务器IP:8765/`（若改了端口则换端口）。

### 4. 可选：Nginx 反向代理与 HTTPS

若希望使用 443、证书或域名，可在本进程前加 Nginx，把 `location /` 代理到 `http://127.0.0.1:8765`，此时可把 Python 的 `CLASSROOM_STREAM_VIEWER_HOST` 改回 `127.0.0.1`，只让 Nginx 对外监听。

### 5. 安全说明（重要）

当前服务 **无登录、无权限控制**，`urlCache.json` 与页面会暴露内网流地址信息。建议：

- 仅部署在 **内网 / VPN** 后，或配合 **IP 白名单**、**Nginx 基本认证** 等再对外开放；
- 流媒体 m3u8 本身通常仍需在校园网或指定网络下才能播放，与是否部署查看器无关。

## 项目文件

| 文件                                 | 说明                                                         |
| ------------------------------------ | ------------------------------------------------------------ |
| `classroom_stream_viewer.py`         | 本地 HTTP 服务 + 内置页面逻辑                                |
| `urlCache.json`                      | 设备号 → 各画面类型的 m3u8 地址（需自行维护或从上游导出）    |
| `room/A.txt` … `room/X2.txt`（可选） | 历史/备用的「门牌→设备号」表；**运行时已内置进脚本**，修改映射需改 `classroom_stream_viewer.py` 中的 `BUILDING_MAPS`（或编辑 `room/` 下 txt 后合并再粘贴进脚本） |

## `urlCache.json` 结构

顶层键为 **6 位设备号**（字符串），值为包含以下键的对象：

| 键              | 含义           |
| --------------- | -------------- |
| `ppt_video`     | PPT / 电脑画面 |
| `teacher_full`  | 教师全景       |
| `teacher_track` | 教师跟踪       |
| `student_full`  | 学生全景       |

每个键对应值为完整的 **m3u8 URL**。

## 页面功能简述



1. **楼栋 + 门牌**：从下拉框选择后，会自动填入对应 **设备号**（例如 B 楼门牌 501 → `004370`）。也可点 **「写入设备号」** 仅同步输入框而不查流。
2. **设备号**：可直接输入或修改；datalist 来自缓存中已有设备号列表。
3. **画面类型** + **「显示画面」**：请求本地 `/api/lookup` 并尝试在页面内播放。
4. **复制流地址 / 新窗口打开**：便于在外部播放器或新标签页打开。

### 楼栋显示名称（内置）

- **X**：西大楼
- **X1**：信远1号楼
- **X2**：信远2号楼
- 其余为 A/B/C/D/J 教学楼等简称，见脚本内 `BUILDING_LABELS`。

## API（本地）



| 路径                                            | 说明                                      |
| ----------------------------------------------- | ----------------------------------------- |
| `GET /`                                         | 主页面（内嵌注入楼栋门牌数据）            |
| `GET /api/rooms`                                | 返回 `urlCache.json` 中所有设备号（排序） |
| `GET /api/lookup?room=<设备号>&type=<画面类型>` | 返回 JSON：`ok`、`url`、错误信息等        |

## 常见问题

**端口被占用**
程序会自动递增端口；也可用环境变量 `CLASSROOM_STREAM_VIEWER_PORT` 指定起始端口，或自行 `lsof -iTCP:8765 -sTCP:LISTEN` 后结束占用进程。

**服务器上浏览器打不开**
需设置 `CLASSROOM_STREAM_VIEWER_HOST=0.0.0.0` 并放行防火墙，用 `http://服务器IP:端口` 访问；详见上文「服务器部署」。

**浏览器无法播放**
先试「新窗口打开」；仍失败则用 VLC / PotPlayer / ffplay 打开 m3u8 链接。

**修改门牌与设备号对应关系**
编辑 `classroom_stream_viewer.py` 中 `BUILDING_MAPS` 的 JSON 字符串（或从 `room/A.txt` 等合并后再粘贴），保存后重启服务即可。
