// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_text_outline(x, y, text, col, outlineCol, thickness){
	for(var i=0; i<8; i++){
		var _x = x + cos((i/8)*2*pi)*thickness;
		var _y = y - sin((i/8)*2*pi)*thickness;
		draw_text_color(_x, _y, text, outlineCol, outlineCol, outlineCol, outlineCol, 1);
	}
	draw_text_color(x, y, text, col, col, col, col, 1);
}

function draw_arrow_outline(x1, y1, x2, y2, size, col, outlineCol, thickness){
	var arrowStart = 0.3;
	var arrowEnd = 0.7;
	if(point_distance(x1, y1, x2, y2) > 50){
		arrowStart = 0;
		arrowEnd = 1;
	}
	draw_set_color(outlineCol);
	for(var i=0; i<8; i++){
		var _x = cos((i/8)*2*pi)*thickness;
		var _y = sin((i/8)*2*pi)*thickness;
		draw_arrow(
			_x + lerp(x1, x2, arrowStart),
			_y + lerp(y1, y2, arrowStart),
			_x + lerp(x1, x2, arrowEnd),
			_y + lerp(y1, y2, arrowEnd),
			size
		);
	}
	draw_set_color(col);
	draw_arrow(
		lerp(x1, x2, arrowStart),
		lerp(y1, y2, arrowStart),
		lerp(x1, x2, arrowEnd),
		lerp(y1, y2, arrowEnd),
		size
	);
	draw_set_color(c_white);
}