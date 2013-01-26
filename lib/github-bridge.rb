require 'parseconfig'
require 'github_api'

class GithubBridge
  
  def initialize(args)
    @command = args.shift
    @args = args
    @config = ParseConfig.new(Dir.home + '/.github/bridge.conf')
  end
  
  
  def self.start(args)
    GithubBridge.new(args).run
  end
  
  def run
    if @command && self.respond_to?(@command)
      self.send @command
    elsif %w(-h --help).include?(@command)
      usage
    else
      help
    end
  end

  def self.github_user_repo(url)
    # Get name of user (or organization) and repository from any valid github url
    # html_url, ssh_url, git_url, https_url
    m = /github\.com.(.*?)\/(.*)/.match(url)
    if m
     return m[1], m[2].sub(/\.git\Z/, "")
    end
     return nil, nil
  end

  ## COMMANDS start ##

  def help
    puts "No command: #{@command}"
    puts "Try: fork"
    puts "or call with '-h' for usage information"
  end
  
  def fork
    url = @args.shift
    user, repo = self.class.github_user_repo url
    if user and repo
      #read config
      github_login = @config['github']['login']
      github_password = @config['github']['password']
      local_repo_base = @config['local']['path']
      enterprise_host = @config['enterprise']['host']
      enterprise_login = @config['enterprise']['login']
      enterprise_password = @config['enterprise']['password']
      enterprise_name = @config['enterprise']['name']
      
      github = self.class.login_github(github_login, github_password)
      fork_res = fork_on_github(github, user, repo)
      clone_to_local(local_repo_base, fork_res.clone_url)
      
      add_remote("#{local_repo_base}/#{fork_res.name}", "upstream", fork_res.parent.clone_url)
      
      github_enterprise = self.class.login_github(enterprise_login, enterprise_password, enterprise_host)

      create_res = new_repo_github(github_enterprise, fork_res.name,
                      "#{fork_res.parent.description} | Forked from #{fork_res.parent.html_url}",
                      fork_res.parent.homepage)
      
      add_remote("#{local_repo_base}/#{fork_res.name}", enterprise_name, create_res.ssh_url)

      push_remote("#{local_repo_base}/#{fork_res.name}", enterprise_name)
    else
      puts "No user and repo info from url: #{url}"
      usage
    end

  end
   ## COMMANDS - end ##

  def fork_on_github(github, user, repo)    
    begin
      fork_res = github.repos.forks.create user, repo
      if fork_res.status == 202
        puts "#{user}/#{repo} forked on github.com"
        return fork_res
      else
        puts fork_res.status
        #TODO  handle fork error
        return fork_res
      end
    rescue Github::Error::GithubError => e
      puts e.message
    end
  end
  
  def clone_to_local(base_path, url)
    puts "Cloning #{url} under #{base_path}"
    Dir.chdir(base_path) {
      cmd = "git clone #{url}"
      clone_res = `#{cmd}`
      puts clone_res
    }

  end
  
  def add_remote(repo_path, remote_name, url)
    Dir.chdir(repo_path) {
      cmd = "git remote add #{remote_name} #{url}"
      addremote_res = `#{cmd}`
      puts addremote_res
    }
  end

  def push_remote(repo_path, remote_name)
    puts "Pushing to #{remote_name}"
    Dir.chdir(repo_path) {
       cmd = "git push -u --all #{remote_name}"
       push_res = `#{cmd}`
       puts push_res
    }

  end

  def new_repo_github(github, name, description, homepage)
    begin
      create_res = github.repos.create :name => name,
                          :description => description,
                          :homepage => homepage
      if create_res.status == 201
          puts "#{name} created on GitHub Enterprise"
          return create_res
      else
          puts create_res.status
          #TODO
          return create_res
      end
    rescue Github::Error::GithubError => e
      puts e.message
    end
  end

  def self.login_github(username, password, host =  nil)
    if host
      puts "Login to #{host} ..."
      return Github.new do |attr|
              attr.endpoint    = "https://#{host}/api/v3"
              attr.login       = username
              attr.password    = password
            end
    else
      puts "Login to github.com ..."
      return Github.new login: username, password: password
    end
  end

  def usage
    puts <<-USAGE
Usage:
       ghb fork <url: e.g. https://github.com/branky/github-bridge>
    USAGE
  end

end
