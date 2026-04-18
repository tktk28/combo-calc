# Poker Keyboard — iPhone キーボード拡張

ポーカーのハンドヒストリー記録専用の iOS カスタムキーボードです。
アクション・ランク・ポジション・スーツだけをワンタップで入力できます。

## キー配列

| 行 | キー | 用途 |
|----|------|------|
| 1 | `f` `c` `r` `b` `x` `all-in` `/` | アクション / ストリート区切り |
| 2 | `1` `2` `3` `4` `5` `6` `7` `8` `9` `T` `J` `Q` `K` | ランク(ベットサイズ、カード) |
| 3 | `UTG` `+1` `+2` `LJ` `HJ` `CO` `BTN` `SB` `BB` | ポジション |
| 4 | 🌐 `♠`(黒) `♥`(赤) `♦`(青) `♣`(緑) `⌫` `⏎` | キーボード切替 / スーツ / 削除 / 改行 |

- `⌫` は長押しで連続削除します。
- `♣` はユーザ要望に従い緑色で表示します。

## ファイル構成

```
PokerKeyboard/
├── PokerKeyboardApp/                 # コンテナ App (拡張を配布するための必須 App)
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift          # 動作確認用のテキスト欄と案内
│   ├── Info.plist
│   └── Assets.xcassets/
└── PokerKeyboardExtension/           # キーボード拡張本体
    ├── KeyboardViewController.swift  # UI / 入力ロジック
    └── Info.plist                    # NSExtensionPointIdentifier = com.apple.keyboard-service
```

## Xcode でプロジェクトをセットアップする手順

Apple のキーボード拡張テンプレートを使うと最短で動きます。

1. **コンテナ App を作成**
   - Xcode ▶ `File` ▶ `New` ▶ `Project…` ▶ `iOS` ▶ `App`
   - Product Name: `PokerKeyboardApp`
   - Interface: `Storyboard` は使わず、手動で `SceneDelegate` を参照するので `Storyboard` を空にしても OK
   - Language: `Swift`
   - 作成直後に生成された `AppDelegate.swift` / `SceneDelegate.swift` / `ViewController.swift` / `Info.plist` を、本リポジトリ `PokerKeyboardApp/` 内のファイルで **置き換え**ます。
   - `Main.storyboard` は削除し、`Info.plist` から `UIMainStoryboardFile` 行を消します (本リポジトリの Info.plist は既にこの状態)。

2. **キーボード拡張ターゲットを追加**
   - プロジェクト ▶ `File` ▶ `New` ▶ `Target…` ▶ `iOS` ▶ `Custom Keyboard Extension`
   - Product Name: `PokerKeyboardExtension`
   - 生成された `KeyboardViewController.swift` と `Info.plist` を、本リポジトリ `PokerKeyboardExtension/` 内のファイルで **置き換え**ます。
   - 拡張の Deployment Target は iOS 15 以上を推奨 (`UIAction` を使用しているため)。

3. **ビルド & 実機インストール**
   - 実機 (iPhone) を接続し、`PokerKeyboardApp` スキームを選択して Run。
   - コンテナ App 自体は確認用のテキストビューが出るだけで機能はありません。

4. **キーボードを有効化**
   - iPhone の `設定` ▶ `一般` ▶ `キーボード` ▶ `キーボード` ▶ `新しいキーボードを追加…`
   - `Poker Keyboard` を選択。
   - メモ等のテキスト欄を開き、地球儀キーで `Poker Keyboard` に切り替え。

## 入力仕様メモ

- `all-in` はそのままリテラル文字列 `all-in` を挿入します。
- `/` はストリート区切り用 (例: `UTG r3 BB c / x x / x b5 ...`)。
- ポジション `+1` `+2` は UTG+1 / UTG+2 を想定。
- `T` は 10 の略記。
- スーツは Unicode の `♠ ♥ ♦ ♣` をテキストとして挿入します。絵文字 (`♠️` 等) の VS16 セレクタは付けません (検索・grep 性を優先)。

## カスタマイズポイント

`KeyboardViewController.swift` の `rows: [[Key]]` を編集すれば配列はすぐ変更できます。色は `background(for:)` / `foreground(for:)`、サイズは `fontSize(for:)` にまとまっています。

## 制限事項

- Open Access (`RequestsOpenAccess = true`) は不要な設計です。クリップボードやネットワークは使っていません。
- ダークテーマ固定 (背景 `#1a1a2e` 相当) です。OS のライト/ダーク追従が必要なら `viewDidLoad` を調整してください。
