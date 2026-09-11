# Python Documentation Standard

This document defines the normative source-documentation standard for maintained
Python files in projects that adopt it.  The standard deliberately prefers
verbose, explanatory documentation.  Source brevity is not a goal when brevity
would force a future maintainer to infer intent, contracts, assumptions, failure
semantics, state ownership, portability constraints, security boundaries, or
architectural relationships from executable code alone.

This standard follows the same documentation philosophy used for maintained Bash
and AWK projects while adopting Python-native docstrings as the maintained source
of truth.  It is designed to work with Python documentation and linting tools,
including Pylint documentation checks, while remaining suitable for Doxygen-based
reference generation.

Python has a different documentation model from Bash and AWK.  Modules, classes,
functions, and methods expose runtime docstrings through `__doc__`; type
annotations can carry interface type information; exceptions are part of the
call contract; generators yield values rather than returning them conventionally;
and decorators, descriptors, context managers, asynchronous functions, and class
inheritance introduce Python-specific interface semantics.  This standard
therefore preserves the documentation philosophy of the other language standards
without mechanically copying their syntax.

Maintainers should not reduce source documentation merely to optimize package or
wheel size.  If a project strips docstrings, generates optimized artifacts, or
otherwise transforms maintained Python source for distribution, that distribution
policy is separate from the maintained source-documentation standard.

Prefer thorough, detailed, in-depth commentary over brevity.  The goal is for the
work to be accessible, readable, and maintainable while targeting developers with
basic Python competence.  Pay particular attention to assumptions and
preconditions.  Consider that the reader may be a human new to the project or an
AI/LLM operating with focused context that may not retain the complete project
history or the consequences of prior decisions.

## Precedence

Repository-specific requirements, accepted Architecture Decision Records (ADRs),
documented public interfaces, compatibility requirements, security requirements,
and project-specific Python standards take precedence over this general Python
documentation standard.

Do not perform unrelated documentation rewrites or refactoring solely to bring
existing code into compliance unless that work is part of the requested scope.

## Docstring Syntax

Maintained Python documentation must use Python docstrings rather than Doxygen
comment blocks as the primary source of API documentation.

Use triple double quotes for docstrings:

```python
"""Describe the documented object."""
```

For multi-line docstrings, use a one-line summary, a blank line, substantive
explanation, and a closing triple quote on its own line:

```python
def load_configuration(path: Path) -> Configuration:
    """Load and validate a configuration file.

    Explain why the operation exists, relevant preconditions, validation rules,
    side effects, failure semantics, and assumptions callers must preserve.
    """
```

Use raw triple-double-quoted docstrings when backslashes are intended literally
and would otherwise be interpreted by Python.

Docstrings should follow PEP 257 structural conventions unless repository-specific
policy establishes a stricter rule.

Documentation lines should normally remain within the project's configured line
length.  When no stricter project rule exists, prefer 80-character documentation
lines where practical.  Long URLs, literal values, generated identifiers, and
other unbreakable content may exceed that limit.

## Documentation Markup

This standard uses Sphinx/reStructuredText field syntax for structured function
and method contracts.

Use:

```text
:param name: description
:returns: description
:raises ExceptionType: description
:yields: description
```

When type annotations are present and authoritative, do not repeat the same type
information in `:type:` or `:rtype:` fields merely to satisfy documentation
formatting.  Type hints and prose serve different purposes: annotations express
the machine-readable type contract, while the docstring explains semantics,
units, accepted ranges, ownership, mutation, special values, and behavior that a
type alone cannot express.

When a maintained interface intentionally lacks type annotations and type
information is necessary for a linter or generated documentation, a project may
use fields such as:

```text
:type name: str
:rtype: Configuration
```

Do not maintain duplicate type declarations when one authoritative annotation is
sufficient.

## Relationship to Python Linters

The documentation format must remain consumable by the project's configured
Python linters.

At minimum, maintained public modules, classes, functions, and methods should have
docstrings.  Projects that enable stricter Pylint documentation extensions may
also require complete parameter, return, yield, and raised-exception
specification.

Documentation must agree with the executable signature.  Parameter names in
structured fields must match the actual parameter names.  Do not document
parameters that do not exist, omit meaningful public parameters, or preserve
stale names after a signature change.

When a linter reports disagreement between code and documentation, treat the
mismatch as a defect to investigate.  Do not automatically rewrite the docstring
to match the current implementation; the implementation may be the part that has
drifted from the intended contract.

## Relationship to Doxygen

