User.destroy_all
OnboardingTask.destroy_all
TaskAssignment.destroy_all

alice = User.create!(email: "alice@tsmc.com", name: "Alice Chen", start_date: Date.today - 3)
bob   = User.create!(email: "bob@tsmc.com",   name: "Bob Wu",   start_date: Date.today - 1)

t1 = OnboardingTask.create!(title: "觀看入門安全訓練影片", description: "30 分鐘 e-learning", required: true,  order_num: 1)
t2 = OnboardingTask.create!(title: "設定公司信箱與 SSO",  description: "完成密碼重設與 2FA", required: true,  order_num: 2)
t3 = OnboardingTask.create!(title: "加入部門 Slack/Line 群", description: "認識同事",       required: false, order_num: 3)
t4 = OnboardingTask.create!(title: "提交員工資料表",     description: "基本個資/薪資帳戶", required: true,  order_num: 4)

[ t1, t2, t3, t4 ].each_with_index do |task, i|
  TaskAssignment.create!(user: alice, onboarding_task: task, due_date: Date.today + i)
  TaskAssignment.create!(user: bob,   onboarding_task: task, due_date: Date.today + i)
end

puts "Seed done. Visit: http://localhost:3000/?as=alice@tsmc.com"
