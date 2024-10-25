/// @description Insert description here
// You can write your code in this editor

randomize();

global.lowerLimit = 2;
global.upperLimit = 2;

lastGameStep = current_time;
gameStepSeconds = 0.1;
population = 0;

size = 16;
gridRadius = 12;
hexGrid = new HexGrid(HEX_TYPE.POINTY_TOP, {
	moveCost: infinity
}, gridRadius);

hexZero = new Hex(0,0,0, HEX_TYPE.POINTY_TOP);

hex1 = undefined;
hex2 = undefined;
path = undefined;

var hexes = hexZero.GetRange(gridRadius);
for(var i=0; i<array_length(hexes); i++){
	var data = {
		heat: 0.5,
		heatNext: 0.5,
		history: [irandom_range(0, 1), irandom_range(0, 1), irandom_range(0, 1)],
		nextStep: false,
		adjustHistory: function(hexGrid, hex){
			return;
			array_pop(history);
			array_insert(history, 0, nextStep);
			heat = heatNext;
		},
		calcNextHistoryStep: function(hexGrid, hex){
			return;
			heatNext *= 0.25;
			var neighbors = hexGrid.GetNeighbors(hex);
			var count = 0;
			for(var i=0; i<array_length(neighbors); i++){
				var neighbor = neighbors[i];
				var neighborData = hexGrid.Get(neighbor);
				//show_debug_message(neighborData);
				if(neighborData.moveCost == infinity) continue;
				if(
					neighborData.history[0] &&
					neighborData.history[1] &&
					neighborData.history[2]
				){
					count++;
					heatNext += 0.1;
				}
				if(
					neighborData.history[0] +
					neighborData.history[1] +
					neighborData.history[2] >= 2
				){
					count++;
					heatNext += 0.1;
				}
			}
			if(count >= global.lowerLimit && count <= global.upperLimit){
				nextStep = true;
			}else{
				nextStep = false;
			}
		},
		moveCost: irandom_range(0, 10),
		getColor: function(){
			if(heat < 0.5){
				return merge_color(c_blue, c_white, heat*2);
			}else{
				return merge_color(c_white, c_red, (heat-0.5)*2);
			}
		},
		Draw: function(_x, _y, hexGrid, hex, size){
			var pixel = hex.ToPixel(size);
			_x += pixel.x;
			_y += pixel.y;
			var hexData = hexGrid.Get(hex);
			var cost = hexData.moveCost;
			
			/* Just color stuff */
			var wrappedHex = hexGrid.WrapCoords(hex);
			var normalizedHex = wrappedHex.Normalize();
			var low = min(min(normalizedHex.q, normalizedHex.r), normalizedHex.s);
			var high = max(max(normalizedHex.q, normalizedHex.r), normalizedHex.s);
			var range = high-low;
			var col_r = lerp(0, 255, clamp((normalizedHex.q-low)/range, 0, 1));
			var col_g = lerp(0, 255, clamp((normalizedHex.r-low)/range, 0, 1));
			var col_b = lerp(0, 255, clamp((normalizedHex.s-low)/range, 0, 1));
			var col = make_color_rgb(col_r, col_g, col_b);
			//var col = getColor();
			draw_set_color(col);
			/* End color stuff */
	
			draw_circle(_x, _y, size*0.75, false);
	
			/*
			for(var j=0; cost!=undefined && j<cost; j++){
				var rot = (cost <= 1 ? 0 : 90*j/(cost-1));
				draw_sprite_ext(SprHashing, 0, _x, _y, size/32, size/32, rot, c_white, 0.25);
			}
			*/
			
			/*
			draw_set_color(merge_color(c_white, c_black, !history[0]));
			draw_circle(_x, _y, size*0.6, false);
			draw_set_color(merge_color(c_white, c_black, !history[1]));
			draw_circle(_x, _y, size*0.4, false);
			draw_set_color(merge_color(c_white, c_black, !history[2]));
			draw_circle(_x, _y, size*0.2, false);
			*/
	
	
			/* Draw data on hex */
			draw_set_color(c_white);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text_outline(_x, _y, string(cost), c_white, c_black, 2);
			/* End draw data */
		}
	};
	
	hexGrid.Set(hexes[i], data);
}

with(hexGrid){
	GetMoveCost = function(_coords){
		show_debug_message(Get(_coords));
		return Get(_coords).moveCost;
	};
}

x = room_width/2;
y = room_height/2;