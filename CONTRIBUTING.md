# Contributing Guidelines

Contributions are welcome via GitHub pull requests.


## Use Semantic Commits

We use [semantic commits](https://www.conventionalcommits.org/en/v1.0.0/) to help us automatically generate changelogs and release notes.

__The name of your PR must be a semantic commit message__, with one of the following prefixes:

- `fix:` (bug fixes)
- `feat:` (new features)
- `improve:` (improvements to existing features)
- `refactor:` (code changes that neither fixes a bug nor adds a feature)
- `revert:` (reverts a previous commit)
- `test:` (adding missing tests, refactoring tests; no production code change)
- `ci:` (changes to CI configuration or build scripts)
- `docs:` (documentation only changes)
- `chore:` (ignored in changelog)

To indicate a breaking change, add `!` after the prefix, e.g. `feat!: my commit message`.

Please do NOT include a scope, as we do not use them, for example `feat(deploy): my commit message`.

## Sign Your Work

To certify you agree to the [Developer Certificate of Origin](https://developercertificate.org/) you must sign-off each commit message using `git commit --signoff`, or manually write the following:
```text
This is my commit message

Signed-off-by: John Smith <john-smith@users.noreply.github.com>
```

The text of the agreement is:
```text
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
1 Letterman Drive
Suite D4700
San Francisco, CA, 94129

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```
