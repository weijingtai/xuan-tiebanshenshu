# Unified Divination Dashboard (One-Click Divination) - Product Requirements Document (PRD)

## 1. Introduction

### 1.1 Purpose

To transform the current fragmented divination experience into a cohesive, "One-Stop" dashboard. The goal is to allow users to generate a comprehensive divination report from a single entry point (EightChars), with an interactive, chat-like flow for refining parameters (like KeFen) and exploring different possibilities.

### 1.2 Scope

This feature covers the aggregation of all 18+ existing divination strategies into a unified UI, a new "Divination Flow" architecture, and a comparison system for parallel testing of different parameters.

## 2. User Personas

### 2.1 The Novice

- **Goal:** Wants to get a general overview of their destiny without understanding the complex underlying algorithms.
- **Pain Point:** Overwhelmed by selecting individual strategies; doesn't know the order of operations.
- **Solution:** A "One-Click" start button that automatically runs all "Direct" strategies and presents a simple summary.

### 2.2 The Professional / Researcher

- **Goal:** Wants to verify specific time parameters (KeFen) and compare how different choices affect the final outcome.
- **Pain Point:** Hard to manually switch between different "KeFen" or "YuanHui" settings to compare results.
- **Solution:** A "Branching" feature that allows forking the divination process to see side-by-side comparisons of different assumptions.

## 3. Functional Requirements

### 3.1 Unification & Automation

- **FR_01 (One-Click Start):** Users shall be able to input Birth Data (EightChars) once and trigger the calculation of all compatible strategies.
- **FR_02 (Automatic Classification):** The system shall automatically classify strategies into:
  - **Direct:** Run immediately (e.g., FourZhuTianGan).
  - **Pre-Interactive:** Require user input before running (e.g., KeFen for TaiXuan).
  - **Mid-Interactive:** Require iterative input during execution (e.g., HuangJi).

### 3.2 Interactive Flow

- **FR_03 (Stream Interface):** The report shall be presented as a vertical stream of cards.
- **FR_04 (In-Place Interaction):** When a strategy requires input (e.g., "Verify KeFen"), an interactive card shall appear directly in the stream.
- **FR_05 (Reactive Updates):** Answering an interactive card shall automatically trigger downstream dependent calculations without a full page reload.

### 3.3 Comparison & Branching

- **FR_06 (Forking):** At any decision point (e.g., choosing "Zi Ke"), users shall be able to "Fork" the session.
- **FR_07 (Side-by-Side View):** Forked sessions shall be displayed as parallel vertical streams (columns) in a horizonally scrolling container.
- **FR_08 (History Navigation):** Users shall see a history of their choices and be able to jump back to any previous decision point to create a new branch.

### 3.4 Persistence & Export

- **FR_09 (Session Save):** The entire state of a divination session (including all branches) should be savable.
- **FR_10 (Export):** Users shall be able to export the final report (or a specific branch) as an image or PDF.

## 4. Non-Functional Requirements

- **NFR_01 (Performance):** "Direct" strategies must calculate and display within 200ms of input.
- **NFR_02 (Extensibility):** Adding a new strategy to the "One-Click" flow should require minimal configuration changes.
- **NFR_03 (State Management):** The system must efficiently manage memory, especially when multiple branches are open.

## 5. UI/UX Concept

- **Layout:** Horizontal list of "Divination Columns".
- **Column:** Vertical list of "Result Cards" and "Interactive Cards".
- **Theme:** Consistent with the "New Chinese Style" (Glassmorphism, Traditional Colors).
