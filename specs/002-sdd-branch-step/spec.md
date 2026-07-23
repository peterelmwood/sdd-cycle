# Feature Specification: Mandatory Branch-Creation Step in the SDD Workflow

**Feature Branch**: `002-sdd-branch-step`

**Created**: 2026-07-23

**Status**: Draft

**Input**: User description: "Add a mandatory step to create a new branch (using either the speckit predefined schema or the numerical schema, e.g., 00x-[feature]-[description]) to the sdd workflow."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Branch is always created before spec artifacts (Priority: P1)

A developer starts a new feature by running the SDD cycle. Before any
specification, plan, or task artifacts are produced, the workflow creates and
switches to a new, correctly-named feature branch so that all subsequent work is
isolated from the main/integration branch.

**Why this priority**: This is the core of the feature. Without a guaranteed
branch, SDD artifacts and implementation commits can land on `main` (or an
unrelated branch), which is exactly the outcome the feature exists to prevent.
It is the minimum viable slice: on its own it delivers the isolation guarantee.

**Independent Test**: Start the SDD cycle from the `main` branch with a feature
description and confirm that, by the time the specify step produces `spec.md`,
the active git branch is a new feature branch whose name follows an accepted
schema — and that `main` has received no new commits.

**Acceptance Scenarios**:

1. **Given** a clean repository checked out on `main`, **When** a developer
   starts the SDD cycle with a feature description, **Then** a new feature
   branch is created and checked out before the specification artifact is
   written, and the spec artifact is committed on that branch, not on `main`.
2. **Given** the SDD cycle has started, **When** the branch-creation step
   completes, **Then** the branch name follows either the numerical schema
   (`NNN-<short-name>`, e.g. `002-sdd-branch-step`) or the timestamp schema
   configured for the project.

---

### User Story 2 - Branch step cannot be silently skipped (Priority: P1)

A developer (or an automated runner) proceeds through the SDD cycle in an
environment where optional hooks might be disabled or misconfigured. The
branch-creation step is mandatory: the workflow will not continue to
specification while still on a shared/integration branch, and the step's
required status is visible in the workflow definition and its documentation.

**Why this priority**: The user's request is specifically for a *mandatory*
step. A branch step that can be turned off or skipped fails the core intent, so
this shares P1 with Story 1.

**Independent Test**: Inspect the SDD workflow definition and its launcher
documentation and confirm the branch step is declared as required (not
optional), and that a run which cannot create a branch does not silently
proceed to produce artifacts on a non-feature branch.

**Acceptance Scenarios**:

1. **Given** the SDD workflow definition, **When** it is inspected, **Then** the
   branch-creation step is present and marked mandatory (non-optional), and the
   documented step order reflects it.
2. **Given** a run where branch creation cannot succeed (e.g., not a git
   repository), **When** the workflow reaches the branch step, **Then** the
   workflow surfaces a clear warning about the missing isolation rather than
   silently creating artifacts on a shared branch.

---

### User Story 3 - Consistent behavior between the workflow definition and the launcher (Priority: P2)

A developer runs the SDD cycle either through the declarative workflow
(`workflow.yml`) or through the in-session launcher command (`speckit-sdd-run`).
In both entry points the mandatory branch step happens at the same point in the
order and behaves the same way, so the documented `specify → plan → …` chain and
the actual behavior agree.

**Why this priority**: Two entry points describe the same cycle. If only one
gains the branch step, the artifacts disagree with behavior and users get
inconsistent results depending on how they start the cycle. Important, but the
isolation guarantee (P1) delivers value even before both paths are aligned.

**Independent Test**: Compare the step order documented in the workflow
definition, the launcher command, and any published step-order references, and
confirm all describe the mandatory branch step in the same position.

**Acceptance Scenarios**:

1. **Given** both the workflow definition and the launcher command, **When**
   their step orders are compared, **Then** both include the mandatory branch
   step in the same position relative to specify.
2. **Given** the project's governing documents describe the canonical cycle step
   order, **When** the branch step is added, **Then** those documents are updated
   to remain consistent with the workflow definition.

---

### Edge Cases

- **Already on a valid feature branch**: When the cycle starts while already on
  a correctly-named feature branch for the same feature, the step reuses that
  branch instead of creating a redundant one or erroring.
- **Branch name collision**: When a branch matching the generated name already
  exists, the numbering/naming resolves to the next available name rather than
  failing or overwriting.
