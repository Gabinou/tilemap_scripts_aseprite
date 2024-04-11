local sprite = app.activeSprite

-- credits to boombuler

-- Check constraints
if sprite == nil then
  app.alert("No Sprite...")
  return
end
if sprite.colorMode ~= ColorMode.INDEXED then
  app.alert("Sprite needs to be indexed")
  return
end

local function getPaletteData(palette)
  local ncolors = #palette
  local res = string.format("%i\n", ncolors)

  for i=0, ncolors-1 do
    local color = palette:getColor(i)
    res = res .. string.format("%i %i %i %i\n", color.red, color.green, color.blue, color.alpha)    
  end

  return res
end

local function getIndexData(img, x, y, w, h)
  local res = ""
  for y = 0,h-1 do
    for x = 0, w-1 do
      px = img:getPixel(x, y)
      res = res .. string.format("%i ", px)
    end
    res = res .. "\n"
  end

  return res
end

local function exportFrame(frm)
  if frm == nil then
    frm = 1
  end

  local img = Image(sprite.spec)
  img:drawSprite(sprite, frm)
  
  io.write("Palette Indexed Picture\n")
  io.write("begin palette\n")
  io.write(getPaletteData(sprite.palettes[1]))
  io.write("end palette\n")
  io.write("begin indices\n")
  io.write(getIndexData(img, x, y, sprite.width, sprite.height))
  io.write("end indices\n")
end


local dlg = Dialog()
dlg:file{ id="exportFile",
          label="File",
          title="Gameboy-Assembler Export",
          open=false,
          save=true,
        --filename= p .. fn .. "pip",
          filetypes={"txt", "pip" }}
dlg:check{ id="onlyCurrentFrame",
           text="Export only current frame",
           selected=true }

dlg:button{ id="ok", text="OK" }
dlg:button{ id="cancel", text="Cancel" }
dlg:show()
local data = dlg.data
if data.ok then
  local f = io.open(data.exportFile, "w")
  io.output(f)

  if data.onlyCurrentFrame then
    exportFrame(app.activeFrame)
  else
    for i = 1,#sprite.frames do
      io.write(string.format(";Frame %d\n", i))
      exportFrame(i)
    end
  end

  io.close(f)
end