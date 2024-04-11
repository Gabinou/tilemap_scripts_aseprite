
-- Import Palette to .hex file.

local sprite = app.activeSprite
local palette = sprite.palettes[1]
palette:saveAs(app.fs.fileTitle(sprite.filename) .. ".hex")