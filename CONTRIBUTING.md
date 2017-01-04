# How to contribute

This module was developed in to support Puppet training. It is open to
the public so that students can see the code that goes in to creating
the classroom experience. Although most of the development is done by 
Puppet employees we welcome outside contributions. Be aware that your
suggested change may not fit in with our future plans, so even very good
code may not be accepted.

Priority will be given to contributions from Puppet Professional Services
engineers and Service Delivery Partners actively teaching classes.

There are a few guidelines that we need contributors to follow so that 
we can have a chance of keeping on top of things.

## Getting Started

* Make sure you have a [Jira account](https://tickets.puppetlabs.com)
* Make sure you have a [GitHub account](https://github.com/signup/free)
* Submit a ticket for your issue, assuming one does not already exist.
  * Clearly describe the issue including steps to reproduce when it is a bug.
  * Make sure you fill in the earliest version that you know has the issue.
* Fork the repository on GitHub

## Making Changes

Releases are made from the `release` branch, which should always be in a
releasable state. `master` is the active development branch and changes 
are periodically moved to the release branch for acceptance testing.

Before you begin working on an issue or feature, check that it hasn't
already been addressed in the `master` branch.

* Create a topic branch from where you want to base your work.
  * This is usually the master branch.
  * Only target release branches if you are certain your fix must be on that
    branch.
  * To quickly create a topic branch based on master; `git checkout -b
    fix/master/my_contribution master`. Please avoid working directly on the
    `master` branch.
* Make atomic commits of logical units. Do not combine unrelated fixes.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are in the proper format.
* Don't update version numbers or changelogs. Instead, write a good commit 
  subject and description. We will use the commit subject to update the 
  changelog as needed.

````
    (PUP-1234) Make the example in CONTRIBUTING imperative and concrete

    Without this patch applied the example commit message in the CONTRIBUTING
    document is not a concrete example.  This is a problem because the
    contributor is left to imagine what the commit message should look like
    based on a description rather than an example.  This patch fixes the
    problem by making the example concrete and imperative.

    The first line is a real life imperative statement with a ticket number
    from our issue tracker.  The body describes the behavior without the patch,
    why this is a problem, and how the patch fixes the problem when applied.
````

* Make sure you have added the necessary tests for your changes.
* Run _all_ the tests to assure nothing else was accidentally broken.
  * Tests can be run with the command `rake spec`

## Making Trivial Changes

### Documentation

For changes of a trivial nature to comments and documentation, it is not
always necessary to create a new ticket in Jira. In this case, it is
appropriate to start the first line of a commit with '(doc)' instead of
a ticket number.

````
    (doc) Add documentation commit example to CONTRIBUTING

    There is no example for contributing a documentation commit
    to the Puppet repository. This is a problem because the contributor
    is left to assume how a commit of this nature may appear.

    The first line is a real life imperative statement with '(doc)' in
    place of what would have been the ticket number in a
    non-documentation related commit. The body describes the nature of
    the new documentation or comments added.
````

## Submitting Changes

* Sign the [Contributor License Agreement](http://links.puppet.com/cla).
* Push your changes to a topic branch in your fork of the repository.
* Submit a pull request to the repository in the puppetlabs organization.
* Update your Jira ticket to mark that you have submitted code and are ready for it to be reviewed (Status: Ready for Merge).
  * Include a link to the pull request in the ticket.
* The Education team looks at pull requests on a regular basis.
* After feedback has been given we expect responses within two weeks. After two
  weeks we may close the pull request if it isn't showing any activity.

## Revert Policy
By running tests in advance and by engaging with peer review for prospective
changes, your contributions have a high probability of becoming long lived
parts of the the project. After being merged, the code will run through a
series of testing pipelines on a large number of operating system
environments. These pipelines can reveal incompatibilities that are difficult
to detect in advance.

If the code change results in a test failure, we will make our best effort to
correct the error. If a fix cannot be determined and committed within 24 hours
of its discovery or as needed for expediency, the commit(s) responsible _may_ 
be reverted, at the discretion of the committer and maintainers. This action 
would be taken to help maintain passing states in our testing pipelines.

The original contributor will be notified of the revert in the Jira ticket
associated with the change. A reference to the test(s) and operating system(s)
that failed as a result of the code change will also be added to the Jira
ticket. This test(s) should be used to check future submissions of the code to
ensure the issue has been resolved.

## Release Policy
Stable features and bug fixes are moved to the release branch on a regular
basis for full automated integration and acceptance testing. Published releases
happen on an as needed basis, generally at least once a month if there are
unpublished changes in the release branch.

### Summary
* Changes resulting in test pipeline failures will be reverted if they cannot
  be resolved within one business day.

# Additional Resources

* [Puppet community guidelines](https://docs.puppet.com/community/community_guidelines.html)
* [Bug tracker (Jira)](https://tickets.puppetlabs.com)
* [Contributor License Agreement](http://links.puppet.com/cla)
* [General GitHub documentation](https://help.github.com/)
* [GitHub pull request documentation](https://help.github.com/articles/about-pull-requests/)
