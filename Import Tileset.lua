if TilesetMode == nil then return app.alert "Use Aseprite v1.3"  end

-- Import Tilesets for every tilemap layer. 
-- Layer name should be same name as in the Tileset_*layername*.png 
-- For Every Tilemap Layer:
-- 1. Create empty Tilemap *layername*_2
-- 2. Import .png tileset. 
-- 3. Copy tileset pixels pixels.
-- 4. Delete all tile indices/pixels on the canvas
-- 5. Copy pixels from *layername*
-- 6. Delete *layername*
-- 7. Rename *layername*_2 to *layername* 

local spr = app.activeSprite
local lay = app.activeLayer
local fs = app.fs
local output_folder = fs.filePath(spr.filename)
local tileset_folder
if string.find(output_folder, "Maps")  then
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

local function layer_tilemap_create(layername)
  app.command.NewLayer()
  app.command.ConvertLayer{["to"]="tilemap"}
  -- app.command.NewLayer{["tilemap"]=true} -- Borks placement offset Aseprite Issue #2743
  layer = app.activeLayer
  layer.name = layername .. "_2"
  return(layer)
end
layernames = {}
for i,layer in ipairs(spr.layers) do
  layernames[#layernames + 1] = layer.name 
end

for i = 1, (#layernames) do
  -- print(layernames[i])
  local tileset_filename = app.fs.joinPath(tileset_folder, "Tileset_"..layernames[i]..".png")
  layer_tilemap_create(layernames[i])
  local newlayer = getLayer(spr, layernames[i].."_2")
  local oldlayer = getLayer(spr, layernames[i])
  assert(newlayer ~= nil)
  assert(oldlayer ~= nil)
  oldlayer.isVisible = true
  newlayer.isVisible = true
  sprite_tileset = app.open(tileset_filename)

  -- Copy all pixels from tileset_filename to newlayer (creates new tiles)
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
  -- app.activeSprite = spr
  app.activeLayer = oldlayer
  spr.selection:selectAll()
  app.command.Copy()
  app.activeLayer = newlayer
  -- spr.selection:selectAll()
  spr.selection:deselect()
  app.command.Paste()
  spr.selection:deselect()
end

