#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
BRIDGE="$WORKSPACE_DIR/scripts/skill_multiagent_bridge.py"

usage() {
  cat <<'EOF'
Usage:
  market-alpha-short-batch.sh [options]

Options:
  --task-slug <slug>    Task slug. Optional if an active task exists.
  --market <name>       cn | us | hk. Default: multi
  --alpha-mode <name>   hunt | lead-follow. Default: hunt
  --horizon <name>      h24-48 | d3-7 | w1-2 | w2-4. Default: h24-48
  --objective <text>    Objective string for notes.
  --dry-run             Print prepared agent commands without executing.
  --help                Show this message.
EOF
}

TASK_SLUG=""
MARKET="multi"
ALPHA_MODE="hunt"
HORIZON="h24-48"
OBJECTIVE="hunt pre-consensus short-term buy opportunities"
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-slug)
      TASK_SLUG="${2:-}"
      shift 2
      ;;
    --market)
      MARKET="${2:-}"
      shift 2
      ;;
    --alpha-mode)
      ALPHA_MODE="${2:-}"
      shift 2
      ;;
    --horizon)
      HORIZON="${2:-}"
      shift 2
      ;;
    --objective)
      OBJECTIVE="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

NOTE="short-alpha-${ALPHA_MODE} | market=${MARKET} | horizon=${HORIZON} | objective=${OBJECTIVE}"

declare -a AGENTS=()

if [[ "$ALPHA_MODE" == "lead-follow" ]]; then
  AGENTS=(
    "planner|task decomposition|Own the lead-follow dependency graph. Force the run to separate signal_market from execution_market and optimize for ${HORIZON} execution, not generic idea generation."
    "signal-market-mapper|source sweep|Identify the earliest market and asset that emits the strongest signal. Distinguish genuine leading information from already-crowded price action."
    "execution-market-mapper|source sweep|Map each leading signal into the most executable follow trade for the user's likely session. Prefer CN/HK follow trades when US is only the signal market."
    "lead-lag-analyst|historical analysis|Measure how similar signals historically transmitted across markets and over what delay. Estimate realistic lead_lag_window and decay speed."
    "crowding-killer|quality filter|Disqualify trades that require East Asia users to manage crowded US night-session single-name exposure unless explicitly requested."
    "quant-verifier|quant verification|Validate relative strength, transmission lag, turnover regime change, and expected holding window for the execution market. Use task-local scripts/market-alpha-quant-compass.py and write JSON outputs under reports/quant/."
    "synthesis-analyst|synthesis|Rank opportunities by executable alpha quality, not by how important the original US signal asset is."
    "reviewer|quality review|Reject any result that confuses signal asset with execution asset or leaves horizon/entry/exit windows vague. Every actionable name must include entry trigger, entry zone, order type, stop loss, take-profit ladder, time stop, invalidation, position sizing, and max holding period. The report must include a Bot Handoff json block that a Rust bot can parse directly. The report must also include a `## Data Freshness & Completeness` section with exact markers: `Market data as of:`, `News data as of:`, `Options data as of:`, `Options data status:`, `Timeline span:`, `Completeness status:`, `Precision level:`, `Critical missing fields:`, `Fallback sources used:`, `Mixed freshness risk:`, `Timeline integrity:`, `Open interest status:`, `Bid-ask status:`, `Expiry-window fit:`. It must include an `## 事件驱动因子` section derived from the task-local news ledger. Any research fact not mapped to thesis, trigger, risk, data gap, or event driver should be removed. If data is missing, precision must downgrade to `DIRECTIONAL_ONLY`, `WATCHLIST`, or `NOT_EXECUTABLE`. If the setup is bearish but the name is already oversold, require a bounce-failure or fresh continuation confirmation; otherwise downgrade to `WAIT` or `WATCHLIST`. If the report claims quant validation, it must include a Quant Evidence section with script path, input path, output path, PNG references, and score/backtest summary. Follow references/report-example-market-alpha.md."
    "report-generator|report generation|Generate the final report with signal_market, execution_market, session_fit, lead_lag_window, entry_window, exit_window, and max_holding_period explicitly filled, and write it in Simplified Chinese by default unless the user explicitly requested another language. Add `## Data Freshness & Completeness` with exact markers: `Market data as of:`, `News data as of:`, `Options data as of:`, `Options data status:`, `Timeline span:`, `Completeness status:`, `Precision level:`, `Critical missing fields:`, `Fallback sources used:`, `Mixed freshness risk:`, `Timeline integrity:`, `Open interest status:`, `Bid-ask status:`, `Expiry-window fit:`. Add `## 事件驱动因子` from task-local `news-event-log.jsonl`. For each actionable trade, provide strategy tag, direction, entry trigger, entry zone, order type, add/reduce rules, take-profit ladder, stop loss, trailing stop or none, time stop, invalidation, slippage budget, and position sizing. Add a Bot Handoff fenced json block for direct Rust-bot consumption; if the setup is not tradable, emit NOT_EXECUTABLE with reason and missing_fields instead of bluffing. If options data is incomplete, do not emit precise strike or expiry as EXECUTABLE output. If market/technical freshness is incomplete, downgrade to `DIRECTIONAL_ONLY` or `WATCHLIST`. If the setup is bearish but the current state is already oversold, do not emit `EXECUTABLE` unless you have fresh continuation confirmation or a bounce-failure entry plan. Map every search result to thesis, trigger, risk, event driver, or data gap; do not dump orphan research. Follow references/report-example-market-alpha.md. If quant validation exists, add a Quant Evidence section listing script path, input path, output path, method used, concise score/backtest summary, and markdown image references to reports/quant/*.png. Before delivery, the draft must pass `python3 ./scripts/finance-intel-report-gate.py --report <draft-report> --task-slug ${TASK_SLUG:-<task-slug>}`. After delivery, the final user-facing handoff must include both FILEPATH and TASK_PATH so the task directory can be reopened locally. If the user explicitly asks for the whole task bundle, run market-alpha-package-task.py and include the package path plus Feishu send payload."
  )
