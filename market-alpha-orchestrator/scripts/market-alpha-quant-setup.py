#!/usr/bin/env python3

from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path
import sys

SCRIPT_DIR = Path(__file__).resolve().parent
WORKSPACE_DIR = SCRIPT_DIR.parent.parent.parent
TASK_SCRIPT_DIR = WORKSPACE_DIR / "scripts"
sys.path.insert(0, str(TASK_SCRIPT_DIR))

import task_session  # noqa: E402


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def append_script_registry(task_dir: Path, path: Path, purpose: str) -> None:
    payload = {
        "timestamp_utc": task_session.iso_now(),
        "path": str(path),
        "relative_path": f".{str(path).replace(str(WORKSPACE_DIR), '')}",
        "purpose": purpose,
        "linked_question": "",
    }
    task_session.append_jsonl(task_dir / "scripts.jsonl", payload)


def main() -> int:
    parser = argparse.ArgumentParser(description="Scaffold quant files into the active market-alpha task")
    parser.add_argument("--task-slug")
    parser.add_argument("--style", default="hybrid")
    parser.add_argument("--horizon", default="auto")
    parser.add_argument("--objective", default="")
    args = parser.parse_args()

    task_dir = task_session.resolve_task_dir(task_slug=args.task_slug, prefer_active=True)
    scripts_dir = task_dir / "scripts"
    scratch_dir = task_dir / "scratch" / "quant"
    reports_dir = task_dir / "reports" / "quant"
    scripts_dir.mkdir(parents=True, exist_ok=True)
    scratch_dir.mkdir(parents=True, exist_ok=True)
    reports_dir.mkdir(parents=True, exist_ok=True)

    source_script = SCRIPT_DIR / "market-alpha-quant-compass.py"
    target_script = scripts_dir / "market-alpha-quant-compass.py"
    shutil.copy2(source_script, target_script)
    target_script.chmod(0o755)
    append_script_registry(task_dir, target_script, "market-alpha quant compass")

    candidate_csv = scratch_dir / "candidate-factors.csv"
    if not candidate_csv.exists():
        write_text(
            candidate_csv,
            "\n".join(
                [
                    "ticker,date,price,signal_strength,relative_strength,turnover_pulse,flow_confirmation,crowding_penalty",
                    "EXAMPLE,2026-03-16,100,0.0,0.0,0.0,0.0,0.0",
                ]
            ),
        )

    backtest_csv = scratch_dir / "signal-backtest.csv"
    if not backtest_csv.exists():
        write_text(
            backtest_csv,
            "\n".join(
                [
                    "date,close,signal",
                    "2026-03-10,100,0",
                    "2026-03-11,102,1",
                    "2026-03-12,103,0",
                    "2026-03-13,105,1",
                    "2026-03-14,104,0",
                    "2026-03-15,108,0",
                ]
            ),
        )

    readme = scratch_dir / "README.md"
    write_text(
        readme,
        f"""# Market Alpha Quant Workspace

- style: `{args.style}`
- horizon: `{args.horizon}`
- objective: {args.objective or 'N/A'}

## Files

- `candidate-factors.csv`
  - 用于因子打分
- `signal-backtest.csv`
  - 用于 forward return 回测
- `../scripts/market-alpha-quant-compass.py`
  - 真实可执行的量化脚本

## Example

```bash
python3 scripts/market-alpha-quant-compass.py detect-runtime \\
  --output reports/quant/runtime-profile.json

python3 scripts/market-alpha-quant-compass.py choose-model \\
  --rows 200 \\
  --features 6 \\
  --horizon {args.horizon} \\
  --target-type continuous \\
  --output reports/quant/model-router.json

python3 scripts/market-alpha-quant-compass.py score \\
  --input scratch/quant/candidate-factors.csv \\
  --factors signal_strength:0.35,relative_strength:0.25,turnover_pulse:0.20,flow_confirmation:0.30,crowding_penalty:-0.30 \\
  --top 10 \\
  --output reports/quant/factor-score.json

python3 scripts/market-alpha-quant-compass.py backtest-forward \\
  --input scratch/quant/signal-backtest.csv \\
  --signal-col signal \\
  --horizons 1,2,3,5 \\
  --output reports/quant/backtest-summary.json
```

JSON 写出时会自动生成同名 `.csv` 和 `.png` companion（适用于 score / backtest / bucket-eval / lead-lag-scan）。
""",
    )

    runtime_profile = reports_dir / "runtime-profile.json"
    model_router = reports_dir / "model-router.json"
    subprocess.run(
        [
            "python3",
            str(target_script),
            "detect-runtime",
            "--output",
            str(runtime_profile),
        ],
        check=True,
    )
    subprocess.run(
        [
            "python3",
            str(target_script),
            "choose-model",
            "--rows",
            "200",
            "--features",
            "6",
            "--horizon",
            args.horizon,
            "--target-type",
            "continuous",
            "--output",
            str(model_router),
        ],
        check=True,
    )

    print("MARKET_ALPHA_QUANT_SETUP_OK")
    print(f"TASK_DIR={task_dir}")
    print(f"SCRIPT={target_script}")
    print(f"CANDIDATE_TEMPLATE={candidate_csv}")
    print(f"BACKTEST_TEMPLATE={backtest_csv}")
    print(f"README={readme}")
    print(f"RUNTIME_PROFILE={runtime_profile}")
    print(f"MODEL_ROUTER={model_router}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
