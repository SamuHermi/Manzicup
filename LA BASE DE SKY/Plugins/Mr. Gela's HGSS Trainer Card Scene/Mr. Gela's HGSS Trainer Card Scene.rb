# Overhauls the classic Trainer Card from Pokémon Essentials
class Player < Trainer
  # These need to be initialized
  # A swinging number, increases and decreases with progress
  attr_accessor(:score)
  # Changes the Trainer Card, similar to achievements
  attr_accessor(:stars)
  # Date and time
  attr_accessor(:halloffame)
  # Fake Trainer Class
  attr_accessor(:tclass)

  def score
    @score=0 if !@score
    return @score
  end

  def stars
    @stars=0 if !@stars
    return @stars
  end

  def halloffame
    @halloffame=[] if !@halloffame
    return @halloffame
  end

  def tclass
    @tclass="Entrenador Pokémon" if !@tclass
    return @tclass
  end

  def publicID(id = nil)   # Portion of the ID which is visible on the Trainer Card
    return id ? id&0xFFFF : @id&0xFFFF
  end

  def fullname2
    return _INTL("{1} {2}", $player.tclass, $player.name)
  end

  def initialize(name, trainer_type)
    super
    @character_ID          = -1
    @outfit                = 0
    @badges                = [false] * 8
    @money                 = GameData::Metadata.get.start_money
    @coins                 = 0
    @battle_points         = 0
    @soot                  = 0
    @pokedex               = Pokedex.new
    @has_pokedex           = false
    @has_pokegear          = false
    @has_running_shoes     = false
    @seen_storage_creator  = false
    @mystery_gift_unlocked = false
    @mystery_gifts         = []
    @score = 0
    @stars = 0
    @halloffame = []
    @tclass = "Entrenador Pokémon"
  end

  def getForeignID(number = nil)   # Random ID other than this Trainer's ID
    fid = 0
    fid = number if number != nil
    loop do
      fid = rand(256)
      fid |= rand(256) << 8
      fid |= rand(256) << 16
      fid |= rand(256) << 24
      break if fid != @id
    end
    return fid
  end

  def setForeignID(other, number = nil)
    @id=other.getForeignID(number)
  end
end

class HallOfFame_Scene # Minimal change to store HoF time into a variable

  def writeTrainerData
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    # Store time of first Hall of Fame in $player.halloffame if not array is empty
    if $player.halloffame = []
      $player.halloffame.push(pbGetTimeNow)
      $player.halloffame.push(totalsec)
    end
    pubid=sprintf("%05d", $player.publicID($player.id))
    lefttext= _INTL("Nombre<r>{1}<br>", $player.name)
    lefttext+=_INTL("Nº ID<r>{1}<br>", pubid)
    lefttext+=_ISPRINTF("Tiempo<r>{1:02d}:{2:02d}<br>", hour, min)
    lefttext+=_INTL("Pokédex<r>{1}/{2}<br>",
        $player.pokedex.owned_count, $player.pokedex.seen_count)
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new(lefttext)
    @sprites["messagebox"].viewport = @viewport
    @sprites["messagebox"].width = 192 if @sprites["messagebox"].width < 192
    @sprites["msgwindow"] = pbCreateMessageWindow(@viewport)
    pbMessageDisplay(@sprites["msgwindow"],
        _INTL("¡Campeón de la liga!\n¡Enhorabuena!\\^"))
  end

end

