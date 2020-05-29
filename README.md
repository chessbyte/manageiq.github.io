# manageiq.github.io

[![Build Status](https://travis-ci.com/ManageIQ/manageiq.github.io.svg?branch=build)](https://travis-ci.com/ManageIQ/manageiq.github.io)

This is the GitHub pages repo for manageiq.org.

The files in `master` are generated from a number of repos, so changes are not made here.

If you'd like to make changes to manageiq.org, please do so here:

- Main site - https://github.com/ManageIQ/manageiq.org
- User Reference - https://github.com/ManageIQ/manageiq-documentation
- Developer Guides - https://github.com/ManageIQ/guides

## Build

From the repos above, the `trigger.sh` script is called using the following snippet in the .travis.yml

```yaml
deploy:
  provider: script
  skip_cleanup: true
  script: curl -sSL https://raw.githubusercontent.com/ManageIQ/manageiq.github.io/build/trigger.sh | bash -s
  on:
    branch: master
```

The trigger script pokes Travis to re-run the build branch in this repo.  The `build` branch checks out the repos above,
executes the build, and when complete, deploys the `dest` directory to the `master` branch, which is configured for
GitHub pages.

## License

This project is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).
