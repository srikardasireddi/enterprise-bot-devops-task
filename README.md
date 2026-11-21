# Enterprise Bot DevOps / Platform Engineering Assignment

## Overview
This repository contains the work completed for the Enterprise Bot DevOps / Platform Engineering take-home assignment, including local Kubernetes (`kind`) setup, automation/deployment scripts, the Part 4 Helm/Kubernetes debugging lab in `lab/`, and Part 5 architectural answers in `ANSWERS.md`.

## Repository Structure
- `lab/` — Debugging lab environment (`cluster-state/`, `broken-chart/`, `scenario.sh`, and `lab/FINDINGS.md`).
- `ANSWERS.md` — Part 5 responses covering Ingress to Gateway API migration.
- `README.md` — Setup notes, execution summary, and AI usage disclosure.

## Running & Verifying
From the `lab/` directory in Git Bash (with Docker Desktop and the `kind` cluster running):
./scenario.sh up
./scenario.sh verify

## AI Assistance Disclosure
An AI assistant was used during this assignment as a technical collaborator to help structure investigation steps, diagnose Kubernetes/Helm/DNS behaviors, review configurations, and draft documentation (`lab/FINDINGS.md`, `ANSWERS.md`, and `README.md`). All commands, cluster changes, and final files were reviewed and verified in the local environment.
