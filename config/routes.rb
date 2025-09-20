Rails.application.routes.draw do
  root "my/onboarding#index"    # 仍保留 US1 首頁

  namespace :my do
    get "onboarding", to: "onboarding#index"
    patch "onboarding/complete/:id", to: "onboarding#complete", as: :complete_task
    resources :mood_checkins, only: [ :create ]

    # Chatbot
    resources :chat, only: [ :index, :create ], controller: "chat"
  end
end
