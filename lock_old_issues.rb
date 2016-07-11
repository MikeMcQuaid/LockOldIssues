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

MAX_RETRIES = 3

(@options[:first_issue]..@options[:last_issue]).each do |n|
  @retries = 0
  begin
    begin
      issue = @client.issue(@repo, n)
    rescue Octokit::NotFound
      next puts("#{@repo}##{n}: skipping: not found (404).")
    end

    next puts("#{@repo}##{n}: skipping: already locked.") if issue.locked?
    next puts("#{@repo}##{n}: skipping: not closed.") unless issue.closed_at
    next puts("#{@repo}##{n}: skipping: closed recently.") if too_new?(issue)
    next puts("#{@repo}##{n}: would be locked.") unless @options[:force]

    @client.put("#{issue.url}/lock",
                accept: "application/vnd.github.the-key-preview")
    puts "#{@repo}##{n}: locked."
  rescue Octokit::TooManyRequests
    sleep_seconds = @client.rate_limit.resets_in
    puts "Rate limited: sleeping for #{sleep_seconds}s..."
    sleep sleep_seconds
    retry
  rescue Faraday::TimeoutError
    raise if @retries >= MAX_RETRIES
    @retries += 1
    retry
  end
end
