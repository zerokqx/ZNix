local obs = obslua

local source_name = ""
local zoom_factor = 2.0
local speed = 0.15
local zoom_enabled = false

local target_crop_l = 0
local target_crop_t = 0
local target_crop_r = 0
local target_crop_b = 0

local current_crop_l = 0
local current_crop_t = 0
local current_crop_r = 0
local current_crop_b = 0

local base_width = 1920
local base_height = 1080

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

local function update_crop()
  if source_name == "" then return end

  local current_scene_source = obs.obs_frontend_get_current_scene()
  if not current_scene_source then return end
  local scene = obs.obs_scene_from_source(current_scene_source)
  obs.obs_source_release(current_scene_source)
  if not scene then return end

  local scene_item = obs.obs_scene_find_source(scene, source_name)
  if not scene_item then return end

  if zoom_enabled then
    local cx, cy = get_cursor_pos()
    if not cx or not cy then
      cx = base_width / 2
      cy = base_height / 2
    end

    local vis_w = base_width / zoom_factor
    local vis_h = base_height / zoom_factor

    local l = clamp(cx - vis_w / 2, 0, base_width - vis_w)
    local t = clamp(cy - vis_h / 2, 0, base_height - vis_h)
    local r = base_width - (l + vis_w)
    local b = base_height - (t + vis_h)

    target_crop_l = l
    target_crop_t = t
    target_crop_r = r
    target_crop_b = b
  else
    target_crop_l = 0
    target_crop_t = 0
    target_crop_r = 0
    target_crop_b = 0
  end

  -- Плавная интерполяция (lerp)
  current_crop_l = current_crop_l + (target_crop_l - current_crop_l) * speed
  current_crop_t = current_crop_t + (target_crop_t - current_crop_t) * speed
  current_crop_r = current_crop_r + (target_crop_r - current_crop_r) * speed
  current_crop_b = current_crop_b + (target_crop_b - current_crop_b) * speed

  local crop = obs.obs_sceneitem_crop()
  crop.left = math.floor(current_crop_l)
  crop.top = math.floor(current_crop_t)
  crop.right = math.floor(current_crop_r)
  crop.bottom = math.floor(current_crop_b)

  obs.obs_sceneitem_set_crop(scene_item, crop)
end

function toggle_zoom(pressed)
  if pressed then
    zoom_enabled = not zoom_enabled
  end
end

function script_description()
  return "Плавный зум и автоматическое слежение за курсором для Hyprland (Screen Studio style)."
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
  obs.obs_properties_add_int(props, "width", "Ширина экрана (px)", 640, 3840, 10)
  obs.obs_properties_add_int(props, "height", "Высота экрана (px)", 480, 2160, 10)
  
  return props
end

function script_update(settings)
  source_name = obs.obs_data_get_string(settings, "source")
  zoom_factor = obs.obs_data_get_double(settings, "zoom_factor")
  speed = obs.obs_data_get_double(settings, "speed")
  base_width = obs.obs_data_get_int(settings, "width")
  base_height = obs.obs_data_get_int(settings, "height")
end

function script_defaults(settings)
  obs.obs_data_set_default_double(settings, "zoom_factor", 2.0)
  obs.obs_data_set_default_double(settings, "speed", 0.15)
  obs.obs_data_set_default_int(settings, "width", 1920)
  obs.obs_data_set_default_int(settings, "height", 1080)
end

function script_load(settings)
  hotkey_id = obs.obs_hotkey_register_frontend("hyprland_zoom_toggle", "Включить/выключить Zoom за мышкой", toggle_zoom)
  local hotkey_save_array = obs.obs_data_get_array(settings, "hyprland_zoom_toggle")
  obs.obs_data_array_release(hotkey_save_array)

  obs.timer_add(update_crop, 16)
end

function script_save(settings)
  local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
  obs.obs_data_set_array(settings, "hyprland_zoom_toggle", hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)
end
