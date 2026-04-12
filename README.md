# TalbyOrgs

![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/talbyai/TalbyOrgs?utm_source=oss&utm_medium=github&utm_campaign=talbyai%2FTalbyOrgs&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)

## Build Conventions

Shared MSBuild defaults live in `Directory.Build.props`, and shared NuGet package versions live in `Directory.Packages.props`.

Shared late-evaluated build defaults that depend on project metadata, such as generating XML docs only for packable projects, live in `Directory.Build.targets`.

New SDK-style projects in this repository should:

- inherit the shared `net10.0`, nullable, and implicit usings defaults unless they intentionally need a local override.
- use `PackageReference` items without a `Version` attribute so Central Package Management resolves versions from `Directory.Packages.props`.
- keep test-only package references in test projects rather than production library projects.
