// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

enum HEX_TYPE{
	FLAT_TOP, POINTY_TOP
}

function HexGrid(_hexType = HEX_TYPE.FLAT_TOP, _defaultValue = {}, _wrapDistance = undefined) constructor{
	hexType = _hexType;
	map = ds_map_create();
	defaultValue = _defaultValue;
	wrapDistance = _wrapDistance;
	mirrorTable = [];
	if(wrapDistance != undefined){
		for(var i=0; i<6; i++){
			array_push(mirrorTable, (new Hex(2*wrapDistance+1, -wrapDistance, -wrapDistance-1, hexType)).Rotate(i));
		}
	}
	
	GetMoveCost = function(_coords){
		return Get(_coords);
	}
	
	static GetNeighbors = function(_coords){
		return [
			WrapCoords(_coords.Add(new Hex(1, -1, 0))),
			WrapCoords(_coords.Add(new Hex(-1, 1, 0))),
			WrapCoords(_coords.Add(new Hex(0, 1, -1))),
			WrapCoords(_coords.Add(new Hex(0, -1, 1))),
			WrapCoords(_coords.Add(new Hex(1, 0, -1))),
			WrapCoords(_coords.Add(new Hex(-1, 0, 1)))
		];
	}
	
	static GetPath = function(_start, _target){
		/*show_debug_message("GetPath(...)");
		show_debug_message({
			_start: _start,
			_target: _target
		});*/
		var frontier = ds_priority_create();
		ds_priority_add(frontier, _start, 0);
		var came_from = ds_map_create();
		var cost_so_far = ds_map_create();
		came_from[? _start] = undefined;
		cost_so_far[? _start] = 0;
		
		while(ds_priority_size(frontier) > 0){
			//show_debug_message("Frontier size: "+string(ds_priority_size(frontier)));
			var current = ds_priority_delete_min(frontier);
			
			if(current.Equals(_target)){
				break;
			}
			
			var neighbors = GetNeighbors(current);
			for(var i=0; i<array_length(neighbors); i++){
				var next = neighbors[i];
				var new_cost = HexMapGet(cost_so_far, current) + GetMoveCost(next);
				
				if(
					!MapContainsKey(cost_so_far, next) ||
					new_cost < HexMapGet(cost_so_far, next)
				){
					cost_so_far[? next] = new_cost;
					var priority = new_cost;
					ds_priority_add(frontier, next, priority);
					came_from[? next] = current;
				}
			}
		}
		
		//show_debug_message("came_from.size: "+string(ds_map_size(came_from)));
		
		var current = _target;
		var path = [];
		while(current != _start){
			/* Just Debugging Here
			if(current == undefined){
				//show_debug_message("Current: "+current.ToString());
				var mapKeys = ds_map_keys_to_array(came_from);
				for(var i=0; i<array_length(mapKeys); i++){
					try{
						show_debug_message(mapKeys[i].ToString()+": "+came_from[? mapKeys[i]].ToString());
					}catch(e){
						
					}
				}
				break;
			}
			show_debug_message("Current: "+current.ToString());
			*/
			array_push(path, current);
			current = HexMapGet(came_from, current);
		}
		array_push(path, _start);
		path = array_reverse(path);
		
		ds_priority_destroy(frontier);
		ds_map_destroy(came_from);
		ds_map_destroy(cost_so_far);
		
		return path;
	}
	
	static ArrayContains = function(_array, _item){
		for(var i=0; i<array_length(_array); i++){
			if(_array[i].Equals(_item)) return true;
		}
		return false;
	}
	
	static MapContainsKey = function(_map, _key){
		var mapKeys = ds_map_keys_to_array(_map);
		return ArrayContains(mapKeys, _key);
	}
	
	static HexMapGet = function(_map, _key){
		var mapKeys = ds_map_keys_to_array(_map);
		for(var i=0; i<array_length(mapKeys); i++){
			if(mapKeys[i].Equals(_key)){
				return _map[? mapKeys[i]];
			}
		}
		return undefined;
	}
	
	static ArrayCoords = function(_coords){
		//Ensure coordinates are in array format.
		if(is_array(_coords)){
			return _coords;
		}else if(is_struct(_coords)){
			return [_coords.q, _coords.r, _coords.s];
		}else{
			show_error("Invalid coords provided to ArrayCoords(): "+string(_coords), true);
		}
	}
	
	static StructCoords = function(_coords){
		//Ensure coordinates are in struct format.
		if(is_struct(_coords)){
			return _coords;
		}else if(is_array(_coords)){
			return new Hex(_coords.q, _coords.r, _coords.s, hexType);
		}else{
			show_error("Invalid coords provided to StructCoords(): "+string(_coords), true);
		}
	}
	
	static WrapCoords = function(_coords){
		_coords = StructCoords(_coords);
		if(wrapDistance == undefined) return _coords;
		while(_coords.Distance(new Hex(0,0,0, hexType)) > wrapDistance){
			for(var i=0; i<array_length(mirrorTable); i++){
				var zeroDis = _coords.Distance(new Hex(0,0,0, hexType));
				if(_coords.Distance(mirrorTable[i]) < zeroDis){
					_coords = _coords.Subtract(mirrorTable[i]);
				}
			}
		}
		return _coords;
	}
	
	static CoordsToKey = function(_coords){
		_coords = ArrayCoords(_coords);
		return string(_coords[0])+"_"+string(_coords[1])+"_"+string(_coords[2]);
	}
	
	static Set = function(_coords, _value){
		_coords = WrapCoords(_coords);
		map[? CoordsToKey(_coords)] = _value;
	}
	
	static Get = function(_coords, _default=defaultValue){
		_coords = WrapCoords(_coords);
		var key = CoordsToKey(_coords);
		if(!ds_map_exists(map, key)){
			Set(_coords, _default);
		}
		return map[? key];
	}
	
	static Exists = function(_coords){
		_coords = WrapCoords(_coords);
		var key = CoordsToKey(_coords);
		return ds_map_exists(map, key);
	}
}