else
  AGENTS=(
    "planner|task decomposition|Own the short-alpha dependency graph. Force the run to prioritize 2-15 trading day pre-consensus buy opportunities, not same-day crowded event chases."
    "catalyst-hunter|source sweep|Find hidden or under-covered catalysts that can reprice a name within 2-15 trading days. Prefer supply-chain, order-flow, policy-edge, product-cycle, or expectation-gap evidence."
    "microstructure-hunter|source sweep|Use minute and daily structure to find quiet accumulation, abnormal turnover pulses, and relative strength during weak tape."
    "crowding-killer|quality filter|Actively disqualify crowded event trades, over-covered narratives, and likely exit-liquidity setups. If a setup is late, label it crowded-event or volatility-only."
    "history-analog|historical analysis|Compare with prior stealth accumulation and failed blow-off setups. Separate pre-launch structures from terminal euphoric structures."
    "quant-verifier|quant verification|Score anomaly strength, relative strength, turnover regime change, and flow confirmation with lightweight numeric validation. Use task-local scripts/market-alpha-quant-compass.py and write JSON outputs under reports/quant/."
    "synthesis-analyst|synthesis|Integrate only names that survive both the catalyst and crowding filters. Rank by alpha quality, not headline visibility."
    "reviewer|quality review|Check that the output still represents buy opportunities with asymmetry. Reject any report that mainly explains obvious public sell-the-news setups. Every actionable name must include entry trigger, entry zone, order type, stop loss, take-profit ladder, time stop, invalidation, position sizing, and max holding period. The report must include a Bot Handoff json block that a Rust bot can parse directly. The report must also include a `## Data Freshness & Completeness` section with exact markers: `Market data as of:`, `News data as of:`, `Options data as of:`, `Options data status:`, `Timeline span:`, `Completeness status:`, `Precision level:`, `Critical missing fields:`, `Fallback sources used:`. Any research fact not mapped to thesis, trigger, risk, or data gap should be removed. If data is missing, precision must downgrade to `DIRECTIONAL_ONLY`, `WATCHLIST`, or `NOT_EXECUTABLE`. If the report claims quant validation, it must include a Quant Evidence section with script path, input path, output path, PNG references, and score/backtest summary. Follow references/report-example-market-alpha.md."
    "report-generator|report generation|Generate the final report, explicitly tag each name as pre-consensus-buy, mispriced-catalyst, relative-strength-breakout, crowded-event, or volatility-only, then hand off for delivery. Add `## Data Freshness & Completeness` with exact markers: `Market data as of:`, `News data as of:`, `Options data as of:`, `Options data status:`, `Timeline span:`, `Completeness status:`, `Precision level:`, `Critical missing fields:`, `Fallback sources used:`. For each actionable trade, provide strategy tag, direction, entry trigger, entry zone, order type, add/reduce rules, take-profit ladder, stop loss, trailing stop or none, time stop, invalidation, slippage budget, and position sizing. Add a Bot Handoff fenced json block for direct Rust-bot consumption; if the setup is not tradable, emit NOT_EXECUTABLE with reason and missing_fields instead of bluffing. If options data is incomplete, do not emit precise strike or expiry as EXECUTABLE output. If market/technical freshness is incomplete, downgrade to `DIRECTIONAL_ONLY` or `WATCHLIST`. Map every search result to thesis, trigger, risk, or data gap; do not dump orphan research. Follow references/report-example-market-alpha.md. If quant validation exists, add a Quant Evidence section listing script path, input path, output path, method used, concise score/backtest summary, and markdown image references to reports/quant/*.png. Before delivery, the draft must pass `python3 ./scripts/finance-intel-report-gate.py --report <draft-report> --task-slug ${TASK_SLUG:-<task-slug>}`. After delivery, the final user-facing handoff must include both FILEPATH and TASK_PATH so the task directory can be reopened locally. If the user explicitly asks for the whole task bundle, run market-alpha-package-task.py and include the package path plus Feishu send payload."
  )
fi

echo "MARKET_ALPHA_SHORT_BATCH"
echo "TASK_SLUG=${TASK_SLUG:-<active-task>}"
echo "MARKET=$MARKET"
echo "ALPHA_MODE=$ALPHA_MODE"
echo "HORIZON=$HORIZON"
echo "OBJECTIVE=$OBJECTIVE"

for spec in "${AGENTS[@]}"; do
  IFS='|' read -r AGENT_NAME ROLE MISSION <<<"$spec"
  AGENT_SLUG="$(printf '%s' "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
  CMD=(
    python3 "$BRIDGE" prepare-agent
    --skill deep-research
  )
  if [[ -n "$TASK_SLUG" ]]; then
    CMD+=(--task-slug "$TASK_SLUG")
  fi
  CMD+=(
    --agent-name "$AGENT_NAME"
    --role "$ROLE"
    --mission "$MISSION"
    --output-path "research/${AGENT_SLUG}.md"
    --output-path "research/${AGENT_SLUG}.worklog.md"
    --output-path "research/${AGENT_SLUG}.raw.json"
    --parallel-group short-hunt
    --note "$NOTE"
  )
  printf 'COMMAND='
  printf '%q ' "${CMD[@]}"
  printf '\n'
  if [[ "$DRY_RUN" != "true" ]]; then
    "${CMD[@]}"
  fi
done
