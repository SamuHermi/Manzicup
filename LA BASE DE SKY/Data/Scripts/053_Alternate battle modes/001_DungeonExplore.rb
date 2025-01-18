#===============================================================================
#
#===============================================================================
class DungeonState
    attr_accessor :floorsexplored
    attr_accessor :floorstoboss
    attr_accessor :biome
    attr_accessor :bossesdefeated


    def initialize
        @floorsexplored = 0
        @floorstoboss = 0
        @bossesdefeated = 0
        @inProgress = false
    end
    
    def pbStart
      @floorsexplored = 0
      @floorstoboss = 3 + rand(5)
      @biome = rand(6)
      @bossesdefeated = 0
      @inProgress = true      
    end

    def loseDungeon
        $player.party.clear()
        pbMessage("\\w[]\\wm\\c[13]\\l[3]" +
        _INTL("¡Todos tus Pokémon te han abandonado!"))


        coins_obtained = (3*$player.money**0.9/(100) + 5*Math.exp(-$player.money))
        coins_obtained = coins_obtained.ceil()
        pbMessage("\\w[]\\wm\\c[13]\\l[3]" +
        _INTL("Todo tu dinero se ha convertido en monedas.\nHas conseguido {1} monedas",coins_obtained))  
        $player.coins += coins_obtained
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
    end

    def advanceFloor()
      @floorsexplored += 1
      @floorstoboss -= 1
    end

    def bossDefeat()
      @bossesdefeated +=1
      @floorstoboss = 3 + rand(5)
      @biome = rand(6)
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