Doxygen can extract Python docstrings directly.  Python docstrings remain the
maintained source of truth; projects must not maintain a second parallel Doxygen
comment block for the same object merely to satisfy Doxygen.

A baseline Doxygen integration may consume Python docstrings as ordinary Python
docstrings.  When a project requires structured Doxygen parameter, return,
yield, exception, or custom-section output, the preferred integration is a
source-preserving input filter that translates the maintained
Sphinx/reStructuredText fields into equivalent Doxygen commands for generated
reference documentation.

Conceptually, a filter may translate:

```text
:param path: Configuration file to read.
:returns: Validated configuration.
:raises ValueError: The file contains invalid configuration.
```

into a generated Doxygen representation equivalent to:

```text
@param path Configuration file to read.
@return Validated configuration.
@exception ValueError The file contains invalid configuration.
```

That generated representation is derivative.  It is not maintained source and
must not become an independent documentation authority.

Where practical, a Doxygen filter should preserve source line correspondence and
should translate only the documented structure it actually understands.  It
should not claim to be a complete Python parser or invent semantic certainty that
is absent from the source.

## Module Docstrings

Every maintained Python module should contain a module docstring near the start of
the file, after any required shebang or encoding declaration and before imports.

For example:

```python
"""Provide configuration loading and validation.

This module owns the boundary between external configuration files and the
validated application configuration model.  It documents accepted formats,
validation policy, security assumptions, and the errors callers should expect.
"""
```

A useful module docstring explains why the module exists, not merely which names
it exports.

When applicable, describe:

- the module's responsibility and architectural role;
- important public classes, functions, or protocols;
- global state owned by the module;
- initialization behavior and import-time side effects;
- persistence, filesystem, network, environment, or subprocess interactions;
- thread, process, or asynchronous concurrency assumptions;
- important compatibility or portability constraints;
- security boundaries; and
- relevant ADRs or governing specifications.

Avoid import-time behavior that is surprising merely because it has been
documented.  Documentation explains a contract; it does not justify unnecessary
side effects.

## Function and Method Docstrings

Maintained functions and methods must document their interface and non-obvious
behavior sufficiently for a caller to use them without reading the implementation.

A complete function docstring should use the following structure as applicable:

```python
def load_configuration(path: Path, *, strict: bool = True) -> Configuration:
    """Load and validate configuration from ``path``.

    Explain the contract, important preconditions, validation policy, side
    effects, external interactions, and why the function exists.

    :param path: Filesystem path containing the configuration document.
    :param strict: Whether unknown configuration keys are rejected.
    :returns: A validated configuration object owned by the caller.
    :raises FileNotFoundError: The requested path does not exist.
    :raises PermissionError: The configuration cannot be read.
    :raises ValueError: The document is syntactically or semantically invalid.
    """
```

Document parameters in signature order when practical.  Keyword-only parameters
must be documented as part of the public interface.  Positional-only semantics,
variadic arguments, and meaningful default behavior must be explained when they
affect callers.

### Parameters

Use one `:param name:` field for each meaningful documented parameter.

Do not document `self` or `cls` as ordinary caller-supplied parameters unless a
specific documentation tool or repository convention requires it.

For `*args` and `**kwargs`, document the accepted contents and semantics rather
than merely saying "additional arguments":

```text
:param args: Additional path fragments joined in order.
:param kwargs: Keyword options forwarded only to the configured transport.
```

If arbitrary keyword arguments are constrained to a known set, document that set
or link to the authoritative contract.

A parameter description should explain semantics that the annotation does not,
including as applicable:

- allowed values or ranges;
- units;
- sentinel meanings such as `None`;
- mutability and ownership;
- whether the object may be modified in place;
- whether iteration consumes the value;
- whether a callback may be retained;
- whether a path may be relative;
- encoding assumptions;
- ordering requirements; and
- security-sensitive interpretation.

### Return Values

Use `:returns:` when a function returns a meaningful value.

```text
:returns: A normalized repository identifier suitable for cache lookup.
```

Do not repeat only the annotated type.  Explain the meaning and ownership of the
returned value, relevant special cases, and whether the returned object aliases
input or internal state.

A function that intentionally returns `None` and exists for side effects may omit
`:returns:` when project linter configuration permits it.  When explicit return
documentation is required, state the contract clearly rather than pretending that
`None` is meaningful data.

If a function may return multiple semantic forms, document the conditions that
select them.  Prefer precise return types in annotations and avoid prose that hides
an unnecessarily ambiguous interface.

### Generators and Iterators

Functions that use `yield` should document yielded values with `:yields:` rather
than describing them as ordinary return values.

