# encoding: UTF-8
# frozen_string_literal: true

class MoodFeedback
  FEEDBACKS = {
    1 => [
      "感覺你今天有點辛苦呢 💙 可以多喝水休息一下～或許想找誰聊聊？",
      "低潮期總會過去的 🌱 要不要試試深呼吸，或者聽首喜歡的歌？",
      "辛苦了！記得照顧好自己，明天會更好的 ✨"
    ],
    2 => [
      "看起來今天有點累呢 😌 給自己一點時間放鬆吧",
      "適應期總是比較辛苦，你已經很努力了 💪",
      "今天可能不太順，但這都是成長的一部分 🌟"
    ],
    3 => [
      "感覺你在適應中，辛苦了 👍 保持這個節奏！",
      "還不錯呢！慢慢來，不用給自己太大壓力 😊",
      "平穩的一天，繼續加油！ 🎯"
    ],
    4 => [
      "看起來今天心情不錯呢！ 😄 保持這個好狀態",
      "很棒的一天！你的積極態度很有感染力 ✨",
      "感覺你越來越適應了，真為你開心！ 🌈"
    ],
    5 => [
      "哇！今天看起來超棒的！ 🎉 你的正能量很有感染力",
      "太棒了！這種好心情要好好保持下去 ✨",
      "你的笑容一定很燦爛！繼續發光發熱吧 🌟"
    ]
  }.freeze

  EMOJIS = {
    1 => "💙",
    2 => "😌",
    3 => "👍",
    4 => "😄",
    5 => "🎉"
  }.freeze

  def self.generate(score)
    feedbacks = FEEDBACKS[score] || FEEDBACKS[3]
    emoji = EMOJIS[score] || EMOJIS[3]

    {
      message: feedbacks.sample,
      emoji: emoji,
      score: score
    }
  end
end
