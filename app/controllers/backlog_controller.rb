class BacklogController < ApplicationController
  # protect_from_forgery with: :null_session  # CSRF対策を無効化 (API用)
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  def webhook
    payload = request.body.read
    json_data = JSON.parse(payload) rescue {}

    Rails.logger.info("Received webhook: #{json_data}")

    # 必要な処理をここに実装
    # 例: json_dataの中身に応じて処理を実行

    render json: { message: "Webhook received successfully" }, status: :ok
  end
end
