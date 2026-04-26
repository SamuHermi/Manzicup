#===============================================================================
#
#===============================================================================
class DungeonState
  attr_accessor :floorsexplored, :floorstoboss, :biome, :bossesdefeated, :trainers_on, :objects_on, :timer_start,
                :monster_attack

  NUM_BIOMES = 11
  TIME_ALLOWED = 30 * 60 # 10    # In seconds
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
    @floorstoboss = rand(3..7)
    @biome = rand(NUM_BIOMES)
    @bossesdefeated = 0
    @inProgress = true
    @trainers_on = 0
    @objects_on = 0
    $stats.dungeon_count += 1
    @monster_attack = false
    @timer_start = System.uptime
  end

  def expired?
    return false unless pbInDungeon?
    return false if TIME_ALLOWED <= 0

    System.uptime - timer_start >= TIME_ALLOWED
  end

  def loseDungeon
    $game_switches[RandomizedChallenge::Switch] = false
    if $game_variables[101] < 2
      $bag.remove_non_important
      pbMessage('\\w[]\\wm\\c[13]\\l[3]' +
      _INTL('Has perdido todos los objetos'))
    end
    pbEnd
  end

  def pbInDungeon?
    @inProgress
  end

  def pbEnd
    Console.echo_li('Dungeon ended')
    @inProgress = false
    $game_map.need_refresh = true
  end

  def advanceFloor
    @floorsexplored += 1
    @floorstoboss -= 1
    pbDungeonState.restartTimer

    for i in 0...$player.pokemon_count
      $player.party[i].hp += ($player.party[i].totalhp * (5.0 * $bag.quantity(:OVALCHARM) / 100.0)).floor
    end
  end

  def randomizeTrainers
    @trainers_on = 0
    @objects_on = 0
    return unless $game_map

    $game_map.events.each_value do |event|
      prob = rand(100)
      if event.name[/trainer/i]
        $game_self_switches[[$game_map.map_id, event.id, 'A']] = true
        if prob >= 50
          $game_self_switches[[$game_map.map_id, event.id, 'A']] = false
          @trainers_on += 1
        end
      end
      $game_self_switches[[$game_map.map_id, event.id, 'A']] = false if event.name[/environment/i]
      if event.name[/object/i]
        $game_self_switches[[$game_map.map_id, event.id, 'A']] = true
        if prob >= 25
          $game_self_switches[[$game_map.map_id, event.id, 'A']] = false
          @objects_on += 1
        end
      end
      next unless event.name[/Den/i]

      $game_self_switches[[$game_map.map_id, event.id, 'A']] = true
      $game_self_switches[[$game_map.map_id, event.id, 'A']] = false if prob >= 1
    end
    $game_map.need_refresh = true
  end

  def bossDefeat
    @bossesdefeated += 1
    @floorstoboss = rand(3..7)
    @biome = rand(NUM_BIOMES)
  end

  def restartTimer
    @timer_start = System.uptime
  end
end

def pbInDungeon?
  pbDungeonState.pbInDungeon?
end

def pbLoseDungeon
  Console.echo_li("\nDungeon lost")
  pbDungeonState.loseDungeon
end

def pbDungeonState
  $PokemonGlobal.dungeonState = DungeonState.new unless $PokemonGlobal.dungeonState
  $PokemonGlobal.dungeonState
end
