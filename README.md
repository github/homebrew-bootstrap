# Homebrew Bootstrap
A series of helper scripts to reduce duplication across `script/bootstrap`s.

- [`brew bootstrap-rbenv-ruby`](cmd/brew-bootstrap-rbenv-ruby): Installs Ruby and Bundler.
- [`brew bootstrap-nodenv-node`](cmd/brew-bootstrap-nodenv-node): Installs Node and npm.
- [`brew setup-nginx-conf`](cmd/brew-setup-nginx-conf): Generates and installs a project nginx configuration using erb.
- [`ruby-definitions/`](ruby-definitions): `ruby-build` definitions for GitHub Rubies (from [boxen/puppet-ruby](https://github.com/boxen/puppet-ruby/tree/master/files/definitions)).