class PokemonTrainerCard_Scene

  # Waits x frames
  def wait(frames)
    frames.times do
    Graphics.update
    end
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    if @sprites["bg"]
       @sprites["bg"].ox -= 2
       @sprites["bg"].oy -= 2
    end
  end

  def pbStartScene
    @front = true
    @flip = false
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    bgName = "bg_"
    case $player.character_ID
      when 1
        bgName += "hermi"
      when 2
        bgName += "iria"
      when 3
        bgName += "jess"
      when 4
        bgName += "brais"
      when 5
        bgName += "isa"
      when 6
        bgName += "samer"
      when 7
        bgName += "rodri"
      when 8
        bgName += "bra"
      when 9
        bgName += "ana"
      when 10
        bgName += "pablo"  
      when 11
        bgName += "sabo" 
      when 12
        bgName += "nerea"
    end
    Console.echo_li(bgName)
    addBackgroundPlane(@sprites, "bg", "Trainer Card/"+bgName, @viewport)
    @sprites["card"] = IconSprite.new(128 * 2, 96 * 2, @viewport)
    @sprites["card"].setBitmap("Graphics/UI/Trainer Card/card_#{$player.stars}")
    @sprites["card"].zoom_x = 2 ; @sprites["card"].zoom_y = 2

    @sprites["card"].x=64
    @sprites["card"].oy = @sprites["card"].bitmap.height / 2

    @sprites["bg"].zoom_x = 2 ; @sprites["bg"].zoom_y = 2
    @sprites["bg"].ox += 6
    @sprites["bg"].oy -= 26
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)

    @sprites["overlay2"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay2"].bitmap)

    @sprites["overlay"].x = 128 * 2
    @sprites["overlay"].y = 96 * 2
    @sprites["overlay"].ox=@sprites["overlay"].bitmap.width / 2
    @sprites["overlay"].oy=@sprites["overlay"].bitmap.height / 2

    @sprites["help_overlay"] = IconSprite.new(0, Graphics.height - 48, @viewport)
    @sprites["help_overlay"].setBitmap("Graphics/UI/Trainer Card/overlay_0")
    @sprites["help_overlay"].zoom_x = 2 ; @sprites["help_overlay"].zoom_y = 2
    @sprites["trainer"] = IconSprite.new(318, 106, @viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($player.trainer_type))
    @sprites["trainer"].x =460
    @sprites["trainer"].y =40
  #  @sprites["trainer"].x += 140
   @sprites["trainer"].y += 40
   # @tx=@sprites["trainer"].x
   # @ty=@sprites["trainer"].y

    @sprites["trainer"].ox=@sprites["trainer"].bitmap.width / 2



    pbDrawTrainerCardFront
    pbFadeInAndShow(@sprites) { pbUpdate }
  end


  def flip1
    # "Flip"
    7.times do
      @sprites["overlay"].zoom_y = 1.03
      @sprites["card"].zoom_y = 2.06
      @sprites["overlay"].zoom_x -= 0.1
      @sprites["trainer"].zoom_x -= 0.2
      @sprites["trainer"].x -= 12
      @sprites["card"].zoom_x -= 0.15
      pbUpdate
      wait(1)
    end
      pbUpdate
  end

  def flip2
    # UNDO "Flip"
    7.times do
      @sprites["overlay"].zoom_x += 0.1
      @sprites["trainer"].zoom_x += 0.2
      @sprites["trainer"].x += 12
      @sprites["card"].zoom_x += 0.15
      @sprites["overlay"].zoom_y = 1
      @sprites["card"].zoom_y = 2
      pbUpdate
      wait(1)
    end
      pbUpdate
  end

  def pbDrawTrainerCardFront
    flip1 if @flip==true
    @front=true
    @sprites["trainer"].visible = true
    @sprites["card"].setBitmap("Graphics/UI/Trainer Card/card_#{$player.stars}")
    @overlay  = @sprites["overlay"].bitmap
    @overlay2 = @sprites["overlay2"].bitmap
    @overlay.clear
    @overlay2.clear
    base   = Color.new(72, 72, 72)
    shadow = Color.new(160, 160, 160)
    baseGold = Color.new(255, 198, 74)
    shadowGold = Color.new(123, 107, 74)
    if $player.stars == 5
      base   = baseGold
      shadow = shadowGold
    end
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = _ISPRINTF("{1:02d}:{2:02d}", hour, min)
    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
       pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
       $PokemonGlobal.startTime.day,
       $PokemonGlobal.startTime.year)
    textPositions = [
       [$player.name, 312 + 132 * 2, 70 + 8, 1, base, shadow],
       [_INTL("Nº ID"), 144+16, 70 + 12, 0, base, shadow],
       [sprintf("%05d", $player.publicID($player.id)), 468 - 80 * 2, 70 + 12, 1, base, shadow],
       [_INTL("DINERO"), 144+16, 118 + 12, 0, base, shadow],
       [_INTL("${1}", $player.money.to_s_formatted), 362 + 42, 118 + 12, 1, base, shadow],
       [_INTL("PUNTOS BATALLA"), 144+16, 118 + 60, 0, base, shadow],
       [sprintf("%d", $player.battle_points), 302 + 100, 118 + 60, 1, base, shadow],
       [_INTL("MEDALLAS"), 144+16, 214+28, 0, base, shadow],
       [sprintf("%d", $player.badge_count), 342 + 42, 214+28, 1, base, shadow],
       [_INTL("TIEMPO"), 144+16, 214 + 78, 0, base, shadow],
       [time, 202+ 88 * 2, 214 + 78, 1, base, shadow],
       [_INTL("COMIENZO AVENTURA"), 144+16, 262 + 60, 0, base, shadow],
       [starttime, 332 + 129 * 2, 262 + 60, 1, base, shadow]
    ]
    @sprites["overlay"].z += 10
    pbDrawTextPositions(@overlay, textPositions)
    textPositions = [
      [_INTL("Pulsa D para girar la tarjeta."), 16, 404, 0, Color.new(216, 216, 216), Color.new(80, 80, 80)]
    ]
    @sprites["overlay2"].z += 20
    pbDrawTextPositions(@overlay2, textPositions)
    flip2 if @flip == true
  end

  def pbDrawTrainerCardBack
    pbUpdate
    @flip = true
    flip1
    @front = false
    @sprites["trainer"].visible = false
    @sprites["card"].setBitmap("Graphics/UI/Trainer Card/card_#{$player.stars}b")
    @overlay  = @sprites["overlay"].bitmap
    @overlay2 = @sprites["overlay2"].bitmap
    @overlay.clear
    @overlay2.clear
    base   = Color.new(72, 72, 72)
    shadow = Color.new(160, 160, 160)
    baseGold = Color.new(255, 198, 74)
    shadowGold = Color.new(123, 107, 74)
    if $player.stars == 5
      base   = baseGold
      shadow = shadowGold
    end
    hof=[]
    if $player.halloffame!=[]
      hof.push(_INTL("{1} {2}, {3}",
      pbGetAbbrevMonthName($player.halloffame[0].mon),
      $player.halloffame[0].day,
      $player.halloffame[0].year))
      hour = $player.halloffame[1] / 60 / 60
      min = $player.halloffame[1] / 60 % 60
      time=_ISPRINTF("{1:02d}:{2:02d}", hour, min)
      hof.push(time)
    else
      hof.push("--- --, ----")
      hof.push("--:--")
    end
    textPositions = [
      [_INTL("DEBUT HALL DE LA FAMA"), 144+16, 50, 0, base, shadow],
      [hof[0], 352 + 89 * 2, 50, 1, base, shadow],
      [hof[1], 352 + 89 * 2, 100 - 16, 1, base, shadow],
      # These are meant to be Link Battle modes, use as you wish, see below
      #[_INTL(" "), 32 + 111 * 2, 112 - 16, 0, base, shadow],
      #[_INTL(" "), 32 + 176 * 2, 112 - 16, 0, base, shadow],

      [_INTL("V"), 144+16 + 111 * 2, 118 - 16 + 64, 0, base, shadow],
      [_INTL("D"), 144+16 + 176 * 2, 118 - 16 + 64, 0, base, shadow],

      [_INTL("V"), 144+16 + 111 * 2, 118 - 16 + 96, 0, base, shadow],
      [_INTL("D"), 144+16 + 176 * 2, 118 - 16 + 96, 0, base, shadow],

      # Customize "$game_variables[100]" to use whatever variable you'd like
      # Some examples: eggs hatched, berries collected,
      # total steps (maybe converted to km/miles? Be creative, dunno!)
      # Pokémon defeated, shiny Pokémon encountered, etc.
      # While I do not include how to create those variables, feel free to HMU
      # if you need some support in the process, or reply to the Relic Castle
      # thread.

      [_INTL($player.fullname2), 144+16, 118 - 16+28, 0, base, shadow],
      #[_INTL(" ", $game_variables[100]), 302 + 2 + 48 - 2, 112 - 16, 1, base, shadow],
      #[_INTL(" ", $game_variables[100]), 302 + 2 + 48 + 63 * 2, 112 - 16, 1, base, shadow],

      [_INTL("TEXTO 1"), 144+16, 118 + 60 - 16, 0, base, shadow],
      [_INTL("{1}", $game_variables[105]), 302 + 2 + 48 - 2, 118 + 60 - 16, 1, base, shadow],
      [_INTL("{1}", $game_variables[105]), 302 + 2 + 48 + 63 *2, 118 + 60 - 16, 1, base, shadow],

      [_INTL("TEXTO 2"), 144+16, 118 - 16 + 92, 0, base, shadow],
      [_INTL("{1}", $game_variables[105]), 302 + 2 + 48 - 2, 118 - 16 + 92, 1, base, shadow],
      [_INTL("{1}", $game_variables[105]), 302 + 2 + 48 + 63 * 2, 118 - 16 + 92, 1, base, shadow],
    ]
    @sprites["overlay"].z += 20
    pbDrawTextPositions(@overlay, textPositions)
    textPositions = [
      [_INTL("Pulsa D para girar la tarjeta."), 16, 404, 0, Color.new(216, 216, 216), Color.new(80, 80, 80)]
    ]
    @sprites["overlay2"].z += 20
    pbDrawTextPositions(@overlay2, textPositions)
    # Draw Badges on overlay (doesn't support animations, might support .gif)
    imagepos=[]
    # Draw Region 0 badges
    x = 160
    8.times do |i|
      if $player.badges[i + 0 * 8]
        imagepos.push(["Graphics/UI/Trainer Card/badges0", x, 238, i * 48, 0 * 48, 48, 48])
      end
      x += 48 + 8
    end
    # Draw Region 1 badges
    x = 160
    8.times do |i|
      if $player.badges[i + 1 * 8]
        imagepos.push(["Graphics/UI/Trainer Card/badges1", x, 248 + 52, i * 48, 0 * 48, 48, 48])
      end
      x += 48 + 8
    end
    #print(@sprites["overlay"].ox, @sprites["overlay"].oy, x)
    pbDrawImagePositions(@overlay, imagepos)
    flip2
  end

  def pbTrainerCard
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::SPECIAL)
        if @front == true
		 pbSEPlay("GUI trainer card flip")
          pbDrawTrainerCardBack
          wait(3)
        else
		  pbSEPlay("GUI trainer card flip")
          pbDrawTrainerCardFront if @front == false
          wait(3)
        end
      end
      if Input.trigger?(Input::BACK)
	  pbPlayCloseMenuSE
        break
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end


class PokemonTrainerCardScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end
