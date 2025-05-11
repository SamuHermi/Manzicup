########## AUTORES: Kyu y Clara ☆ ################################################
# Abrir el gacha: openGacha
# Dar monedas al jugador: $player.coins += cantidad
#BannerReward###################################################################
class BannerReward < Sprite
  
  def initialize(id,reward,stars,viewport=nil)
    super(viewport)
    @viewport = viewport
    @id = id
    @stars = stars - 1
    @reward = reward
    
    self.bitmap = Bitmap.new(160,160)
    @rewardSprite = Sprite.new(@viewport)
    @rewardSprite.bitmap = Bitmap.new(@reward)
    @animated_sprites = PluginManager.installed?("[DBK] Animated Pokémon System") || PluginManager.installed?("Sprites Animados") ? true : false
    #Mostrar solo el primer frame en sprites animados
    if @animated_sprites 
      frames = @rewardSprite.bitmap.width / @rewardSprite.bitmap.height
      frame_uno = @rewardSprite.bitmap.width / frames
      @rewardSprite.src_rect.set(0, 0, frame_uno, @rewardSprite.bitmap.height)
    end
    # Centra el sprite ajustando las coordenadas de origen
    @rewardSprite.ox = @rewardSprite.src_rect.width / 2
    @rewardSprite.oy = @rewardSprite.src_rect.height / 2
    # Zoom si tienes plugin de sprite animados y segun tamaño sprite
    if @animated_sprites
      if @rewardSprite.bitmap.height <= 20
        @rewardSprite.zoom_x = 2.3
        @rewardSprite.zoom_y = 2.3
      elsif @rewardSprite.bitmap.height <= 50
        @rewardSprite.zoom_x = 2.0
        @rewardSprite.zoom_y = 2.0
      elsif @rewardSprite.bitmap.height <= 75
        @rewardSprite.zoom_x = 1.7
        @rewardSprite.zoom_y = 1.7
      elsif @rewardSprite.bitmap.height <= 90
        @rewardSprite.zoom_x = 1.6
        @rewardSprite.zoom_y = 1.6
      elsif @rewardSprite.bitmap.height <= 100
        @rewardSprite.zoom_x = 1.5
        @rewardSprite.zoom_y = 1.5
      elsif @rewardSprite.bitmap.height <= 200
        @rewardSprite.zoom_x = 1.2
        @rewardSprite.zoom_y = 1.2
      end
    else
      if @rewardSprite.bitmap.height <= 89
        @rewardSprite.zoom_x = 1.0
        @rewardSprite.zoom_y = 1.0
      elsif @rewardSprite.bitmap.height >= 90
        @rewardSprite.zoom_x = 0.85
        @rewardSprite.zoom_y = 0.85
      end
    end
    
    @starsSprite = Sprite.new(@viewport)
    starsBitmap = Bitmap.new("Graphics/UI/Gacha/Estrellas")
    @starsSprite.bitmap = Bitmap.new(starsBitmap.width, starsBitmap.height/6)
    starsY = @starsSprite.bitmap.height*@stars
    starsRect = Rect.new(0, starsY, @starsSprite.bitmap.width, @starsSprite.bitmap.height)
    @starsSprite.bitmap.blt(0, 0, starsBitmap, starsRect)
    @starsSprite.x= 36
    @starsSprite.y = (@id!=1 ? 140 : 112)
    @starsSprite.ox = @starsSprite.bitmap.width/2 
    @starsSprite.oy = @starsSprite.bitmap.height/2 
  end


  def x=(value)
    super(value)
    @rewardSprite.x = value + self.bitmap.width/2 - self.ox
    @starsSprite.x = value + 36 + @starsSprite.ox - self.ox 
  end
  
  def y=(value)
    super(value)
    if @animated_sprites
		  y = (@id != 1 ? 30 : 5) # Corrección de altura sprite pokemon animados
    else
		  y = (@id != 1 ? -5 : -25) # Corrección de altura sprite pokemon estáticos
    end
    @rewardSprite.y = value + y + @rewardSprite.oy - self.oy
	  y2 = (@id != 1 ? 120 : 90) # Corrección de altura sprite estrellas
    @starsSprite.y = value + y2 + @starsSprite.oy - self.oy
  end
  
  def zoom_x=(value)
    super(value)
		if @animated_sprites # Ajuste al zoom x del premio
			x = 0
		else
			x = -1
		end
    @rewardSprite.zoom_x = value + 1.0 + x
    @starsSprite.zoom_x = value
  end
  
  def zoom_y=(value)
    super(value)
		if @animated_sprites # Ajuste al zoom y del premio
			y = 0
		else
			y = -1
		end
    @rewardSprite.zoom_y = value + 1.0 + y
    @starsSprite.zoom_y = value
  end
    
  def opacity=(value)
    super(value)
    @rewardSprite.opacity = value
    @starsSprite.opacity = value
  end
  
  def dispose
    @rewardSprite.dispose
    @starsSprite.dispose
  end
