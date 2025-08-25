

module Enumerable	
  def max_nth(n)
    inject([]) do |acc, x|
      (acc + [x]).sort[[acc.size-(n-1), 0].max..-1]
    end.first
  end	
end

class Pokemon
  attr_accessor :trainerevs
  # Max total EVs
  EV_LIMIT      = 0  # DemICE edit
  # Max EVs that a single stat can have
  EV_STAT_LIMIT = 0  # DemICE edit

  
  # Recalculates this Pokémon's stats.
  alias mixed_ev_alloc_calc_stats calc_stats
  def calc_stats
    #DemICE failsafe for the new EV system
    evpool=80+self.level*8
    evpool=(evpool.div(4))*4      
    evpool=512 if evpool>512 
    evcap=40+@level*4
    evcap=(evcap.div(4))*4
    evcap=252 if evcap>252
    evsum=@ev[:HP]+@ev[:ATTACK]+@ev[:DEFENSE]+@ev[:SPECIAL_DEFENSE]+@ev[:SPEED]
		evsum+=@ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
    #EV_LIMIT = evpool
    if evsum>evpool
      GameData::Stat.each_main do |s|
        coef_reduc = evpool.to_f/evsum
        #Console.echo_li(evsum.to_s + "/" + evpool.to_s + " = " + coef_reduc.to_s)
        #Console.echo_li("EV: " + @ev[s.id].to_s + "Máximo: " + evcap.to_s + "\n")
        @ev[s.id] = ((@ev[s.id] * coef_reduc) / 4).floor * 4
      end  
    end
    if !Settings::PURIST_MODE 
      @ev[:SPECIAL_ATTACK]=@ev[:ATTACK]
    end  
    mixed_ev_alloc_calc_stats
  end
end  

 