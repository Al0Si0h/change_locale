#!/bin/bash

set -e

TARGET_LOCALE="en_US.UTF-8"

# 获取当前 LANG
CURRENT_LANG=$(locale | grep '^LANG=' | cut -d= -f2)

echo "=============================="
echo " 当前系统语言环境检测/Current system language environment detection"
echo "------------------------------"
echo " current LANG: $CURRENT_LANG"
echo " Target LANG: $TARGET_LOCALE"
echo "=============================="

# 判断是否已经是 UTF-8
if [[ "$CURRENT_LANG" == *"UTF-8"* ]]; then
    echo "✔ Already UTF-8 No Change"
    exit 0
fi

echo "⚠ Not UTF-8"

# 第一次确认
read -rp "Continue Change $TARGET_LOCALE ? [y/N]: " confirm1
if [[ ! "$confirm1" =~ ^[Yy]$ ]]; then
    echo "Canceled"
    exit 0
fi

echo
echo "⚠ Will be modified locale config："
echo " - /etc/locale.gen"
echo " - /etc/default/locale"
echo " - Current SHELL environment variables"
echo

# 第二次确认（更强提醒）
read -rp "Confirm the operation again (enter YES to continue): " confirm2
if [[ "$confirm2" != "YES" ]]; then
    echo "Canceled"
    exit 0
fi

echo
echo "Start Change..."

# 1️⃣ 确保 locales 包存在
if ! command -v locale-gen >/dev/null 2>&1; then
    echo "[1/5] install locales package..."
    apt-get update
    apt-get install -y locales
else
    echo "[1/5] locales already exists"
fi

# 2️⃣ 启用 en_US.UTF-8
if ! grep -q "^en_US.UTF-8 UTF-8" /etc/locale.gen; then
    echo "[2/5] Use en_US.UTF-8..."
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
else
    echo "[2/5] locale Enabled"
fi

# 3️⃣ 生成 locale
echo "[3/5] Create locale..."
locale-gen en_US.UTF-8

# 4️⃣ 写入默认配置（幂等）
echo "[4/5] Write /etc/default/locale..."
cat > /etc/default/locale <<EOF
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

# 5️⃣ 当前 session 生效
echo "[5/5] Apply to current shell..."
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo
echo "✅ OK！Now locale："
locale
