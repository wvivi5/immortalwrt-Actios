#!/bin/bash
# DIY脚本第1部分（更新feeds之前）

# 添加 small-package (包含了 openclash/passwall 等常用插件)
echo 'src-git smpackage https://github.com/kenzok8/small-package' >> feeds.conf.default
# 添加 iStore 应用商店
echo 'src-git store https://github.com/linkease/istore.git;main' >> feeds.conf.default
