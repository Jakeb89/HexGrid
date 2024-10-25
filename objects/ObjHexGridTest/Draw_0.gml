/// @description Insert description here
// You can write your code in this editor

var hexes = hexZero.GetRange(gridRadius*2);
for(var i=0; i<array_length(hexes); i++){
	var hex = hexes[i];
	
	if(struct_exists(hexGrid.Get(hex), "Draw")){
		hexGrid.Get(hex).Draw(x, y, hexGrid, hex, size);
	}
	
}

if(path != undefined){
	var prevHex = undefined;
	for(var i=0; i<array_length(path); i++){
		var currentHex = path[i];
		if(i>0){
			var prevHexPixel = prevHex.ToPixel(size);
			var currentHexPixel = currentHex.ToPixel(size);
			draw_arrow_outline(prevHexPixel.x+x, prevHexPixel.y+y, currentHexPixel.x+x, currentHexPixel.y+y, size, c_white, c_black, 2);
		}
		prevHex = currentHex;
	}
}

draw_set_halign(fa_left);
draw_text_outline(12, 12+20*0, "Population: "+string(population), c_white, c_black, 2);
draw_text_outline(12, 12+20*1, "Lower Limit: "+string(global.lowerLimit), c_white, c_black, 2);
draw_text_outline(12, 12+20*2, "Upper Limit: "+string(global.upperLimit), c_white, c_black, 2);