- **Git unavailable / not a repository**: The step degrades gracefully with a
  clear warning and does not fabricate a false success, consistent with existing
  branch-creation behavior.
- **User-supplied branch name**: When the developer explicitly provides a branch
  name, that exact name is honored (bypassing schema generation) while the step
  remains mandatory.
- **Numbering source**: The numeric prefix is derived so that it does not
  collide with existing feature numbers, regardless of which existing artifacts
  are present.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The SDD workflow MUST include a branch-creation step that runs
  before the specification step, so that every feature's spec, plan, tasks, and
  implementation artifacts are produced on a dedicated feature branch.
- **FR-002**: The branch-creation step MUST be mandatory — it MUST NOT be
  declared optional or be configurable to a state where the cycle proceeds to
  specification on a shared/integration branch without warning.
- **FR-003**: The created branch name MUST follow an accepted schema: the
  numerical schema (`NNN-<short-name>`, e.g. `002-sdd-branch-step`) or the
  project-configured timestamp schema; when the user explicitly supplies a
  branch name, that name MUST be used verbatim.
- **FR-004**: The step MUST derive a branch number/prefix that does not collide
  with existing feature branches or feature directories.
- **FR-005**: When branch creation cannot be performed (git unavailable or not a
  repository), the step MUST surface a clear warning and MUST NOT report a false
  success, allowing callers to make an informed decision rather than silently
  producing artifacts on a shared branch.
- **FR-006**: When the cycle is already on a valid feature branch for the current
  feature, the step MUST reuse that branch rather than creating a duplicate.
- **FR-007**: The workflow definition (`workflow.yml`) and the in-session
  launcher command MUST both reflect the mandatory branch step in the same
  position in the step order.
- **FR-008**: The project's governing/step-order documentation MUST be updated to
  describe the canonical cycle including the mandatory branch step, so that
  manifests, launcher, and governance remain internally consistent.
- **FR-009**: The change MUST preserve the existing single pre-implementation
  human approval gate and the meaning and relative order of all existing steps
  (specify, plan, tasks, analyze, apply, gate, implement).

### Key Entities *(include if feature involves data)*

- **SDD Workflow Definition**: The declarative description of the cycle's ordered
  steps; gains a mandatory branch-creation step positioned before specify.
- **Feature Branch**: An isolated line of work named per an accepted schema
  (numerical or timestamp), on which all of a feature's SDD artifacts and
  implementation commits are produced.
- **Step-Order Documentation**: The governing and launcher documents that state
  the canonical cycle order; must remain consistent with the workflow definition.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In 100% of SDD cycle runs started from a shared/integration branch
  in a valid git repository, a correctly-named feature branch is active before
  the first specification artifact is written.
- **SC-002**: 100% of feature branches created by the step have names conforming
  to an accepted schema (numerical or timestamp, or an explicit user-supplied
  name).
- **SC-003**: Zero SDD artifacts (spec, plan, tasks) are committed to the
  shared/integration branch across cycle runs where a branch could be created.
- **SC-004**: Every entry point to the cycle (declarative workflow and in-session
  launcher) and every governing step-order document agree on the presence and
  position of the mandatory branch step — verifiable by inspection with zero
  discrepancies.
- **SC-005**: When git is unavailable, 100% of runs surface a warning rather than
  reporting a successful branch creation.

## Assumptions

- **Relationship to the existing git hook**: The project already creates a
  feature branch via the mandatory `before_specify` git hook
  (`speckit.git.feature`). This feature formalizes branch creation as a
  first-class, guaranteed part of the SDD cycle — reflected in the workflow
  definition, the launcher, and governance — so the guarantee does not depend on
  an extension hook remaining enabled. It reuses the existing branch-creation
  mechanism rather than introducing a second, competing one.
- **Naming schema selection**: The active schema (numerical vs. timestamp) is
  determined by existing project configuration (`feature_numbering` /
  `branch_numbering`), defaulting to sequential numerical when unset.
- **Graceful degradation**: "Mandatory" governs the workflow's intent to always
  isolate work; it does not require the impossible (creating a branch outside a
  git repository). In non-git contexts the step warns and continues, matching
  current behavior.
- **Behavior preservation**: Adding the branch step is a deliberate, explicit
  change to the cycle. All other step semantics, the step order among existing
  steps, and the single human gate are preserved.
- **Scope boundary**: This feature covers making the branch step mandatory and
  consistently documented within the SDD cycle; it does not redesign the branch
  naming scheme itself or the git extension's internal scripts beyond what is
  needed to guarantee the step.