```python
def iter_records(path: Path) -> Iterator[Record]:
    """Yield validated records from ``path``.

    :param path: Input file containing newline-delimited records.
    :yields: Validated records in source order.
    :raises OSError: The input cannot be read.
    :raises ValueError: A record is malformed and strict parsing is enabled.
    """
```

Document whether iteration is lazy, whether the underlying resource remains open
between yields, whether iteration may produce side effects, whether partial
iteration is safe, and what cleanup occurs when iteration stops early.

For asynchronous generators, document cancellation and resource cleanup when
those semantics matter.

### Exceptions

Use one `:raises ExceptionType:` field for each exception that forms part of the
function's meaningful caller-visible contract.

```text
:raises ValueError: The supplied configuration violates validation rules.
:raises PermissionError: The requested file cannot be read.
```

Do not enumerate every implementation-level exception that could theoretically
escape.  Document exceptions callers are expected to understand, handle, or treat
as part of the stable interface.

If an exception from a dependency may intentionally propagate unchanged, describe
that behavior rather than inventing a new wrapper exception solely for
documentation consistency.

When a function translates one exception into another, document the caller-visible
exception and explain relevant context preservation when useful.

### Side Effects

Material side effects must be documented in the descriptive prose or in an
explicit section when the side effects deserve prominence.

Examples include:

- modifying a caller-supplied mutable object;
- changing module or process-global state;
- changing environment variables;
- writing files or persistent storage;
- creating or removing directories;
- performing network operations;
- invoking subprocesses;
- emitting logs, metrics, or audit records;
- acquiring locks;
- registering callbacks;
- caching data with process-lifetime effects; and
- modifying external resources.

A function that appears observational should not hide mutation merely because the
mutation is documented elsewhere.

## Class Docstrings

Every maintained public class must have a docstring that explains the abstraction
represented by the class, its responsibilities, important invariants, lifecycle,
and meaningful relationships with collaborators.

For example:

```python
class RepositoryCache:
    """Cache validated repository metadata.

    Instances own an in-memory mapping for one synchronization run.  The cache
    does not persist data across processes and is not safe for concurrent mutation
    without external synchronization.
    """
```

Class documentation should address as applicable:

- what concept the class represents;
- ownership of resources and mutable state;
- construction preconditions;
- lifecycle and cleanup requirements;
- thread, process, and async safety;
- equality, hashing, ordering, or identity semantics;
- public attributes or properties whose meaning is not self-evident;
- subclassing expectations and extension points; and
- important invariants.

Avoid documenting constructor parameters twice.  A project should choose one
maintained location for constructor parameter documentation when its linter checks
for duplicate constructor documentation.  Unless repository governance states
otherwise, document constructor-specific behavior in `__init__` and document the
class abstraction in the class docstring.

If `__init__` contains no behavior or contract beyond what the class docstring
already establishes and the project's linter configuration permits omission,
avoid duplicating prose solely to satisfy an imagined requirement.

## Properties and Descriptors

A property docstring should describe the semantic attribute exposed to callers,
including mutation or validation behavior when a setter exists.

```python
@property
def status(self) -> Status:
    """Return the current lifecycle status."""
```

Do not describe a property as a trivial getter when accessing it performs I/O,
expensive computation, caching, synchronization, or other meaningful side effects.

Descriptors should document binding, caching, mutation, and exception semantics
when those behaviors are not obvious from normal attribute access.

## Asynchronous Functions

Async function docstrings should document behavior that is materially different
from synchronous calls.

When applicable, identify:

- when work begins;
- whether cancellation is supported or deferred;
- what state remains after cancellation;
- timeout behavior;
- concurrency limits;
- ordering guarantees;
- synchronization primitives used at the interface boundary; and
- whether returned objects or callbacks are safe across event loops.

Do not describe an async function merely as "asynchronous" when the important
contract is resource ownership, cancellation, or concurrency behavior.

## Context Managers

Context managers should document resource acquisition, what becomes valid inside
the context, cleanup behavior, and exception handling.

For example:

```python
@contextmanager
def locked_repository(path: Path) -> Iterator[Repository]:
    """Yield a repository while holding its process lock.

    :param path: Repository root whose lock is acquired.
    :yields: Repository access valid while the lock is held.
    :raises TimeoutError: The lock cannot be acquired within the configured time.
    """
```

Document whether cleanup occurs when the body raises, whether exceptions are
suppressed, and whether the yielded value remains valid after context exit.

## Decorators

A decorator should document how it changes the wrapped callable's behavior and
interface.

