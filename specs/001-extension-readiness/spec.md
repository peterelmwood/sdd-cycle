# Feature Specification: Extension Readiness

**Feature Branch**: `001-extension-readiness`

**Created**: 2026-06-30

**Status**: Draft

**Input**: User description: "Get this repository to be maximally ready for use as a spec-kit extension (github/spec-kit)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Install and run the SDD cycle on a fresh project (Priority: P1)

A developer who already uses Spec Kit wants to add this project's SDD cycle to
their own repository. They follow the documented install steps once, then launch
the cycle and drive a feature from `specify` through the pre-implement gate
without hitting an error, a missing file, or a step that behaves differently
from what the documentation promised.

**Why this priority**: The entire purpose of packaging this repository as a Spec
Kit extension is that other people can install and use it. If the first-run
install-and-launch experience is broken or contradicts the docs, nothing else
matters.

**Independent Test**: From a clean checkout of a separate Spec Kit project,
follow only the README install instructions, then invoke the launcher. Success =
the workflow/extension registers, the launcher starts, and the chain reaches the
approval gate.

**Acceptance Scenarios**:

1. **Given** a Spec Kit project on a supported version, **When** the user runs
   the documented workflow-install command against this repository, **Then** the
   `sdd` workflow appears in `specify workflow list` and its step graph matches
   the documented order.
2. **Given** the workflow and launcher are installed, **When** the user invokes
   the launcher with a feature description, **Then** the cycle runs
   `specify → plan → tasks → analyze → apply` and stops at exactly one approval
   gate before `implement`.
3. **Given** the user follows the README verbatim, **When** they reach the end of
   the install section, **Then** every command shown succeeds and no documented
   step references a file or path that does not exist in the repository.

---

### User Story 2 - Trust the manifests and versions (Priority: P2)

A user or automated tool inspects the bundle before installing it. Every manifest
(`bundle.yml`, `extension.yml`, `workflow.yml`, `extensions.yml`) declares
metadata that is internally consistent — the versions a component advertises match
the versions the bundle claims it provides, required Spec Kit versions agree, and
identifiers line up — so the install is predictable and nothing silently drifts.

**Why this priority**: Inconsistent version or requirement metadata causes
confusing installs, wrong-version resolution, and erodes trust in the bundle even
when the underlying commands work.

**Independent Test**: Read each manifest and cross-check declared versions, IDs,
and `speckit_version` requirements against one another. Success = no
contradictions.

**Acceptance Scenarios**:

1. **Given** the bundle manifest lists the components it provides, **When** the
   version each component declares in its own manifest is compared to the version
   the bundle pins, **Then** they are identical for every component.
2. **Given** each manifest declares a required Spec Kit version, **When** the
   requirements are compared, **Then** they are mutually compatible and stated
   consistently.
3. **Given** a reader opens the project constitution, **When** they read it,
   **Then** it contains real project principles rather than unfilled template
   placeholders.

---

### User Story 3 - Validate the bundle before publishing (Priority: P3)

A maintainer preparing a release wants confidence that the bundle is correct
before tagging it. They run a single repeatable check that verifies the manifests
parse, the referenced files exist, versions are consistent, and the bundle builds
into a distributable artifact — catching regressions before users ever see them.

**Why this priority**: Sustained readiness requires a guardrail that keeps the
repository installable over time; without it, correctness achieved once decays as
the files change.

**Independent Test**: Run the repeatable validation check on a clean checkout.
Success = it reports pass on a correct bundle and fails loudly when a manifest,
reference, or version is broken.

**Acceptance Scenarios**:

1. **Given** a correct bundle, **When** the validation check runs, **Then** it
   completes successfully and reports what it verified.
2. **Given** a manifest is edited to reference a missing file or an inconsistent
   version, **When** the validation check runs, **Then** it fails and identifies
   the specific problem.
3. **Given** a maintainer wants a distributable artifact, **When** they run the
   documented build step, **Then** a versioned bundle archive is produced.

---

### Edge Cases

- What happens when a user installs on a Spec Kit version older than the declared
  minimum? The requirement should be stated so the mismatch is visible rather than
  failing obscurely.
