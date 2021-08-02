
-- Modified from https://gist.github.com/dacap/9df368ba276a45048dc85f96b23ea818 by Gabriel Taillon

-- Copyright (c) 2021  Gabriel Taillon
-- Copyright (c) 2020  David Capello
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


-- EXPORT TILESET for aseprite files with many layers.
-- Layer names don't matter. Script keeps layer ordering.
-- 1. Copies all layers, make copies visible
-- 2. Turn original layers invisible
-- 3. Flatten copied layers
-- 4. Convert flattened layer to tilemap layer
-- 5. Export tileset with col_len
-- 6. Delete flattened layer

if TilesetMode == nil then return app.alert "Use Aseprite v1.3"  end

local col_len = 8

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
  spec.width = size.width * (#tileset // col_len)
  spec.height = size.height * col_len
  local image = Image(spec)
  image:clear() 
  for j = 0,(#tileset // col_len) do
    for i = 0, col_len-1 do
      local current = j * col_len + i
      if (current < #tileset) then
        local tile = tileset:getTile(current)
        image:drawImage(tile, j*size.width, i*size.height)
      end
    end
  end
  local path = fs.joinPath(output_folder, app.fs.fileTitle(spr.filename) .. ".png")
  image:saveAs(path)
end
app.command.RemoveLayer()

