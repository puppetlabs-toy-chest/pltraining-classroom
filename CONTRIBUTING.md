Contribution Guidelines
=======================

## How to contribute

This module was developed in to support Puppet training. It is open to
the public so that students can see the code that goes in to creating
the classroom experience. Although most of the development is done by 
Puppet employees we welcome outside contributions. Be aware that your
suggested change may not fit in with our future plans, so even very good
code may not be accepted.

Priority will be given to contributions from Puppet Professional Services
engineers and Service Delivery Partners actively teaching classes.

Please refer to our [contribution
guidelines](https://github.com/puppetlabs/edu-documentation/blob/master/CONTRIBUTING.md)
documentation for general information on contributing to Puppet Education
projects.

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
