require "net/http"
require "httpclient"
module Net
  class HTTP < Protocol
    class << HTTP
      def get(uri_or_host, path = nil, port = nil)
        raise if path or port
        HTTPClient.get_content(uri_or_host)
      end

      Response = Struct.new(:body)
      def post_form(url, params)
        result = HTTPClient.post_content(url, params)
        Response.new(result)
      end
    end
  end
end
require "yaml"

module GHI
  VERSION = "0.0.8"

  def self.login
    return @login if defined? @login
    @login = `git config --get github.user`.chomp
    if @login.empty?
      begin
        print "Please enter your GitHub username: "
        @login = gets.chomp
        valid = user? @login
        warn "invalid username" unless valid
      end until valid
      `git config --global github.user #@login`
    end
    @login
  end

  def self.token
    return @token if defined? @token
    @token = `git config --get github.token`.chomp
    if @token.empty?
      begin
        print "GitHub token (https://github.com/account): "
        @token = gets.chomp
        valid = token? @token
        warn "invalid token for #{GHI.login}" unless valid
      end until valid
      `git config --global github.token #@token`
    end
    @token
  end

  private

  def self.user?(username)
    url = "http://github.com/api/v2/yaml/user/show/#{username}"
    !YAML.load(Net::HTTP.get(URI.parse(url)))["user"].nil?
  rescue ArgumentError, URI::InvalidURIError
    false
  end

  def self.token?(token)
    url  = "http://github.com/api/v2/yaml/user/show/#{GHI.login}"
    url += "?login=#{GHI.login}&token=#{token}"
    !YAML.load(Net::HTTP.get(URI.parse(url)))["user"]["plan"].nil?
  rescue ArgumentError, NoMethodError, URI::InvalidURIError
    false
  end
end
