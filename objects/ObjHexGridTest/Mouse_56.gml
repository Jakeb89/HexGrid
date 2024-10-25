/// @description Insert description here
// You can write your code in this editor

hex2 = hexZero.FromPixel([mouse_x-x, mouse_y-y], size).Round();
show_debug_message(hex2.ToString());

if(hex1 == undefined || hex2 == undefined) return;
if(!hexGrid.Exists(hex1) || !hexGrid.Exists(hex2)) return;

path = hexGrid.GetPath(hex1, hex2);
show_debug_message(path);