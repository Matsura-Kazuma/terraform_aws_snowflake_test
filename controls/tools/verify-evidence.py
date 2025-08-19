#!/usr/bin/env python3
# verify-evidence.py — evidence-record.schema.json による簡易検証
import json, sys, pathlib, datetime, re

def load_json(p):
    with open(p, encoding="utf-8") as f:
        return json.load(f)

def iso8601(s):
    try:
        datetime.datetime.fromisoformat(s.replace("Z","+00:00"))
        return True
    except Exception:
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: verify-evidence.py <record.json>"); sys.exit(2)
    rec = load_json(sys.argv[1])
    errs = []
    # 必須キー
    for k in ["id","title","controls","framework","produced_at","produced_by","environment","artifacts","hashes"]:
        if k not in rec: errs.append(f"missing: {k}")
    # produced_at ISO8601
    if "produced_at" in rec and not iso8601(rec["produced_at"]):
        errs.append("produced_at not ISO8601")
    # environment
    if rec.get("environment") not in ["Dev","Stg","Prod","Preview"]:
        errs.append("environment must be Dev/Stg/Prod/Preview")
    # hashes 空チェック
    if "hashes" in rec:
        for k,v in rec["hashes"].items():
            if not v: errs.append(f"hash for {k} is empty")
    if errs:
        print("INVALID:", *errs, sep="\n- ")
        sys.exit(1)
    print("OK:", sys.argv[1])

if __name__ == "__main__":
    main()
