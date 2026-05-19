#!/bin/bash
# 自动生成：OpenWrt Airoha 补丁部署脚本
# 用法：将patch文件夹放入源码根目录，cd patch && ./patch.sh

# 获取脚本所在绝对路径，避免相对路径错误
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

echo "正在部署补丁到源码目录：$PROJECT_ROOT"
echo "========================================"

# 复制所有修改/新增文件
mkdir -p "$PROJECT_ROOT/package/base-files/files/etc/uci-defaults"
cp -a "$SCRIPT_DIR/package/base-files/files/etc/uci-defaults/99_fix-airoha-mac" "$PROJECT_ROOT/package/base-files/files/etc/uci-defaults/99_fix-airoha-mac"
mkdir -p "$PROJECT_ROOT/package/boot/uboot-tools/uboot-envtools/files"
cp -a "$SCRIPT_DIR/package/boot/uboot-tools/uboot-envtools/files/mediatek_filogic" "$PROJECT_ROOT/package/boot/uboot-tools/uboot-envtools/files/mediatek_filogic"
mkdir -p "$PROJECT_ROOT/package/kernel/linux/files"
cp -a "$SCRIPT_DIR/package/kernel/linux/files/sysctl-nf-conntrack.conf" "$PROJECT_ROOT/package/kernel/linux/files/sysctl-nf-conntrack.conf"
mkdir -p "$PROJECT_ROOT/package/kernel/linux/modules"
cp -a "$SCRIPT_DIR/package/kernel/linux/modules/netdevices.mk" "$PROJECT_ROOT/package/kernel/linux/modules/netdevices.mk"
mkdir -p "$PROJECT_ROOT/package"
cp -a "$SCRIPT_DIR/package/luci-app-airoha-npu/" "$PROJECT_ROOT/package/luci-app-airoha-npu/"
mkdir -p "$PROJECT_ROOT/target/linux/airoha/an7581/base-files/etc/board.d"
cp -a "$SCRIPT_DIR/target/linux/airoha/an7581/base-files/etc/board.d/02_network" "$PROJECT_ROOT/target/linux/airoha/an7581/base-files/etc/board.d/02_network"

echo "========================================"
echo "✅ 补丁部署完成！请重新编译源码。
