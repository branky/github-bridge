require 'test/unit'
require 'github-bridge'

class TestBridge < Test::Unit::TestCase
    def test_github_user_repo
      expected = ['test-user','test-repo']
      #html_url
      result = GithubBridge.github_user_repo "https://github.com/test-user/test-repo"
      assert_equal expected, result
      #http_url
      result = GithubBridge.github_user_repo "https://github.com/test-user/test-repo.git"
      assert_equal expected, result
      #ssh_url
      result = GithubBridge.github_user_repo "git@github.com:test-user/test-repo.git"
      assert_equal expected, result

      result = GithubBridge.github_user_repo "http://a.invalid.url"
      assert_equal [nil, nil], result

    end

    def test_usage
      GithubBridge.new(['-h']).usage
    end

    def test_help
      GithubBridge.new(['unknown']).help
    end

    def test_login_github
      github = GithubBridge.login_github('githubbridge', 'Github4me', 'github.com')
      puts github.client
    end
end