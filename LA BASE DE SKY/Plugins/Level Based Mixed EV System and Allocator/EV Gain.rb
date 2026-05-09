# -------------------------------------------------------------------------------
# Redistributes a Pokémon's EVs proportionally when it gains levels.
# Preserves the ratio between stats, fills the new pool, respects evcap,
# and corrects rounding remainders by assigning leftover EVs to the stats
# with the highest proportional claim that haven't yet hit the cap.
# -------------------------------------------------------------------------------
def pbRedistributeEVsForLevel(pkmn, new_level)
  new_evpool = 80 + new_level * 8
  new_evpool = new_evpool.div(4) * 4
  new_evpool = 512 if new_evpool > 512
  new_evcap  = 40 + new_level * 4
  new_evcap  = new_evcap.div(4) * 4
  new_evcap  = 252 if new_evcap > 252

  stat_ids = []
  GameData::Stat.each_main { |s| stat_ids << s.id }
  stat_ids.delete(:SPECIAL_ATTACK) unless Settings::PURIST_MODE

  evsum = stat_ids.sum { |s| pkmn.ev[s] }
  return if evsum == 0 # no EVs assigned yet — nothing to redistribute

  # Calculate proportions from current EVs
  proportions = {}
  stat_ids.each { |s| proportions[s] = pkmn.ev[s].to_f / evsum }

  # First pass: assign proportional share, floor, respect cap
  assigned = 0
  new_evs = {}
  fractionals = {}
  stat_ids.each do |s|
    raw   = new_evpool * proportions[s]
    value = [raw.floor, new_evcap].min
    new_evs[s]      = value
    fractionals[s]  = raw - raw.floor
    assigned       += value
  end

  # Second pass: distribute remainder by largest fractional part first
  remainder = new_evpool - assigned
  if remainder > 0
    sorted = fractionals.sort_by { |_, frac| -frac }.map(&:first)
    sorted.each do |s|
      break if remainder <= 0
      next if new_evs[s] >= new_evcap

      add = [1, new_evcap - new_evs[s], remainder].min
      new_evs[s] += add
      remainder  -= add
    end
  end

  # Apply new EVs
  stat_ids.each { |s| pkmn.ev[s] = new_evs[s] }
  pkmn.ev[:SPECIAL_ATTACK] = pkmn.ev[:ATTACK] unless Settings::PURIST_MODE
  pkmn.calc_stats
end

alias mixed_ev_alloc_pbChangeLevel pbChangeLevel
def pbChangeLevel(pkmn, new_level, scene)
  if new_level > pkmn.level
    # DemICE edit — redistribute EVs proportionally to the new pool
    pbRedistributeEVsForLevel(pkmn, new_level)
    # DemICE end
  elsif new_level < pkmn.level
    GameData::Stat.each_main do |s|
      pkmn.calc_stats if pkmn.ev[s.id] = 0
    end
  end
  mixed_ev_alloc_pbChangeLevel(pkmn, new_level, scene)
end

class Battle
  alias mixed_ev_alloc_pbGainExpOne pbGainExpOne
  def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    pkmn = pbParty(0)[idxParty] # The Pokémon gaining Exp from defeatedBattler
    current_level = pkmn.level
    mixed_ev_alloc_pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages)

    if pkmn.level > current_level
      # DemICE edit — redistribute EVs proportionally to the new pool
      pbRedistributeEVsForLevel(pkmn, pkmn.level)
      pkmn.calc_stats
      # DemICE end
    elsif pkmn.level < current_level
      GameData::Stat.each_main do |s|
        pkmn.calc_stats if pkmn.ev[s.id] = 0
      end
    end
  end

  def pbGainEVsOne(idxParty, defeatedBattler)
    nil
  end
end
