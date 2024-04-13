# zen-cjktty

Linux ZEN with [cjktty-patches](https://github.com/zhmars/cjktty-patches)

## 使用说明
将如下内容添加到 `/etc/pacman.conf`
```
[zencjktty]
SigLevel = PackageOptional
Server = https://github.com/Bryan2333/arch-zen-cjktty/releases/download/packages
```

## 改动

- 使用O2优化级别进行编译
- 添加[cjktty-patches](https://github.com/zhmars/cjktty-patches)
