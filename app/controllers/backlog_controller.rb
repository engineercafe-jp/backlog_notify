require "net/http"
require "uri"
require "json"

class BacklogController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  def webhook
    payload = request.body.read
    backlog_data = JSON.parse(payload) rescue {}

    Rails.logger.info("Received webhook: #{backlog_data}")
    Rails.logger.info("Received webhook(raw): #{payload}")

    webhook_url = ENV["DISCORD_WEBHOOK_URL"]

    uri = URI.parse(webhook_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    req = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
    req.body = "test test test"

    response = http.request(req)
    if response.is_a?(Net::HTTPSuccess)
      Rails.logger.info("Message sent to Discord successfully")
      render json: { message: "Webhook received and sent to Discord successfully" }, status: :ok
    else
      Rails.logger.error("Failed to send message to Discord: #{response.code} - #{response.message}")
      render json: { message: "Failed to send message to Discord" }, status: :internal_server_error
    end
  end

  # message_content = "Backlogの更新情報: #{backlog_data('content', 'text')}"
  # message_content = message_content[0, 997] + "..." if message_content.length > 1000
  # message = {
  #   content: message_content
  # }

  # uri = URI.parse(webhook_url)
  # http = Net::HTTP.new(uri.host, uri.port)
  # http.use_ssl = true if uri.scheme == "https"

  # req = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
  # req.body = message.to_json

  # response = http.request(req)

  # if response.is_a?(Net::HTTPSuccess)
  #   Rails.logger.info("Message sent to Discord successfully")
  #   render json: { message: "Webhook received and sent to Discord successfully" }, status: :ok
  # else
  #   Rails.logger.error("Failed to send message to Discord: #{response.code} - #{response.message}")
  #   render json: { message: "Failed to send message to Discord" }, status: :internal_server_error
  # end

  # rescue => e
  #   Rails.logger.error("Error processing webhook: #{e.message}")
  #   render json: { message: "Error processing webhook" }, status: :internal_server_error
  # end
end
