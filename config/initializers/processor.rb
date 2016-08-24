require 'line/bot/api/version'
require 'line/bot/utils'

module Line
  module Bot
    class Processor
      attr_accessor :client, :data, :to_mid

      def initialize(client, data)
        @client = client
        @data = data
        @to_mid = data.from_mid
      end

      def process
        case data
        when Line::Bot::Receive::Operation
          case data.content
          when Line::Bot::Operation::AddedAsFriend
            client.send_text(
              to_mid: to_mid,
              text: initial_processor,
            )
          end
        when Line::Bot::Receive::Message
          case data.content
          when Line::Bot::Message::Text
            client.send_text(
              to_mid: to_mid,
              text: text_processor,
            )
          when Line::Bot::Message::Sticker
            client.rich_message.set_action(
              MANGA: {
                text: "manga",
                link_url: 'http://yh11.tumblr.com/page/9',
              },
              HELLO: {
                text: "Say hello.",
                params_text: "Hello, Brown!",
                type: "sendMessage",
              }
            ).add_listener(
              action: "MANGA",
              x: 0,
              y: 0,
              width: 520,
              height: 520,
            ).add_listener(
              action: "HELLO",
              x: 521,
              y: 0,
              width: 520,
              height: 520
            ).send(
              to_mid: to_mid,
              image_url: "https://i.ytimg.com/vi/qS0OLh8UrZk",
              alt_text: "test!!!!",
            )
          end
        end
      end

      private
      def initial_processor
        user = User.where(mid: to_mid).first_or_initialize
        user.save!

        message = ""
        message += "ご登録ありがとうございます！\n"
        message += "こちらで気になるイベントのキーワードを登録してください\n"
        message += "https://line-lovers.herokuapp.com/keywords/new"

        message
      end

      def text_processor
        message = ""
        message = "テスト"
      end
    end
  end
end
