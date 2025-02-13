require "faraday"

class BacklogController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  def webhook
    payload = request.body.read
    backlog_data = JSON.parse(payload) rescue {}

    Rails.logger.info("Received webhook(raw): #{payload}")
    Rails.logger.info("Received webhook: #{backlog_data}")# 2個出るのは問題ない。こちらはbodyだけ

    # 課題URLの生成
    issue_id = backlog_data.dig("content", "key_id")||"不明"
    project_key = backlog_data.dig("project", "projectKey").to_s.strip
    spaceid = ENV["BACKLOG_SPACE_ID"]
    backlog_url = "https://#{spaceid}.backlog.com/view/#{project_key}-#{issue_id}"

    # 送信するプロパティを取得
    summary = backlog_data.dig("content", "summary") # タイトル
    assignee = backlog_data.dig("content", "assignee", "name") # 担当者
    description = backlog_data.dig("content", "description") # 課題の詳細
    createduser = backlog_data.dig("createdUser", "name") # 変更者
    comment = backlog_data.dig("content", "comment", "content") # コメント
    projectid = backlog_data.dig("project", "id") # プロジェクトID（数字）
    due_date = backlog_data.dig("content", "dueDate") # 期限日

    # 送信内容の生成
    discord_message = {
      content: "------\n更新がありました！\n期限日：#{due_date}\nタイトル：#{summary}\n課題URL：#{backlog_url}\n変更者：#{createduser}\n担当者：#{assignee}\n課題の詳細：#{description}\nコメント：#{comment}\n------"
    }.to_json

    # プロジェクトごとにWebhookを分ける
    webhook_url = case projectid
    when 88765 then ENV["DISCORD_WEBHOOK_URL_1"]
    when 134840 then ENV["DISCORD_WEBHOOK_URL_2"]
    when 203433 then ENV["DISCORD_WEBHOOK_URL_3"]
    when 217826 then ENV["DISCORD_WEBHOOK_URL_4"]
    when 294737 then ENV["DISCORD_WEBHOOK_URL_5"]
    when 354234 then ENV["DISCORD_WEBHOOK_URL_6"]
    when 515286 then ENV["DISCORD_WEBHOOK_URL_7"]
    when 515288 then ENV["DISCORD_WEBHOOK_URL_8"]
    when 519661 then ENV["DISCORD_WEBHOOK_URL_9"]
    when 519665 then ENV["DISCORD_WEBHOOK_URL_10"]
    when 519666 then ENV["DISCORD_WEBHOOK_URL_11"]
    when 526323 then ENV["DISCORD_WEBHOOK_URL_12"]
    when 545810 then ENV["DISCORD_WEBHOOK_URL_13"]
    else ENV["DISCORD_WEBHOOK_URL"]
    end

    conn = Faraday.new
    conn.post do |req|
      req.url webhook_url
      req.headers["Content-Type"] = "application/json"
      req.body = discord_message
    end
  end
end
