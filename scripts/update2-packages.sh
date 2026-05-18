#!/bin/bash
# 安装和更新第三方软件包
# 此脚本在 openwrt/package/ 目录下运行，在 feeds install 之后执行

UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)
	local REPO_NAME=${PKG_REPO#*/}

	echo " "
	echo "=========================================="
	echo "Processing: $PKG_NAME from $PKG_REPO"
	echo "=========================================="

	# 删除 feeds 中可能存在的同名软件包
	for NAME in "${PKG_LIST[@]}"; do
		echo "Search directory: $NAME"
		local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not found directory: $NAME"
		fi
	done

	# 克隆 GitHub 仓库
	git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/$PKG_REPO.git"

	if [ ! -d "$REPO_NAME" ]; then
		echo "ERROR: Failed to clone $PKG_REPO"
		return 1
	fi

	# 处理克隆的仓库
	if [[ "$PKG_SPECIAL" == "pkg" ]]; then
		# 从大杂烩仓库中提取特定包
		find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
		rm -rf ./$REPO_NAME/
	elif [[ "$PKG_SPECIAL" == "name" ]]; then
		# 重命名仓库
		mv -f $REPO_NAME $PKG_NAME
	fi

	echo "Done: $PKG_NAME"
}

echo "Starting package updates..."

# 删除 feeds 中的 sing-box 相关包，避免与第三方包冲突
echo " "
echo "=========================================="
echo "Removing conflicting sing-box packages from feeds..."
echo "=========================================="
rm -rf ../feeds/packages/net/sing-box
rm -rf ../package/feeds/packages/sing-box
echo "Done removing sing-box from feeds"

# 可选：如果你还需要 homeproxy，取消下面一行的注释
# UPDATE_PACKAGE "homeproxy" "immortalwrt/homeproxy" "master"

# 只集成 PassWall2（代理软件）
UPDATE_PACKAGE "passwall2" "Openwrt-Passwall/openwrt-passwall2" "main" "pkg"

# ========== 新增：集成 Airoha NPU 监控界面 ==========
UPDATE_PACKAGE "luci-app-airoha-npu" "rchen14b/luci-app-airoha-npu" "main"
# ========== 新增结束 ==========

# ========== 新增：集成 Glass 主题 ==========
UPDATE_PACKAGE "luci-theme-glass" "rchen14b/luci-theme-glass" "main"
# ========== 新增结束 ==========

# ========== 新增：修复 PassWall2 的 ShadowsocksR 组件默认禁用 ==========
# 原因：OpenWrt 25.12 下 shadowsocksr-libev 的上游归档内容已变化，旧 MIRROR_HASH 失效。
# 通过修改 Makefile 默认选项，避免在未手动选择 SSR 时因下载失败中断编译。
if [ -f "./luci-app-passwall2/Makefile" ]; then
	echo " "
	echo "=========================================="
	echo "Patching PassWall2 Makefile to disable broken ShadowsocksR components..."
	echo "=========================================="
	# 禁用 ShadowsocksR-Libev 客户端（默认 y -> n）
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR_Libev_Client/,/default y/s/default y/default n/' "./luci-app-passwall2/Makefile"
	# 禁用 ShadowsocksR-Libev 服务端（虽然默认已是 n，但显式再设置为 n 确保安全）
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR_Libev_Server/,/default n/s/default n/default n/' "./luci-app-passwall2/Makefile"
	echo "PassWall2 Makefile patched successfully."
else
	echo "WARNING: luci-app-passwall2/Makefile not found, cannot patch SSR components."
fi
# ========== 修复结束 ==========

# PassWall2 依赖包（从 openwrt-passwall-packages 中获取）
echo " "
echo "=========================================="
echo "Installing PassWall2 dependencies..."
echo "=========================================="
git clone --depth=1 --single-branch --branch main "https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git"
if [ -d "openwrt-passwall-packages" ]; then
	for pkg in openwrt-passwall-packages/*/; do
		pkg_name=$(basename "$pkg")
		if [ -d "$pkg" ] && [ -f "$pkg/Makefile" ]; then
			echo "Installing: $pkg_name"
			rm -rf "./$pkg_name"
			cp -rf "$pkg" ./
		fi
	done
	rm -rf openwrt-passwall-packages
fi

echo " "
echo "=========================================="
echo "Package updates completed!"
echo "=========================================="
