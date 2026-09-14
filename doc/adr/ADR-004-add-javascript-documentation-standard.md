# ADR-004: Add a JavaScript Documentation Standard Based on JSDoc

## Status

Accepted

## Context

The standards library already defines language-specific documentation contracts for AWK, Bash, PHP, and Python.  The new `javascript-doxygen` project needs an authoritative maintained-source contract before it can translate JSDoc syntax into a Doxygen-facing representation.

JavaScript already has a native documentation convention in JSDoc.  Using JSDoc as the maintained source format preserves compatibility with JavaScript-native tooling and avoids requiring a second Doxygen-specific comment dialect.

The source-documentation contract and the filter implementation also need separate boundaries.  The shared standard should define valid maintained JavaScript documentation.  The `javascript-doxygen` repository should separately govern which subset it translates, the representation it emits, and the executable evidence supporting those claims.

The first planned filter behavior is the canonical required parameter form:

```text
@param {Type} name - Description.
```

## Decision

The standards library will add `standards/javascript/documentation-standard.md` and use JSDoc comments as the maintained source of truth for projects that adopt it.

The standard defines the canonical required parameter form as:

```text
@param {Type} name - Description.
```

It also documents normal JSDoc forms for optional and defaulted parameters, returns, throws, yields, reusable types, callbacks, properties, classes, modules, and related documentation concerns.  A valid source construct does not automatically become a supported `javascript-doxygen` translation.

`javascript-doxygen` is the designated Doxygen input-filter project for JavaScript when translation is required.  That repository governs its implemented translation subset, generated representation, recognition boundary, diagnostics, portability, tests, and release artifacts.

The standards library will also add the non-normative example `standards/examples/javascript/documentation/example.js`.

TypeScript and TSDoc are outside this decision and may receive a separate standard later.

## Alternatives Considered

Writing Doxygen-native comments directly in maintained JavaScript was rejected because documentation-generation tooling should not dictate the source dialect.

Limiting the shared standard to the filter's first implemented subset was rejected because the source standard should describe valid JavaScript documentation independently of the filter's current maturity.

Combining JavaScript and TypeScript into one standard was rejected because their documentation ecosystems and source-language semantics differ.

## Consequences

Projects adopting the standard gain one JavaScript-native documentation contract based on JSDoc.  `javascript-doxygen` can grow incrementally while remaining precise about which standard-conforming forms it actually translates.

The first filter increment has an explicit source contract:

```text
@param {Type} name - Description.
```

Future filter work can add optional parameters, returns, throws, yields, typedefs, callbacks, properties, modules, inline tags, and other constructs one tested behavior at a time.

## Compatibility and Migration

Existing repositories are unaffected until they adopt a release containing the JavaScript standard.  Consumers receive it through the complete release archive governed by ADR-003.  Presence in the archive does not make the JavaScript standard applicable to repositories that do not maintain JavaScript.

## Expected Outcome

A coding-standards release contains a normative JavaScript documentation standard and representative example.  JavaScript repositories can adopt that release, and `javascript-doxygen` can implement JSDoc translation against an explicit source contract.

## Related Decisions

- ADR-003 governs release artifacts and consumer adoption.
