# frozen_string_literal: true

require 'thor'
require 'faraday'
require 'json'

module ClickupGitUtils
  class CLI < Thor
    desc 'new', 'git checkout with clickup tasks.'
    def new(_str)
      impl = Impl.new
      impl.checkTasks

      ## 作成するタスクの選択
      puts 'Please input taskId below to checkout.'
      inputTaskId = STDIN.gets.chomp
      puts "#{inputTaskId} selected."

      impl.checkout_new(inputTaskId)
    end

    desc 'checkout', 'git checkout with clickup tasks.'
    def checkout(_str)
      puts 'hoge'
    end

    desc 'pull', 'git checkout with clickup tasks.'
    def pull
      puts 'fuga'
    end
  end

  class Impl
    @token = nil
    @client = nil
    @tasks = []

    def initialize
      clickupToken = ENV['CLICK_UP_TOKEN']
      if clickupToken.nil?
        p "You haven't set environment variable 'CLICK_UP_TOKEN' yet."
        return
      end
      @token = clickupToken
      puts "used token: #{token}"

      @client = Faraday.new(url: 'https://api.clickup.com') do |f|
        f.request  :url_encoded
        f.response :logger
        f.adapter  Faraday.default_adapter
      end
    end

    def checkout_new(id)
      branchName = "feature/##{id}"
      `git checkout -b #{branchName}`
    end

    def checkout(id)
      branchName = "feature/##{id}"
      `git checkout #{branchName}`      
    end

    def push(id)
      branchName = "feature/##{id}"
      `git push #{branchName}`      
    end

    def pull(id)
      branchName = "feature/##{id}"
      `git pull #{branchName}`      
    end

    ## Taskの取得 ##
    def checkTasks
      res = @client.get do |req|
        req.headers['Authorization'] = @token
        req.url '/api/v2/team/906839/task?archived=false&list_ids[]=1036289'
      end
      pp res.status
      if res.body.nil?
        p 'No tasks.'
        return
      end
      obj = JSON.parse(res.body)
      @tasks = obj['tasks']
      @tasks.each do |task|
        pp "id: #{task['id']}, name: #{task['name']}"
      end
    end
  end
end
