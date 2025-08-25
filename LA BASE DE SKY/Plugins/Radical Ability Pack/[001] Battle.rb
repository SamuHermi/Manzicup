class Battle
  # Added Phoenix Down
  attr_accessor :phoenixDown
  alias rr_initialize initialize
  def initialize(scene, p1, p2, player, opponent)
    rr_initialize(scene, p1, p2, player, opponent)
    @phoenixDown = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
  end

  # Aliased for Frozen Mist and Mountaineer.
  alias rr_pbEntryHazards pbEntryHazards
  def pbEntryHazards(battler)
    return if battler.hasActiveAbility?(:FROZENMIST) && !@moldBreaker
    battler_side = battler.pbOwnSide
    if battler_side.effects[PBEffects::StealthRock] 
      if battler.takesIndirectDamage? &&
       GameData::Type.exists?(:ROCK) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS) &&
       (!battler.hasActiveAbility?(:MOUNTAINEER) && !@moldBreaker)
        bTypes = battler.pbTypes(true)
        eff = Effectiveness.calculate(:ROCK, *bTypes)
        if !Effectiveness.ineffective?(eff)
          battler.pbReduceHP(battler.totalhp * eff / 8, false)
          pbDisplay(_INTL("Pointed stones dug into {1}!", battler.pbThis))
          battler.pbItemHPHealCheck
        end
      end
    else
      rr_pbEntryHazards(battler)
    end
  end
end