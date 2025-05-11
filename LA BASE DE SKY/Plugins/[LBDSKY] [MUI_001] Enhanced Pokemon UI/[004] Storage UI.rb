#===============================================================================
# Storage UI edits.
#===============================================================================
class PokemonStorageScene
  def pbUpdateOverlay(selection, party = nil)
    if !@sprites["plugin_overlay"]
      @sprites["plugin_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
      pbSetSystemFont(@sprites["plugin_overlay"].bitmap)
    end
    plugin_overlay = @sprites["plugin_overlay"].bitmap
    plugin_overlay.clear
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    buttonbase = Color.new(248, 248, 248)
    buttonshadow = Color.new(80, 80, 80)
    pbDrawTextPositions(
      overlay,
      [[_INTL("Equipo: {1}", (@storage.party.length rescue 0)), 270, 392, :center, buttonbase, buttonshadow, :outline],
       [_INTL("Salir"), 446, 392, :center, buttonbase, buttonshadow, :outline]]
    )
    pokemon = nil
    if @screen.pbHeldPokemon
      pokemon = @screen.pbHeldPokemon
    elsif selection >= 0
      pokemon = (party) ? party[selection] : @storage[@storage.currentBox, selection]
    end
    if !pokemon
      @sprites["pokemon"].visible = false
      return
    end
    @sprites["pokemon"].visible = true
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    nonbase   = Color.new(90, 82, 82)
    nonshadow = Color.new(165, 165, 173)
    pokename = pokemon.name
    textstrings = [
      [pokename, 10, 14, :left, base, shadow]
    ]
    if !pokemon.egg?
      imagepos = []
      if pokemon.male?
        textstrings.push([_INTL("♂"), 148, 14, :left, Color.new(24, 112, 216), Color.new(136, 168, 208)])
      elsif pokemon.female?
        textstrings.push([_INTL("♀"), 148, 14, :left, Color.new(248, 56, 32), Color.new(224, 152, 144)])
      end
      imagepos.push([_INTL("Graphics/UI/Storage/overlay_lv"), 6246, 240])
      textstrings.push(["Nv. " + pokemon.level.to_s, 110, 260, :left, base, shadow])
      textstrings.push([pokemon.nature.name.to_s, 10, 260, :left, base, shadow])
      if pokemon.ability
        textstrings.push([pokemon.ability.name, 90, 350, :center, base, shadow])
      else
        textstrings.push([_INTL("Sin habilidad"), 90, 350, :center, nonbase, nonshadow])
      end
      if pokemon.item
        textstrings.push([pokemon.item.name, 90, 382, :center, base, shadow])
      else
        textstrings.push([_INTL("Sin objeto"), 90, 382, :center, nonbase, nonshadow])
      end
      if pokemon.shiny?
        pbDrawImagePositions(plugin_overlay, [["Graphics/Pictures/shiny", 134, 16]])
      end
      pbDisplayShinyLeaf(pokemon, plugin_overlay, 158, 50)      if Settings::STORAGE_SHINY_LEAF
      pbDisplayIVRatings(pokemon, plugin_overlay, 8, 198, true) if Settings::STORAGE_IV_RATINGS
      typebitmap = AnimatedBitmap.new(_INTL("Graphics/UI/types"))
      pokemon.types.each_with_index do |type, i|
        type_number = GameData::Type.get(type).icon_position
        type_rect = Rect.new(0, type_number * 28, 64, 28)
        type_x = (pokemon.types.length == 1) ? 52 : 18 + (70 * i)
        overlay.blt(type_x, 300, typebitmap.bitmap, type_rect)
      end
      drawMarkings(overlay, 90-50, 262+150, 128, 20, pokemon.markings)
      pbDrawImagePositions(overlay, imagepos)
    end
    pbDrawTextPositions(overlay, textstrings)
    @sprites["pokemon"].setPokemonBitmap(pokemon)
  end
end	