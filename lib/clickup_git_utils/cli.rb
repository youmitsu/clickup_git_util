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

      puts 'hoge'
      ## 作成するタスクの選択
      p 'Please input taskId below to checkout.'
      inputTaskId = STDIN.gets.chomp
      p "#{inputTaskId} selected."

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
      p @token

      @client = Faraday.new(url: 'https://api.clickup.com') do |f|
        f.request  :url_encoded
        f.response :logger
        f.adapter  Faraday.default_adapter
      end
    end

    def checkout_new(id)
      # task = @tasks.select { |task| task['id'] == id }
      branchName = "feature/##{id}"
      `git checkout -b #{branchName}`
    end

    ## Taskの取得 ##
    def checkTasks
      res = @client.get do |req|
        req.headers['Authorization'] = @token
        req.url '/api/v2/team/906839/task'
        # req.url '/api/v2/list/6-1036289-2/task?archived=false&page=&order_by=&reverse=&subtasks=&space_ids%5B%5D=&project_ids%5B%5D=&statuses%5B%5D=&include_closed=&assignees%5B%5D=&due_date_gt=&due_date_lt=&date_created_gt=&date_created_lt=&date_updated_gt=&date_updated_lt='
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
