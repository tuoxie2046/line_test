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
          user = User.where(mid: from_mid).first_or_initialize
          user.save!
          user.stage = 0
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
        message = "=========================="
        user = User.where(mid: from_mid).first_or_initialize
        user.save!
        user.stage = 0
        user = User.where(mid: from_mid)

        stage = user.stage

        case stage
        when 0
          regions = ["練馬", "板橋", "北", "足立", "葛飾", "杉並", "中野", "豊島", "文京", "荒川", "世田谷", "渋谷", "新宿", "千代田", "台東", "墨田", "目黒", "港", "中央", "江東", "江戸川", "品川", "大田"]
          regions.each do |region|
            if region === data.content[:text]
              data = User.where(mid: from_mid)
              #data.first.update_attributes()
              stage += 1
              user.stage = stage
              break
            end
          end
        when 1
          case data.content[:text]
          when "1"
            stage += 1
            user.stage = 0
          when "2"
            stage += 1
            user.stage = stage
          when "3"
            stage += 1
            user.stage = stage
          when "4"
            stage += 1
            user.stage = stage
          else
            message += "選択は正しくない,もう一回しましょう\n"
          end
        when 2
          if data.content[:text].length < 10
            message += "みじかい！！（<10文字）\n"
          elsif data.content[:text].length < 20
            message += "もっと詳しく教えてちょうだい　（＜20文字）\n"
          else
            message += "いい感じの出会いしてるじゃないの（＞20文字）\n"
          end
          stage += 1
          user.stage = stage
        when 3
          if data.content[:text].length < 20
            message += "みじかい！もっとあるでしょう！！恥ずかしがらずに！（＜20文字）\n"
          else
            message += "ふぅ～～ん，素敵じゃない（＞20文字）\n"
          end
          stage += 1
          user.stage = stage
        when 4
          stage += 1
          user.stage = stage
        end

        case stage
        when 0
          message += "あなたをグループの一員として認めます！\n"
          message += "ようこそ，悩める彼氏のための相談BOTへ"
          message += "まずあなたが本当に悩める男なのか，私が見定めてあげるわ♪\n"
          message += "========================================="
          message += "まずあなたの地域はどこ？\n"
          message += "以下の選択の中で１つ入力ください\n"
          message += "練馬, 板橋, 北, 足立, 葛飾, 杉並, 中野, 豊島, 文京, 荒川, 世田谷, 渋谷, 新宿, 千代田, 台東, 墨田, 目黒, 港, 中央, 江東, 江戸川, 品川, 大田\n"
        when 1
          message += "今の彼女とは付き合い始めて何か月？"
          message += "以下の選択の中の数字を入力ください\n"
          message += "1. あら，結構長いじゃない (>12か月）\n"
          message += "2. 彼氏歴もそこそこね， （<12か月）\n"
          message += "3. 新米彼氏さんなのね， （<3か月）\n"
          message += "4. 恥ずかしがらないでちゃんと答えなさ～い　(数字じゃない)\n"
        when 2
          message += "どこで出会ったのかしら？なれそめを詳しく教えて？\n"
        when 3
          message += "彼女のどこが好きなのかしら，詳しく聞かせて？\n"
        when 4
          message += "審査中（スタンプとかあるとかわいいなぁ）\n"
          message += "あなたは悩める彼氏，．．．．　のようね！（全部ok）\n"
        end 

        message
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
