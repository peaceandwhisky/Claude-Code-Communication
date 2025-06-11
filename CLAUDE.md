# Agent Communication System

## 概要
このシステムは、複数のAIエージェントが協調して開発タスクを実行するための汎用的なフレームワークです。
任意のプロジェクトに対して、変更内容を指定することで、エージェントが自動的にタスクを分解・実行します。

## エージェント構成
- **PRESIDENT** (別セッション): プロジェクト全体の統括・タスク計画
- **boss1** (multiagent:0.0): チームリーダー・タスク割り振り
- **worker1,2,3** (multiagent:0.1-3): 実際の開発作業実行

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md

## 使用方法

### 1. エージェントの起動
```bash
# セットアップ
./setup.sh

# Claude Code起動
./start-agents.sh
```

※ 主要な開発ツール（Bash, Edit, Read, Write等）は`--allowedTools`フラグにより事前許可されます。

### 2. PRESIDENTセッションで開発を開始
PRESIDENTに以下の情報を提供：
- 対象プロジェクトのパス
- プロジェクトの概要説明
- 実装したい変更内容

### 3. メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

### 4. 基本的な実行フロー
1. PRESIDENT: セッション作成 → ブランチ作成 → プロジェクト分析 → タスク計画
2. PRESIDENT → boss1: タスク一覧と実行指示（セッションディレクトリ情報含む）
3. boss1 → workers: 個別タスクの割り振り
4. workers: タスク実行 → 品質確認 → コミット
5. workers → boss1: 作業結果報告（コミットID含む）
6. boss1 → PRESIDENT: 全体進捗報告
7. PRESIDENT: 最終確認 → GitHubへプッシュ

### 5. セッション管理
- 全ての調査内容と指示は`./sessions/`以下に保存される
- セッションが中断されても、保存された情報から再開可能
- セッションディレクトリ構造：
  ```
  sessions/
  └── [プロジェクト名]_[日時]/
      ├── user_request.md      # ユーザーからの初期指示
      ├── project_info.md      # プロジェクト基本情報
      ├── project_analysis.md  # 分析結果
      ├── task_plan.md        # タスク計画
      ├── boss_instruction.md  # boss1への指示
      ├── progress.md         # 進捗記録
      ├── worker_instructions/ # worker個別指示
      └── worker_progress.md   # worker進捗
  ```

## 特徴
- **汎用性**: 任意のプロジェクトに適用可能
- **並列実行**: 独立したタスクを複数workerで同時実行
- **品質管理**: 各段階でのテストとエラーチェック
- **進捗追跡**: リアルタイムでの作業状況把握
- **バージョン管理**: 自動的なブランチ作成、コミット、プッシュ
- **セッション管理**: 作業内容の永続化と中断からの再開サポート 