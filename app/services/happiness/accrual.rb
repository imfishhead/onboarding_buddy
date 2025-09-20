module Happiness
  class Accrual
    RULE_VERSION = "v1"

    def self.call(user:, source:, delta:, reason:, payload: {})
      wallet = user.happiness_wallet || user.create_happiness_wallet!
      delta  = (delta * wallet.multiplier).round
      new_balance = [ wallet.current_points + delta, 0 ].max

      tx = HappinessTransaction.create!(
        user:, delta:, balance_after: new_balance,
        source_type: source.class.name.underscore,
        source_id: source.id,
        reason:, payload: payload.merge(rule_version: RULE_VERSION),
        occurred_at: Time.current
      )
      wallet.update!(
        current_points: new_balance,
        lifetime_points: wallet.lifetime_points + [ delta, 0 ].max,
        last_calculated_at: Time.current,
        level: compute_level(wallet.lifetime_points + [ delta, 0 ].max)
      )
      tx
    end

    def self.compute_level(lifetime_points)
      case lifetime_points
      when 0..29   then 1
      when 30..59  then 2
      when 60..99  then 3
      else              4
      end
    end
  end
end
