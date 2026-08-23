local obs = obslua

local source_name = ""
local zoom_factor = 2.0
local speed = 0.15
local zoom_enabled = false

local current_zoom = 1.0
local current_x = 960.0
local current_y = 540.0

local base_width = 1920.0
local base_height = 1080.0

local hotkey_id = obs.OBS_INVALID_HOTKEY_ID

local function get_cursor_pos()
  local handle = io.popen("hyprctl cursorpos 2>/dev/null")
  if not handle then return nil, nil end
  local res = handle:read("*a")
  handle:close()
  if res then
    local x, y = res:match("(%d+),%s*(%d+)")
    if x and y then
      return tonumber(x), tonumber(y)
    end
  end
  return nil, nil
end

local function clamp(val, min_val, max_val)
  if val < min_val then return min_val end
  if val > max_val then return max_val end
  return val
end

local function update_zoom()
  if source_name == "" then return end

  local current_scene_source = obs.obs_frontend_get_current_scene()
  if not current_scene_source then return end
  local scene = obs.obs_scene_from_source(current_scene_source)
  obs.obs_source_release(current_scene_source)
  if not scene then return end

  local scene_item = obs.obs_scene_find_source(scene, source_name)
  if not scene_item then return end

  local target_zoom = zoom_enabled and zoom_factor or 1.0
  local target_x = base_width / 2.0
  local target_y = base_height / 2.0

  if zoom_enabled then
    local cx, cy = get_cursor_pos()
    if cx and cy then
      target_x = cx
      target_y = cy
    end
  end

  -- Плавная интерполяция зума и координат мыши
  current_zoom = current_zoom + (target_zoom - current_zoom) * speed
  current_x = current_x + (target_x - current_x) * speed
  current_y = current_y + (target_y - current_y) * speed

  -- 1. Сбрасываем обрезку (crop), чтобы не было черных полос
  local crop = obs.obs_sceneitem_crop()
  crop.left = 0
  crop.top = 0
  crop.right = 0
  crop.bottom = 0
  obs.obs_sceneitem_set_crop(scene_item, crop)

  -- 2. Устанавливаем масштаб (Scale)
  local scale = obs.vec2()
  scale.x = current_zoom
  scale.y = current_zoom
  obs.obs_sceneitem_set_scale(scene_item, scale)

  -- 3. Вычисляем смещение позиции камеры, чтобы фокус был на курсоре
  local target_pos_x = (base_width / 2.0) - (current_x * current_zoom)
  local target_pos_y = (base_height / 2.0) - (current_y * current_zoom)

  -- Ограничиваем координаты, чтобы экран не улетал за границы видео
  local min_x = base_width * (1.0 - current_zoom)
  local min_y = base_height * (1.0 - current_zoom)

  local pos = obs.vec2()
  pos.x = clamp(target_pos_x, min_x, 0.0)
  pos.y = clamp(target_pos_y, min_y, 0.0)

  obs.obs_sceneitem_set_pos(scene_item, pos)
end

function toggle_zoom(pressed)
  if pressed then
    zoom_enabled = not zoom_enabled
  end
end

function script_description()
  return "Плавный зум на курсор без черных рамок для Hyprland (Screen Studio style)."
end

function script_properties()
  local props = obs.obs_properties_create()
  
  local p_source = obs.obs_properties_add_list(props, "source", "Источник экрана", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
  local sources = obs.obs_enum_sources()
  if sources then
    for _, s in ipairs(sources) do
      local name = obs.obs_source_get_name(s)
      obs.obs_property_list_add_string(p_source, name, name)
    end
    obs.source_list_release(sources)
  end

  obs.obs_properties_add_float(props, "zoom_factor", "Кратность зума", 1.2, 5.0, 0.1)
  obs.obs_properties_add_float_slider(props, "speed", "Плавность слежения", 0.05, 0.5, 0.01)
  obs.obs_properties_add_float(props, "width", "Ширина экрана (px)", 640.0, 3840.0, 10.0)
  obs.obs_properties_add_float(props, "height", "Высота экрана (px)", 480.0, 2160.0, 10.0)
  
  return props
end

function script_update(settings)
  source_name = obs.obs_data_get_string(settings, "source")
  zoom_factor = obs.obs_data_get_double(settings, "zoom_factor")
  speed = obs.obs_data_get_double(settings, "speed")
  base_width = obs.obs_data_get_double(settings, "width")
  base_height = obs.obs_data_get_double(settings, "height")
end

function script_defaults(settings)
  obs.obs_data_set_default_double(settings, "zoom_factor", 2.0)
  obs.obs_data_set_default_double(settings, "speed", 0.15)
  obs.obs_data_set_default_double(settings, "width", 1920.0)
  obs.obs_data_set_default_double(settings, "height", 1080.0)
end

function script_load(settings)
  hotkey_id = obs.obs_hotkey_register_frontend("hyprland_zoom_toggle", "Включить/выключить Zoom за мышкой", toggle_zoom)
  local hotkey_save_array = obs.obs_data_get_array(settings, "hyprland_zoom_toggle")
  obs.obs_data_array_release(hotkey_save_array)

  obs.timer_add(update_zoom, 16)
end

function script_save(settings)
  local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
  obs.obs_data_set_array(settings, "hyprland_zoom_toggle", hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)
end
