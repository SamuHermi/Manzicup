#===============================================================================
# Related to the Move list menu within the Data page.
#===============================================================================
class PokemonPokedexInfo_Scene
  #-----------------------------------------------------------------------------
  # Utility for generating lists of a species' learnable moves.
  #-----------------------------------------------------------------------------
  def pbGenerateMoveList(species_data, special_form)
    @moveCommands.clear
    @moveList.clear
    case @moveListIndex
    when 0  # Level-up moves
      species_data.moves.each do |m|
        next if @moveList.include?(m)

        @moveCommands.push(GameData::Move.get(m[1]).name)
        @moveList.push(m)
      end
    when 1  # Tutor moves
      species_data.get_tutor_moves.each do |m|
        next if @moveList.include?(m)

        @moveCommands.push(GameData::Move.get(m).name)
        @moveList.push(m)
      end
    when 2  # Egg moves
      species_data.get_inherited_moves.each do |m|
        next if @moveList.include?(m)

        @moveCommands.push(GameData::Move.get(m).name)
        @moveList.push(m)
      end
    when 3  # Mega Moves
      pbGenerateMegaMoves(species_data, special_form)
    when 4  # Z-Moves
      pbGenerateZMoves(species_data, special_form)
    when 5  # Max Moves
      pbGenerateMaxMoves(species_data, special_form)
    end
    @sprites['movecmds'].commands = @moveCommands
    @sprites['movecmds'].index = 0
  end

  #-----------------------------------------------------------------------------
  # Utility for generating list of all compatible Z-Moves.
  #-----------------------------------------------------------------------------
  def pbGenerateMegaMoves(species, special_form)
    return if special_form != :mega
    return unless MultipleForms.hasFunction?(species.species, 'getMegaMoves')

    MultipleForms.call('getMegaMoves', species).each_value do |m|
      @moveCommands.push(GameData::Move.get(m).name)
      @moveList.push(m)
    end
  end

  #-----------------------------------------------------------------------------
  # Utility for generating list of all compatible Z-Moves.
  #-----------------------------------------------------------------------------
  def pbGenerateZMoves(species, special_form)
    return unless @zcrystals
    return if special_form && special_form != :ultra

    allMoves = []
    species.moves.each { |m| allMoves.push(m[1]) }
    allMoves.concat(species.get_tutor_moves.clone)
    allMoves.concat(species.get_inherited_moves.clone)
    allMoves.uniq!
    @zcrystals.each do |item|
      if item.has_zmove_combo?
        id = item.has_flag?('UsableByAllForms') ? species.species : species.id
        next unless item.zmove_species.include?(id)

        if allMoves.include?(item.zmove_base_move)
          @moveCommands.push(GameData::Move.get(item.zmove).name)
          @moveList.push(item.zmove)
        end
      else
        allMoves.each do |m|
          move = GameData::Move.get(m)
          next if move.power == 0
          next if move.type != item.zmove_type

          @moveCommands.push(GameData::Move.get(item.zmove).name)
          @moveList.push(item.zmove)
          break
        end
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Utility for generating list of all compatible Max Moves.
  #-----------------------------------------------------------------------------
  def pbGenerateMaxMoves(species, special_form)
    return unless @maxmoves
    return if special_form && !%i[gmax emax].include?(special_form)

    allMoves = []
    species.moves.each { |m| allMoves.push(m[1]) }
    allMoves.concat(species.get_tutor_moves.clone)
    allMoves.concat(species.get_inherited_moves.clone)
    allMoves.uniq!
    maxGuard = false
    @maxmoves.each do |type, id|
      allMoves.each do |m|
        move = GameData::Move.get(m)
        maxGuard = true if move.power == 0 && !maxGuard
        next if move.power == 0
        next if move.type != type

        @moveCommands.push(GameData::Move.get(id).name)
        @moveList.push(id)
        break
      end
    end
    if maxGuard
      @moveCommands.insert(0, GameData::Move.get(:MAXGUARD).name)
      @moveList.insert(0, :MAXGUARD)
    end
    return unless species.gmax_move

    @moveCommands.push(GameData::Move.get(species.gmax_move).name)
    @moveList.push(species.gmax_move)
  end

  #-----------------------------------------------------------------------------
  # Controls for navigating the move list UI.
  #-----------------------------------------------------------------------------
  def pbChooseMove(species_data, special_form = nil)
    pages = []
    pages.push(0) unless species_data.moves.empty?
    pages.push(1) unless species_data.get_tutor_moves.empty?
    pages.push(2) unless species_data.get_inherited_moves.empty?
    if special_form == :mega && MultipleForms.hasFunction?(species_data.species,
                                                           'getMegaMoves') && !MultipleForms.call('getMegaMoves',
                                                                                                  species_data).empty?
      pages.push(3)
    end
    pages.push(4) if @zcrystals && [:ultra, nil].include?(special_form)
    pages.push(5) if @maxmoves && [:gmax, :emax, nil].include?(special_form)
    oldcmd = -1
    idxPage = 0
    maxPage = pages.length - 1
    @moveListIndex = pages[idxPage]
    @viewingMoves = true
    pbResetFamilyIcons
    pbSEPlay('GUI storage show party panel')
    pbGenerateMoveList(species_data, special_form)
    pbDrawMoveList
    pbActivateWindow(@sprites, 'movecmds') do
      loop do
        oldcmd = @sprites['movecmds'].index
        Graphics.update
        Input.update
        pbUpdate
        #-----------------------------------------------------------------------
        # Scrolls through the different types of movelists.
        if Input.trigger?(Input::LEFT)
          idxPage -= 1
          idxPage = maxPage if idxPage < 0
          @moveListIndex = pages[idxPage]
          pbGenerateMoveList(species_data, special_form)
          pbPlayCursorSE
          pbDrawMoveList
        elsif Input.trigger?(Input::RIGHT)
          idxPage += 1
          idxPage = 0 if idxPage > maxPage
          @moveListIndex = pages[idxPage]
          pbGenerateMoveList(species_data, special_form)
          pbPlayCursorSE
          pbDrawMoveList
        #-----------------------------------------------------------------------
        # Views all owned species compatible with a highlighted move.
        elsif Input.trigger?(Input::USE)
          if @moveListIndex <= 2
            pbDeactivateWindows(@sprites)
            pbChooseSpeciesDataList(:move)
            break if @forceRefresh

            pbActivateWindow(@sprites, 'movecmds')
          else
            pbPlayBuzzerSE
          end
        #-----------------------------------------------------------------------
        # Views all species in a similar Egg Group compatible with a highlighted move.
        elsif Input.trigger?(Input::ACTION)
          if @moveListIndex <= 2
            pbDeactivateWindows(@sprites)
            pbChooseSpeciesDataList(:egg)
            break if @forceRefresh

            pbActivateWindow(@sprites, 'movecmds')
          else
            pbPlayBuzzerSE
          end
        #-----------------------------------------------------------------------
        # Closes the movelist menu.
        elsif Input.trigger?(Input::BACK)
          @moveListIndex = 0
          @viewingMoves = false
          @sprites['movecmds'].index = 0
          @sprites['leftarrow'].visible = false
          @sprites['rightarrow'].visible = false
          pbSEPlay('GUI storage hide party panel')
          drawPage(@page)
          pbDrawDataNotes
          break
        elsif @sprites['movecmds'].index != oldcmd
          pbDrawMoveList
        end
      end
    end
    pbDeactivateWindows(@sprites)
  end

  #-----------------------------------------------------------------------------
  # Utility for getting the ID of the currently highlighted move.
  #-----------------------------------------------------------------------------
  def pbCurrentMoveID
    selection = @moveList[@sprites['movecmds'].index]
    @moveListIndex == 0 ? selection[1] : selection
  end

  #-----------------------------------------------------------------------------
  # Used to draw the move list UI.
  #-----------------------------------------------------------------------------
  def pbDrawMoveList
    @sprites['familyicon0'].x = 320 + 71
    @sprites['familyicon0'].y = 80 - 2
    @sprites['familyicon0'].visible = true
    @sprites['itemicon'].item = nil
    @sprites['leftarrow'].visible = true
    @sprites['rightarrow'].visible = true
    path = Settings::POKEDEX_DATA_PAGE_GRAPHICS_PATH
    @sprites['background'].setBitmap(_INTL(path + 'bg_moves'))
    @sprites['data_overlay'].bitmap.clear
    overlay = @sprites['overlay'].bitmap
    overlay.clear
    drawPageIcons
    base     = Color.new(248, 248, 248)
    shadow   = Color.new(72, 72, 72)
    base2    = Color.new(88, 88, 80)
    shadow2  = Color.new(168, 184, 184)
    imagepos = []
    textpos  = []
    yPos     = 99
    species_data = GameData::Species.get_species_form(@species, @form)
    species_data.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * 28, 64, 28)
      type_x = species_data.types.length == 1 ? 400 + 81 : 366 + 81 + (70 * i)
      overlay.blt(type_x, 66 - 4, @typebitmap2.bitmap, type_rect)
    end
    case @moveListIndex
    when 0 then title = _INTL('NIVEL')
    when 1 then title = _INTL('MT/TUTOR')
    when 2 then title = _INTL('CRIANZA')
    when 3 then title = _INTL('MOVS. MEGA')
    when 4 then title = _INTL('MOVS. Z')
    when 5 then title = _INTL('MOVS. DINA.')
    end
    textpos.push([title, 130 + 37, 51 + 5, :center, base, shadow, :outline])
    #---------------------------------------------------------------------------
    # Draws the move list.
    #---------------------------------------------------------------------------
    4.times do |i|
      moveID = @moveList[@sprites['movecmds'].top_item + i]
      next if moveID.nil?

      if moveID.is_a?(Array)
        moveLevel = moveID[0]
        moveData = GameData::Move.get(moveID[1])
      else
        moveData = GameData::Move.get(moveID)
      end
      type_number = GameData::Type.get(moveData.type).icon_position
      imagepos.push([_INTL('Graphics/UI/types'), 56 + 29, yPos + 24, 0, type_number * 28, 64, 28])
      moveName = moveData.name.length > 16 ? moveData.name[0..14] + '...' : moveData.name
      movePP = defined?(moveData.powerMove?) && moveData.powerMove? ? 0 : moveData.total_pp
      textpos.push([moveName, 58 + 29, yPos, :left, base, shadow, :outline],
                   [_INTL('PP'), 144 + 50, yPos + 31, :left, base2, shadow2],
                   [movePP > 0 ? movePP.to_s : '??', 230 + 50, yPos + 31, :right, base2, shadow2])
      case @moveListIndex
      #-------------------------------------------------------------------------
      when 0 # Level-up moves
        if moveLevel == 0
          textpos.push(['Ev.', 29 + 19, yPos + 16, :center, base, shadow, :outline])
        elsif moveLevel == 1 || moveLevel < 0
          imagepos.push([_INTL('Graphics/UI/Party/overlay_lv_white'), 17 + 19, yPos + 4])
          textpos.push(['--', 29 + 19, yPos + 26, :center, base, shadow, :outline])
        else
          moveLevel > 0
          imagepos.push([_INTL('Graphics/UI/Party/overlay_lv_white'), 17 + 19, yPos + 2])
          textpos.push([moveLevel.to_s, moveLevel < 100 ? 29 + 19 : 28 + 15, yPos + 26, :center, base, shadow,
                        :outline])
        end
      #-------------------------------------------------------------------------
      when 1 # TM/Tutor moves
        machine = '??'
        GameData::Item.each do |item|
          next unless item.is_machine?
          next if item.move != moveData.id
          next unless $bag.has?(item.id)

          machine = item.id
        end
        case machine
        when Symbol
          name = GameData::Item.get(machine).name
          textpos.push([name[0..1], 29 + 19, yPos + 4, :center, base, shadow, :outline],
                       [name[2..machine.length], machine.length < 5 ? 29 + 19 : 28 + 19, yPos + 28, :center, base,
                        shadow, :outline])
        else
          textpos.push([machine, 29 + 19, yPos + 17, :center, base, shadow, :outline])
        end
      #-------------------------------------------------------------------------
      when 2 # Egg moves
        imagepos.push([_INTL('Graphics/Pokemon/Eggs/000_icon'), -4 + 19, yPos - 14, 0, 0, 64, 64])
      #-------------------------------------------------------------------------
      when 3 # Mega Moves
        imagepos.push([_INTL('Graphics/UI/Battle/icon_mega'), 14, yPos + 11])
      #-------------------------------------------------------------------------
      when 4 # Z-Moves
        @zcrystals.each do |item|
          next if moveData.id != item.zmove

          imagepos.push([_INTL("Graphics/Items/#{item.id}"), 4, yPos + 2])
          break
        end
      #-------------------------------------------------------------------------
      when 5 # Max Moves
        icon = Settings::DYNAMAX_GRAPHICS_PATH + 'icon_dynamax'
        imagepos.push([icon, 11, yPos + 8])
      end
      yPos += 77
    end
    #---------------------------------------------------------------------------
    # Draws the info for the highlighted move.
    #---------------------------------------------------------------------------
    unless @moveCommands.empty?
      cursorY = 80 + ((@sprites['movecmds'].index - @sprites['movecmds'].top_item) * 77)
      imagepos.push([path + 'page_cursor', 17, cursorY + 10, 0, 0, 290, 70])
      selMoveID = pbCurrentMoveID
      selMoveData = GameData::Move.get(selMoveID)
      power = selMoveData.power
      category = selMoveData.category
      accuracy = selMoveData.accuracy
      movecount = (@sprites['movecmds'].index + 1).to_s + '/' + @moveCommands.length.to_s
      textpos.push(
        [_INTL('CATEGORÍA'), 344 + 81, 116 - 4, :center, base, shadow, :outline],
        [_INTL('POTENCIA'), 344 + 81, 150 - 4, :center, base, shadow, :outline],
        [if power <= 1
           power == 1 ? '???' : '---'
         else
           power.to_s
         end, 468 + 81, 150 - 4, :center, base2, shadow2],
        [_INTL('PRECISIÓN'), 344 + 81, 184 - 4, :center, base, shadow, :outline],
        [accuracy == 0 ? '---' : "#{accuracy}%", 468 + 81, 184 - 4, :center, base2, shadow2],
        [movecount, 50 + 17, 357 + 49, :center, base, shadow, :outline]
      )
      if defined?(selMoveData.powerMove?) && selMoveData.powerMove? && selMoveData.power == 1
        textpos.push(['???', 468 + 81, 115 - 4, :center, base2, shadow2])
      else
        imagepos.push(['Graphics/UI/category', 436 + 81, 110 - 4, 0, category * 28, 64, 28])
      end
      if @sprites['movecmds'].index < @moveCommands.length - 1
        imagepos.push([path + 'page_cursor', 100 + 38, 350 + 48, 0, 70, 76, 32])
      end
      imagepos.push([path + 'page_cursor', 178 + 38, 350 + 48, 76, 70, 76, 32]) if @sprites['movecmds'].index > 0
      drawTextEx(overlay, 272 + 86, 216, 230, 6, selMoveData.description, base2, shadow2)
    end
    pbDrawImagePositions(overlay, imagepos)
    pbDrawTextPositions(overlay, textpos)
  end
end