Document as applicable:

- whether the wrapper preserves the original signature and metadata;
- added retry, caching, authorization, logging, or synchronization behavior;
- newly raised exceptions;
- altered return values;
- ordering requirements relative to other decorators; and
- whether decoration occurs at import time with side effects.

Use `functools.wraps` where appropriate, but do not rely on metadata preservation
to communicate semantic changes that callers need to know.

## Variables, Constants, and Attributes

Python type annotations and meaningful names often make local variables
self-documenting.  Do not add docstrings or comments to every local value merely
to increase documentation volume.

Document module-level constants, configuration values, registries, public class
attributes, security-sensitive state, caches, and other values whose meaning,
ownership, lifecycle, units, mutability, or compatibility role is not
self-evident.

Attribute docstrings may be used when supported by the project's documentation
tooling.  Ordinary comments are appropriate for local implementation intent that
is not part of generated API documentation.

## Type Annotations and Documentation

Type annotations are part of the interface but do not replace documentation.

Prefer annotations for machine-readable structure:

```python
def parse_manifest(path: Path) -> list[Dependency]:
```

and docstrings for semantic meaning:

```text
:param path: Manifest file interpreted relative to the physical project root.
:returns: Dependencies in manifest order after complete validation.
```

Document behavior that types cannot express reliably, including ordering,
ownership, normalization, validation, aliasing, security interpretation, and
failure semantics.

Do not contradict annotations in prose.  If the type contract and documented
behavior disagree, resolve the inconsistency rather than choosing whichever form
is more convenient for a tool.

## Security-Sensitive Documentation

For parsing, validation, authentication, authorization, redaction, persistence,
subprocess, filesystem, network, serialization, and output code, documentation
should make it possible for a reviewer to determine:

- what untrusted or sensitive data enters the interface;
- whether values are interpreted as text, paths, regular expressions, templates,
  shell arguments, SQL, URLs, or serialized objects;
- what validation or normalization occurs and when;
- whether original sensitive input may reach logs, exceptions, or output;
- what external systems or privilege boundaries are crossed;
- what happens on partial failure;
- whether retries can duplicate side effects;
- whether mutable state retains sensitive data after the call;
- whether concurrency affects the security guarantee; and
- which ADR establishes the relevant security promise when applicable.

Do not describe ordinary Python objects as secure memory, private storage, or
isolated state unless a real mechanism supports that claim.

## Internal Helpers

Private naming conventions such as a leading underscore communicate intended API
visibility; they are not a reason to omit documentation from complex,
security-sensitive, stateful, or semantically important helpers.

Document internal functions and methods when their contract, assumptions, side
effects, failure behavior, architectural purpose, or interaction with shared state
would otherwise need to be rediscovered from implementation.

Trivial helpers may use concise docstrings when their complete contract is obvious
from a short summary and signature.

## Document Intent, Not Syntax

Avoid comments such as:

```python
# Increment the counter.
count += 1
```

Prefer documentation that explains why the counter exists, what invariant it
represents, why the update occurs at that point, or why a seemingly unusual
implementation is necessary.

Docstrings describe caller-visible and maintainer-relevant contracts.  Ordinary
comments explain local implementation intent that does not belong in the public or
structural documentation.

## Relationship to ADRs

Docstrings own implementation-level and interface-level intent.  ADRs own durable
architectural reasoning, promises, non-promises, compatibility and portability
decisions, adversary or failure models, rejected alternatives, and accepted
tradeoffs.

Source documentation may link to an ADR when a local implementation exists
specifically to satisfy an architectural constraint.

Do not copy an entire ADR into a docstring.  Do not invent historical rationale
when no source supports it.  State uncertainty or add an ADR when a new
consequential decision is required.

A project's `doc/decisions.md`, when present, provides concise ADR summaries and
does not replace either the full ADR or local documentation contract.

## Generated Reference Documentation

Generated Doxygen output is derivative and is not a maintained source of truth.
The maintained Python source, its docstrings, type annotations, and governing
repository documentation remain authoritative.

A Doxygen integration may transform Sphinx/reStructuredText fields into Doxygen
commands for presentation and indexing.  Such transformation must preserve the
meaning of the maintained docstring and must not silently invent missing
parameters, return values, exceptions, types, or guarantees.

Projects should test the generated documentation path when changes affect the
filter, Doxygen configuration, or supported docstring vocabulary.

## Recommended Doxygen Integration

For direct extraction without translation, Doxygen can consume standard Python
docstrings.  Projects that need Doxygen special-command semantics should use a
configured translation filter rather than embedding duplicate `@param` and
`:param:` declarations in maintained source.

