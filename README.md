# Scripts for Aseprite v1.3-beta (tilemap editor)

These Lua scripts automate Tileset and Tilemap export.

Both ```Export Tilemap.lua``` and ```Export Tileset.lua``` are modified versions of scripts by [David Capello](https://github.com/dacap).
Credit to [rxi](https://github.com/rxi/json.lua) for ```json.lua```.
Everything including my modifications are under the MIT licence, feel free to use and modify.

- ```Export Tilemap.lua``` uses json.lua to export aseprite tile indices for each tilemap layer. The exported active area is visible in aseprite by holding the ctrl key. Let me repeat: Exported tilemaps are *NOT* for the whole canvas. I don't know how to change this behavior. 

- ```Export Tileset.lua``` exports a tileset into a rectangular ```png``` with a maximal ```row_len```, by copying and flattening all layers. I use it to create tiles with different backgrounds.
