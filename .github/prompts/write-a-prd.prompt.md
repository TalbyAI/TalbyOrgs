---
description: "Create a PRD through user interview, codebase exploration, and module design"
name: "Write a PRD"
argument-hint: "Problem to solve, proposed solution, constraints, and desired outcome"
agent: "agent"
---

Create a product requirements document for the feature or problem described below.

Execution rules:
- Start by extracting the core problem, intended users, constraints, and any proposed solution ideas from the input.
- If important information is missing, interview me relentlessly until the problem, scope, and tradeoffs are clear.
- Explore the repo to verify assumptions and understand the current architecture before locking implementation decisions.
- Walk meaningful branches of the design tree and resolve dependencies one by one.
- Sketch the major modules or subsystems that will be built or modified.
- Prefer deep modules with simple, testable interfaces that encapsulate complexity.
- Check your design assumptions against the existing codebase instead of guessing.
- If something is still ambiguous after repo exploration, ask focused follow-up questions.

Output requirements:
- Produce the PRD in Markdown.
- Be concrete and specific.
- Do not include file paths or code snippets in implementation decisions.
- Make the user stories extensive and cover the full feature surface.
- For testing decisions, focus on testing external behavior rather than implementation details.

Use this template:

## Problem Statement

Describe the problem from the user's perspective.

## Solution

Describe the proposed solution from the user's perspective.

## User Stories

Write a long, numbered list of user stories in this format:

1. As a <actor>, I want a <feature>, so that <benefit>

## Implementation Decisions

List the implementation decisions that were made. Include things like:
- Modules or subsystems to build or modify
- Interface changes
- Technical clarifications
- Architectural decisions
- Schema changes
- API contracts
- Important interaction details

## Testing Decisions

List the testing decisions that were made. Include:
- What makes a good test for this feature
- Which modules or behaviors should be tested
- Relevant prior art or similar test patterns in the codebase

## Out of Scope

Describe what is intentionally excluded.

## Further Notes

Add any remaining notes, assumptions, risks, or follow-up items.

Feature request or problem statement:

{{input}}