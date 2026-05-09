#===============================================================================
# Adds/edits various Summary utilities.
#===============================================================================
class PokemonSummary_Scene
  PRESET_SPRITESHEET     = 'Graphics/Plugins/Level Based Mixed EV System and Allocator/ev_presets'
  PRESET_CURSOR          = 'Graphics/Plugins/Level Based Mixed EV System and Allocator/cursor_presets'
  PRESET_ICON_SIZE       = 30   # px — selected icon size (drawn 1:1 from spritesheet)
  PRESET_ICON_SIZE_SMALL = 20   # px — unselected icon size (scaled down with stretch_blt)

  # Draws the horizontal preset icon bar using the external spritesheet.
  # Spritesheet layout (ev_presets.png): single column, 30x30 per icon, one row per preset.
  # cursor_presets.png: 30x30, drawn on top of the selected icon.
  def drawEVPresetBar(overlay, sel = -1)
    n = EV_PRESETS.length
    return if n == 0

    sheet    = AnimatedBitmap.new(PRESET_SPRITESHEET).bitmap
    cursor   = AnimatedBitmap.new(PRESET_CURSOR).bitmap
    icon_big = PRESET_ICON_SIZE
    icon_sm  = PRESET_ICON_SIZE_SMALL
    gap      = 6

    panel_left  = 256
    panel_right = 542
    has_sel     = sel >= 0

    name_w  = has_sel ? (EV_PRESETS[sel][:name].length * 7 + 8) : 0
    icons_w = (0...n).inject(0) { |sum, i| sum + (has_sel && i == sel ? icon_big : icon_sm) } + (n - 1) * gap
    total_w = icons_w + (has_sel ? 4 + name_w : 0)
    start_x = panel_left + ((panel_right - panel_left) - total_w) / 2
    bar_cy  = 80

    sel_c  = Color.new(220, 255, 220)
    sel_sh = Color.new(30,  80,  30)

    label_textpos = []
    cursor_x = start_x
    n.times do |i|
      selected = has_sel && i == sel
      iw = selected ? icon_big : icon_sm
      ih = selected ? icon_big : icon_sm
      iy = bar_cy - ih / 2
      src = Rect.new(0, i * icon_big, icon_big, icon_big)
      if selected
        overlay.blt(cursor_x, iy, sheet, src)
        overlay.blt(cursor_x, iy, cursor, Rect.new(0, 0, icon_big, icon_big))
        label_x = cursor_x + iw + 4
        label_y = iy + (ih - 16) / 2
        label_textpos << [EV_PRESETS[i][:name], label_x, label_y, :left, sel_c, sel_sh]
      else
        dst = Rect.new(cursor_x, iy, iw, ih)
        overlay.stretch_blt(dst, sheet, src)
      end
      cursor_x += iw + gap
    end
    pbDrawTextPositions(overlay, label_textpos)
  end

  def drawPageAllStats
    overlay = @sprites['overlay'].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    ev_total = 0

    statshadows = {}
    if Settings::PURIST_MODE
      GameData::Stat.each_main do |s|
        statshadows[s.id] = shadow
        ev_total += @pokemon.ev[s.id]
      end
    end
    unless Settings::PURIST_MODE
      ev_total = @pokemon.ev[:HP] + @pokemon.ev[:ATTACK] + @pokemon.ev[:DEFENSE] + @pokemon.ev[:SPECIAL_DEFENSE] + @pokemon.ev[:SPEED]
    end
    if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        statshadows[change[0]] = Color.new(136, 96, 72) if change[1] > 0
        statshadows[change[0]] = Color.new(64, 120, 152) if change[1] < 0
      end
    end
    evpool = 80 + @pokemon.level * 8
    evpool = evpool.div(4) * 4
    evpool = 512 if evpool > 512

    textpos = [
      [_INTL('Total'), 361, 102 + 16, :left, base, shadow],
      [_INTL('IV'),    466, 102 + 16, :left, base, shadow],
      [_INTL('EV'),    511, 102 + 16, :left, base, shadow],

      [_INTL('PS'), 256, 141 + 16, :left, base, statshadows[:HP]],
      [@pokemon.totalhp.to_s, 381, 141 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.iv[:HP]),  466, 141 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.ev[:HP]),  511, 141 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],

      [_INTL('Ataque'), 256, 178 + 16, :left, base, statshadows[:ATTACK]],
      [@pokemon.attack.to_s, 381, 178 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.iv[:ATTACK]), 466, 178 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.ev[:ATTACK]), 511, 178 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],

      [_INTL('Defensa'), 256, 215 + 16, :left, base, statshadows[:DEFENSE]],
      [@pokemon.defense.to_s, 381, 215 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.iv[:DEFENSE]), 466, 215 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.ev[:DEFENSE]), 511, 215 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],

      [_INTL('At. Esp.'), 256, 252 + 16, :left, base, statshadows[:SPECIAL_ATTACK]],
      [@pokemon.spatk.to_s, 381, 252 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.iv[:SPECIAL_ATTACK]),  466, 252 + 16, :left, Color.new(64, 64, 64),
       Color.new(176, 176, 176)],
      [format('%d', @pokemon.ev[:SPECIAL_ATTACK]),  511, 252 + 16, :left, Color.new(64, 64, 64),
       Color.new(176, 176, 176)],

      [_INTL('Def Esp.'), 256, 289 + 16, :left, base, statshadows[:SPECIAL_DEFENSE]],
      [@pokemon.spdef.to_s, 381, 289 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.iv[:SPECIAL_DEFENSE]), 466, 289 + 16, :left, Color.new(64, 64, 64),
       Color.new(176, 176, 176)],
      [format('%d', @pokemon.ev[:SPECIAL_DEFENSE]), 511, 289 + 16, :left, Color.new(64, 64, 64),
       Color.new(176, 176, 176)],

      [_INTL('Velocidad'), 256, 326 + 16, :left, base, statshadows[:SPEED]],
      [@pokemon.speed.to_s, 381, 326 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.iv[:SPEED]), 466, 326 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [format('%d', @pokemon.ev[:SPEED]), 511, 326 + 16, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],

      [_INTL('EVs Totales'), 300, 380, :left, base, shadow],
      [format('%d/%d', ev_total, evpool), 465, 380, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL('Poder Oculto'), 300, 410, :left, base, shadow]
    ]
    pbDrawTextPositions(overlay, textpos)

    drawEVPresetBar(overlay, $ev_preset_selected || -1) if $evalloc

    if $evalloc
      green    = Color.new(64, 200, 64)
      green_sh = Color.new(20, 80, 20)
      red      = Color.new(220, 64, 64)
      red_sh   = Color.new(80, 20, 20)

      rows = [
        [:HP,              @pokemon.ev[:HP],             @pokemon.totalhp, 141 + 16],
        [:ATTACK,          @pokemon.ev[:ATTACK],          @pokemon.attack,  178 + 16],
        [:DEFENSE,         @pokemon.ev[:DEFENSE],         @pokemon.defense, 215 + 16],
        [:SPECIAL_ATTACK,  @pokemon.ev[:SPECIAL_ATTACK],  @pokemon.spatk,   252 + 16],
        [:SPECIAL_DEFENSE, @pokemon.ev[:SPECIAL_DEFENSE], @pokemon.spdef,   289 + 16],
        [:SPEED,           @pokemon.ev[:SPEED],           @pokemon.speed,   326 + 16]
      ]

      if $ev_preset_selected && $ev_preset_selected >= 0
        preset = EV_PRESETS[$ev_preset_selected]
        if preset
          tmp = @pokemon.clone
          pbApplyEVPreset(tmp, $ev_preset_selected)
          preview_ev = {
            HP: tmp.ev[:HP],
            ATTACK: tmp.ev[:ATTACK],
            DEFENSE: tmp.ev[:DEFENSE],
            SPECIAL_ATTACK: tmp.ev[:SPECIAL_ATTACK],
            SPECIAL_DEFENSE: tmp.ev[:SPECIAL_DEFENSE],
            SPEED: tmp.ev[:SPEED]
          }
          proj_stats = {
            HP: tmp.totalhp,
            ATTACK: tmp.attack,
            DEFENSE: tmp.defense,
            SPECIAL_ATTACK: tmp.spatk,
            SPECIAL_DEFENSE: tmp.spdef,
            SPEED: tmp.speed
          }
          delta_textpos = []
          rows.each do |stat_id, cur_ev, cur_stat, row_y|
            ev_delta   = preview_ev[stat_id] - cur_ev
            stat_delta = proj_stats[stat_id] - cur_stat
            unless ev_delta == 0
              ev_str = ev_delta > 0 ? "+#{ev_delta}" : ev_delta.to_s
              c, sh  = ev_delta > 0 ? [green, green_sh] : [red, red_sh]
              delta_textpos << [ev_str, 542, row_y, :left, c, sh]
            end
            next if stat_delta == 0

            stat_str = stat_delta > 0 ? "+#{stat_delta}" : stat_delta.to_s
            c, sh    = stat_delta > 0 ? [green, green_sh] : [red, red_sh]
            delta_textpos << [stat_str, 254, row_y, :right, c, sh]
          end
          pbDrawTextPositions(overlay, delta_textpos)
        end

      elsif $ev_entry_snapshot
        snap = $ev_entry_snapshot
        snap_stats = {
          HP: snap[:hp],
          ATTACK: snap[:atk],
          DEFENSE: snap[:def_],
          SPECIAL_ATTACK: snap[:satk],
          SPECIAL_DEFENSE: snap[:sdef],
          SPEED: snap[:spd]
        }
        delta_textpos = []
        rows.each do |stat_id, cur_ev, cur_stat, row_y|
          ev_delta   = cur_ev - snap[:ev][stat_id]
          stat_delta = cur_stat - snap_stats[stat_id]
          unless ev_delta == 0
            ev_str = ev_delta > 0 ? "+#{ev_delta}" : ev_delta.to_s
            c, sh  = ev_delta > 0 ? [green, green_sh] : [red, red_sh]
            delta_textpos << [ev_str, 542, row_y, :left, c, sh]
          end
          next if stat_delta == 0

          stat_str = stat_delta > 0 ? "+#{stat_delta}" : stat_delta.to_s
          c, sh    = stat_delta > 0 ? [green, green_sh] : [red, red_sh]
          delta_textpos << [stat_str, 254, row_y, :right, c, sh]
        end
        pbDrawTextPositions(overlay, delta_textpos)
      end
    end

    hiddenpower = pbHiddenPower(@pokemon)
    type_number = GameData::Type.get(hiddenpower[0]).icon_position
    type_rect = Rect.new(0, type_number * 28, 64, 28)
    overlay.blt(440, 406, @typebitmap.bitmap, type_rect)
  end
end
