#===============================================================================
# Related to displaying various text in the message box of the Data page.
#===============================================================================
class PokemonPokedexInfo_Scene
  #-----------------------------------------------------------------------------
  # Draws the relevant text relative to the cursor position.
  #-----------------------------------------------------------------------------
  def pbDrawDataNotes(cursor = nil)
    t = DATA_TEXT_TAGS
    cursor = @cursor if !cursor
    path = Settings::POKEDEX_DATA_PAGE_GRAPHICS_PATH + "cursor"
    species = GameData::Species.get_species_form(@species, @form)
    overlay = @sprites["data_overlay"].bitmap
    overlay.clear
    case cursor
    when :encounter then text = pbDataTextEncounters(path, species, overlay)
    when :general   then text = pbDataTextGeneral(path, species, overlay)
    when :stats     then text = pbDataTextStats(path, species, overlay)
    when :family    then text = pbDataTextFamily(path, species, overlay)
    when :habitat   then text = pbDataTextHabitat(path, species, overlay)
    when :shape     then text = pbDataTextShape(path, species, overlay)
    when :egg       then text = pbDataTextEggGroup(path, species, overlay)
    when :item      then text = pbDataTextItems(path, species, overlay)
    when :ability
      pbDrawImagePositions(overlay, [[path, 248+25+19, 240+38-24, 0, 244, 147, 44]])
      text = t[0] + _INTL("Habilidades") + "\n"
      if $player.owned?(@species)
        text << _INTL("Ver todas las habilidades de esta especie.")
      else
        text << _INTL("Desconocido.")
      end
    when :moves
      pbDrawImagePositions(overlay, [[path, 376+25+61, 240+38-24, 0, 244, 147, 44]])
      text = t[0] + _INTL("Movimientos") + "\n"
      if $player.owned?(@species)
        text << _INTL("Ver todos los movimientos que esta especie puede aprender.")
      else
        text << _INTL("Desconocido.")
      end
    end
    drawFormattedTextEx(overlay, 34+25, 294+38, 528, _INTL("{1}", text))
  end
  
  
  ##############################################################################
  #
  # These methods draw text when the cursor is highlighting a selection.
  #
  ##############################################################################
  
  
  #=============================================================================
  # Determines the encounter text to display. (Cursor == :encounter)
  #=============================================================================
  def pbDataTextEncounters(path, species, overlay)
    t = DATA_TEXT_TAGS
    text = t[0] + _INTL("Encuentros:") + "\n"
    text << _INTL("Derrotados:") + " " + "#{$player.pokedex.defeated_count(species.id)}\n"
    text << _INTL("Capturados:") + " " + "#{$player.pokedex.caught_count(species.id)}\n"
    pbDrawTextPositions(overlay, [
      [_INTL("Pulsa [C] para más información"), Graphics.width - 54, 292+38+10, :right, Color.new(0, 112, 248), Color.new(120, 184, 232)],
      [_INTL("y desplázate con las flechas."), Graphics.width - 54 - 6, 292+38+34+10, :right, Color.new(0, 112, 248), Color.new(120, 184, 232)]
      ])
    return text
  end
  
  #=============================================================================
  # Determines the general text to display. (Cursor == :general)
  #=============================================================================
  def pbDataTextGeneral(path, species, overlay, inMenu = false)
    t = DATA_TEXT_TAGS
    pbDrawImagePositions(overlay, [[path, 0, 36, 0, 0, 640, 56]])
    owned = $player.owned?(@species)
    text = t[0] + _INTL("Estadísticas Generales:") + "\n"
    if owned
      chance = species.catch_rate
      c = ((chance / 256.0) * 100).floor
      c = 1 if c < 1
      text << _INTL("Ratio de Captura:") + " #{c}%" + "\n"
      gender = _INTL("Prob. de género:") + " "
      case species.gender_ratio
      when :AlwaysMale   then gender << t[2] + _INTL("100% Macho")
      when :AlwaysFemale then gender << t[1] + _INTL("100% Hembra")
      when :Genderless   then gender << _INTL("sin género")
      else
        chance = GameData::GenderRatio.get(species.gender_ratio).female_chance
        if chance
          f = ((chance / 256.0) * 100).round
          m = (100 - f)
          #if m > f      # Male odds are higher than female.
          #  gender << t[2] + "#{m.to_s}% Macho"
          #elsif f > m   # Female odds are higher than male.
          #  gender << + t[1] + "#{f.to_s}% Hembra"
          #else          # Gender odds are equal.
          #  gender << "has an equal gender ratio"
          #end
          gender << t[2] + "#{m.to_s}" + _INTL("% Macho") + t[0] + ", " + t[1] + "#{f.to_s}" + _INTL("% Hembra")
        else
          gender = ""
        end
      end
      text << gender + t[0] + "." if gender != ""
      pbDrawTextPositions(overlay, [
        [_INTL("C: Ver relacionados"), Graphics.width - 54, 292+38, :right, Color.new(0, 112, 248), Color.new(120, 184, 232)]
      ]) if !inMenu && !@data_hash[:general].empty?
    else
      text << _INTL("Desconocido.")
    end
    return text
  end
  
  #=============================================================================
  # Determines the wild held item text to display. (Cursor == :item)
  #=============================================================================
  def pbDataTextItems(path, species, overlay)
    t = DATA_TEXT_TAGS
    pbDrawImagePositions(overlay, [[path, 224+55, 166, 432, 208, 74, 72]])
    owned = $player.owned?(@species)
    text = ""
    if owned
      @data_hash[:item].keys.each_with_index do |r, a|
        next if @data_hash[:item][r].empty?
        text << ", " if !nil_or_empty?(text)
        @data_hash[:item][r].each_with_index do |item, i|
          text << t[1] + GameData::Item.get(item).name + t[0]
          text << ", " if i < @data_hash[:item][r].length - 1
        end
      end
      if nil_or_empty?(text)
        text << "---" 
      else
        pbDrawTextPositions(overlay, [
          [_INTL("C: Más información"), Graphics.width - 54, 292+38, :right, Color.new(0, 112, 248), Color.new(120, 184, 232)]
        ])
      end
    else
      text << _INTL("Desconocido.")
    end
    text = t[0] + _INTL("Objetos") + "\n" + text
    return text
  end
  
  #=============================================================================
  # Determines the base stat text to display. (Cursor == :stats)
  #=============================================================================
  def pbDataTextStats(path, species, overlay, s2 = nil)
    t = DATA_TEXT_TAGS
    pbDrawImagePositions(overlay, [[path, 6, 90+18, 507, 56, 259, 188]])
    owned = $player.owned?(@species)
    text = t[0] + _INTL("Estadísticas")
    if owned
      nt = (s2 && s2.base_stat_total == species.base_stat_total) ? t[2] : t[1]
      text << " - " + nt + _ISPRINTF(_INTL("Total:") + " {1:3d}", species.base_stat_total)
      s1 = species.base_stats
      s2 = s2.base_stats if s2
      stats_order = [[:HP, :SPECIAL_ATTACK], [:ATTACK, :SPECIAL_DEFENSE], [:DEFENSE, :SPEED]]
      stats_order.each_with_index do |st, i|
        names = values = ""
        st.each_with_index do |s, j|
          stat = (s == :SPECIAL_ATTACK) ? _INTL("At. Esp.") : (s == :SPECIAL_DEFENSE) ? _INTL("Def. Esp.") : GameData::Stat.get(s).name
          nt = (s2 && s2[s] == s1[s]) ? t[2] : t[0]
          names  += nt + _INTL("{1}", stat)
          values += nt + _ISPRINTF("{1:3d}", s1[s])
          names  += "\n" if j == 0
          values += "\n" if j == 0
        end
        nameX = 34 + 192 * i + 25
        valueX = nameX + 100
        drawFormattedTextEx(overlay, nameX, 324+38, 76+16, _INTL("{1}", names))
        drawFormattedTextEx(overlay, valueX, 324+38, 52, _INTL("{1}", values))
      end
      pbDrawTextPositions(overlay, [
        [_INTL("C: Ver similares"), Graphics.width - 54, 292+38, :right, Color.new(0, 112, 248), Color.new(120, 184, 232)]
      ]) if !s2 && !@data_hash[:stats].empty?
    else
      text << _INTL("\nDesconocido.")
    end
    return text
  end
  
  #=============================================================================
  # Determines the habitat text to display. (Cursor == :habitat)
  #=============================================================================
  def pbDataTextHabitat(path, species, overlay, s2 = nil)
    t = DATA_TEXT_TAGS
    pbDrawImagePositions(overlay, [[path, 440+106, 166, 432, 208, 74, 72]])
    owned = $player.owned?(@species)
    text = t[0] + _INTL("Hábitat") + "\n"
    if owned
      habitat = GameData::Habitat.get(species.habitat)
      nt = (s2 && s2 == habitat.id) ? t[2] : t[1]
      name = habitat.name.downcase
      text << _INTL("Esta especie se puede encontrar") + " "
      case habitat.id
      when :Grassland    then text << _INTL("correteando por zonas de") + " " + nt + _INTL("{1}", name) + t[0] + "."
      when :Forest       then text << _INTL("en zonas densas de") + " " + nt + _INTL("{1}", name) + t[0] + "."
      when :WatersEdge   then text << _INTL("cerca de zonas de") + " " + nt + _INTL("{1}", name) + t[0] + "."
      when :Sea          then text << _INTL("en zonas de") + " " + nt + _INTL("{1}", name) + t[0] + "."
      when :Cave         then text << _INTL("en zonas de") + " " + nt + _INTL("{1}", name) + t[0] + "."
      when :Mountain     then text << _INTL("en zonas escarpadas de") + " " + nt + _INTL("{1}", name) + t[0] + "."
      when :RoughTerrain then text << _INTL("en zonas de") + " " + nt + _INTL("{1}", name) + t[0] + "."
      when :Urban        then text << _INTL("cerca de estructuras creadas por humanos o de") + " " + nt + _INTL("{1}", name) + t[0] + "."
      when :Rare         then text << _INTL("en lugares bastante") + " " + nt + _INTL("{1}", name) + t[0] + "."
      else                    text << _INTL("en sitios desconocidos.")
      end
      pbDrawTextPositions(overlay, [
        [_INTL("C: Ver relacionados"), Graphics.width - 54, 292+38, :right, Color.new(0, 112, 248), Color.new(120, 184, 232)]
      ]) if !s2 && !@data_hash[:habitat].empty?
    else
      text << _INTL("Desconocido.")
    end
    return text
  end
  
  #=============================================================================
  # Determines the body color & shape text to display. (Cursor == :shape)
  #=============================================================================
  def pbDataTextShape(path, species, overlay, s2 = nil)
    t = DATA_TEXT_TAGS
    pbDrawImagePositions(overlay, [[path, 368+89, 166, 432, 208, 74, 72]])
    text = t[0] + _INTL("Morfología") + "\n"
    color = GameData::BodyColor.get(species.color)
    nt = (s2 && s2[0] == color.id) ? t[2] : t[1]
    name = color.name.downcase
    text << _INTL("El color principal de la especie es el") + " " + nt + _INTL("{1}", name) + t[0] + ". "
    shape = GameData::BodyShape.get(species.shape)
    nt = (s2 && s2[1] == shape.id) ? t[2] : t[1]
    name = shape.name.downcase
    case shape.id
    when :Head, :Serpentine, :Finned, :HeadArms, :HeadBase, :Winged, :Multiped, :MultiBody, :MultiWinged
      text << _INTL("Tiene forma de") + " " + nt + _INTL("{1}", name) + t[0] + "."
    when :Bipedal, :BipedalTail, :HeadLegs,  :Quadruped, :Insectoid
      text << _INTL("Tiene forma") + " " + nt + _INTL("{1}", name) + t[0] + "."
    else
      text << _INTL("La forma no puede ser clasificada.")
    end
    if !s2 && $player.owned?(@species) && !@data_hash[:shape].empty?
      pbDrawTextPositions(overlay, [
        [_INTL("C: Ver Pokémon similares"), Graphics.width - 54, 292+38, :right, Color.new(0, 112, 248), Color.new(120, 184, 232)]
      ])
    end
    return text
  end
  
  #=============================================================================
  # Determines the egg group text to display. (Cursor == :egg)
  #=============================================================================
  def pbDataTextEggGroup(path, species, overlay, s2 = nil)
    return pbDataTextMoveSource(path, species, overlay) if @viewingMoves
    t = DATA_TEXT_TAGS
    pbDrawImagePositions(overlay, [[path, 296+72, 166, 432, 208, 74, 72]])
    owned = $player.owned?(@species)
    text = t[0] + _INTL("Crianza") + "\n"
    if owned
      text << _INTL("Especie") + " "
      groups = species.egg_groups
      groups = [:None] if species.gender_ratio == :Genderless && 
                          !(groups.include?(:Ditto) || groups.include?(:Undiscovered))
      if groups.include?(:None)
        data = GameData::EggGroup.get(:Ditto)
        name = (Settings::ALT_EGG_GROUP_NAMES) ? data.alt_name : data.name
        text << _INTL("sin género, solo compatible con el grupo") + " " + t[1] + "#{name}" + t[0] + "."
      elsif groups.include?(:Ditto)
        data = GameData::EggGroup.get(:Ditto)
        name = (Settings::ALT_EGG_GROUP_NAMES) ? data.alt_name : data.name
        text << _INTL("en el grupo") + " " + t[1] + "#{name}" + t[0] + _INTL(", compatible con todos salvo Desconocido.")
      elsif groups.include?(:Undiscovered) || groups.empty?
        data = GameData::EggGroup.get(:Undiscovered)
        name = (Settings::ALT_EGG_GROUP_NAMES) ? data.alt_name : data.name
        text << _INTL("en el grupo") + " " + t[1] + "#{name}" + t[0] + _INTL(", no puede ser criado.")
      else
        size_groups_sky = 0
        groups.each_with_index do |group, i|
          size_groups_sky+=1
        end
        if size_groups_sky == 2
          text << _INTL("compatible con los grupos") + " "
        else
          text << _INTL("compatible con el grupo") + " "
        end
        groups.each_with_index do |group, i|
          data = GameData::EggGroup.get(group)
          name = (Settings::ALT_EGG_GROUP_NAMES) ? data.alt_name : data.name
          nt = (s2 && s2.include?(group)) ? t[2] : t[1]
          text << nt + "#{name}" + t[0]
          if i < groups.length - 1
            text << " " + _INTL("y") + " "
          else
            text << "."
          end
        end
      end
      pbDrawTextPositions(overlay, [
        [_INTL("C: Ver Pokémon compatibles"), Graphics.width - 54, 292+38, :right, Color.new(0, 112, 248), Color.new(120, 184, 232)]
      ]) if !s2 && !@data_hash[:egg].empty?
    else
      text << _INTL("Desconocido.")
    end
    return text
  end
  
  #=============================================================================
  # Determines the family & evolution method text to display. (Cursor == :family)
  #=============================================================================
  def pbDataTextFamily(path, species, overlay, inMenu = false)
    t = DATA_TEXT_TAGS
    #---------------------------------------------------------------------------
    # Determines how many species icons to draw.
    #---------------------------------------------------------------------------
    if @sprites["familyicon1"].visible && @sprites["familyicon2"].visible
      pbDrawImagePositions(overlay, [[path, 228+78, 90, 222, 56, 284, 76]])
    elsif @sprites["familyicon1"].visible
      pbDrawImagePositions(overlay, [[path, 280+78, 90, 222, 132, 180, 76]])
    else
      pbDrawImagePositions(overlay, [[path, 332+78, 90, 402, 132, 76, 76]])
    end
    text = pbDrawSpecialFormText(species) # If this species is a special form.
    if nil_or_empty?(text)
      prevo = species.get_previous_species
      #-------------------------------------------------------------------------
      # These unique forms are treated as if they have no family trees.
      #-------------------------------------------------------------------------
      if [:PICHU_2, :FLOETTE_5, :GIMMIGHOUL_1].include?(species.id) ||
         species.species == :PIKACHU && (8..15).include?(species.form)
        prevo = species.species
      end
      #-------------------------------------------------------------------------
      # When the species is the base species in a family tree.
      #-------------------------------------------------------------------------
      if prevo == species.species
        text = t[0] + _INTL("Ramas evolutivas") + "\n"
        # Updated
        family_ids = []
        evos = species.get_evolutions
        evos.each do |evo|
          next if family_ids.include?(evo[0]) || evo[1] == :None
          family_ids.push(evo[0])
          species.branch_evolution_forms.each do |form|
            try_species = GameData::Species.get_species_form(evo[0], form)
            try_evos = try_species.get_evolutions
            next if try_evos.empty?
            try_evos.each do |try_evo|
              next if family_ids.include?(try_evo[0]) || try_evo[1] == :None
              family_ids.push(try_evo[0])
            end
          end
        end
        if family_ids.empty?          # Species doesn't evolve.
          text << _INTL("No evoluciona.")
        else                          # Species does evolve.
          family_ids.each_with_index do |fam, i|  
            name = GameData::Species.get(fam).name
            text << t[1] + name
            if i < family_ids.length - 1
              if fam == GameData::Species.get(family_ids[i + 1]).get_previous_species
                text << t[0] + "=> "  # Shows evolution pathway.
              else
                text << t[0] + ", "   # Shows a new pathway.
              end				
            end
          end
          text << t[0] + "."
        end
      #-------------------------------------------------------------------------
      # When the species is an evolved species.
      #-------------------------------------------------------------------------
      else
        form = (species.default_form >= 0) ? species.default_form : species.form
        prevo_data = GameData::Species.get_species_form(prevo, form)
        #-----------------------------------------------------------------------
        # Compiles the actual description for this species' evolution method.
        # Some species require special treatment due to unique evolution traits.
        #-----------------------------------------------------------------------
        if species.species == :ALCREMIE
          name = t[1] + "#{prevo_data.name}" + t[0]
          text = t[0] + _INTL("Subir de nivel a") + " " + "#{name}" + " " + _INTL("llevando equipado un Confite.")
        else
          text = ""
          index = 0
          prevo_data.get_evolutions(true).each do |evo|
            next if evo[0] != species.species
            next if evo[1] == :None
            if species.species == :URSHIFU && evo[1] == :Item
              next if evo[2] != [:SCROLLOFDARKNESS, :SCROLLOFWATERS][species.form]
            end
            spec = prevo_data.id #($player.seen?(prevo_data.id)) ? prevo_data.id : nil
            data = GameData::Evolution.get(evo[1])
            text << " " if index > 0
            text << data.description(spec, evo[0], evo[2], nil_or_empty?(text), true, t)
            break if index > 0
            index += 1
          end
          case species.species
          when :LYCANROC
            case species.form
            when 0 then text += " " + _INTL("Tiene que ser de día para esta forma.")
            when 1 then text += " " + _INTL("Tiene que ser de noche para esta forma.")
            when 2 then text += " " + _INTL("Requiere") + " " + t[2] + GameData::Ability.get(:OWNTEMPO).name + t[0] + "."
            end
          when :TOXTRICITY
            text += " " + _INTL("Forma depende de su") + " " + t[2] + _INTL("Naturaleza") + t[0] + "."
          end
        end
        #-----------------------------------------------------------------------
        # Determines what should be displayed as the "heading" in the message box.
        #-----------------------------------------------------------------------
        heading = ""
        if species.form_name
          Settings::REGIONAL_NAMES.each do |region|
            next if !species.form_name.include?(region)
            heading = t[0] + "#{region} " + _INTL("Evolución") + "\n"
          end
        end
        if nil_or_empty?(heading)
          evos = species.evolutions
          if inMenu && evos[-1][0] == prevo && evos.any? { |evo| evo[0] != prevo && evo[1] == :None }
            heading = t[0] + _INTL("Método evolutivo (etapa final)") + "\n"
          else
            heading = t[0] + _INTL("Método evolutivo") + "\n"
          end
        end
        text = heading + text
      end
      if !inMenu && !@data_hash[:family].empty? #&& $player.owned?(@species)
        pbDrawTextPositions(overlay, [
          [_INTL("C: Ver evoluciones"), Graphics.width - 54, 292+38, :right, Color.new(0, 112, 248), Color.new(120, 184, 232)]
        ])
      end
    end
    return text
  end
  
  #=============================================================================
  # Draws text related to special forms such as Mega Evolutions.
  #=============================================================================
  def pbDrawSpecialFormText(species)
    text = ""
    t = DATA_TEXT_TAGS
    special_form, check_form, check_item = pbGetSpecialFormData(species)
    if special_form
      base_data = GameData::Species.get_species_form(species.species, check_form)
      form_name = base_data.form_name
      if nil_or_empty?(form_name)
        spname = base_data.name
      elsif form_name.include?(base_data.name)
        spname = form_name
      else
        spname = form_name + " " + base_data.name
      end
      case special_form
      #-------------------------------------------------------------------------
      # Mega forms
      #-------------------------------------------------------------------------
      when :mega
        text = t[0] + _INTL("Mega Evolución") + "\n"
        text << t[0] + _INTL("Obtenible cuando") + " " + t[1] + "#{spname}" + t[0]
        if species.mega_stone
          param = GameData::Item.get(check_item).name
          text << " " + _INTL("activa la") + " " + t[2] + "#{param}" + t[0] + " " + _INTL("equipada.")
        else
          param = GameData::Move.get(species.mega_move).name
          text << " " + _INTL("tiene el movimiento") + " " + t[2] + "#{param}" + t[0] + "."
        end
      #-------------------------------------------------------------------------
      # Primal forms
      #-------------------------------------------------------------------------
      when :primal
        text = t[0] + _INTL("Regresión Primigenia") + "\n"
        text << t[0] + _INTL("Ocurre cuando") + " " + t[1] + "#{spname}"
        item = GameData::Item.try_get(check_item)
        param = (item) ? t[2] + item.name + t[0] : _INTL("Orbe Primignio")
        text << t[0] + " " + _INTL("entra en combate con el") + " " + "#{param}" + " " + _INTL("equipado.")
      #-------------------------------------------------------------------------
      # Ultra Burst forms
      #-------------------------------------------------------------------------
      when :ultra
        spname = _INTL("una forma fusionada de") + " #{base_data.name}" if species.species == :NECROZMA
        text = t[0] + _INTL("Método Ultraexplosión") + "\n"
        text << t[0] + _INTL("Obtenible cuando") + " " + t[1] + "#{spname}" + t[0]
        item = GameData::Item.try_get(check_item)
        param = (item) ? t[2] + item.name + t[0] : _INTL("Ultranecrostal Z")
        text << " " + _INTL("activa su") + " " + "#{param}" + " " + _INTL("equipado.")
      #-------------------------------------------------------------------------
      # Gigantamax forms
      #-------------------------------------------------------------------------
      when :gmax
        spname = _INTL("cualquier forma de")+ " #{base_data.name}" if species.has_flag?("AllFormsShareGmax") || species.species == :TOXTRICITY
        text = t[0] + _INTL("Método Gigamax") + "\n"
        text << t[0] + _INTL("Obtenible cuando") + " " + t[1] + "#{spname}" + t[0]
        text << " " + _INTL("tiene el") + " " + t[2] + _INTL("factor Gigamax") + t[0] + "."
      #-------------------------------------------------------------------------
      # Eternamax forms
      #-------------------------------------------------------------------------
      when :emax
        text = t[0] + _INTL("Método Eternamax") + "\n"
        text << _INTL("Desconocido.")
      #-------------------------------------------------------------------------
      # Terastal forms
      #-------------------------------------------------------------------------
      when :tera
        text = t[0] + _INTL("Método forma Teracristal") + "\n"
        text << t[0] + _INTL("Obtenible cuando") + " " + t[1] + "#{spname}" + t[0] + " " + _INTL("activa la Teracristalización.")
      end
    end
    return text
  end
  
  
  ##############################################################################
  #
  # These methods draw text only when a selection has been opened to view.
  #
  ##############################################################################

  
  #=============================================================================
  # Determines item rarity text to display. (Viewing item compatibility)
  #=============================================================================
  def pbDataTextItemSource(path, species, overlay, item)
    t = DATA_TEXT_TAGS
    itemName = GameData::Item.get(item).name
    text = t[2] + "#{itemName}\n"
    text << t[0]
    if species.wild_item_common.include?(item)
      text << _INTL("Objeto que") + " " + t[1] + _INTL("de forma común")     # Common items.
    elsif species.wild_item_uncommon.include?(item)
      text << _INTL("Objeto que") + " " + t[1] + _INTL("de forma poco común")  # Uncommon items.
    elsif species.wild_item_rare.include?(item)
      text << _INTL("Objeto que") + " " + t[1] + _INTL("rara vez")       # Rare items.
    end
    text << t[0] + " " + _INTL("puede llevar equipado esta especie.")
    return text
  end
  
  #=============================================================================
  # Determines ability availability text to display. (Viewing ability compatibility)
  #=============================================================================
  def pbDataTextAbilitySource(path, species, overlay, ability)
    t = DATA_TEXT_TAGS
    abilityName = GameData::Ability.get(ability).name
    text = t[2] + "#{abilityName}\n"
    text << t[0] + _INTL("Obtenible como") + " "
    #---------------------------------------------------------------------------
    # Natural abilities.
    #---------------------------------------------------------------------------
    if species.abilities.include?(ability)
      case species.abilities.length
      when 1 # Species only has one base ability.
        if species.hidden_abilities.empty? || 
           species.mega_stone || species.mega_move
          text << t[1] + _INTL("única") + t[0] + " " + _INTL("habilidad")
        else
          text << _INTL("habilidad") + " " + t[1] + _INTL("base")
        end
      when 2 # Species has two base abilities.
        if species.abilities[0] == ability
          text << _INTL("habilidad") + " " + t[1] + _INTL("primaria")
        else
          text << _INTL("habilidad") + " " + t[1] + _INTL("secundaria")
        end
      end
    #---------------------------------------------------------------------------
    # Hidden abilities.
    #---------------------------------------------------------------------------
    elsif species.hidden_abilities.include?(ability)
      text << _INTL("habilidad") + " " + t[1] + _INTL("oculta")
    else
      text << _INTL("habilidad") + " " + t[1] + _INTL("especial" )
    end
    text << t[0] + " " + _INTL("de esta especie.")
    return text
  end
  
  #=============================================================================
  # Determines move learning text to display. (Viewing move compatibility)
  #=============================================================================
  def pbDataTextMoveSource(path, species, overlay)
    t = DATA_TEXT_TAGS
    moveID = pbCurrentMoveID
    moveName = GameData::Move.get(moveID).name
    text = t[2] + "#{moveName}\n"
    text << t[0] + _INTL("Aprendido por esta especie") + " "
    methods = []
    #---------------------------------------------------------------------------
    # Move appears in the species' learnset.
    #---------------------------------------------------------------------------
    species.moves.each do |m|
      next if m[1] != moveID
      case m[0]
      when -1 then method = _INTL("en el") + " " + t[1] + _INTL("recuerda movimientos") + t[0]  # Gen 9 move relearning.
      when 0  then method = _INTL("al") + " " + t[1] + _INTL("evolucionar") + t[0]           # Evolution move.
      else         method = _INTL("a") + " " + t[1] + _INTL("nivel") + " " + "#{m[0]}" + t[0]         # Level-up move.
      end
      methods.push(method)
      break	  
    end
    #text << "a través de " if methods.empty?
    #---------------------------------------------------------------------------
    # Move is learned as an Egg Move.
    #---------------------------------------------------------------------------
    if species.get_egg_moves.include?(moveID)
      method = t[1] + _INTL("crianza") + t[0]
      methods.push(method)
    end
    #---------------------------------------------------------------------------
    # Move is learned via TM or move tutor.
    #---------------------------------------------------------------------------
    if species.get_tutor_moves.include?(moveID)
      method = _INTL("visitando un") + " " + t[1] + _INTL("tutor de movimientos") + t[0]
      # If none of the below applies, assume this is a move tutor move.
      GameData::Item.each do |item|
        next if !item.is_machine?
        next if item.move != moveID
        if $bag.has?(item.id)  # Player owns required machine.
          method = _INTL("usando") + " " + t[1] + item.name + t[0]
        elsif item.is_HM?      # Move is taught via HM.
          method = _INTL("usando una") + " " + t[1] + _INTL("MO") + t[0]
        elsif item.is_TM?      # Move is taught via TM.
          method = _INTL("usando una") + " " + t[1] + _INTL("MT") + t[0]
        elsif item.is_TR?      # Move is taught via TR.
          method = _INTL("usando una") + " " + t[1] + _INTL("DT") + t[0]
        end
        break
      end
      methods.push(method)
    end
    #---------------------------------------------------------------------------
    # Fixes up grammar and phrasing of learning methods.
    #---------------------------------------------------------------------------
    methods.push("método desconocido") if methods.empty?
    methods.each_with_index do |m, i|
      if i > 0 && i == methods.length - 1
        if m.include?("crianza")
          text << " " + _INTL("o a través de") + " "
        else
          text << " " + _INTL("o") + " "
        end
      end
      text << m
      text << ", " if i == 0 && methods.length > 2
    end
    text << "."
    return text
  end
end