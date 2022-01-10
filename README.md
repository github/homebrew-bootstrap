# Homebrew Bootstrap

A series of helper scripts, casks and formulae to reduce duplication across `script/bootstrap`s. Scripts:

- [`brew bootstrap-jenv-java`](cmd/brew-bootstrap-jenv-java): Installs Zulu JDK.
- [`brew bootstrap-nodenv-node`](cmd/brew-bootstrap-nodenv-node): Installs Node and NPM.
- [`brew bootstrap-rbenv-ruby`](cmd/brew-bootstrap-rbenv-ruby): Installs Ruby and Bundler.
- [`brew macos-vscode-codespaces`](cmd/brew-macos-vscode-codespaces): Get Visual Studio Code ready for running with Codespaces.
- [`brew report-issue`](cmd/brew-report-issue.rb): Creates and closes failure debugging issues on a project.
- [`brew setup-nginx-conf`](cmd/brew-setup-nginx-conf.rb): Generates and installs a project `nginx` configuration using `erb`.
- [`brew upgrade-mysql`](cmd/brew-upgrade-mysql): Upgrade `mysql` version used by GitHub production.
- [`brew vendor-gem`](cmd/brew-vendor-gem): Build and cache a RubyGem for the given `git` repository
- [`ruby-definitions/`](ruby-definitions): `ruby-build` definitions for GitHub Rubies (migrated from [boxen/puppet-ruby](https://github.com/boxen/puppet-ruby/tree/HEAD/files/definitions)).

## How do I install these scripts/casks/formulae?

`brew install github/bootstrap/<cask|formula>`

Or `brew tap github/bootstrap` and then `brew install <formula>`.

## Status

In active development.

[@MikeMcQuaid](https://github.com/MikeMcQuaid/)

## License

Homebrew Bootstrap is licensed under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
The full license text is available in [LICENSE.txt](https://github.com/github/homebrew-bootstrap/blob/HEAD/LICENSE.txt).
