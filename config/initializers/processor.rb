require 'line/bot/api/version'
require 'line/bot/utils'
require 'net/http'
require 'uri'

module Line
  module Bot
    class Processor
      attr_accessor :client, :data, :from_mid

      def initialize(client, data)
        @client = client
        @data = data
        @from_mid = data.from_mid
      end

      def process
        case data
        when Line::Bot::Receive::Operation
          case data.content
          when Line::Bot::Operation::AddedAsFriend
            client.send_text(
              to_mid: from_mid,
              text: initial_processor,
            )
          end
        when Line::Bot::Receive::Message
          case data.content
          when Line::Bot::Message::Text
            client.send_text(
              to_mid: to_mid,
              text: initial_processor#data.content[:text],
            )
          end
        end
      end

      # private
      def initial_processor
        user = User.where(mid: from_mid).first_or_initialize
        user.save!

        stage = 0
        case stage
        when 0
          message = "あなたをグループの一員として認めます！"
          message += "ようこそ，悩める彼氏のための相談BOTへ"
          message += "まずあなたが本当に悩める男なのか，私が見定めてあげるわ♪"
          message += "今の彼女とは付き合い始めて何か月？"
        when 1
          message = "どこで出会ったのかしら？なれそめを詳しく教えて？"
        when 2
          message = "彼女のどこが好きなのかしら，詳しく聞かせて？"
        when 3
          message = "審査中（スタンプとかあるとかわいいなぁ）"
        end 

      end

      def text_processor
        message = ""
      end

      def to_mid
        mids = User.all.map{|user| user.mid}
        # mids.delete(from_mid)

        mids
      end
    end
  end
end
