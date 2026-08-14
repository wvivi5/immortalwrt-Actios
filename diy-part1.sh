#!/bin/bash
# DIY脚本第1部分（更新feeds之前）

# 添加 small-package
echo 'src-git smpackage https://github.com/kenzok8/small-package' >> feeds.conf.default
# 添加 iStore 应用商店
echo 'src-git store https://github.com/linkease/istore.git;main' >> feeds.conf.default
# 添加 daed 源 (HTTPS 公开仓库，免鉴权)
echo 'src-git daed https://github.com/daeuniverse/luci-app-daed.git;main' >> feeds.conf.default
