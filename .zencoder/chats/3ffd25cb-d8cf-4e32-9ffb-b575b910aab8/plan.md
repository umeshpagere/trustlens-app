# Spec and build

## Agent Instructions

Ask the user questions when anything is unclear or needs their input. This includes:

- Ambiguous or incomplete requirements
- Technical decisions that affect architecture or user experience
- Trade-offs that require business context

Do not make assumptions on important decisions — get clarification first.

---

## Workflow Steps

### [x] Step: Technical Specification

Assess the task's difficulty, as underestimating it leads to poor outcomes.

- easy: Straightforward implementation, trivial bug fix or feature
- medium: Moderate complexity, some edge cases or caveats to consider
- hard: Complex logic, many caveats, architectural considerations, or high-risk changes

Create a technical specification for the task that is appropriate for the complexity level:

- Review the existing codebase architecture and identify reusable components.
- Define the implementation approach based on established patterns in the project.
- Identify all source code files that will be created or modified.
- Define any necessary data model, API, or interface changes.
- Describe verification steps using the project's test and lint commands.

Save the output to `/Users/umeshpagere/orchids-projects/trustlens-mobile app/.zencoder/chats/3ffd25cb-d8cf-4e32-9ffb-b575b910aab8/spec.md` with:

- Technical context (language, dependencies)
- Implementation approach
- Source code structure changes
- Data model / API / interface changes
- Verification approach

If the task is complex enough, create a detailed implementation plan based on `/Users/umeshpagere/orchids-projects/trustlens-mobile app/.zencoder/chats/3ffd25cb-d8cf-4e32-9ffb-b575b910aab8/spec.md`:

- Break down the work into concrete tasks (incrementable, testable milestones)
- Each task should reference relevant contracts and include verification steps
- Replace the Implementation step below with the planned tasks

Rule of thumb for step size: each step should represent a coherent unit of work (e.g., implement a component, add an API endpoint, write tests for a module). Avoid steps that are too granular (single function).

Save to `/Users/umeshpagere/orchids-projects/trustlens-mobile app/.zencoder/chats/3ffd25cb-d8cf-4e32-9ffb-b575b910aab8/plan.md`. If the feature is trivial and doesn't warrant this breakdown, keep the Implementation step below as is.

---

### [x] Step: Cleanup

- [x] Remove `extension/` directory.
- [x] Remove other extension-specific files (e.g., `public/` if unused by the mobile app's backend).

---

### [ ] Step: Implementation

#### 1. Native Configuration Polish
- [x] Add URL Scheme to `ios/Runner/Info.plist` for `receive_sharing_intent`.
- [x] Verify `android/app/src/main/AndroidManifest.xml` intent filters.
- [x] Ensure `ios/Runner/AppDelegate.swift` is correctly set up for URL handling if needed.

#### 2. Service & Model Verification
- [x] Verify `ApiService` handles timeouts and errors gracefully.
- [x] Ensure `AnalysisResponse` model correctly parses all backend fields.

#### 3. UI/UX Refinement
- [x] Refine `AnalysisScreen` bottom-sheet behavior (prevent accidental dismiss, handle large text).
- [x] Polish `DetailedAnalysisScreen` layout for smaller devices.
- [x] Ensure colors and styles match the browser extension's design language.

#### 4. Verification & Testing
- [x] Run `flutter analyze` to check for issues.
- [ ] (Manual) Test sharing text from browser/X/Instagram.
- [ ] (Manual) Test sharing image URLs from browser.

---

### [x] Step: Final Report
Write a report describing the implementation and testing.
