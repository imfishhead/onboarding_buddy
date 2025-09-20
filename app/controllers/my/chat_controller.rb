class My::ChatController < ApplicationController
  layout "mobile"
  helper_method :current_user, :current_session

  def current_user
    # 與 US1 相同：用 ?as=email 切換 demo 身份
    User.find_by(email: params[:as]) || User.first
  end

  def current_session
    @current_session ||= begin
      session_id = session[:llm_session_id]
      s = session_id && LlmSession.find_by(id: session_id, user_id: current_user.id)
      s ||= LlmSession.create!(user: current_user, channel: :app, purpose: :faq, started_at: Time.current)
      session[:llm_session_id] = s.id
      s
    end
  end

  def index
    @messages = current_session.llm_messages.order(:created_at)
  end

  def create
    # 1) 存一筆使用者訊息
    user_msg = current_session.llm_messages.create!(
      role: :user,
      content: params[:q].to_s,
      meta: { lang: "zh-TW" }
    )

    # 2) 呼叫 LLM（先用 stub，同學之後換掉）
    reply_text, reply_meta = Llm::Client.reply(user: current_user, session: current_session, message: user_msg)

    # 3) 存一筆助理訊息
    current_session.llm_messages.create!(
      role: :assistant,
      content: reply_text,
      meta: reply_meta
    )

    redirect_to my_chat_index_path(as: params[:as])
  end
end
