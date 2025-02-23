const fetch = require('node-fetch');
require('dotenv').config();
const fs = require('fs');

const webhookURL = process.env.DISCORD_WEBHOOK_URL; // DiscordのWebhook URLを設定

exports.handler = async (event) => {
    try {
        // Backlogからのデータを受信する
        const backlogData = event.body ? JSON.parse(event.body) : {};

        // ログを追加
        console.log('Received raw data:', JSON.stringify(backlogData));

        // Secret FilesからチャンネルIDを読み込む
        const channelIdPath = process.env.DISCORD_CHANNEL_ID_PATH;
        const channelId = fs.readFileSync(channelIdPath, 'utf8').trim();

        // Discordに送信するメッセージを作成
        let messageContent = `Backlogの更新情報: ${backlogData.content.text}`;
        if (messageContent.length > 1000) {
            messageContent = messageContent.substring(0, 997) + '...'; // 最大1000文字に制限し、末尾に"..."を追加
        }
        const message = {
            content: messageContent,
        };

        // Webhookを使ってDiscordにメッセージを送信
        const response = await fetch(webhookURL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(message),
        });

        if (!response.ok) {
            console.error('Failed to send message to Discord:', response.status, response.statusText);
            return { statusCode: 500, body: 'Failed to send message to Discord' };
        }

        return { statusCode: 200, body: 'Message sent to Discord' };
    } catch (error) {
        console.error('Error processing webhook:', error);
        return { statusCode: 500, body: 'Error processing webhook' };
    }
};