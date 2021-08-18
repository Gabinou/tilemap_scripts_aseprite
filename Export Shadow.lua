if TilesetMode == nil then return app.alert "Use Aseprite v1.3"  end

-- Export layer named Shadow as an array of ones and zeros
-- 1. Copy both layers.
-- 2. Turn original layers invisible
-- 3. Flatten copied layers, make them visible
-- 4. Convert flattened layer to tilemap layer
-- 5. Export tileset
-- 6. Delete flattened layer

local row_len = 8

local spr = app.activeSprite
local lay = app.activeLayer
local fs = app.fs
local output_folder = fs.filePath(spr.filename)
if not lay.isTilemap then return app.alert "No active tilemap layer" end

local function layers_duplicate(spr)
  for i,layer in ipairs(spr.layers) do
    app.activeLayer = layer
    layer.isVisible = true    
    app.command.DuplicateLayer()
    layer.isVisible = false
  end
end

local function layers_visible_flatten(spr)
  for i,layer in ipairs(spr.layers) do
    app.command.FlattenLayers{["visibleOnly"]="true"}
    local grid = spr.gridBounds
    grid.height = 16
    grid.width = 16
    spr.gridBounds = grid
  end
end

local function layers_visible2tilemap(spr)
  for i,layer in ipairs(spr.layers) do
    if layer.isVisible then
      app.command.ConvertLayer{["to"]="tilemap"}
    end
  end
end

layers_duplicate(spr)
layers_visible_flatten(spr)
layers_visible2tilemap(spr)

local lay = app.activeLayer
if lay.isTilemap then
  local tileset = lay.tileset
  local spec = spr.spec
  local grid = tileset.grid
  local size = grid.tileSize
  spec.width = size.width * row_len
  spec.height = size.height * ((#tileset // row_len) + 1)
  local image = Image(spec)
  image:clear() 
  for i = 0,row_len-1 do
    for j = 0, (#tileset // row_len) do
      local current = i + j* row_len
      if (current < #tileset) then
        local tile = tileset:getTile(current)
        image:drawImage(tile, i*size.width, j*size.height)
      end
    end
  end
  local path = fs.joinPath(output_folder, app.fs.fileTitle(spr.filename) .. ".png")
  image:saveAs(path)
end
app.command.RemoveLayer()

