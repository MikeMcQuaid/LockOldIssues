#!/usr/bin/env ruby
require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path "#{__FILE__}/../Gemfile"
require "rubygems"
require "bundler/setup"

require "octokit"
require "trollop"

@options = Trollop.options do
  opt :force, "Actually lock issues"
  opt :repository, "The GitHub repository to lock issues on", type: :string
  opt :first_issue, "The first issue number to iterate through", default: 1
  opt :last_issue, "The last issue number to iterate through", type: :int
  opt :days, "Lock issues closed more than this many days ago", default: 365
end
@repo = @options[:repository]

Trollop.die :repository, "must be set" if @repo.to_s.empty?
Trollop.die :last_issue, "must be set" if @options[:last_issue].to_s.empty?
unless ENV["GITHUB_TOKEN"]
  Trollop.die "GITHUB_TOKEN environment variable must be set"
end

@client = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
@oldest_issue_time_to_keep = Time.now - @options[:days] * 24 * 60 * 60

def too_new?(issue)
  issue.closed_at > @oldest_issue_time_to_keep
end

(@options[:first_issue]..@options[:last_issue]).each do |n|
  issue = @client.issue(@repo, n)
  next puts("#{@repo}##{n}: skipping: already locked.") if issue.locked?
  next puts("#{@repo}##{n}: skipping: not closed.") unless issue.closed_at
  next puts("#{@repo}##{n}: skipping: closed too recently.") if too_new?(issue)
  next puts("#{@repo}##{n}: would be locked.") unless @options[:force]
  @client.put("#{issue.url}/lock",
              accept: "application/vnd.github.the-key-preview")
  puts "#{@repo}##{n}: locked."
end
