#===============================================================================
# Primal Reversion.
#===============================================================================


#-------------------------------------------------------------------------------
# Game stat tracking for Primal Reversion.
#-------------------------------------------------------------------------------
class GameStats
  alias manzi_initialize initialize
  def initialize
    manzi_initialize
    @manzi_reversion_count = 0
  end

  def manzi_reversion_count
    return @manzi_reversion_count || 0
  end
  
  def manzi_reversion_count=(value)
    @manzi_reversion_count = 0 if !@manzi_reversion_count
    @manzi_reversion_count = value
  end
end

#-------------------------------------------------------------------------------
# Updates to Primal Reversion battle scripts.
#-------------------------------------------------------------------------------
class Battle
  def pbManziform(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon || battler.fainted?
    return if !battler.hasManzi?  || battler.manzi?
    return if battler.form != MultipleForms.call("getUnmanziForm", battler)
    $stats.manzi_reversion_count += 1 if battler.pbOwnedByPlayer?
    pbDeluxeTriggers(idxBattler, nil, "BeforePrimalReversion", battler.species, *battler.pokemon.types)
    @scene.pbAnimateSubstitute(idxBattler, :hide)
    pbAnimateManziForm(battler)
    pbDisplay(_INTL("¡Forma personal de {1}!\n¡Ha asimilado una nueva forma!", battler.pbThis))
    pbDeluxeTriggers(idxBattler, nil, "AfterPrimalReversion", battler.species, *battler.pokemon.types)
    @scene.pbAnimateSubstitute(idxBattler, :show)
  end
  
  def pbAnimateManziForm(battler)

    if Settings::SHOW_PRIMAL_ANIM && $PokemonSystem.battlescene == 0
      @scene.pbShowManziForm(battler.index)
      battler.pokemon.makeManzi
      battler.form_update(true)
    else
      @scene.pbRevertBattlerStart(battler.index)
      battler.pokemon.makeManzi
      battler.form_update(true)
      @scene.pbRevertBattlerEnd
    end
  end
end

#-------------------------------------------------------------------------------
# Used to more easily obtain Primal form data for the animation.
#-------------------------------------------------------------------------------
class Pokemon
  def getManziForm
    v = MultipleForms.call("getManziForm", self)
    return v || @form
  end
  
  def getUnmanziForm
    v = MultipleForms.call("getUnmanziForm", self)
    return v || 0
  end
end

#===============================================================================
# Battle animation for triggering Primal Reversion.
#===============================================================================
class Battle::Scene::Animation::BattlerManziForm < Battle::Scene::Animation
  def initialize(sprites, viewport, idxBattler, battle)
    @idxBattler = idxBattler
    #---------------------------------------------------------------------------
    # Gets Pokemon data from battler index.
    @battle = battle
    @battler = @battle.battlers[idxBattler]
    @opposes = @battle.opposes?(idxBattler)
    @pkmn = @battler.pokemon
    @primal = {
      :pokemon => @pkmn,
      :species => @pkmn.species,
      :gender  => @pkmn.gender,
      :form    => @pkmn.getManziForm,
      :shiny   => @pkmn.shiny?,
      :shadow  => @pkmn.shadowPokemon?,
      :hue     => @pkmn.super_shiny_hue
    }
    @cry_file = GameData::Species.cry_filename(@primal[:species], @primal[:form])
    trainer = @battle.pbGetOwnerFromBattlerIndex(@idxBattler)
    Console.echo_li(trainer.trainer_type.to_s)
    @trainer_file = GameData::TrainerType.front_sprite_filename(trainer.trainer_type)
    case trainer.trainer_type
    when :ANA then @bg_color = MessageConfig::ANA_TEXT_COLOR
    when :BRAIS then @bg_color = MessageConfig::BRAIS_TEXT_COLOR
    when :BRA then @bg_color = MessageConfig::BRA_TEXT_COLOR  
    when :HERMI then @bg_color = MessageConfig::HERMI_TEXT_COLOR  
    when :IRIA then @bg_color = MessageConfig::IRIA_TEXT_COLOR 
    when :ISA then @bg_color = MessageConfig::ISA_TEXT_COLOR   
    when :NEREA then @bg_color = MessageConfig::NEREA_TEXT_COLOR  
    when :PABLO then @bg_color = MessageConfig::PABLO_TEXT_COLOR  
    when :RODRI then @bg_color = MessageConfig::RODRI_TEXT_COLOR  
    when :SABO then @bg_color = MessageConfig::SABO_TEXT_COLOR 
    when :SAMER then @bg_color = MessageConfig::SAMER_TEXT_COLOR   
    else               @bg_color = Color.new(0, 0, 0, 180)
    end
    #---------------------------------------------------------------------------
    # Gets background and animation data.
    @path = Settings::DELUXE_GRAPHICS_PATH
    backdropFilename, baseFilename = @battle.pbGetBattlefieldFiles
    @bg_file   = "Graphics/Battlebacks/" + backdropFilename + "_bg"
    @base_file = "Graphics/Battlebacks/" + baseFilename + "_base1"
    super(sprites, viewport)
  end
  
  #-----------------------------------------------------------------------------
  # Plays the animation.
  #-----------------------------------------------------------------------------
  def createProcesses
    delay = 0
    center_x, center_y = Graphics.width / 2, Graphics.height / 2
    #---------------------------------------------------------------------------
    # Sets up background.
    bgData = dxSetBackdrop(@path + "Primal/bg", @bg_file, delay)
    picBG, sprBG = bgData[0], bgData[1]
    #---------------------------------------------------------------------------
    # Sets up bases.
    baseData = dxSetBases(@path + "Primal/base", @base_file, delay, center_x, center_y)
    arrBASES = baseData[0]
    #---------------------------------------------------------------------------
    # Sets up overlay.
    overlayData = dxSetOverlay(@path + "burst", delay)
    picOVERLAY, sprOVERLAY = overlayData[0], overlayData[1]
    #---------------------------------------------------------------------------
    # Sets up battler.
    pokeData = dxSetPokemon(@pkmn, delay, !@opposes)
    picPOKE, sprPOKE = pokeData[0], pokeData[1]
    baseData = dxSetBases(@path + "Mega/base", @base_file, delay, center_x, center_y, true)
    arrBASES, base_width = baseData[0], baseData[1]
    arrBASES.last.setVisible(0, false)
    trData = dxSetTrainerWithItem(@trainer_file, @item_file, delay, !@opposes, base_width)
    picTRAINER = trData
    #---------------------------------------------------------------------------
    # Animation objects.
    shineData = dxSetSprite(@path + "shine", delay, center_x, center_y)
    picSHINE, sprSHINE = shineData[0], shineData[1]
    #---------------------------------------------------------------------------
    # Sets up Primal Pokemon.
    arrPOKE = dxSetPokemonWithOutline(@primal, delay, !@opposes)
    arrPOKE.last[0].setColor(delay, Color.white)
    #---------------------------------------------------------------------------
    # Animation objects.
    arrPARTICLES = dxSetParticles(@path + "particle", delay, center_x, center_y, 200)
    pulseData = dxSetSprite(@path + "pulse", delay, center_x, center_y, PictureOrigin::CENTER, 100, 50)
    picPULSE, sprPULSE = pulseData[0], pulseData[1]
    #---------------------------------------------------------------------------
    # Sets up skip button & fade out.
    picBUTTON = dxSetSkipButton(delay)
    picFADE = dxSetFade(delay)
    ############################################################################
    # Animation start.
    ############################################################################
    # Fades in scene.
    picFADE.moveOpacity(delay, 8, 255)
    delay = picFADE.totalDuration
    picBG.setVisible(delay, true)
    arrBASES.first.setVisible(delay, true)
    picPOKE.setVisible(delay, true)
    picFADE.moveOpacity(delay, 8, 0)
    delay = picFADE.totalDuration

    picTRAINER.setVisible(delay + 4, true)
    arrBASES.first.setVisible(delay + 4, true)
    delta = (base_width.to_f * 0.75).to_i
    delta = -delta if @opposes

    picBUTTON.moveDelta(delay, 6, 0, -38)
    picBUTTON.moveDelta(delay + 36, 6, 0, 38)
    picTRAINER.setVisible(delay + 4, true)
    picTRAINER.moveDelta(delay + 4, 8, delta, 0)
    delay = picTRAINER.totalDuration + 1
    #---------------------------------------------------------------------------
    # Darkens background/base tone; brightens Pokemon to white.
    picPOKE.setSE(delay, "DX Action")
    picBG.moveTone(delay, 15, Tone.new(-200, -200, -200))
    arrBASES.first.moveTone(delay, 15, Tone.new(-200, -200, -200))
    picPOKE.moveTone(delay, 8, Tone.new(-255, -255, -255, 255))
    picPOKE.moveColor(delay + 8, 6, Color.white)
    picTRAINER.moveTone(delay, 8, Tone.new(-255, -255, -255, 255))
    picTRAINER.moveColor(delay + 8, 6, Color.white)    
    #---------------------------------------------------------------------------
    # Particles begin drawing in to Pokemon.
    repeat = delay
    2.times do |t|
      repeat -= 4 if t > 0
      arrPARTICLES.each_with_index do |p, i|
        p[0].setVisible(repeat + i, true)
        p[0].moveXY(repeat + i, 4, center_x, center_y)
        repeat = p[0].totalDuration
        p[0].setVisible(repeat + i, false)
        p[0].setXY(repeat + i, p[1], p[2])
        p[0].setZoom(repeat + i, 100)
        repeat = p[0].totalDuration - 2
      end
    end
    particleEnd = arrPARTICLES.last[0].totalDuration
    delay = picPOKE.totalDuration + 4
    #---------------------------------------------------------------------------
    #delay = picORB2.totalDuration
    picSHINE.setVisible(delay, true)
    picSHINE.moveOpacity(delay, 4, 255)
    if @bg_color
      picBG.moveColor(delay, 12, @bg_color)
      arrBASES.first.moveColor(delay, 12, @bg_color)
      picTRAINER.moveColor(delay, 12, @bg_color)
    end
    t = 0.5
    arrPOKE.each { |p, s| p.setVisible(delay + 6, true) }

    #picORB.moveZoom(delay + 6, 8, 1000)
    #picORB.moveOpacity(delay + 6, 8, 0)
    #---------------------------------------------------------------------------
    # White screen flash; shows silhouette of Primal Pokemon.
    picFADE.setColor(delay + 4, @bg_color || Color.white)
    picFADE.moveOpacity(delay + 4, 12, 255)
    delay = picFADE.totalDuration
    picTRAINER.setVisible(delay,false)
    arrPOKE.last[0].setColor(delay, Color.black)
    picFADE.moveOpacity(delay, 6, 0)
    picFADE.setColor(delay + 6, Color.black)
    delay = picFADE.totalDuration
    #---------------------------------------------------------------------------
    # Primal Pokemon revealed; pulse expands outwards; overlay shown.
    picOVERLAY.setVisible(delay, true)
    picOVERLAY.moveOpacity(delay, 5, 0)
    picSHINE.setVisible(delay, true)
    picPULSE.setVisible(delay, true)
    picPULSE.moveZoom(delay, 5, 1000)
    picPULSE.moveOpacity(delay + 2, 5, 0)
    arrPOKE.last[0].moveColor(delay, 8, Color.new(0, 0, 0, 0))
    picPOKE.setVisible(delay, false)
    #---------------------------------------------------------------------------
    # Shakes Pokemon; plays cry; flashes overlay. Fades out.
    16.times do |i|
      if i > 0
        arrPOKE.each { |p, s| p.moveXY(delay, t, @pictureSprites[s].x, @pictureSprites[s].y + 2) }
        arrPOKE.each { |p, s| p.moveXY(delay + t, t, @pictureSprites[s].x, @pictureSprites[s].y - 2) }
        picOVERLAY.moveOpacity(delay + t, 2, 160)
        picSHINE.moveOpacity(delay + t, 2, 160)
      else
        picPOKE.setSE(delay + t, @cry_file) if @cry_file
      end
      picOVERLAY.moveOpacity(delay + t, 2, 240)
      picSHINE.moveOpacity(delay + t, 2, 240)
      delay = arrPOKE.last[0].totalDuration
    end
    picOVERLAY.moveOpacity(delay, 4, 0)
    picSHINE.moveOpacity(delay, 4, 0)
    picFADE.moveOpacity(delay + 20, 8, 255)
  end
end

#-------------------------------------------------------------------------------
# Calls the animation.
#-------------------------------------------------------------------------------
class Battle::Scene
  def pbShowManziForm(idxBattler)
    primalAnim = Animation::BattlerManziForm.new(@sprites, @viewport, idxBattler, @battle)
    loop do
      if Input.press?(Input::ACTION)
        pbPlayCancelSE
        break 
      end
      primalAnim.update
      pbUpdate
      break if primalAnim.animDone?
    end
    primalAnim.dispose
  end
end