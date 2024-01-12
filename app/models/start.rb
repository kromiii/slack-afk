module App
  module Model
    class Start < Base
      def add_list?
        true
      end

      def bot_run(uid, params)
        user_presence = App::Model::Store.get(uid)
        user_presence['today_begin'] = Time.now.to_s
        if user_presence['mention_histotry']
          history = user_presence['mention_histotry'].map do |h|
            <<~EOS
              <@#{h['user']}>: <https://#{ENV['SLACK_DOMAIN']}/archives/#{h['channel']}/p#{h['event_ts'].gsub(/\./, '')}|Link>
              内容: #{h['text']}
            EOS
          end
        end
        App::Model::Store.set(uid, user_presence)
        bot_token_client.chat_postMessage(channel: params['channel_id'], text: "#{params['user_name']}が始業しました。", as_user: true)
        private_message = (RedisConnection.pool.get("start_#{Date.today}") + "\n\n" || ENV['AFK_START_MESSAGE'] || 'おはようございます、今日も自分史上最高の日にしましょう!!1')
        history ||= []
        if history.empty?
          private_message
        else
          private_message + "\n\nいない間に飛んできたメンションです\n" + history.join("\n")
        end
      end
    end
  end
end
