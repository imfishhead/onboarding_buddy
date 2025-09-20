module Happiness
  class Accrual
    RULE_VERSION = "v1"

    def self.call(user:, source:, delta:, reason:, payload: {})
      wallet = user.happiness_wallet || user.create_happiness_wallet!

      # Initialize wallet with default values if nil
      if wallet.current_points.nil?
        wallet.update!(
          current_points: 0,
          lifetime_points: 0,
          level: 1,
          multiplier: 1.0,
          last_calculated_at: Time.current
        )
      end

      multiplier = wallet.multiplier || 1.0
      delta = (delta * multiplier).round
      new_balance = [ (wallet.current_points || 0) + delta, 0 ].max

      tx = HappinessTransaction.create!(
        user:, delta:, balance_after: new_balance,
        source_type: source.class.name.underscore,
        source_id: source.id,
        reason:, payload: payload.merge(rule_version: RULE_VERSION),
        occurred_at: Time.current
      )
      current_lifetime = wallet.lifetime_points || 0
      new_lifetime = current_lifetime + [ delta, 0 ].max

      wallet.update!(
        current_points: new_balance,
        lifetime_points: new_lifetime,
        last_calculated_at: Time.current,
        level: compute_level(new_lifetime)
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