end

#BANNER#########################################################################

class BannerSprite < Sprite
  def initialize(bg,rewards,stars,viewport=nil,cost = 1)
    super(viewport)
    @viewport = viewport
    @bg       = bg
    @rewards  = rewards
    @stars    = stars
    @cost     = cost
    createGraphics
  end

  def createGraphics
    @bgSprite = Sprite.new(@viewport)
    @bgSprite.bitmap = Bitmap.new(@bg)
    @bgSprite.ox = @bgSprite.bitmap.width/2
    @bgSprite.oy = @bgSprite.bitmap.height/2
    @bgSprite.x = Graphics.width/2
    @bgSprite.y = Graphics.height/2
    
    @reward1 = BannerReward.new(0,@rewards[0],@stars[0],@viewport)
    @reward1.x = 16
    @reward1.y = 180

    @reward2 = BannerReward.new(1,@rewards[1],@stars[1],@viewport)
    @reward2.x = 176
    @reward2.y = 151
    #@reward2.zoom_x = 2
    #@reward2.zoom_y = 2  

    @reward3 = BannerReward.new(2,@rewards[2],@stars[2],@viewport)
    @reward3.x = 336
    @reward3.y = 50



  end
  
  def x=(value)
    super(value)
    @bgSprite.x = value + @bgSprite.bitmap.width/2
    @reward1.x = value + 450
    @reward2.x = value + 306
    @reward3.x = value + 450
  end
  
  def dispose
    @bgSprite.dispose
    @reward1.dispose
    @reward2.dispose
    @reward3.dispose
    super
  end
end

#INTERFAZ#######################################################################

