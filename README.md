# 🤖 Multi-Agent Development System

複数のAIエージェントが協調して開発タスクを実行する汎用的なシステム

## 🎯 システム概要

任意のプロジェクトに対して、PRESIDENTエージェントが開発計画を立案し、BOSSが作業を割り振り、Workersが実際の開発作業を並列実行する階層型開発システムです

### 👥 エージェント構成

```
📊 PRESIDENT セッション (1ペイン)
└── PRESIDENT: プロジェクト統括・タスク計画立案

📊 multiagent セッション (4ペイン)  
├── boss1: チームリーダー・タスク割り振り
├── worker1: 開発作業実行者A
├── worker2: 開発作業実行者B
└── worker3: 開発作業実行者C
```

### 🔄 システムの特徴

- **汎用性**: 任意のプロジェクトに適用可能
- **並列実行**: 独立したタスクを複数workerで同時実行
- **品質管理**: 各段階でのテストとエラーチェック
- **進捗追跡**: リアルタイムでの作業状況把握

## 🚀 クイックスタート

### 0. リポジトリのクローン

```bash
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication
```

### 1. tmux環境構築

⚠️ **注意**: 既存の `multiagent` と `president` セッションがある場合は自動的に削除されます。

```bash
./setup.sh
```

### 2. セッションアタッチ

```bash
# マルチエージェント確認
tmux attach-session -t multiagent

# プレジデント確認（別ターミナルで）
tmux attach-session -t president
```

### 3. Claude Code起動

#### 方法1: 一括起動スクリプト（推奨）
```bash
./start-agents.sh
```

※ 主要な開発ツール（Bash, Edit, Read, Write等）は自動的に許可されます。

#### 方法2: 手動起動
**手順1: President起動**
```bash
# まずPRESIDENTを起動（主要ツールを事前許可）
tmux send-keys -t president 'claude --allowedTools "Bash Edit Read Write MultiEdit Glob Grep LS WebFetch TodoRead TodoWrite"' C-m
```

**手順2: Multiagent一括起動**
```bash
# multiagentセッションを一括起動（主要ツールを事前許可）
for i in {0..3}; do tmux send-keys -t multiagent:0.$i 'claude --allowedTools "Bash Edit Read Write MultiEdit Glob Grep LS WebFetch TodoRead TodoWrite"' C-m; done
```

**起動確認方法**
```bash
# すべてのtmuxセッションを確認
tmux ls

# 特定のセッション内のウィンドウを確認
tmux list-windows -t president
tmux list-windows -t multiagent

# 各ペインの内容を確認（例: presidentセッション）
tmux attach-session -t president
# Ctrl+b, d でデタッチ

# multiagentセッションの特定のペインを確認
tmux attach-session -t multiagent:0.0  # boss1
tmux attach-session -t multiagent:0.1  # worker1
tmux attach-session -t multiagent:0.2  # worker2
tmux attach-session -t multiagent:0.3  # worker3
```

※ 主要な開発ツールは`--allowedTools`フラグにより事前許可されます。

### 4. 開発プロジェクトの実行

PRESIDENTセッションで以下の情報を提供：

```
開発したいプロジェクトのパス: /path/to/your/project
プロジェクトの概要: [プロジェクトの説明]
実装したい変更: [具体的な変更内容]
```

PRESIDENTが自動的に：
1. プロジェクトを分析
2. タスクを計画・分解
3. boss1に指示を送信
4. 開発作業を開始

## 📜 システムアーキテクチャ

### 役割別指示書
- **PRESIDENT**: `instructions/president.md` - プロジェクト分析とタスク計画
- **boss1**: `instructions/boss.md` - タスク割り振りと進捗管理
- **worker1,2,3**: `instructions/worker.md` - 実際の開発作業実行

### 処理フロー

```
1. PRESIDENT: セッション作成 → ブランチ作成 → プロジェクト分析 → タスク分解 → 実行計画作成
2. PRESIDENT → boss1: タスク一覧と実行指示を送信（セッション情報含む）
3. boss1: タスクを分析 → workerへ適切に割り振り → 指示内容を記録
4. workers: 並列/順次でタスク実行 → 品質確認 → コミット → 完了報告
5. boss1 → PRESIDENT: 全体進捗と完了報告（コミットID含む）
6. PRESIDENT: 最終確認 → テスト実行 → GitHubへプッシュ
```

### セッション管理機能

作業内容は自動的に`./sessions/`ディレクトリに保存され、セッションが中断されても再開可能：

- ユーザーからの初期指示（原文をそのまま保存）
- プロジェクト分析結果
- タスク計画
- boss1への指示
- 各workerへの指示
- 進捗状況

セッション再開時は保存された情報を参照して、ユーザーの最初の要求を確認しながら中断地点から作業を継続できます。

### タスク実行例

**並列実行可能なタスク:**
- UIコンポーネントの作成
- 独立したAPIエンドポイントの実装
- 異なるモジュールのテスト作成

**順次実行が必要なタスク:**
- データベーススキーマ変更 → マイグレーション実行
- APIの実装 → それを使用するフロントエンド実装

## 🔧 手動操作

### agent-send.shを使った送信

```bash
# 基本送信
./agent-send.sh [エージェント名] [メッセージ]

# 例
./agent-send.sh boss1 "緊急タスクです"
./agent-send.sh worker1 "作業完了しました"
./agent-send.sh president "最終報告です"

# エージェント一覧確認
./agent-send.sh --list
```

## 🧪 確認・デバッグ

### ログ確認

```bash
# 送信ログ確認
cat logs/send_log.txt

# 特定エージェントのログ
grep "boss1" logs/send_log.txt

# 作業進捗の確認
tail -f logs/send_log.txt
```

### セッション状態確認

```bash
# セッション一覧
tmux list-sessions

# ペイン一覧
tmux list-panes -t multiagent
tmux list-panes -t president
```

## 🔄 環境リセット

```bash
# セッション削除
tmux kill-session -t multiagent
tmux kill-session -t president

# ログクリア
rm -rf logs/

# 再構築（自動クリア付き）
./setup.sh
```

## 💡 活用例

### Webアプリケーション開発
- フロントエンド、バックエンド、データベースの並列開発
- APIとUIの統合テスト

### リファクタリング
- 大規模なコードベースの段階的な改善
- テストカバレッジの向上

### 新機能追加
- 機能の設計から実装、テストまでの一貫した開発
- ドキュメントの自動更新

---

🚀 **Multi-Agent Development System で効率的な開発を！** 🤖✨ 