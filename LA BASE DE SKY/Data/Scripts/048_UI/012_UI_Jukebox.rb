#===============================================================================
#
#===============================================================================
class PokemonJukebox_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands)
    @commands = commands
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/UI/jukebox_bg"))
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Reproductor"), 2, -18, 128, 64, @viewport
    )
    @sprites["header"].baseColor   = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.black
    @sprites["header"].windowskin  = nil
    @sprites["commands"] = Window_CommandPokemon.newWithSize(
      @commands, 94, 92, 324, 224, @viewport
    )
    @sprites["commands"].windowskin = nil
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        break
      elsif Input.trigger?(Input::USE)
        ret = @sprites["commands"].index
        break
      end
    end
    return ret
  end

  def pbSetCommands(newcommands, newindex)
    @sprites["commands"].commands = (!newcommands) ? @commands : newcommands
    @sprites["commands"].index    = newindex
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonJukeboxScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdPallet   = -1
    cmdRaiz     = -1
    cmdEpic     = -1
    cmdGenshin  = -1
    cmdBaldur   = -1
    cmdHonkai   = -1
    cmdStardew  = -1
    cmdYTTD     = -1
    cmdSona     = -1
    cmdDuki     = -1
    cmdPersona  = -1
    cmdTurnOff  = -1
    commands[cmdPallet = commands.length]    = _INTL("Play: Pokémon RBY - Pueblo Paleta")
    commands[cmdRaiz = commands.length]      = _INTL("Play: Pokémon ORAS - Villa Raíz")
    commands[cmdEpic = commands.length]      = _INTL("Play: Epic Seven - The Pub on a Sleepy Afternoon")
    commands[cmdGenshin = commands.length]   = _INTL("Play: Genshin Impact - Loading Screen Music Theme #2")
    commands[cmdBaldur = commands.length]    = _INTL("Play: Baldur's Gate 3 - Down By The River")
    commands[cmdHonkai = commands.length]    = _INTL("Play: Honkai Star Rail - Space Walk")
    commands[cmdStardew = commands.length]   = _INTL("Play: Stardew Valley - Stardew Valley Overture")
    commands[cmdYTTD = commands.length]      = _INTL("Play: Umineko no Naku Koro ni- Movie passing by")
    commands[cmdSona = commands.length]      = _INTL("Play: League of Legends - DJ Sona Music_ Ethereal")
    commands[cmdPersona = commands.length]   = _INTL("Play: Persona 5 - Beneath the Mask Rain")
    commands[cmdDuki = commands.length]      = _INTL("Play: DUKI - Malbec (Piano)")
    commands[cmdTurnOff = commands.length]   = _INTL("Stop")
    commands[commands.length]                = _INTL("Salir")
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd < 0
        pbPlayCloseMenuSE
        break
      elsif cmdPallet >= 0 && cmd == cmdPallet
        pbPlayDecisionSE
        pbBGMPlay("Pokémon RBY - Pueblo Paleta", 100, 100)
        $game_variables[95] = "Pokémon RBY - Pueblo Paleta"
      elsif cmdRaiz >= 0 && cmd == cmdRaiz
        pbPlayDecisionSE
        pbBGMPlay("Pokémon ORAS - Villa Raíz", 100, 100)
        $game_variables[95] = "Pokémon ORAS - Villa Raíz"        
      elsif cmdEpic >= 0 && cmd == cmdEpic
        pbPlayDecisionSE
        pbBGMPlay("Epic Seven - The Pub on a Sleepy Afternoon", 100, 100)
        $game_variables[95] = "Epic Seven - The Pub on a Sleepy Afternoon"
      elsif cmdGenshin >= 0 && cmd == cmdGenshin
        pbPlayDecisionSE
        pbBGMPlay("Genshin Impact - Loading Screen Music Theme #2", 100, 100)
        $game_variables[95] = "Genshin Impact - Loading Screen Music Theme #2"
      elsif cmdBaldur >= 0 && cmd == cmdBaldur
        pbPlayDecisionSE
        pbBGMPlay("Baldur's Gate 3 - Down By The River", 100, 100)       
        $game_variables[95] = "Baldur's Gate 3 - Down By The River"         
      elsif cmdHonkai >= 0 && cmd == cmdHonkai
        pbPlayDecisionSE
        pbBGMPlay("Honkai Star Rail - Space Walk", 100, 100) 
        $game_variables[95] = "Honkai Star Rail - Space Walk"       
      elsif cmdStardew >= 0 && cmd == cmdStardew
        pbPlayDecisionSE
        pbBGMPlay("Stardew Valley - Stardew Valley Overture", 100, 100)  
        $game_variables[95] = "Stardew Valley - Stardew Valley Overture"          
      elsif cmdYTTD >= 0 && cmd == cmdYTTD
        pbPlayDecisionSE
        pbBGMPlay("Umineko - Movie passing by", 100, 100)   
        $game_variables[95] = "Umineko - Movie passing by"         
      elsif cmdSona >= 0 && cmd == cmdSona
        pbPlayDecisionSE
        pbBGMPlay("League of Legends - DJ Sona Music_ Ethereal", 100, 100)    
        $game_variables[95] = "League of Legends - DJ Sona Music_ Ethereal"          
      elsif cmdPersona >= 0 && cmd == cmdPersona
        pbPlayDecisionSE
        pbBGMPlay("Persona 5 - Beneath the Mask Rain", 100, 100)      
        $game_variables[95] = "Persona 5 - Beneath the Mask Rain"           
      elsif cmdDuki >= 0 && cmd == cmdDuki
        pbPlayDecisionSE
        pbBGMPlay("DUKI - Malbec (Piano)", 100, 100)      
        $game_variables[95] = "DUKI - Malbec (Piano)"          
      elsif cmdTurnOff >= 0 && cmd == cmdTurnOff
        pbPlayDecisionSE
        $game_system.setDefaultBGM(nil)
        pbBGMPlay(pbResolveAudioFile($game_map.bgm_name, $game_map.bgm.volume, $game_map.bgm.pitch))
        if $PokemonMap
          $PokemonMap.lower_encounter_rate = false
          $PokemonMap.higher_encounter_rate = false
        end
      else   # Exit
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
  end
end