function Hex(_q, _r, _s=undefined, _hexType = HEX_TYPE.FLAT_TOP) constructor{
	q = _q;
	r = _r;
	s = _s;
	
	s ??= 0-(q+r);
	
	hexType = _hexType;
	
	static Add = function(_other){
		return new Hex(q+_other.q, r+_other.r, s+_other.s, hexType);
	}
	static Subtract = function(_other){
		return new Hex(q-_other.q, r-_other.r, s-_other.s, hexType);
	}
	static Distance = function(_other){
		//Manhattan distance by default
		var vec = Subtract(_other);
		return (abs(vec.q) + abs(vec.r) + abs(vec.s))/2;
	}
	static DistanceEuclidian = function(_other){
		var vec = Subtract(_other);
		return sqrt(sqr(vec.q) + sqr(vec.r) + vec.q*vec.r);
	}
	static Multiply = function(_value){
		return new Hex(q*_value, r*_value, s*_value, hexType);
	}
	static GetRange = function(_dis){
		var results = [];
		for(var _q = -_dis; _q <= _dis; _q++){
			for(var _r = max(-_dis, -_q-_dis); _r <= min(_dis, -_q+_dis); _r++){
				array_push(results, new Hex(_q, _r,, hexType));
			}
		}
		return results;
	}
	static Rotate = function(_steps=1, _pivot=new Hex(0,0,0, hexType)){
		//Positive steps are clockwise.
		if(_steps==0) return self;
		if(_steps < 0){
			return Rotate(ceil(abs(_steps)/6)*6 + _steps, _pivot);
		}
		_steps = _steps%6;
		var vec = Subtract(_pivot);
		var rotatedVec = new Hex(-vec.r, -vec.s, -vec.q, hexType);
		return _pivot.Add(rotatedVec).Rotate(_steps-1);
	}
	static ToPixel = function(_size){
		if(hexType == HEX_TYPE.FLAT_TOP){
			return {
				x: _size * 3/2 * q,
				y: _size * (sqrt(3)/2 * q + sqrt(3) * r)
			};
		}else{
			return {
				x: _size * (sqrt(3) * q + sqrt(3)/2 * r),
				y: _size * 3/2 * r
			};
		}
	}
	static FromPixel = function(_pixel, _size, _hexType=hexType){
		if(is_array(_pixel)){
			_pixel = {
				x: _pixel[0],
				y: _pixel[1]
			};
		}
		if(hexType == HEX_TYPE.FLAT_TOP){
			return new Hex(
				(2/3 * _pixel.x)/_size,
				(-1/3 * _pixel.x + sqrt(3)/3 * _pixel.y)/_size,, hexType
			);
		}else{
			return new Hex(
				(sqrt(3)/3 * _pixel.x - 1/3 * _pixel.y)/_size,
				(2/3*_pixel.y)/_size,, hexType
			);
		}
	}
	static Round = function(){
		var r_q = round(q);
		var r_r = round(r);
		var r_s = round(s);
		
		var q_diff = abs(r_q-q);
		var r_diff = abs(r_r-r);
		var s_diff = abs(r_s-s);
		
		if(q_diff > r_diff && q_diff > s_diff){
			r_q = -r_r-r_s;
		}else if(r_diff > s_diff){
			r_r = -r_q-r_s;
		}else{
			r_s = -r_q-r_r;
		}
		
		return new Hex(r_q, r_r, r_s, hexType);
	}
	static Normalize = function(){
		var dis = DistanceEuclidian(new Hex(0, 0, 0, hexType));
		if(dis == 0) return new Hex(0, 0, 0, hexType);
		return new Hex(q/dis, r/dis, s/dis, hexType);
	}
	static Equals = function(_other){
		return (
			q == _other.q &&
			r == _other.r &&
			s == _other.s
		);
	}
	static ToString = function(){
		return "["+string(q)+", "+string(r)+", "+string(s)+"]";
	}
}