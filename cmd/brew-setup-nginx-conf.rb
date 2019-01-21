#!/usr/bin/env ruby
# Generates and installs a project nginx configuration using erb.
require "erb"
require "pathname"

# Prunes invalid symlinks; an invalid project can lead
# to dangling symlinks in the Nginx root, which need
# to be removed.
def prune_dangling_symlinks_from prefix
  base = Pathname.new(prefix)
  base.children.select(&:symlink?).each do |symlink|
    if !symlink.realpath.exist?
      puts "Deleting invalid symlink: #{symlink}"
      symlink.unlink
    end
  end
end

root_configuration = ARGV.delete "--root"
if root_configuration
  http_port = 80
  https_port = 443
else
  http_port = 8080
  https_port = 8443
end

name = ARGV.shift
root = ARGV.shift || "."
input = ARGV.shift || "config/dev/nginx.conf.erb"

if !name || !root || !input
  abort "Usage: brew setup-nginx-conf [--root] [--extra-val=variable=value] <project_name> <project_root_path> <nginx.conf.erb>"
end

abort "Error: #{input} is not a .erb file!" unless input.end_with? ".erb"

root = File.expand_path root
input = File.expand_path input

# Find extra variables in the form of --extra-val=variable=value
# Using a hash and ERB#result_with_hash would be nice, but it didn't
# appear until Ruby 2.5. :/
variables = binding
ARGV.delete_if do |argument|
  next unless argument.start_with? "--extra-val="
  variable, value = argument.sub(/^--extra-val=/, "").split("=", 2)
  variables.local_variable_set(variable.to_sym, value)

  true
end

data = IO.read input
conf = ERB.new(data).result(variables)
output = input.sub(/.erb$/, "")
output.sub!(/.conf$/, ".root.conf") if root_configuration
IO.write output, conf

exit if root_configuration

/access_log (?<log>.+);/ =~ conf
if log
  log = Pathname(log)
  log.dirname.mkpath
  FileUtils.touch log unless log.exist?
end

exit unless RUBY_PLATFORM.include? "darwin"

strap_url = ENV["HOMEBREW_STRAP_URL"]
strap_url ||= "https://strap.githubapp.com"

unless File.exist? "/usr/local/bin/brew"
  abort <<~EOS
    Error: Homebrew is not in /usr/local. Install it by running Strap:
      #{strap_url}
EOS
end

brewfile = <<~EOS
  brew "launchdns", restart_service: true
  brew "launch_socket_server"
  brew "nginx", restart_service: true
EOS

started_services = false
unless system "echo '#{brewfile}' | brew bundle check --file=- >/dev/null"
  puts "Installing *.dev dependencies:"
  unless system "echo '#{brewfile}' | brew bundle --file=-"
    abort "Error: install *.dev dependencies with brew bundle!"
  end
  started_services = true
end

if `readlink /etc/resolver 2>/dev/null`.chomp != "/usr/local/etc/resolver"
  unless system "sudo -n true >/dev/null"
    puts "Asking for your password to setup *.dev:"
  end
  system "sudo rm -rf /etc/resolver"
  unless system "sudo ln -sf /usr/local/etc/resolver /etc/resolver"
    abort "Error: failed to symlink /usr/local/etc/resolver to /etc/resolver!"
  end
end

if File.exist? "/etc/pf.anchors/dev.strap"
  unless system "sudo -n true >/dev/null"
    puts "Asking for your password to uninstall pf:"
  end
  system "sudo rm /etc/pf.anchors/dev.strap"
  system "sudo grep -v 'dev.strap' /etc/pf.conf | sudo tee /etc/pf.conf"
  system "sudo launchctl unload /Library/LaunchDaemons/dev.strap.pf.plist 2>/dev/null"
  system "sudo launchctl load -w /Library/LaunchDaemons/dev.strap.pf.plist 2>/dev/null"
  system "sudo launchctl unload /Library/LaunchDaemons/dev.strap.pf.plist 2>/dev/null"
  system "sudo rm -f /Library/LaunchDaemons/dev.strap.pf.plist"
end
if `brew services list | grep launch_socket_server | grep started` == ""
  unless system "sudo -n true > /dev/null"
    puts "Asking for your password to start launch_socket_server:"
  end
  unless system "sudo brew services start launch_socket_server >/dev/null"
    abort "Error: failed to start launch_socket_server!"
  end
end

server_base_path = "/usr/local/etc/nginx/servers"
server = File.join(server_base_path, name)
unless system "ln -sf '#{File.absolute_path(output)}' '#{server}'"
  abort "Error: failed to symlink #{output} to #{server}!"
end

prune_dangling_symlinks_from server_base_path

unless started_services
  unless system "brew services restart nginx >/dev/null"
    abort "Error: failed to (re)start nginx!"
  end
end
