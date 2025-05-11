EventHandlers.add(:on_frame_update, :achievement_message_queue,
proc {
  if !$achievementmessagequeue.nil?
    $achievementmessagequeue.each_with_index {|m,i|
    $achievementmessagequeue.delete_at(i)
    Kernel.pbMessage(m)
    }
  end
})

EventHandlers.add(:on_step_taken, :achievement_step_count,
proc {
  if !$PokemonGlobal.stepcount.nil?
    Achievements.setProgress("STEPS",$PokemonGlobal.stepcount)
  end
})

EventHandlers.add(:on_wild_species_chosen, :achievement_battle_count,
proc { |encounter|
    Achievements.incrementProgress("WILD_ENCOUNTERS",1)
})

EventHandlers.add(:on_trainer_load, :achievement_battle_count,
proc { |trainer|
    Achievements.incrementProgress("TRAINER_BATTLES",1)
})

EventHandlers.add(:on_end_battle, :achievement_pokemon_caught,
proc { |decision|
  if decision==4
    Achievements.incrementProgress("POKEMON_CAUGHT",1)
  end
})

class Battle
  alias achieve_pbMegaEvolve pbMegaEvolve
  def pbMegaEvolve(index)
    achieve_pbMegaEvolve(index)
    return if !pbOwnedByPlayer?(index)
    if @battlers[index].mega?
      Achievements.incrementProgress("MEGA_EVOLUTIONS",1)
    end
  end
end
alias achieve_pbItemBall pbItemBall
def pbItemBall(*args)
  ret=achieve_pbItemBall(*args)
  Achievements.incrementProgress("ITEM_BALL_ITEMS",1) if ret
  return ret
end