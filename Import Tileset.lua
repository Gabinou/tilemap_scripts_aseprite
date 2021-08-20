if TilesetMode == nil then return app.alert "Use Aseprite v1.3"  end

-- Import Tilesets for every tilemap layer. 
-- Layer name should be same name as in the Tileset_*layername*.png 
-- For Every Tilemap Layer:
-- 1. Create empty Tilemap *layername*_2
-- 2. Import .png tileset. 
-- 3. Copy tileset pixels pixels.
-- 4. Delete all tile indices/pixels on the canvas
-- 5. Copy pixels from *layername*
-- 6. Repeat steps 2-5 for all frames
-- 7. Delete *layername*
-- 8. Rename *layername*_2 to *layername* 

app.command.GotoFirstFrame()
local frame = app.activeFrame
local spr = app.activeSprite
local lay = app.activeLayer
local fs = app.fs
local output_folder = fs.filePath(spr.filename)
local tileset_folder
if string.find(output_folder, "Maps") then
 tileset_folder = output_folder:gsub("Maps", "Tiles")
end
-- print(tileset_folder)
if not lay.isTilemap then return app.alert "No active tilemap layer" end

local function getLayer(spr, layername)
  local outlayer
  for i,layer in ipairs(spr.layers) do
    if layer.name == layername then
      outlayer = layer
      break
    end
  end
  return(outlayer)
end

local function layer_tilemap_create(newname)
  app.command.NewLayer()
  app.command.ConvertLayer{["to"]="tilemap"}
  -- app.command.NewLayer{["tilemap"]=true} -- Borks placement offset Aseprite Issue #2743
  layer = app.activeLayer
  layer.name = newname
  return(layer)
end

tilemap_oldlayer_names = {}
for i,layer in ipairs(spr.layers) do
  if layer.isTilemap then
    tilemap_oldlayer_names[#tilemap_oldlayer_names + 1] = layer.name 
  end
end


local postname = "_2"
-- Make new tilemap layers
for i = 1, (#tilemap_oldlayer_names) do
  -- print(tilemap_oldlayer_names[i])
  local tileset_filename = app.fs.joinPath(tileset_folder, "Tileset_"..tilemap_oldlayer_names[i]..".png")
  layer_tilemap_create(tilemap_oldlayer_names[i]..postname)
end

-- Copy new tiles from tilesets, and pixels from old layers
while (frame ~= nil) do
  spr = frame.sprite
  lay = app.activeLayer
  for i = 1, (#tilemap_oldlayer_names) do

  -- get old and new tilemap layers
    local tileset_filename = app.fs.joinPath(tileset_folder, "Tileset_"..tilemap_oldlayer_names[i]..".png")
    local newlayer = getLayer(spr, tilemap_oldlayer_names[i]..postname)
    local oldlayer = getLayer(spr, tilemap_oldlayer_names[i])
    assert(newlayer ~= nil)
    assert(oldlayer ~= nil)
    oldlayer.isVisible = true
    newlayer.isVisible = true
    sprite_tileset = app.open(tileset_filename)

    -- Creates new tileset by copying all pixels from tileset_filename to newlayer
    sprite_tileset.selection:selectAll()
    app.command.Copy()
    app.activeSprite = spr
    app.activeLayer = newlayer
    app.command.ToggleTilesMode()
    app.command.TilesetMode{["mode"]="auto"}
    app.command.Paste()
    
    -- Delete all pixels in newlayer
    app.command.ToggleTilesMode()
    spr.selection:selectAll()
    app.command.TilesetMode{["mode"]="stack"}
    app.command.Clear()
    sprite_tileset.selection:deselect()
    sprite_tileset:close()

    -- Copy pixels from oldlayer
    spr = app.activeSprite
    app.activeLayer = oldlayer
    spr.selection:selectAll()
    app.command.Copy()
    app.activeLayer = newlayer
    spr.selection:deselect()
    app.command.Paste()
    spr.selection:deselect()
  end
  app.command.GotoNextFrame()
  frame = app.activeFrame
  if (frame.frameNumber == 1) then
    break
  end
end

-- Delete old layers
for i = 1, (#tilemap_oldlayer_names) do
  local tileset_filename = app.fs.joinPath(tileset_folder, "Tileset_"..tilemap_oldlayer_names[i]..".png")
  local newlayer = getLayer(spr, tilemap_oldlayer_names[i]..postname)
  local oldlayer = getLayer(spr, tilemap_oldlayer_names[i])
  newlayer.name = oldlayer.name
  spr:deleteLayer(oldlayer)
end
