/// @description Insert description here
// You can write your code in this editor

if((current_time - lastGameStep)/1000 > gameStepSeconds){
	lastGameStep = current_time;
	
	var hexes = hexZero.GetRange(gridRadius);
	for(var i=0; i<array_length(hexes); i++){
		var hex = hexes[i];
		var hexData = hexGrid.Get(hex);
		hexData.calcNextHistoryStep(hexGrid, hex);
	}
	for(var i=0; i<array_length(hexes); i++){
		var hex = hexes[i];
		var hexData = hexGrid.Get(hex);
		hexData.adjustHistory(hexGrid, hex);
	}
	population = 0;
	for(var i=0; i<array_length(hexes); i++){
		var hex = hexes[i];
		var hexData = hexGrid.Get(hex);
		population += hexData.history[0];
		population += hexData.history[1];
		population += hexData.history[2];
	}
}