The maintained-source rule is:

```text
Python docstring -> optional translation filter -> Doxygen representation
```

not:

```text
Python docstring + duplicate Doxygen comment block
```

This preserves one documentation authority while supporting both Python-native
linters and Doxygen output.

## Recommended Linter Posture

Projects adopting this standard should enable documentation checks that are
consistent with their supported Python versions and tooling stack.

When Pylint is used, projects should consider enabling its docstring and parameter
documentation checks, including checks for missing module, class, and function
docstrings and, where appropriate, the `pylint.extensions.docparams` and
`pylint.extensions.docstyle` extensions.

The project configuration remains authoritative for exactly which checks are
enabled.  This standard does not require a particular Pylint version or require a
repository to adopt every optional documentation warning.

Projects may additionally use pydocstyle, Ruff documentation rules, or other
linters.  Those tools should enforce the same maintained docstring contract rather
than establishing competing documentation syntaxes.

## General Module Structure Pattern

A maintained Python module should generally follow this order where applicable:

1. optional governed shebang;
2. optional encoding declaration when actually required;
3. module docstring;
4. `from __future__` imports;
5. imports;
6. module constants and significant documented state;
7. classes;
8. functions; and
9. executable entry-point logic guarded by `if __name__ == "__main__":` when
   appropriate.

Execution or framework requirements may justify another ordering.  Preserve
correctness and repository governance rather than reordering mechanically.

## General Function Docstring Structure Pattern

A maintained non-trivial function or method should generally use:

1. one-line imperative summary;
2. blank line;
3. substantive description of purpose, behavior, assumptions, and side effects;
4. blank line;
5. zero or more `:param name:` fields in signature order;
6. `:returns:` when a meaningful value is returned;
7. `:yields:` when the function is a generator;
8. zero or more `:raises ExceptionType:` fields for caller-visible exception
   contracts; and
9. examples or notes when they materially improve understanding.

Do not add empty sections or placeholder fields merely to satisfy a visual
template.

## Examples

A public or non-trivial interface should include an example when an example
materially improves understanding.

Examples may use Python's doctest-style prompts when executable examples are
useful:

```python
def normalize_name(value: str) -> str:
    """Normalize a repository name.

    :param value: Repository name supplied by a user or external system.
    :returns: Lowercase normalized name with surrounding whitespace removed.

    Example::

        >>> normalize_name(" Example ")
        'example'
    """
```

Do not manufacture a second test suite inside docstrings.  Examples illustrate
the contract; executable tests remain responsible for comprehensive behavioral
verification.

## Review Standard

Review documentation with the same seriousness as executable code.  Ask whether
a maintainer unfamiliar with the implementation could understand:

- the responsibility of each module and class;
- the contract of each public function and method;
- important parameter semantics and default behavior;
- return and yield semantics;
- caller-visible exceptions;
- meaningful side effects and resource ownership;
- mutation and aliasing behavior;
- concurrency, cancellation, or lifecycle requirements;
- meaningful edge cases and failure modes;
- security-sensitive state and output boundaries;
- why non-obvious implementation choices exist;
- which architectural decisions constrain future changes; and
- what the implementation explicitly does not guarantee.

There is no target docstring-to-code ratio.  The desired amount is "enough to
preserve the reasoning."  In infrastructure, security, parsing, and automation
code, this may mean considerably more prose than teams accustomed to terse Python
docstrings expect, and that is intentional.

## Structural Checklist

Before considering a maintained Python module adequately documented, verify as
applicable:

- the module contains a meaningful module docstring;
- public classes have meaningful class docstrings;
- public functions and methods have docstrings;
- complex, security-sensitive, or semantically important private helpers are also
  documented;
- docstrings use triple double quotes;
- multi-line docstrings have a summary line followed by a blank line;
- parameter names in documentation match the executable signature;
- meaningful public parameters are documented with `:param name:`;
- type annotations and prose do not contradict one another;
- meaningful return values use `:returns:`;
- generators document yielded values with `:yields:`;
- caller-visible exceptions use `:raises ExceptionType:`;
- mutation, resource ownership, and material side effects are documented;
- async, context-manager, decorator, and descriptor semantics are documented when
  material;
- examples are present when they materially improve understanding;
- documentation remains compatible with the repository's configured linters;
- Doxygen output is generated from the maintained docstrings rather than a second
  duplicate documentation authority; and
- security-sensitive code documents assumptions a future reviewer would otherwise
  have to infer.
