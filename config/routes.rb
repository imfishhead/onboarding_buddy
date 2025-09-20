Rails.application.routes.draw do
  root "home#index"             # 新的首頁 with tabs
  post "home/message", to: "home#create_message", as: :create_message

  get "onboarding", to: "my/onboarding#index"  # 保留原來的 onboarding 頁面

  namespace :my do
    get "onboarding", to: "onboarding#index"
    patch "onboarding/complete/:id", to: "onboarding#complete", as: :complete_task
    resources :mood_checkins, only: [ :create ]

    # Chatbot
    resources :chat, only: [ :index, :create ], controller: "chat"
  end
end
