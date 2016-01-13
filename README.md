# Homebrew Bootstrap
A series of helper scripts to reduce duplication across `script/bootstrap`s.

- [`brew bootstrap-rbenv-ruby`](cmd/brew-bootstrap-rbenv-ruby): Installs Ruby and Bundler.
- [`brew report-issue`](cmd/brew-report-issue.rb): Creates and closes failure debugging issues on a project.
- [`brew bootstrap-nodenv-node`](cmd/brew-bootstrap-nodenv-node): Installs Node and npm.
- [`brew setup-nginx-conf`](cmd/brew-setup-nginx-conf): Generates and installs a project nginx configuration using erb.
- [`ruby-definitions/`](ruby-definitions): `ruby-build` definitions for GitHub Rubies (from [boxen/puppet-ruby](https://github.com/boxen/puppet-ruby/tree/master/files/definitions)).

## Usage

```bash
brew tap github/bootstrap
brew bootstrap-rbenv-ruby # or any other script
```

## Status
In active development.

## Contact
[@mikemcquaid](https://github.com/mikemcquaid/)

## License
Homebrew Bootstrap is licensed under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
The full license text is available in [LICENSE.txt](https://github.com/github/homebrew-bootstrap/blob/master/LICENSE.txt).
