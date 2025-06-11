#!/bin/bash

# 🤖 エージェント一括起動スクリプト（自動許可モード）

set -e

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🤖 Claude Code エージェント起動"
echo "================================"
echo ""

# セッション存在確認
if ! tmux has-session -t president 2>/dev/null; then
    echo "❌ presidentセッションが見つかりません"
    echo "先に ./setup.sh を実行してください"
    exit 1
fi

if ! tmux has-session -t multiagent 2>/dev/null; then
    echo "❌ multiagentセッションが見つかりません"
    echo "先に ./setup.sh を実行してください"
    exit 1
fi

# PRESIDENT起動
log_info "👑 PRESIDENT起動中..."
tmux send-keys -t president 'claude --allowedTools "Bash Edit Read Write MultiEdit Glob Grep LS WebFetch TodoRead TodoWrite"' C-m
sleep 2

# Multiagent起動
log_info "👥 マルチエージェント起動中..."
for i in {0..3}; do 
    agent_name=""
    case $i in
        0) agent_name="boss1" ;;
        1) agent_name="worker1" ;;
        2) agent_name="worker2" ;;
        3) agent_name="worker3" ;;
    esac
    
    log_info "$agent_name 起動..."
    tmux send-keys -t multiagent:0.$i 'claude --allowedTools "Bash Edit Read Write MultiEdit Glob Grep LS WebFetch TodoRead TodoWrite"' C-m
    sleep 1
done

log_success "✅ 全エージェント起動完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. PRESIDENTセッションにアタッチ:"
echo "     tmux attach-session -t president"
echo ""
echo "  2. 開発プロジェクトの情報を提供:"
echo "     - 対象プロジェクトのパス"
echo "     - プロジェクトの概要"
echo "     - 実装したい変更内容"
echo ""
echo "🎯 主要なツールは事前に許可済みです（Bash, Edit, Read, Write等）"