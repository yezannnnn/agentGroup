# Plan Sprints from a given Milestone. Execute from Top to Bottom

Follow these instructions to sprint the scope of a Milestone into Sprints

## Create a TODO with EXACTLY these 8 items

1. Analyze current milestone state
2. Assess completed work vs milestone requirements
3. Identify remaining work and dependencies
4. Design logical sprint boundaries
5. Create sprint directories and meta files
6. Update PROJECT_MANIFEST with sprint roadmap
7. Validate sprint coherence and dependencies
8. Report milestone plan

---

## 1 · Analyze current milestone state

**CRITICAL:** You are given additional Arguments: <$ARGUMENTS>

**USE PARALLEL SUBAGENTS** to do these tasks:

- Parse arguments for milestone ID (defaults to current milestone from PROJECT_MANIFEST)
- Read `.simone/00_PROJECT_MANIFEST.md` to understand current progress
- Scan `.simone/03_SPRINTS/` to identify existing sprints for the target milestone
- For each existing sprint, read its sprint meta file to determine status from YAML frontmatter
- Analyze the Tasks in Sprints to understand that work that has been done (from Subtasks)

## 2 · Assess completed work vs milestone requirements

- Read milestone meta file from `.simone/02_REQUIREMENTS/$MILESTONE_ID/`
- **CRITICAL:** Follow and read ALL linked documents in the milestone meta:
  - Product Requirements (PRD.md)
  - Database Specifications (SPECS_DB.md)
  - API Specifications (SPECS_API.md)
  - Tool Specifications (SPECS_TOOLS.md)
  - Any other linked specifications
- Study the milestone's Definition of Done (DoD) carefully and **think deeply** about what each DoD criterion actually requires in terms of specific deliverables
- For each existing sprint, analyze what deliverables have been completed by reading sprint meta and task files
- **Think more carefully** about the gap analysis: map each completed deliverable against specific DoD requirements and identify what's genuinely missing vs what might already be covered
- Create clear picture: "What's done vs what's required for milestone completion" with specific justification for each gap identified

## 3 · Identify remaining work and dependencies

- Based on gap analysis, identify remaining deliverables for milestone completion
- Group related deliverables that have natural dependencies
- **CRITICAL:** Each deliverable group should be:
  - **Independently valuable** (shippable increment)
  - **Completable in ~1 week** by one person
  - **Has clear validation criteria**
- Consider technical dependencies (e.g., auth before UI, LLM integration before tools)

## 4 · Design logical sprint boundaries

- Design sprint structure to complete the milestone
- Each sprint should have:
  - **Clear focus**: One main deliverable theme
  - **Natural boundaries**: Minimal dependencies between sprints
  - **Incremental value**: Each sprint advances toward milestone DoD
- Sprint naming: `S<nn>_$milestone_id_$focus_slug`
- **IMPORTANT:** Don't create sprints for work that's already completed

## 5 · Create sprint directories and meta files

- For each planned sprint that doesn't exist:
  - Create directory `.simone/03_SPRINTS/$FULL_SPRINT_NAME/` (using complete sprint name like "S02_M01_LLM_Integration")
  - Use template from `.simone/99_TEMPLATES/sprint_meta_template.md`
  - Fill in sprint meta with:
    - High-level goal and scope
    - Key deliverables (bullet points, not detailed tasks)
    - Clear Definition of Done for the sprint
    - Status: "planned"

## 6 · Update PROJECT_MANIFEST with sprint roadmap

- Update `.simone/00_PROJECT_MANIFEST.md`:
  - Set `highest_sprint_in_milestone` to the highest planned sprint
  - Update sprint summary section with overview of remaining sprints
  - Mark completed sprints as ✅ COMPLETED
  - Show planned sprints with their focus areas
  - Update `last_updated` timestamp

## 7 · Validate sprint coherence and dependencies

- Review the planned sprint sequence for logical flow
- Ensure each sprint builds naturally on previous work
- Verify no sprint has impossible dependencies
- Check that sprint sequence leads to milestone DoD completion
- **Think about** whether each sprint is independently testable and valuable

## 8 · Report milestone plan

Provide comprehensive summary:

**Milestone Status:**

- Target milestone: $milestone_id
- Sprints completed: $count
- Sprints planned: $count
- Estimated completion: $sprint_sequence

**Sprint Roadmap:**

For each sprint (existing and planned):

- **$Sprint_ID**: $status - $focus_description
- Key deliverables: $bullet_list
- Dependencies: $if_any

**Next Steps:**

- Immediate next sprint to detail: $sprint_id

**Validation:**

Summarize your validation analysis covering:

- All milestone DoD items are covered by sprint plan
- Sprint dependencies are logical and minimal
- Each sprint delivers independent value
