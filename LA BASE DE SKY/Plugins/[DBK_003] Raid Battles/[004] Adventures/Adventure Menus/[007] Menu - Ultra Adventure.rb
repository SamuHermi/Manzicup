#===============================================================================
# Core Adventure Menu scene.
#===============================================================================
class AdventureMenuScene
  #-----------------------------------------------------------------------------
  # Z-Crystal vendor menu.
  #-----------------------------------------------------------------------------
  def pbZCrystalMenu
    items = []
    idxPkmn = 0
    idxItem = 0
    selectionMode = 0
	rowSize = AdventureItembox::GRID_ROW_SIZE
	party_select = (0...PARTY_SIZE).to_a
	PARTY_SIZE.times do |i|
      pkmn = $player.party[i]
      crystals = GameData::Item.get_compatible_crystal(pkmn, true)
      items.push(crystals)
      @sprites["party_#{i}"] = AdventurePartyDatabox.new(pkmn, @style, i, @viewport)
      @sprites["party_#{i}"].selected = (i == idxPkmn)
    end
	ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"] = AdventureItembox.new(items[idxPkmn][i], i, @viewport) }
    @sprites["button"] = IconSprite.new(20, Graphics.height - 32, @viewport)
    @sprites["button"].setBitmap(@path + "buttons")
    @sprites["button"].src_rect.width = 32
    @sprites["descbox"] = IconSprite.new(166, 298, @viewport)
    @sprites["descbox"].setBitmap(@path + "desc_box")
	@sprites["descbox"].src_rect.y = 44
	@sprites["name"] = Window_AdvancedTextPokemon.newWithSize("", 170, 242, 338, 88, @viewport)
    @sprites["name"].windowskin = nil
    @sprites["name"].baseColor = Color.new(248, 248, 248)
    @sprites["name"].shadowColor = Color.new(64, 64, 64)
    itemName = @sprites["item_#{idxItem}"].item.name
    @sprites["window"] = Window_AdvancedTextPokemon.newWithSize("", 160, 282, 362, 132, @viewport)
    @sprites["window"].windowskin = nil
    @sprites["window"].lineHeight = 28
    @sprites["window"].baseColor = Color.new(248, 248, 248)
    @sprites["window"].shadowColor = Color.new(64, 64, 64)
    pbSetSmallFont(@sprites["window"].contents)
    pkmn = @sprites["party_#{idxPkmn}"].pokemon
    @sprites["window"].text = _INTL("{1} lleva:\n{2}.", pkmn.name, pkmn.item.name)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    textpos = [
      [_INTL("EQUIPO DE PRÉSTAMO"), 79, 8, :center, BASE_COLOR, SHADOW_COLOR, :outline],
      [_INTL("Elige a un Pokémon."), 337, 12, :center, BASE_COLOR, SHADOW_COLOR],
      [_INTL("Info"), 56, Graphics.height - 20, :left, BASE_COLOR, SHADOW_COLOR, :outline]
    ]
    pbDrawTextPositions(overlay, textpos)
    loop do
      Input.update
      Graphics.update
      pbUpdate
	  #-------------------------------------------------------------------------
      # UP KEY
      #-------------------------------------------------------------------------
      # Cycles through party Pokemon or Z-Crystal lists, depending on selectionMode.
      if Input.repeat?(Input::UP)
        case selectionMode
        when 0 # Cycles through party.
		  next if party_select.length <= 1
		  pbPlayCursorSE
		  nextIdx = party_select.index(idxPkmn) - 1
          idxPkmn = party_select[nextIdx] || party_select.last
          PARTY_SIZE.times { |i| @sprites["party_#{i}"].selected = (i == idxPkmn) }
		  ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].item = items[idxPkmn][i] }
		  pkmn = @sprites["party_#{idxPkmn}"].pokemon
		  @sprites["window"].text = _INTL("{1} lleva:\n{2}.", pkmn.name, pkmn.item.name)
        when 1 # Cycles through Z-Crystals.
          next if items[idxPkmn].length <= rowSize
		  pbPlayCursorSE
          idxItem -= rowSize
		  idxItem += items[idxPkmn].length if idxItem < 0
          ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].selected = (i == idxItem) }
		  itemName = @sprites["item_#{idxItem}"].item.name
          @sprites["name"].text = _INTL("<ac>{1}</ac>", itemName)
          @sprites["window"].text = @sprites["item_#{idxItem}"].item.held_description
        end
	  #-------------------------------------------------------------------------
      # DOWN KEY
      #-------------------------------------------------------------------------
	  # Cycles through party Pokemon or Z-Crystal lists, depending on selectionMode.
      elsif Input.repeat?(Input::DOWN)
        case selectionMode
        when 0 # Cycles through party.
		  next if party_select.length <= 1
		  pbPlayCursorSE
          nextIdx = party_select.index(idxPkmn) + 1
          idxPkmn = party_select[nextIdx] || party_select.first
		  PARTY_SIZE.times { |i| @sprites["party_#{i}"].selected = (i == idxPkmn) }
		  ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].item = items[idxPkmn][i] }
		  pkmn = @sprites["party_#{idxPkmn}"].pokemon
		  @sprites["window"].text = _INTL("{1} lleva:\n{2}.", pkmn.name, pkmn.item.name)
        when 1 # Cycles through Z-Crystals.
          next if items[idxPkmn].length <= rowSize
		  pbPlayCursorSE
          idxItem += rowSize
		  idxItem -= items[idxPkmn].length if idxItem >= items[idxPkmn].length
          ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].selected = (i == idxItem) }
		  itemName = @sprites["item_#{idxItem}"].item.name
          @sprites["name"].text = _INTL("<ac>{1}</ac>", itemName)
          @sprites["window"].text = @sprites["item_#{idxItem}"].item.held_description
        end
	  #-------------------------------------------------------------------------
      # LEFT/RIGHT KEYS
      #-------------------------------------------------------------------------
      # Navigates through item grid when selectionMode == 1.
	  elsif Input.repeat?(Input::LEFT)
	    next if selectionMode != 1
		pbPlayCursorSE
	    idxItem -= 1
        idxItem = items[idxPkmn].length - 1 if idxItem < 0
        ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].selected = (i == idxItem) }
		itemName = @sprites["item_#{idxItem}"].item.name
        @sprites["name"].text = _INTL("<ac>{1}</ac>", itemName)
        @sprites["window"].text = @sprites["item_#{idxItem}"].item.held_description
	  elsif Input.repeat?(Input::RIGHT)
	    next if selectionMode != 1
		pbPlayCursorSE
	    idxItem += 1
        idxItem = 0 if idxItem > items[idxPkmn].length - 1 
        ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].selected = (i == idxItem) }
		itemName = @sprites["item_#{idxItem}"].item.name
        @sprites["name"].text = _INTL("<ac>{1}</ac>", itemName)
        @sprites["window"].text = @sprites["item_#{idxItem}"].item.held_description
      #-------------------------------------------------------------------------
      # ACTION KEY
      #-------------------------------------------------------------------------
      # Opens the Summary for the party.
      elsif Input.trigger?(Input::ACTION)
        pbPlayDecisionSE
        pbSummary($player.party[0...PARTY_SIZE], idxPkmn)
      #-------------------------------------------------------------------------
      # BACK KEY
      #-------------------------------------------------------------------------
      # Exits the menu or returns to party selection, depending on selectionMode.
      elsif Input.trigger?(Input::BACK)
        case selectionMode
        when 0 # Exits the menu.
          break if pbConfirmMessage(_INTL("¿Salir?"))
        when 1 # Returns to party selection.
          pbPlayCancelSE
          overlay.clear
          textpos[1][0] = _INTL("Elige a un Pokémon.")
          pbDrawTextPositions(overlay, textpos)
		  @sprites["descbox"].y += 44
		  @sprites["descbox"].src_rect.y = 44
          ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].selected = false }
		  idxItem = 0
		  itemName = @sprites["item_#{idxItem}"].item.name
		  @sprites["name"].text = ""
          @sprites["window"].text = _INTL("{{1} lleva:\n{2}.", pkmn.name, pkmn.item.name)
          selectionMode = 0
        end
      #-------------------------------------------------------------------------
      # USE KEY
      #-------------------------------------------------------------------------
      # Selects a party Pokemon or a Z-Crystal, depending on selectionMode.
      elsif Input.trigger?(Input::USE)
        case selectionMode
        when 0 # Selects a party Pokemon.
		  if items[idxPkmn].empty?
            pbPlayBuzzerSE
          else
            pbPlayDecisionSE
            overlay.clear
            textpos[1][0] = _INTL("Elige un Cristal Z para {1}'.", pkmn.name)
            pbDrawTextPositions(overlay, textpos)
	        @sprites["descbox"].y -= 44
		    @sprites["descbox"].src_rect.y = 0
            ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].selected = (i == idxItem) }
			itemName = @sprites["item_#{idxItem}"].item.name
		    @sprites["name"].text = _INTL("<ac>{1}</ac>", itemName)
            @sprites["window"].text = @sprites["item_#{idxItem}"].item.description
            selectionMode = 1
          end
        when 1 # Selects a Z-Crystal.
          pbPlayDecisionSE
		  itemPortion = @sprites["item_#{idxItem}"].item.portion_name
          if pbConfirmMessage(_INTL("Cambiar el {2} de {1} por {3}?", pkmn.name, pkmn.item.portion_name, itemPortion))
		    pbMessage("\\se[]" + _INTL("{2} recibió {1} para poder usar el poder Z!", itemPortion, pkmn.name) + "\\se[Pkmn move learnt]")
            pkmn.item = items[idxPkmn][idxItem]
			@sprites["party_#{idxPkmn}"].refreshItem
            items[idxPkmn].delete(pkmn.item_id)
			idxItem = 0
			party_select.delete(idxPkmn)
			idxPkmn = party_select.first
			PARTY_SIZE.times { |i| @sprites["party_#{i}"].selected = (i == idxPkmn) }
			ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].selected = false }
            if party_select.length > 0
			  ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].item = items[idxPkmn][i] }
			  pkmn = @sprites["party_#{idxPkmn}"].pokemon
			  itemName = @sprites["item_#{idxItem}"].item.name
			  textpos[1][0] = _INTL("Elige a un Pokémon.")
			  @sprites["descbox"].y += 44
			  @sprites["descbox"].src_rect.y = 44
			  @sprites["name"].text = ""
			  @sprites["window"].text = _INTL("{1} lleva:\n{2}.", pkmn.name, pkmn.item.name)
		      selectionMode = 0
			else
			  ITEM_LIST_SIZE.times { |i| @sprites["item_#{i}"].item = nil }
			  textpos = [textpos.first]
			  @sprites["name"].text = ""
		      @sprites["window"].text = ""
			  @sprites["button"].visible = false
			  @sprites["descbox"].visible = false
			end
            overlay.clear
			pbDrawTextPositions(overlay, textpos)
          end
		end
	  end
	  break if party_select.empty?
	end
  end
end

def pbAdventureMenuUltra
  return if !pbInRaidAdventure?
  return if pbRaidAdventureState.style != :Ultra
  scene = AdventureMenuScene.new
  scene.pbStartScene(:Ultra)
  scene.pbZCrystalMenu
  scene.pbEndScene
end