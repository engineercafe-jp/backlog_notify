require "faraday"

class BacklogController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  def webhook
    payload = request.body.read
    backlog_data = JSON.parse(payload) rescue {}
    spaceid = ENV["BACKLOG_SPACE_ID"]

    # 課題URLの生成
    issue_id = backlog_data.dig("content", "key_id")
    project_key = backlog_data.dig("project", "projectKey")
    backlog_url = "https://#{spaceid}.backlog.com/view/#{project_key}-#{issue_id}"

    # 担当者、課題の詳細を取得
    summary = backlog_data.dig("content", "summary")
    assignee = backlog_data.dig("content", "assignee", "name")
    description = backlog_data.dig("content", "description")
    createduser = backlog_data.dig("createdUser", "name")
    comment = backlog_data.dig("content", "comment", "content")
    discord_message = {
      content: "------\n更新がありました！\nタイトル：#{summary}\n課題URL：#{backlog_url}\n変更者：#{createduser}\n担当者：#{assignee}\n課題の詳細：#{description}\nコメント：#{comment}\n------"
    }.to_json

    Rails.logger.info("Received webhook: #{backlog_data}")
    Rails.logger.info("Received webhook(raw): #{payload}")

    webhook_url = ENV["DISCORD_WEBHOOK_URL"]

    conn = Faraday.new
    conn.post do |req|
      req.url webhook_url
      req.headers["Content-Type"] = "application/json"
      req.body = discord_message
    end
  end
end
