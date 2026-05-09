#===============================================================================
# Game data for databox styles.
#===============================================================================
module GameData
  class DataboxStyle # :Symbol              : ID for a style.     # "String"             : Name of a style.      # [ally, foe]          : Array of databox base x values. Ally side subtracts from Graphics.width.      # [ally, foe]          : Array of databox base y values. Ally side subtracts from Graphics.height. # [ally, foe]          : Array of x values to shift databox elements by based on side size.      # [[double], [triple]] : Arrays of x values to shift databox values by in double/triple battles.      # [[double], [triple]] : Arrays of y values to shift databox values by in double/triple battles.     # [[ally], [foe]]      : Arrays of [x, y] values to shift HP bar positioning.    # [x, y]               : Array of [x, y] values to shift Exp. bar positioning. Foe side doesn't use this.      # [[ally], [foe]]      : Arrays of [x, y, alignment] values for positioning a battler's name.    # [x, y]               : Array of [x, y] values for ownership icon positioning. Ally side doesn't use this.    # [[ally], [foe]]      : Arrays of [x, y] values for shiny icon positioning.   # [[ally], [foe]]      : Arrays of [x, y] values for status icon positioning.  # [[ally], [foe]]      : Arrays of [x, y] values for Mega Evolution icon positioning (and others). # true/false           : When true, databox slides on/off screen vertically rather than horizontally.
    attr_reader :id, :real_name, :sprite_x, :sprite_y, :sprite_base_x, :offset_x, :offset_y, :hp_offset, :exp_offset, :name_pos, :owned_icon, :shiny_icon, :status_icon, :special_icon, :vertical_anim, :max_side_size # Integer (1-3)        : Sets the max side size this style is compatible with.

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id            = hash[:id]
      @real_name     = hash[:name]          || 'Unnamed'
      @sprite_x      = hash[:sprite_x]      || [0, 0]
      @sprite_y      = hash[:sprite_y]      || [0, 0]
      @sprite_base_x = hash[:sprite_base_x] || [0, 0]
      @offset_x      = hash[:offset_x]      || [[0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
      @offset_y      = hash[:offset_y]      || [[0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
      @hp_offset     = hash[:hp_offset]     || [[0, 0], [0, 0]]
      @exp_offset    = hash[:exp_offset]    || [0, 0]
      @name_pos      = hash[:name_pos]      || [[0, 0], [0, 0]]
      @owned_icon    = hash[:owned_icon]    || [0, 0]
      @shiny_icon    = hash[:shiny_icon]    || [[0, 0], [0, 0]]
      @status_icon   = hash[:status_icon]   || [[0, 0], [0, 0]]
      @special_icon  = hash[:special_icon]  || [[0, 0], [0, 0]]
      @vertical_anim = hash[:vertical_anim] || false
      @max_side_size = hash[:max_side_size] || 3
    end

    def name
      _INTL(@real_name)
    end
  end
end

#===============================================================================

# Basic databox style.
GameData::DataboxStyle.register({
                                  id: :Basic,
                                  name: _INTL('Basic'),
                                  sprite_x: [262, -16],
                                  sprite_y: [154, 12],
                                  sprite_base_x: [34, 16],
                                  offset_x: [[0, 8, -8, 0],    [0, 16, -8, 8, -16, 0]],
                                  offset_y: [[-38, -8, 8, 38], [-80, -10, -34, 36, 12, 82]],
                                  hp_offset: [[46, 30], [90, 26]],
                                  exp_offset: [134, 40],
                                  name_pos: [[22, 6, :left], [22, 2, :left]],
                                  owned_icon: [140, 3],
                                  shiny_icon: [[132, 5], [2, 23]],
                                  status_icon: [[182, 22], [18, 24]],
                                  special_icon: [[-18, 15], [200, 26]]
                                })

# Long databox style.
GameData::DataboxStyle.register({
                                  id: :Long,
                                  name: _INTL('Long'),
                                  hp_offset: [[0, 0], [50, 30]],
                                  name_pos: [[0, 0], [256, 4, :center]],
                                  owned_icon: [10, 27],
                                  shiny_icon: [[0, 0], [10, 25]],
                                  status_icon: [[0, 0], [4, 4]],
                                  special_icon: [[0, 0], [478, 16]],
                                  vertical_anim: true,
                                  max_side_size: 1
                                })

#===============================================================================
# Battle databox styles.
#===============================================================================
class Battle::Scene::PokemonDataBox
  attr_reader :style, :spriteX, :spriteY

  #-----------------------------------------------------------------------------
  # Text colors for stylized databoxes.
  #-----------------------------------------------------------------------------
  STYLE_BASE_COLOR     = Color.new(248, 248, 248)
  STYLE_SHADOW_COLOR   = Color.new(32, 32, 32)
  DYNAMAX_SHADOW_COLOR = Color.new(248, 32, 32)

  #-----------------------------------------------------------------------------
  # Aliases for setting databox style properties if battle rule is enabled.
  #-----------------------------------------------------------------------------
  alias dx_initializeDataBoxGraphic initializeDataBoxGraphic
  def initializeDataBoxGraphic(sideSize, trainerFoe = nil)
    rule = @battler.battle.databoxStyle
    if rule.is_a?(Array)
      @style = GameData::DataboxStyle.try_get(rule.first)
      if @battler.wild?
        case @battler.index
        when 1 then @title = rule[1]
        when 3 then @title = rule[2]
        when 5 then @title = rule[3]
        end
      end
    else
      @style = GameData::DataboxStyle.try_get(rule)
    end
    if @style
      @path = Settings::DELUXE_GRAPHICS_PATH + 'Databoxes'
      @databoxBitmap&.dispose

      trainerName = if %w[ANA BRA BRAIS HERMI IRIA ISA NEREA RODRI PABLO SABO SAMER].include?(
        @battler.battle.pbGetOwnerType(@battler.index).to_s
      )
                      @battler.battle.pbGetOwnerType(@battler.index).to_s + '_'
                    else
                      ''
                    end

      box = trainerName + (@battler.index.even? ? 'databox' : 'databox_foe')
      try_file = format('%s/%s/%s', @path, @style.id, box)
      Console.echo_li((sideSize > @style.max_side_size).to_s + ' ' + (!pbResolveBitmap(try_file)).to_s)
      @style = GameData::DataboxStyle.get(:Basic) if sideSize > @style.max_side_size || !pbResolveBitmap(try_file)
      @databoxBitmap = AnimatedBitmap.new(format('%s/%s/%s', @path, @style.id, box))
      initGraph
      # initializeOtherGraphics(viewport)
      set_style_properties(sideSize)
    else
      dx_initializeDataBoxGraphic(sideSize, trainerFoe)
    end
  end

  alias dx_initializeOtherGraphics initializeOtherGraphics
  def initializeOtherGraphics(viewport)
    if @style
      @numbersBitmap = AnimatedBitmap.new('Graphics/UI/Battle/icon_numbers')
      @hpNumbers = BitmapSprite.new(124, 16, viewport)
      @sprites['hpNumbers'] = @hpNumbers
      try_file = format('%s/%s/overlay_exp', @path, @style.id)
      expPath = pbResolveBitmap(try_file) ? @style.id : :Basic
      @expBarBitmap = AnimatedBitmap.new(format('%s/%s/overlay_exp', @path, expPath))
      @expBar = Sprite.new(viewport)
      @expBar.bitmap = @expBarBitmap.bitmap
      @sprites['expBar'] = @expBar
      overlay = @battler.index.even? ? 'overlay_hp' : 'overlay_hp_foe'
      @hpBarBitmap = AnimatedBitmap.new(format('%s/%s/%s', @path, @style.id, overlay))
      @hpBar = Sprite.new(viewport)
      @hpBar.bitmap = @hpBarBitmap.bitmap
      @hpBar.src_rect.height = @hpBarBitmap.height / 3
      @sprites['hpBar'] = @hpBar
      @contents = Bitmap.new(@databoxBitmap.width, @databoxBitmap.height)
      self.bitmap  = @contents
      self.visible = false
      self.z       = 150 + ((@battler.index / 2) * 5)
      pbSetSmallFont(bitmap)
    else
      dx_initializeOtherGraphics(viewport)
    end
  end

  alias dx_x= x=
  def x=(value)
    self.dx_x = (value)
    @hpBar.x  = value + @hpOffsetXY[0]  if @hpOffsetXY
    @expBar.x = value + @expOffsetXY[0] if @expOffsetXY
  end

  alias dx_y= y=
  def y=(value)
    self.dx_y = (value)
    @hpBar.y  = value + @hpOffsetXY[1]  if @hpOffsetXY
    @expBar.y = value + @expOffsetXY[1] if @expOffsetXY
  end

  alias dx_refresh refresh
  def refresh
    return unless @battler.pokemon

    if @style
      bitmap.clear
      update_style
      draw_background
      draw_style_text
      draw_style_icons
      draw_type_icons
      draw_plugin_elements
      refresh_hp
      refresh_exp
    else
      dx_refresh
    end
  end

  #-----------------------------------------------------------------------------
  # Used to set a databox's style to default in case the side size is changed mid-battle.
  #-----------------------------------------------------------------------------
  def update_style
    sideSize = @battler.battle.pbSideSize(@battler.index)
    return unless sideSize > @style.max_side_size && @style.id != :Basic

    @style = GameData::DataboxStyle.get(:Basic)
    set_style_properties(sideSize)
    @databoxBitmap&.dispose
    suffix = @battler.index.odd? ? '_foe' : ''
    @databoxBitmap = AnimatedBitmap.new(format('%s/%s/databox%s', @path, @style.id, suffix))
    @hpBarBitmap = AnimatedBitmap.new(format('%s/%s/overlay_hp%s', @path, @style.id, suffix))
    @hpBar.bitmap = @hpBarBitmap.bitmap
    @hpBar.src_rect.height = @hpBarBitmap.height / 3
    @sprites['hpBar'] = @hpBar
    @contents = Bitmap.new(@databoxBitmap.width, @databoxBitmap.height)
    self.bitmap = @contents
    pbSetSmallFont(bitmap)
  end

  #-----------------------------------------------------------------------------
  # Utility for manually changing databox styles mid-battle.
  #-----------------------------------------------------------------------------
  def refresh_style
    old_style = @style
    sideSize = @battler.battle.pbSideSize(@battler.index)
    initializeDataBoxGraphic(sideSize, @battler.battle.opponent[i].trainer_type.to_s)
    return if @style == old_style

    if @style.id == :Long
      try_exp = format('%s/%s/overlay_exp', @path, @style.id)
      expPath = pbResolveBitmap(try_exp) ? @style.id : :Basic
      @expBarBitmap = AnimatedBitmap.new(format('%s/%s/overlay_exp', @path, expPath))
      @hpBarBitmap = if @battler.index.odd?
                       AnimatedBitmap.new(format('%s/%s/overlay_hp_foe', @path, @style.id))
                     else
                       AnimatedBitmap.new(format('%s/%s/overlay_hp', @path, @style.id))
                     end
    else
      @hpOffsetXY   = nil
      @expOffsetXY  = nil
      @expBarBitmap = AnimatedBitmap.new('Graphics/UI/Battle/overlay_exp')
      @hpBarBitmap  = AnimatedBitmap.new('Graphics/UI/Battle/overlay_hp')
    end
    @expBar.bitmap = @expBarBitmap.bitmap
    @sprites['expBar'] = @expBar
    @hpBar.bitmap = @hpBarBitmap.bitmap
    @hpBar.src_rect.height = @hpBarBitmap.height / 3
    @sprites['hpBar'] = @hpBar
    @contents = Bitmap.new(@databoxBitmap.width, @databoxBitmap.height)
    self.bitmap = @contents
    if @style
      pbSetSmallFont(bitmap)
    else
      pbSetSystemFont(bitmap)
    end
    refresh
  end

  #-----------------------------------------------------------------------------
  # Utility for setting values for each databox element based on style.
  #-----------------------------------------------------------------------------
  def set_style_properties(sideSize)
    shadow = @battler.dynamax? ? DYNAMAX_SHADOW_COLOR : STYLE_SHADOW_COLOR
    @nameColors = [STYLE_BASE_COLOR, shadow, :outline]
    if @battler.index.even?
      @spriteX = Graphics.width - @style.sprite_x[0]
      @spriteY = Graphics.height - @style.sprite_y[0]
    else
      @spriteX = @style.sprite_x[1].clone
      @spriteY = @style.sprite_y[1].clone
    end
    if sideSize > 1
      @spriteX += @style.offset_x[sideSize - 2][@battler.index]
      @spriteY += @style.offset_y[sideSize - 2][@battler.index]
    end
    side = @battler.index.even? ? 0 : 1
    @spriteBaseX     = @style.sprite_base_x[side].clone
    @hpOffsetXY      = @style.hp_offset[side].clone
    @expOffsetXY     = @style.exp_offset.clone
    @show_exp_bar    = @battler.index.even?
    @show_hp_numbers = false
    @displayPos = {
      name: @style.name_pos[side].clone,
      owned: @style.owned_icon.clone,
      shiny: @style.shiny_icon[side].clone,
      status: @style.status_icon[side].clone,
      special: @style.special_icon[side].clone
    }
    if @style.id == :Long
      @displayPos[:owned][0] = 2  if @battler.shiny?
      @displayPos[:shiny][0] = 18 if @battler.owned? && @battler.opposes?(0)
    end
    @displayPos.each_key { |k| @displayPos[k][0] += @spriteBaseX }
  end

  #-----------------------------------------------------------------------------
  # Draws plugin elements on a databox. Placeholder to be used by plugins.
  #-----------------------------------------------------------------------------
  def draw_plugin_elements; end

  #-----------------------------------------------------------------------------
  # Draws all text elements on a databox based on style.
  #-----------------------------------------------------------------------------
  def draw_style_text
    textpos = []
    namePos = @displayPos[:name]
    if @battler.index.even?
      case @battler.gender
      when 0 then textpos.push(['♂', namePos[0] + 130, namePos[1], namePos[2], MALE_BASE_COLOR, STYLE_SHADOW_COLOR,
                                @nameColors[2]])
      when 1 then textpos.push(['♀', namePos[0] + 130, namePos[1], namePos[2], FEMALE_BASE_COLOR, STYLE_SHADOW_COLOR,
                                @nameColors[2]])
      end
      textpos.push([@battler.name, namePos[0] - 16, namePos[1], namePos[2], *@nameColors])
      textpos.push([@battler.level.to_s, namePos[0] + 168, namePos[1], :left, STYLE_BASE_COLOR, STYLE_SHADOW_COLOR])
    elsif @battler.index.odd? && @style.id == :Basic
      case @battler.gender
      when 0 then textpos.push(['♂', namePos[0] + 150, namePos[1], namePos[2], MALE_BASE_COLOR, STYLE_SHADOW_COLOR,
                                @nameColors[2]])
      when 1 then textpos.push(['♀', namePos[0] + 150, namePos[1], namePos[2], FEMALE_BASE_COLOR, STYLE_SHADOW_COLOR,
                                @nameColors[2]])
      end
      textpos.push([@battler.name, namePos[0] - 16, namePos[1], namePos[2], *@nameColors])
      textpos.push([@battler.level.to_s, namePos[0] + 194, namePos[1], :left, STYLE_BASE_COLOR, STYLE_SHADOW_COLOR])
    elsif display_name = if !@battler.wild?
                           @battler.name
                         elsif @title
                           _INTL(@title, @battler.name)
                         elsif defined?(@battler.pokemon.memento)
                           @battler.name_title(false)
                         else
                           @battler.name
                         end
      textpos.push([display_name, *namePos, *@nameColors])
    end
    pbDrawTextPositions(bitmap, textpos)
  end

  #-----------------------------------------------------------------------------
  # Draws all images on a databox based on style.
  #-----------------------------------------------------------------------------
  def draw_style_icons
    imagepos = []
    namePos = @displayPos[:name]
    imagepos.push([@path + '/overlay_lv', namePos[0] + 144, namePos[1] + 2]) if @battler.index.even?
    if @battler.index.odd? && @style.id == :Basic
      imagepos.push([@path + '/overlay_lv', namePos[0] + 170,
                     namePos[1] + 2])
    end
    imagepos.push([@path + '/icon_own', *@displayPos[:owned]]) if @battler.owned? && @battler.opposes?(0)
    imagepos.push([@path + '/shiny', *@displayPos[:shiny]]) if @battler.shiny?
    if @battler.status != :NONE
      s = if @battler.status == :POISON && @battler.statusCount > 0
            GameData::Status.count - 1
          else
            GameData::Status.get(@battler.status).icon_position
          end
      imagepos.push([_INTL('Graphics/UI/Battle/icon_statuses'), *@displayPos[:status], 0, s * STATUS_ICON_HEIGHT, -1,
                     STATUS_ICON_HEIGHT])
    end
    specialPos = @displayPos[:special]
    if @battler.shadowPokemon? && @battler.inHyperMode?
      filename = 'Graphics/UI/Battle/icon_hyper_mode'
      imagepos.push([filename, specialPos[0] + 4, specialPos[1] + 4])
    elsif @battler.mega?
      base_file = 'Graphics/UI/Battle/icon_mega'
      try_file = base_file + '_' + @battler.pokemon.speciesName
      filename = pbResolveBitmap(try_file) ? try_file : base_file
      imagepos.push([filename, specialPos[0] + 4, specialPos[1] + 4]) if filename
    elsif @battler.primal?
      base_file = 'Graphics/UI/Battle/icon_primal'
      try_file = base_file + '_' + @battler.pokemon.speciesName
      filename = pbResolveBitmap(try_file) ? try_file : base_file
      imagepos.push([filename, *specialPos]) if filename
    elsif @battler.ultra?
      filename = Settings::ZMOVE_GRAPHICS_PATH + 'icon_ultra'
      imagepos.push([filename, specialPos[0], specialPos[1] + 2])
    elsif @battler.dynamax?
      filename = Settings::DYNAMAX_GRAPHICS_PATH + 'icon_dynamax'
      imagepos.push([filename, *specialPos])
    elsif @battler.tera?
      filename = Settings::TERASTAL_GRAPHICS_PATH + 'tera_types'
      type_number = GameData::Type.get(@battler.tera_type).icon_position
      imagepos.push([filename, specialPos[0], specialPos[1] + 2, 0, type_number * 32, 32, 32])
    elsif @battler.battle.raidBattle? && @battler.hasZCrystal?
      filename = _INTL("Graphics/Items/#{@battler.item_id}")
      offsetX = if @battler.index.even?
                  0
                else
                  @style.id == :Basic ? -12 : -16
                end
      offsetY = if @battler.index.even?
                  -12
                else
                  @style.id == :Basic ? -24 : -24
                end
      imagepos.push([filename, specialPos[0] + offsetX, specialPos[1] + offsetY])
    end
    pbDrawImagePositions(bitmap, imagepos)
  end
end

#===============================================================================
# Utility for changing databox styles mid-battle.
#===============================================================================
class Battle::Scene
  def pbRefreshStyle(style = nil, *titles)
    return if pbInSafari?

    if GameData::DataboxStyle.exists?(style)
      if titles.length > 0
        args = [style]
        titles.each { |t| args.push(t) }
        @battle.databoxStyle = args
      else
        @battle.databoxStyle = style
      end
    else
      @battle.databoxStyle = nil
    end
    databoxes = []
    @battle.battlers.each { |b| databoxes.push(@sprites["dataBox_#{b.index}"]) if b }
    hideAnim = Animation::DataBoxDisappearAll.new(@sprites, @viewport, databoxes)
    loop do
      hideAnim.update
      pbUpdate
      break if hideAnim.animDone?
    end
    hideAnim.dispose
    databoxes.each { |box| box.refresh_style }
    showAnim = Animation::DataBoxAppearAll.new(@sprites, @viewport, databoxes)
    loop do
      showAnim.update
      pbUpdate
      break if showAnim.animDone?
    end
    showAnim.dispose
  end
end

#===============================================================================
# Aliases to the show/hide animations for certain databox styles.
#===============================================================================
class Battle::Scene::Animation::DataBoxAppear < Battle::Scene::Animation
  alias dx_createProcesses createProcesses
  def createProcesses
    sprite = @sprites["dataBox_#{@idxBox}"]
    return unless sprite

    safari = sprite.is_a?(Battle::Scene::SafariDataBox)
    if !safari && sprite.style && GameData::DataboxStyle.get(sprite.style).vertical_anim
      box = addSprite(sprite)
      box.setVisible(0, true)
      box.setDelta(0, 0, -sprite.height)
      box.moveDelta(0, 8, 0, sprite.height)
    else
      dx_createProcesses
    end
  end
end

class Battle::Scene::Animation::DataBoxDisappear < Battle::Scene::Animation
  alias dx_createProcesses createProcesses
  def createProcesses
    sprite = @sprites["dataBox_#{@idxBox}"]
    return unless sprite

    safari = sprite.is_a?(Battle::Scene::SafariDataBox)
    if !safari && sprite.style && GameData::DataboxStyle.get(sprite.style).vertical_anim
      box = addSprite(sprite)
      box.moveDelta(0, 8, 0, -sprite.height)
      box.setVisible(8, false)
    else
      dx_createProcesses
    end
  end
end

#===============================================================================
# Animations to show/hide all visible databoxes all at once.
#===============================================================================
class Battle::Scene::Animation::DataBoxAppearAll < Battle::Scene::Animation
  def initialize(sprites, viewport, boxes)
    @boxes = boxes
    super(sprites, viewport)
  end

  def createProcesses
    @boxes.each do |box|
      sprite = addSprite(box)
      vertical = box.style && GameData::DataboxStyle.get(box.style).vertical_anim
      dir = box.battler.index.even? ? 1 : -1
      delta = vertical ? [0, -box.height] : [dir * Graphics.width / 2, 0]
      sprite.setXY(0, box.spriteX, box.spriteY)
      sprite.setDelta(0, *delta)
      sprite.setVisible(0, true) unless box.battler.fainted?
      vertical ? delta[1] *= -1 : delta[0] *= -1
      sprite.moveDelta(0, 8, *delta)
    end
  end
end

class Battle::Scene::Animation::DataBoxDisappearAll < Battle::Scene::Animation
  def initialize(sprites, viewport, boxes)
    @boxes = boxes
    super(sprites, viewport)
  end

  def createProcesses
    @boxes.each do |box|
      sprite = addSprite(box)
      vertical = box.style && GameData::DataboxStyle.get(box.style).vertical_anim
      dir = box.battler.index.even? ? 1 : -1
      delta = vertical ? [0, -box.height] : [dir * Graphics.width / 2, 0]
      sprite.moveDelta(0, 8, *delta)
      sprite.setVisible(8, false)
    end
  end
end
