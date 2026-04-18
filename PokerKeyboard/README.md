# Poker Keyboard — iPhone キーボード拡張

ポーカーのハンドヒストリー記録専用の iOS カスタムキーボードです。
アクション / ランク / ポジション / スーツをワンタップで入力できます。

## キー配列

| 行 | キー | 用途 |
|----|------|------|
| 1 | `f` `c` `r` `b` `x` `all-in` `/` | アクション / ストリート区切り |
| 2 | `1` `2` `3` `4` `5` `6` `7` `8` `9` `T` `J` `Q` `K` | ランク (ベットサイズ、カード) |
| 3 | `UTG` `+1` `+2` `LJ` `HJ` `CO` `BTN` `SB` `BB` | ポジション |
| 4 | 🌐 `♠`(黒) `♥`(赤) `♦`(青) `♣`(緑) `⌫` `⏎` | 切替 / スーツ / 削除 / 改行 |

- `⌫` は長押しで連続削除します
- `♣` は要望通り緑色で表示します

## iPhone 実機で使うまでの最短手順

### 必要なもの

- macOS + Xcode (15 以上推奨)
- Apple ID (無料の Personal Team でも 7 日間なら動きます)
- Lightning / USB-C ケーブル (または Wi-Fi で iPhone を Xcode に pair 済み)

### 1. リポジトリを取得

```bash
git clone -b claude/poker-keyboard-extension-bsIUP https://github.com/tktk28/combo-calc.git
cd combo-calc/PokerKeyboard
```

### 2. セットアップスクリプトを実行

**自分専用の一意な bundle id prefix** を指定してください。`com.<自分の名前>.pokerkeyboard` のように。

```bash
./setup.sh com.taro.pokerkeyboard
```

スクリプトは次を自動で行います:
- `project.yml` 内のダミー bundle id をあなたの id に置換
- `xcodegen` が無ければ Homebrew でインストール
- `PokerKeyboard.xcodeproj` を生成
- Xcode で開く

> 無料 Apple ID の場合、他人が使った bundle id を再利用できません。必ず自分だけの文字列にしてください。

### 3. Xcode で実機にビルド

1. 左ペインで `PokerKeyboardApp` ターゲット → `Signing & Capabilities` タブ
2. `Team` に自分の Apple ID を選択
3. `PokerKeyboardExtension` ターゲットでも同じ Team を選択
4. 画面上部のデバイス選択を **自分の iPhone** にする (初回は iPhone 側で開発者モードを有効化)
5. `⌘R` でビルド & 転送

### 4. iPhone 側でキーボードを有効化

1. `設定` → `一般` → `VPN とデバイス管理` → 自分の Apple ID の項目を **信頼**
2. `設定` → `一般` → `キーボード` → `キーボード` → `新しいキーボードを追加…`
3. `Poker Keyboard` を選択
4. メモ / LINE / Slack などのテキスト欄を開き、🌐 キーを長押しして `Poker Keyboard` を選ぶ

これでポーカー専用キーで直接ハンドヒストリーを打てます。

## ハンドヒストリー入力例

```
UTG r3 CO c BTN c BB c
/ 7♠9♥T♣
BB x UTG b5 CO f BTN c BB c
/ 2♦
BB x UTG b12 BTN f BB c
/ K♥
BB x UTG all-in BB c
```

## ファイル構成

```
PokerKeyboard/
├── project.yml                          # XcodeGen のビルド定義 (ソース・オブ・トゥルース)
├── setup.sh                             # bundle id 置換 + xcodegen + Xcode 起動
├── .gitignore                           # 生成される .xcodeproj を除外
├── PokerKeyboardApp/                    # 拡張を配布するためのコンテナ App
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift             # 動作確認用テキスト欄と案内
│   ├── Info.plist
│   └── Assets.xcassets/
└── PokerKeyboardExtension/              # キーボード拡張本体
    ├── KeyboardViewController.swift     # UI / 入力ロジック
    └── Info.plist
```

## よくあるつまづき

- **「No account for team」** : Xcode の Settings → Accounts に Apple ID を追加
- **「Failed to register bundle identifier」** : 他人と bundle id が衝突しています。`setup.sh` を違う prefix で再実行
- **キーボード一覧に出てこない** : App 側が iPhone にインストールされているか確認。インストール後、設定アプリを再起動
- **7 日で起動しなくなる** : 無料 Apple ID の制限。再度 `⌘R` で転送し直せば OK。有料 Developer Program に加入すれば 1 年間有効

## カスタマイズ

`PokerKeyboardExtension/KeyboardViewController.swift` の `rows: [[Key]]` を編集すれば配列を即変更できます。色は `background(for:)` / `foreground(for:)`、フォントサイズは `fontSize(for:)` に集約しています。

## 制限事項

- Open Access (`RequestsOpenAccess = true`) は不要な設計です。クリップボード・ネットワーク・解析は一切していません
- 背景はダーク固定 (`#1a1a2e` 相当)。ライト追従が欲しい場合は `viewDidLoad` の `view.backgroundColor` を調整してください
- スーツは Unicode の `♠ ♥ ♦ ♣` を素のまま挿入します (絵文字 VS16 セレクタは付けない → `grep` しやすい)