- What happens on the Claude integration, where the extension's command is not
  user-invocable? The documentation must steer the user to the working launcher
  path so they are not stuck.
- What happens when only the workflow (not the launcher) is installed, or vice
  versa? The docs should make the two install artifacts and their roles distinct.
- How does the validation check behave when a referenced script is present for one
  shell (PowerShell) but expected for another (Bash)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST provide install instructions that, followed
  verbatim on a supported Spec Kit project, result in a registered `sdd` workflow
  and a usable launcher.
- **FR-002**: Every documented install/usage command MUST reference only files
  and paths that actually exist in the repository.
- **FR-003**: The version each component declares MUST match the version the
  bundle manifest pins for that component.
- **FR-004**: The required Spec Kit version MUST be declared consistently across
  all manifests that state it.
- **FR-005**: The project constitution MUST contain real, project-specific
  principles and governance rather than unfilled template placeholders.
- **FR-006**: The repository MUST provide a single repeatable validation check
  that verifies manifests parse, referenced files exist, and declared versions are
  internally consistent.
- **FR-007**: The validation check MUST fail with an identifying message when a
  manifest is malformed, a referenced file is missing, or a version is
  inconsistent.
- **FR-008**: The documentation MUST clearly distinguish the two launcher delivery
  paths (Claude Code slash command vs. Spec Kit extension) and state which is the
  reliable path for each integration.
- **FR-009**: The repository MUST document how to produce a distributable bundle
  artifact and MUST state plainly which distribution paths are and are not
  supported (e.g., raw-URL extension install, catalog-based bundle install).
- **FR-010**: Known limitations and their workarounds (e.g., extension command not
  user-invocable on Claude, no published archive) MUST be documented so users are
  never left without a working path.
- **FR-011**: The repository MUST include the metadata files expected of a
  publishable open-source component (at minimum a license and contribution/change
  guidance) sufficient for a stranger to adopt and contribute to it.

### Key Entities *(include if data involved)*

- **Bundle manifest**: Declares the bundle identity and the set of components
  (extension, workflow) it provides, each pinned to a version.
- **Extension manifest**: Declares the launcher extension's identity, version,
  required Spec Kit version, and the command it provides.
- **Workflow manifest**: Declares the `sdd` step graph, inputs, version, and
  integration requirements.
- **Extensions registry (`extensions.yml`)**: Declares installed extensions and
  the lifecycle hooks that fire around each Spec Kit command.
- **Constitution**: The project's governing principles used by the SDD cycle.
- **Validation check**: The repeatable procedure that asserts the above artifacts
  are consistent and installable.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new user can go from a clean Spec Kit project to a running SDD
  cycle by following only the documented steps, with zero failed commands.
- **SC-002**: 100% of documented commands reference paths that exist in the
  repository.
- **SC-003**: 100% of component versions declared in individual manifests match
  the versions pinned in the bundle manifest.
- **SC-004**: The constitution contains zero unfilled template placeholders.
- **SC-005**: The validation check passes on the current repository and fails on
  an intentionally broken manifest, in under one minute, without manual
  interpretation.
- **SC-006**: A maintainer can produce a versioned distributable artifact in a
  single documented step.

## Assumptions

- "Maximally ready as a spec-kit extension" scopes to making the **existing
  local-clone install path** correct, consistent, documented, and validated — plus
  enabling the build of a distributable artifact. Publishing to an external
  public catalog or hosting a downloadable archive is out of scope for this
  feature (the repository states these are unsupported today).
- Claude is the primary, fully-exercised integration. Other integrations named in
  the workflow (copilot, gemini, opencode) are supported on a best-effort basis
  and documented as such; this feature does not require live verification on each.
- The declared minimum Spec Kit version (`>=0.8.5`) remains the intended floor
  unless a concrete incompatibility is found; the installed toolchain (0.12.2) is
  the reference for verifying commands.
- The validation check targets the shell already used by this project
  (PowerShell, per `init-options.json`), and any cross-shell parity is documented
  rather than fully implemented.
- No change to the SDD cycle's behavior (its steps, gate, or semantics) is
  required by this feature; the work is packaging, correctness, documentation,
  governance, and validation.
