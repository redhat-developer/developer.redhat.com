require 'minitest/autorun'
require 'mocha/mini_test'
require 'sawyer'
require_relative '../_lib/github.rb'
require_relative 'test_helper.rb'

class ResourceStub
  def initialize(n)
    @number = n
  end
  def number
    @number
  end
end

class TestGitHub < Minitest::Test
  def test_list_closed_prs
    prs = [ResourceStub.new(5), ResourceStub.new(4), ResourceStub.new(3), ResourceStub.new(2), ResourceStub.new(1)]
    Octokit.stubs(:pull_requests).with("foo/bar", :state => 'closed').returns prs

    pulls = GitHub.list_closed_pulls('foo', 'bar')
    assert_equal(pulls, [5,4,3,2,1])
  end

  def test_comment_on_pull
    pr_number = 88
    expected_comment = "FooBar"
    Octokit.expects(:add_comment).with("foo/bar", pr_number, expected_comment)
    GitHub.comment_on_pull('foo', 'bar', pr_number, expected_comment)
  end

  def test_zero_linked_prs
    issues = []
    pr_number = 144
    Octokit.expects(:add_comment).never
    GitHub.link_issues('foo', 'bar', pr_number, issues)
  end

  def test_one_linked_pr
    issues = ["RHD-99"]
    pr_number = 144
    expectedComment = %Q{Related issue: <a href="https://issues.jboss.org/browse/RHD-99">RHD-99</a>}
    Octokit.expects(:add_comment).with("foo/bar", pr_number, expectedComment)
    GitHub.link_issues('foo', 'bar', pr_number, issues)
  end

  def test_two_linked_prs
    issues = ["RHD-99", "RHD-33"]
    pr_number = 144
    expectedComment = %Q{Related issues: <a href="https://issues.jboss.org/browse/RHD-99">RHD-99</a>, <a href="https://issues.jboss.org/browse/RHD-33">RHD-33</a>}
    Octokit.expects(:add_comment).with("foo/bar", pr_number, expectedComment)
    GitHub.link_issues('foo', 'bar', pr_number, issues)
  end
end
