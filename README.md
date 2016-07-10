# Lock Old Issues
LockOldIssues is a small application to lock your old, closed GitHub issues.

## Features
- Lock old issues
- Select first and last issue to iterate through
- Select how many days old before an issue can be locked

## Usage
To setup locally run:
```bash
git clone https://github.com/mikemcquaid/LockOldIssues
cd LockOldIssues
bundle install
```

Now run LockOldIssues:
```bash
./lock_old_issues.rb --repository Homebrew/legacy-homebrew
```

## Status
Works for locking old issues. Will happily accept pull requests.

[![Build Status](https://travis-ci.org/MikeMcQuaid/LockOldIssues.svg?branch=master)](https://travis-ci.org/MikeMcQuaid/LockOldIssues)

## Contact
[Mike McQuaid](mailto:mike@mikemcquaid.com)

## License
LockOldIssues is licensed under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
The full license text is available in [LICENSE.txt](https://github.com/mikemcquaid/LockOldIssues/blob/master/LICENSE.txt).
