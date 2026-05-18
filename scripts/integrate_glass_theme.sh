bash
#!/bin/bash
# integrate_glass_theme.sh

set -e
echo ">>> Starting integration of luci-theme-glass..."

# 1. 克隆主题源码到 package 目录
#    使用 --depth 1 来克隆，只获取最新代码，可以显著加快速度
git clone --depth=1 https://github.com/rchen14b/luci-theme-glass.git package/luci-theme-glass

# 2. (可选) 自动在 .config 中启用该主题
if ! grep -q "CONFIG_PACKAGE_luci-theme-glass=y" .config; then
    echo "CONFIG_PACKAGE_luci-theme-glass=y" >> .config
fi

echo ">>> Integration finished."
