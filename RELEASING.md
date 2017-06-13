## Process for releasing pltraining modules
**Note** this document describes the plan for automated testing and release of pltraining modules, some modules may not yet be fully automated.

Because these modules are used in live training, it's
important that any changes have been thoroughly tested
against all courses. This document outlines the release
process used by the Puppet Education team.

## Release process steps
1. Changes are proposed via pull request.
1. Automated tests are triggered on Travis-CI
1. The Puppet Education team reviews the pull requests and merges to the `master` branch
  * PRs should not be merged unless they pass the automated tests.
  * Major code changes should include appropriate automated test coverage.
  * Although `master` is a development branch care should be take to be sure no breaking changes are introduced.
1. Automated acceptance tests run nightly against the `master` branch.
1. Once all nightly tests pass, changes are merged into the `release` branch.
1. At the discretion of the Education team, releases are tagged in the `release` branch and published.
  * This should include a review of testing coverage and gaps should be fixed and tests rerun before publishing.
1. Tagged releases are tested a final time before being automatically pushed to the forge.
  * Because tagged releases are automatically built and uploaded, they should be considered the same as uploading a module to the forge.
