if TilesetMode == nil then return app.alert "Use Aseprite v1.3"  end

-- Import Tilesets for every tilemap layer. 
-- Layer name should be same name as in the Tileset_*layername*.png 
-- For Every Tilemap Layer:
-- 1. Create empty Tilemap *layername*_2
-- 2. Import .png pixels. (create many new tiles)
-- 3. Delete all tile indices on the canvas
-- 4. Copy pixels from *layername*
-- 5. Delete *layername*
-- 6. Rename *layername*_2 to *layername* 

local row_len = 8

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
  layer = app.activeLayer
  layer.name = layername .. "_2"
  app.command.ConvertLayer{["to"]="tilemap"}
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
  local oldlayer = getLayer(spr, layernames[i])
  local newlayer = getLayer(spr, layernames[i].."_2")
  if newlayer == nil then
    print("newlayer is nil")
  end
  if oldlayer == nil then
    print("oldlayer is nil")
  end
  sprite_tileset = app.open(tileset_filename)
  -- local selection_temp = Selection()
  sprite_tileset.selection:selectAll()
  app.command.Copy()
  app.activeSprite = spr
  app.activeLayer = newlayer
  spr.selection:selectAll()
  app.command.Paste()
  sprite_tileset:close()
end

  -- local newlayer = layer_tilemap_create(layer.name)

