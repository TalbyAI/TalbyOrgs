---
description: "Extract a DDD-style ubiquitous language glossary from the current conversation, flag ambiguities, and save it to UBIQUITOUS_LANGUAGE.md"
name: "Ubiquitous Language"
argument-hint: "Optional extra domain context, scope, or terminology constraints"
agent: "agent"
---

Extract and formalize domain terminology from the current conversation into a consistent glossary, saved to a local file.

If additional context is provided below, use it to refine the glossary, but treat the conversation as the primary source of truth.

Process:
- Scan the conversation for domain-relevant nouns, verbs, and concepts.
- Identify terminology problems:
  - The same word used for different concepts.
  - Different words used for the same concept.
  - Vague or overloaded terms.
- Propose a canonical glossary with opinionated term choices.
- Write or update `UBIQUITOUS_LANGUAGE.md` in the working directory using the format below.
- Output a concise summary in the conversation after updating the file.

If `UBIQUITOUS_LANGUAGE.md` already exists, read it first and then:
- Incorporate any new terms from the current discussion.
- Update definitions if understanding has evolved.
- Re-flag ambiguities where needed.
- Rewrite the example dialogue so it reflects the latest terminology.

Rules:
- Be opinionated. When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- Flag conflicts explicitly in a `Flagged ambiguities` section with a clear recommendation.
- Only include terms relevant for domain experts. Skip module, class, or implementation names unless they matter in the domain language.
- Keep each definition to one sentence that defines what the term is.
- Show relationships using bold term names and cardinality where obvious.
- Skip generic programming concepts unless they have domain-specific meaning.
- Group terms into multiple tables only when natural clusters emerge. Otherwise keep a single table.
- Write a short example dialogue between a developer and a domain expert that demonstrates precise use of the terms.

Write `UBIQUITOUS_LANGUAGE.md` with this structure:

```md
# Ubiquitous Language

## <Group name>

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Example Term** | A tight, one-sentence definition. | Synonym 1, Synonym 2 |

## Relationships

- A **Term** belongs to exactly one **Other Term**
- A **Term** produces one or more **Another Term**

## Example dialogue

> **Dev:** "Question using the canonical terms precisely?"
> **Domain expert:** "Answer using the same canonical terms precisely."
> **Dev:** "Follow-up that clarifies a boundary between related terms?"
> **Domain expert:** "Answer that resolves the ambiguity clearly."

## Flagged ambiguities

- "Ambiguous word" was used to mean both **Term A** and **Term B**. Use **Term A** for one concept and **Term B** for the other.
```

Additional context:

{{input}}