class GachaScene
  def initialize(banners)
    $player.coins ||= 0 if !$player.coins
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sel = 1
    @banners = banners
    @banner_sel = 0
    @cost = 1
    
    for i in 0...@banners.length
      @sprites["banner#{i}"] = BannerSprite.new(@banners[i].bg, @banners[i].rewards, @banners[i].stars, @viewport, @banners[i].cost)
      @sprites["banner#{i}"].x = Graphics.width*i
    end
    
    @sprites["leftArrow"] = Sprite.new(@viewport)
    @sprites["leftArrow"].bitmap = Bitmap.new("Graphics/UI/Gacha/leftArrow")
    @sprites["leftArrow"].ox = @sprites["leftArrow"].bitmap.width/2
    @sprites["leftArrow"].oy = @sprites["leftArrow"].bitmap.height/2
    @sprites["leftArrow"].x = 20
    @sprites["leftArrow"].y = Graphics.height/2
    
    @sprites["rightArrow"] = Sprite.new(@viewport)
    @sprites["rightArrow"].bitmap = Bitmap.new("Graphics/UI/Gacha/rightArrow")
    @sprites["rightArrow"].ox = @sprites["rightArrow"].bitmap.width/2
    @sprites["rightArrow"].oy = @sprites["rightArrow"].bitmap.height/2
    @sprites["rightArrow"].x = Graphics.width - 20
    @sprites["rightArrow"].y = Graphics.height/2
    
    @sprites["bannerSel"] = Sprite.new(@viewport)
    @sprites["bannerSel"].bitmap = Bitmap.new("Graphics/UI/Gacha/sel_shine")
    #@sprites["bannerSel"].y = 248
    @sprites["bannerSel"].visible = false
    
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].bitmap = Bitmap.new(300,180)
    pbSetSystemFont(@sprites["text"].bitmap)
    @sprites["text"].bitmap.font.size = 40
    @sprites["text"].x = -70
    @sprites["text"].y = 0

    @sprites["button1"] = Sprite.new(@viewport)
    @sprites["button2"] = Sprite.new(@viewport)
    @sprites["button3"] = Sprite.new(@viewport)
    @sprites["button4"] = Sprite.new(@viewport)    
    
    @sprites["coinsIcon"] = Sprite.new(@viewport)
    @sprites["coinsIcon"].bitmap = Bitmap.new("Graphics/UI/Gacha/coin")
    @sprites["coinsIcon"].x = 50
    @sprites["coinsIcon"].y = Graphics.height/2 - 12
    
    @sprites["coins"] = Sprite.new(@viewport)
    @sprites["coins"].bitmap = Bitmap.new(Graphics.width,25)
    @sprites["coins"].x = 70
    @sprites["coins"].y = Graphics.height/2 - 16

    @sprites["costsing"] = Sprite.new(@viewport)
    @sprites["costsing"].bitmap = Bitmap.new(Graphics.width,25)
    pbSetSystemFont(@sprites["costsing"].bitmap)
    @sprites["costsing"].bitmap.font.size = 22
    @sprites["costsing"].x = 430
    @sprites["costsing"].y = 308  

    @sprites["costmult"] = Sprite.new(@viewport)
    @sprites["costmult"].bitmap = Bitmap.new(Graphics.width,25)
    pbSetSystemFont(@sprites["costmult"].bitmap)
    @sprites["costmult"].bitmap.font.size = 22
    @sprites["costmult"].x = 530
    @sprites["costmult"].y = 308


    pbSetSystemFont(@sprites["coins"].bitmap)
    refresh
    update
  end
  
  def refresh
    base   = Color.new(248,248,248)
    shadow = Color.new(72,80,88)
    
    if @sel == 0
      @sprites["button1"].bitmap = Bitmap.new("Graphics/UI/Gacha/Boton Chiquito Sel")
    else
      @sprites["button1"].bitmap = Bitmap.new("Graphics/UI/Gacha/Boton Chiquito")
    end
    @sprites["button1"].x = 16
    @sprites["button1"].y = 342
    pbSetSystemFont(@sprites["button1"].bitmap)
    pbDrawShadowText(@sprites["button1"].bitmap,0,5,128,32,"Info.",base,shadow,1)
    
    if @sel == 2
      @sprites["button2"].bitmap = Bitmap.new("Graphics/UI/Gacha/Boton Sel")
    else
      @sprites["button2"].bitmap = Bitmap.new("Graphics/UI/Gacha/Boton")
    end
    @sprites["button2"].x = 430
    @sprites["button2"].y = 334
    @sprites["button2"].bitmap.font.size = 38
    pbSetSystemFont(@sprites["button2"].bitmap)
    pbDrawShadowText(@sprites["button2"].bitmap,9,12,75,48,"Single",base,shadow,1)

    if @sel == 3
      @sprites["button3"].bitmap = Bitmap.new("Graphics/UI/Gacha/Boton Sel")
    else
      @sprites["button3"].bitmap = Bitmap.new("Graphics/UI/Gacha/Boton")
    end
    @sprites["button3"].x = 530
    @sprites["button3"].y = 334
    @sprites["button3"].bitmap.font.size = 38
    pbSetSystemFont(@sprites["button3"].bitmap)
    pbDrawShadowText(@sprites["button3"].bitmap,9,12,75,48,"Multi",base,shadow,1)

    if @sel == 1
      @sprites["button4"].bitmap = Bitmap.new("Graphics/UI/Gacha/Boton Chiquito Sel")
    else
      @sprites["button4"].bitmap = Bitmap.new("Graphics/UI/Gacha/Boton Chiquito")
    end
    @sprites["button4"].x = 120
    @sprites["button4"].y = 342
    
    pbSetSystemFont(@sprites["button4"].bitmap)
    pbDrawShadowText(@sprites["button4"].bitmap,0,5,128,32,"Salir",base,shadow,1)
    
    if @sel == 4
      @sprites["bannerSel"].visible = true
    else
      @sprites["bannerSel"].visible = false
    end
    
    if @banner_sel == 0
      @sprites["leftArrow"].opacity = 50
    else
      @sprites["leftArrow"].opacity = 255
    end
    
    if @banner_sel == @banners.length-1
      @sprites["rightArrow"].opacity = 50
    else
      @sprites["rightArrow"].opacity = 255
    end
    
    @sprites["text"].bitmap.clear
    drawTextEx(@sprites["text"].bitmap,100,70,300,2,@banners[@banner_sel].name,Color.new(88, 88, 88),Color.new(255, 255, 255))
    
    @sprites["coins"].bitmap.clear
    pbDrawShadowText(@sprites["coins"].bitmap,0,0,Graphics.width,25,"x"+$player.battle_points.to_s,base,shadow)

    @sprites["costsing"].bitmap.clear
    pbDrawShadowText(@sprites["costsing"].bitmap,9,12,75,48,"x"+(@banners[@banner_sel].cost).to_s,base,shadow,1)

    @sprites["costmult"].bitmap.clear
    pbDrawShadowText(@sprites["costmult"].bitmap,9,12,75,48,"x"+(@banners[@banner_sel].cost*10).to_s,base,shadow,1)
  end
  
  def changeBanner(dir)
    if dir == 0 && @banner_sel != @banners.length-1
      move = Graphics.width/16.0
      16.times do
        for i in 0...@banners.length
          @sprites["banner#{i}"].x -= move
        end
        pbWait(0.05)
      end
      @banner_sel += 1
    elsif dir == 1 && @banner_sel != 0
      move = Graphics.width/16.0
      16.times do
        for i in 0...@banners.length
          @sprites["banner#{i}"].x += move
        end
        pbWait(0.05)
      end
      @banner_sel -= 1
    end
  end
  
  def summaryWindow(width, interpad)
    window = SpriteWindow_Base.new(37,27,width,330)
    window.z = 99999
    window.windowskin = Bitmap.new("Graphics/windowskins/goldskin")
    text = @banners[@banner_sel].description
    totalheight = 10 #Modificar alto de Info.
    totalwidth = 22 #Modificar ancho de Info. 
    
    isDarkSkin = isDarkWindowskin(window.windowskin)
    colortag = ""
    if ($game_message && $game_message.background>0) ||
       ($game_system && $game_system.respond_to?("message_frame") &&
        $game_system.message_frame != 0)
      colortag=getSkinColor(window.windowskin,0,true)
    else
      colortag=getSkinColor(window.windowskin,0,isDarkSkin)
    end
    text = colortag + text
    
    #window.newWithSize(text,37,27,width,330)
    aux = getGachaLineChunks(text, width-37+totalwidth,colortag)
    canvas = Bitmap.new(439,(32 + interpad)*(aux.length))
    pbSetSystemFont(canvas)
    
    for i in 0...aux.length
      chr = getFormattedText(canvas,0,totalheight,canvas.width-37+totalwidth, Graphics.height, aux[i])
      drawFormattedChars(canvas,chr)
      totalheight += 32 + interpad
    end
    window.contents = canvas
    
    loop do
      if Input.press?(Input::UP) && window.oy != 0
        window.oy -= 10
      end
      if Input.press?(Input::DOWN) && window.oy < canvas.height - 200
        window.oy += 10
      end
      if Input.trigger?(Input::B)
        window.dispose
        Input.update
        break
      end
      Graphics.update
      Input.update
    end
  end
      
  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    Graphics.update
    Input.update
  end
  
  def rewardAnim(filename,stars) #Animación para obtener premios
    color = TIERCOLORS[stars-1]
    sound = TIERSOUNDS[stars-1]
    
    bg = Sprite.new(@viewport)
    bg.bitmap = Bitmap.new("Graphics/UI/Gacha/rewardBG")
    bg.tone = Tone.new(color.red, color.green, color.blue)
    
    light = Sprite.new(@viewport)
    light.bitmap = Bitmap.new("Graphics/UI/Gacha/gacha")
    light.ox = light.bitmap.width/2
    light.oy = light.bitmap.height/2
    light.x = Graphics.width/2
    light.y = Graphics.height/2
    #light.zoom_x = 11.0
    #light.zoom_y = 11.0
    light.opacity = 0
    light.color = color
    
    reward = BannerReward.new(0,filename,stars,@viewport)
    reward.ox = reward.bitmap.width/2
    reward.oy = reward.bitmap.height/2
    reward.x = Graphics.width/2
    reward.y = Graphics.height/2
    reward.opacity=0
    reward.zoom_x = 11.0
    reward.zoom_y = 11.0
    
    pbSEPlay(sound)
    frame = 0
    while (!Input.trigger?(Input::C) && frame >= 9) || frame <= 9
      if (0..9).include?(frame)
        light.opacity += 25.5
        #light.zoom_x -= 1.0
        #light.zoom_y -= 1.0
        reward.opacity += 25.5
        reward.zoom_x -= 1.0
        reward.zoom_y -= 1.0
      end
      light.angle += 2
      frame+=1
      Graphics.update
      Input.update
    end
    pbSEStop()
    
    bg.dispose
    reward.dispose
    light.dispose
  end
  
  def pokeReward(pkmn,stars) # Obtención de pokémon
    file = GameData::Species.front_sprite_filename(pkmn.species, pkmn.form, pkmn.gender)
    rewardAnim(file, stars)
    pbReceivePokemon(pkmn)
  end
  
  def itemReward(item,stars) # Obtención de objetos
    file = GameData::Item.icon_filename(item)
    rewardAnim(file,stars)
    $bag.add(item)
  end
  

  def update 
    loop do
      if Input.trigger?(Input::RIGHT)
        if @sel == 4
          changeBanner(0)
        elsif @sel != 3
          @sel+=1
        end
        refresh
      end
      
      if Input.trigger?(Input::LEFT)
        if @sel == 4
          changeBanner(1)
        elsif @sel != 0
          @sel -= 1
        end
        refresh
      end
      
      if Input.trigger?(Input::L)
        changeBanner(1)
        refresh
      end
      
      if Input.trigger?(Input::R)
        changeBanner(0)
        refresh
      end
      
      if Input.trigger?(Input::UP) && @sel != 4
        @sel = 4
        refresh
      end
      
      if Input.trigger?(Input::DOWN) && @sel != 1
        @sel = 1
        refresh
      end
      
      if Input.trigger?(Input::C) 
        case @sel
        when 0 #Información
          summaryWindow(439,5)
        when 2 #Single
          if $player.battle_points >= @banners[@banner_sel].cost 
            if pbMessage("¿Quieres hacer un single? SE GUARDARÁ LA PARTIDA",["Sí","No"])==0
              gachaponRead(@banner_sel,false,@banners[@banner_sel].type)
              $player.battle_points -= @banners[@banner_sel].cost 
              Game.save
              refresh
            end
          else
             pbMessage(FRASES[rand(FRASES.length)])
          end
        when 3 #Multi
          if $player.battle_points >= @banners[@banner_sel].cost * 10
            if pbMessage("¿Quieres hacer un multi? SE GUARDARÁ LA PARTIDA",["Sí","No"])==0
              gachaponRead(@banner_sel,true,@banners[@banner_sel].type)
              $player.battle_points -= @banners[@banner_sel].cost * 10
              Game.save
              refresh
            end
          else
             pbMessage(FRASES[rand(FRASES.length)])
          end          
        when 1 #Salir
          dispose
          break
        end     
      end
      
      if Input.trigger?(Input::B)
        dispose
        break
      end
      
      Graphics.update
      Input.update
    end
  end
end