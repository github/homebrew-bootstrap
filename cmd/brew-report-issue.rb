#!/usr/bin/env ruby
# Creates and closes issues on a project.
close = !!ARGV.delete("--close")
user_repo = ARGV.shift
failure_source = ARGV.shift
success_meta = failure_source

if user_repo.to_s.empty? || failure_source.to_s.empty?
  abort "Usage: brew report-issue [--close] <user/repo> <failure-source|success-meta> [<STDIN piped body>]"
end

unless close
  abort "Error: the issue's body should be piped over STDIN!" if STDIN.tty?
  issue_body = STDIN.read
end

github_credentials=`printf "protocol=https\nhost=github.com\n" | git credential fill 2>/dev/null`
/username=(?<github_username>.+)/ =~ github_credentials
/password=(?<github_password>.+)/ =~ github_credentials
github_username ||= ENV["BOXEN_GITHUB_LOGIN"]
github_username ||= `git config github.user`.chomp

if github_username.to_s.empty?
  abort <<-EOS
Error: your GitHub username is not set! Set it by running Strap:
  https://strap.githubapp.com
EOS
end
@github_username = github_username

if github_password.to_s.empty?
  abort <<-EOS
Error: your GitHub password is not set! Set it by running Strap:
  https://strap.githubapp.com
EOS
end
@github_password = github_password

require "net/http"
require "json"

def http_request(type, url, body=nil)
  uri = URI url
  request = if type == :post
    post_request = Net::HTTP::Post.new uri
    post_request.body = body
    post_request
  elsif type == :get
    Net::HTTP::Get.new uri
  end
  return unless request
  request.basic_auth @github_username, @github_password
  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request request
  end
end

def response_check(response, action)
  return if response.is_a? Net::HTTPSuccess
  STDERR.puts "Error: failed to #{action}!"
  unless response.body.empty?
    failure = JSON.parse(response.body)
    STDERR.puts "--\n#{response.code}: #{failure["message"] }"
  end
  exit 1
end

def json_escape(string)
  JSON.generate(string, quirks_mode: true)
end

if close
  closed_issues_url = \
    "https://api.github.com/repos/#{user_repo}/issues?filter=created"
  response = http_request :get, closed_issues_url
  response_check(response, "get issues (#{closed_issues_url})")

  issues = JSON.parse response.body
  issues.each do |issue|
    comments_url = issue["comments_url"]
    succeeded = json_escape "Succeeded at #{success_meta}."
    issue_comment_json = "{ \"body\": #{succeeded} }"
    response = http_request :post, comments_url, issue_comment_json
    response_check(response, "create comment (#{comments_url})")

    issue_url = issue["url"]
    close_issue_json = '{ "state": "closed" }'
    response = http_request :post, issue_url, close_issue_json
    response_check(response, "close issue (#{issue_url})")
  end
else
  title = json_escape "#{failure_source} failed for #{@github_username}"
  body = json_escape issue_body.chomp
  new_issue_json = <<-EOS
    {
      "title": #{title},
      "body":  #{body}
    }
  EOS
  issues_url = "https://api.github.com/repos/#{user_repo}/issues"
  response = http_request :post, issues_url, new_issue_json
  response_check(response, "create issue (#{issues_url})")
  issue = JSON.parse(response.body)
  puts "Created issue: #{issue["html_url"]}"
end
