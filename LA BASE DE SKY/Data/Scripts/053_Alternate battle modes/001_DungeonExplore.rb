#===============================================================================
#
#===============================================================================
class DungeonState
    attr_accessor :floorsexplored
    attr_accessor :floorstoboss
    attr_accessor :biome
    attr_accessor :bossesdefeated
    attr_accessor :trainers_on
    attr_accessor :objects_on
    attr_accessor :timer_start
    attr_accessor :monster_attack

    NUM_BIOMES = 11
    TIME_ALLOWED = 30*60#10    # In seconds
    def initialize
        @floorsexplored = 0
        @floorstoboss = 0
        @bossesdefeated = 0
        @trainers_on = 0
        @objects_on = 0
        @inProgress = false
        @monster_attack = false
    end
    
    def pbStart
      @floorsexplored = 0
      @floorstoboss = 3 + rand(5)
      @biome = rand(NUM_BIOMES)
      @bossesdefeated = 0
      @inProgress = true     
      @trainers_on = 0
      @objects_on = 0
      $stats.dungeon_count += 1
      @monster_attack = false
      $player.party.each do |pkmn|
        pkmn.species = pkmn.species_data.get_baby_species
        pkmn.level = 5
        pkmn.calc_stats
        pkmn.reset_moves
        next false if pkmn.ev.values.none? { |ev| ev > 0 }
        #GameData::Stat.each_main { |s| pkmn.ev[s.id] = 0 }
      end
    end

    def loseDungeon
        $player.party.clear()
        pbMessage("\\w[]\\wm\\c[13]\\l[3]" +
        _INTL("¡Todos tus Pokémon te han abandonado!"))

        if $player.money > 0
          coins_obtained = (3*$player.money**0.9/(100) + 5*Math.exp(-$player.money))
          coins_obtained = coins_obtained.ceil()
        else
          coins_obtained = 0
        end
        $game_switches[RandomizedChallenge::Switch] = false
        pbMessage("\\w[]\\wm\\c[13]\\l[3]" +
        _INTL("Todo tu dinero se ha convertido en monedas.\nHas conseguido {1} monedas",coins_obtained))  
        $player.battle_points += coins_obtained
        $player.money = 0
        $bag.remove_non_important()
        pbMessage("\\w[]\\wm\\c[13]\\l[3]" +
        _INTL("Has perdido todos los objetos"))  
      
      pbEnd
    end
    
    def pbInDungeon?
        return @inProgress
    end

    def pbEnd
        @inProgress = false
        $game_map.need_refresh = true
        $game_variables[LevelCapsEX::LEVEL_CAP_VARIABLE] = 100
    end

    def advanceFloor()
      @floorsexplored += 1
      @floorstoboss -= 1
      pbDungeonState.restartTimer

      for i in 0...$player.pokemon_count
            $player.party[i].hp += ($player.party[i].totalhp * (5.0 * $bag.quantity(:OVALCHARM)/ 100.0)).floor
      end
    end

    def randomizeTrainers()
      @trainers_on = 0
      @objects_on = 0
      if $game_map
        $game_map.events.each_value do |event|
          prob = rand(100)
          if event.name[/trainer/i]
            $game_self_switches[[$game_map.map_id, event.id, "A"]] = true
            if prob >= 50
              $game_self_switches[[$game_map.map_id, event.id, "A"]] = false   
              @trainers_on += 1       
            end
          end
          if event.name[/environment/i]
            $game_self_switches[[$game_map.map_id, event.id, "A"]] = false
          end
          if event.name[/object/i]
            $game_self_switches[[$game_map.map_id, event.id, "A"]] = true
            if prob >= 25
              $game_self_switches[[$game_map.map_id, event.id, "A"]] = false    
              @objects_on += 1       
            end
          end          
        end
        $game_map.need_refresh = true
        
      end
    end

    def bossDefeat
      @bossesdefeated +=1
      @floorstoboss = 3 + rand(5)
      @biome = rand(NUM_BIOMES)
    end

    def restartTimer
      @timer_start = System.uptime
    end
end

def pbInDungeon?
  return pbDungeonState.pbInDungeon?
end
  
def pbLoseDungeon
  pbDungeonState.loseDungeon
end

def pbDungeonState
  $PokemonGlobal.dungeonState = DungeonState.new if !$PokemonGlobal.dungeonState
  return $PokemonGlobal.dungeonState
end