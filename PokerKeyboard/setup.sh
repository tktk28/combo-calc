#!/bin/bash
# Poker Keyboard 実機インストール補助スクリプト
#
# 使い方:
#   ./setup.sh com.yourname.pokerkeyboard
#
# - project.yml のダミー bundle id を置き換え
# - xcodegen が入っていなければ Homebrew で導入
# - xcodeproj を生成して Xcode で開く

set -euo pipefail

cd "$(dirname "$0")"

NEW_ID="${1:-}"
if [ -z "$NEW_ID" ]; then
  echo "使い方: $0 <your-bundle-id-prefix>"
  echo "例:    $0 com.taro.pokerkeyboard"
  exit 1
fi

echo "==> bundle id を $NEW_ID に置換"
# macOS の sed は BSD 系なので -i '' を使う
sed -i '' \
  -e "s|com\\.example\\.pokerkeyboard\\.app\\.keyboard|${NEW_ID}.app.keyboard|g" \
  -e "s|com\\.example\\.pokerkeyboard\\.app|${NEW_ID}.app|g" \
  -e "s|com\\.example\\.pokerkeyboard|${NEW_ID}|g" \
  project.yml

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "==> xcodegen が無いので Homebrew で入れる"
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew が見つかりません。https://brew.sh から入れてやり直してください。" >&2
    exit 1
  fi
  brew install xcodegen
fi

echo "==> xcodeproj を生成"
xcodegen generate

echo "==> Xcode で開く"
open PokerKeyboard.xcodeproj

cat <<'MSG'

次の手順:
  1. Xcode 左ペインで PokerKeyboardApp を選択
  2. Signing & Capabilities タブで Team を選択 (無料 Apple ID で OK)
  3. PokerKeyboardExtension も同じ Team を選択
  4. 画面上部のスキームが PokerKeyboardApp, Destination が自分の iPhone になっている事を確認
  5. ⌘R で実機に転送
  6. iPhone 側: 設定 > 一般 > キーボード > キーボード > 新しいキーボードを追加 > Poker Keyboard
  7. メモ等で地球儀キーを長押しして Poker Keyboard へ切替

MSG
