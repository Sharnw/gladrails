	var initAnimations = function() {
		// dimensions of a single sprite square
		var xb = 85;
		var yb = 55;
	    var stage = new Kinetic.Stage({
	        container: 'canvas_container',
	        width: 360,
	        height: 180
	      });
	     var layer = new Kinetic.Layer();
	     // MAPPING ANIMATE ACTIONS TO SPRITE PIXELS
	     var animations = {
	      // left
	        l_idle: [{ x: 0, y: 0, width: xb, height: yb }],
	        l_fallen: [{ x: xb*5, y: yb*5, width: xb, height: yb }],
	        l_dead: [{ x: 0, y: yb*3, width: xb, height: yb }],  
	        l_flinch: [
	        	{ x: 0, y: 0, width: xb, height: yb },
	        	{ x: xb*2, y: yb*5, width: xb, height: yb },
		        { x: xb*2, y: yb*5, width: xb, height: yb }
		    ],  
	        l_block: [
	        	{ x: 0, y: 0, width: xb, height: yb },
	        	{ x: xb*2, y: 0, width: xb, height: yb },
	        	{ x: xb*1, y: 0, width: xb, height: yb }
	       	],
	        l_kick: [
	        	{ x: xb*1, y: yb*4, width: xb, height: yb },
	        	{ x: xb*4, y: yb*4, width: xb, height: yb },
	        	{ x: xb*5, y: yb*4, width: xb, height: yb }
	       	],
	        l_trip: [
	        	{ x: xb*1, y: yb*2, width: xb, height: yb },
	        	{ x: xb*3, y: yb*4, width: xb, height: yb },
	        	{ x: xb*2, y: yb*4, width: xb, height: yb }
	       	],
	        l_strike: [
	        	{ x: xb*2, y: yb*3, width: xb, height: yb },
	        	{ x: xb*3, y: yb*3, width: xb, height: yb },
	        	{ x: xb*5, y: yb*3, width: xb, height: yb }
	        ],
	        l_fall: [
	        	{ x: xb*2, y: yb*5, width: xb, height: yb },
	        	{ x: xb*3, y: yb*5, width: xb, height: yb },
	        	{ x: xb*4, y: yb*5, width: xb, height: yb }
	        ],
	        l_die: [
	        	{ x: xb*2, y: yb*2, width: xb, height: yb },
	        	{ x: xb*3, y: yb*2, width: xb, height: yb },
	        	{ x: xb*4, y: yb*2, width: xb, height: yb }
	        ],
	        // right
	        r_idle: [{ x: xb*5, y: 0, width: xb, height: yb }],
	        r_fallen: [{ x: 0, y: yb*5, width: xb, height: yb }],
	        r_dead: [{ x: xb*5, y: yb*3, width: xb, height: yb }],  
	        r_flinch: [
	        	{ x: xb*5, y: 0, width: xb, height: yb },
	        	{ x: xb*3, y: yb*5, width: xb, height: yb },
	        	{ x: xb*2, y: 0, width: xb, height: yb }
	        ],   
	        r_block: [
	        	{ x: xb*5, y: 0, width: xb, height: yb},
	       	 	{ x: xb*3, y: 0, width: xb, height: yb },
	       	 	{ x: xb*4, y: 0, width: xb, height: yb }],
	        r_kick: [
	        	{ x: xb*4, y: yb*4, width: xb, height: yb },
	        	{ x: xb*1, y: yb*4, width: xb, height: yb },
	        	{ x: 0, y: yb*4, width: xb, height: yb }
	        ],
	        r_trip: [
	        	{ x: xb*4, y: yb*2, width: xb, height: yb },
	        	{ x: xb*2, y: yb*4, width: xb, height: yb },
	        	{ x: xb*3, y: yb*4, width: xb, height: yb }
	        ],
	        r_strike: [
	        	{ x: xb*3, y: yb*3, width: xb, height: yb },
	        	{ x: xb*2, y: yb*3, width: xb, height: yb },
	        	{ x: 0, y: yb*3, width: xb, height: yb }
	        ],
	        r_fall: [
	        	{ x: xb*3, y: yb*5, width: xb, height: yb },
	        	{ x: xb*2, y: yb*5, width: xb, height: yb },
	        	{ x: xb*1, y: yb*5, width: xb, height: yb }],
	        r_die: [
	        	{ x: xb*3, y: yb*2, width: xb, height: yb },
	        	{ x: xb*2, y: yb*2, width: xb, height: yb },
	        	{ x: xb*1, y: yb*2, width: xb, height: yb }
	        ],
	      };
	
		// create image objects for each char animation
		var l_imageObj = new Image();
		l_blob = new Kinetic.Sprite({ x: 70, y: 40, image: l_imageObj, animation: 'l_idle', animations: animations, frameRate: 4 });
		l_imageObj.onload = function() {
	        layer.add(l_blob);
	        stage.add(layer);
			l_blob.start();
		};
		l_imageObj.src = '/img/sprites/glad1.png';
	
		var r_imageObj = new Image();
  		r_blob = new Kinetic.Sprite({ x: 110, y: 40, image: r_imageObj, animation: 'r_idle', animations: animations, frameRate: 4 });
		r_imageObj.onload = function() {
			layer.add(r_blob);
			stage.add(layer);
			r_blob.start();
		};
		r_imageObj.src = '/img/sprites/glad2.png';
	}
	
	var reward_messages = false;
	function loadAnimations(hist_hash, rewards) {
		initAnimations();
		if (rewards != false) {
			reward_messages = rewards
		}
		// load battle log into animation action queue
		get_json(hist_hash);
	}
	
	var animating = false;
	var bout_interval = '';
	var action_queue = new Array();
	var i = 0;
	var animate_actions = function() {
		if (i < action_queue.length) {
			var current_action = action_queue[i];
			var action = action_queue[i].action;
			var owner = action_queue[i].owner;
			var message = action_queue[i].message;
			var name = action_queue[i].name;
			i++;
			
			if (owner == 1) {
				// left
				switch(action){
				case 'dmg_other':
					l_blob.setAnimation('l_strike');
					r_blob.setAnimation('r_flinch');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'dmg_self':
					l_blob.setAnimation('l_flinch');
					r_blob.setAnimation('r_block');	
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'dodge':
					l_blob.setAnimation('l_strike');
					r_blob.setAnimation('r_block');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'deflect':
					l_blob.setAnimation('l_strike');
					r_blob.setAnimation('r_block');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'countered':
					l_blob.setAnimation('l_strike');
					r_blob.setAnimation('r_block');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'kick':
					l_blob.setAnimation('l_kick');
					r_blob.setAnimation('r_fall');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_fallen');
					},500);
				  break;
				case 'trip':
					l_blob.setAnimation('l_trip');
					r_blob.setAnimation('r_fall');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_fallen');
					},500);
				  break;
				case 'skip':
					l_blob.setAnimation('l_fallen');
					r_blob.setAnimation('r_idle');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						l_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'wait':
					l_blob.setAnimation('l_idle');
					r_blob.setAnimation('r_idle');
				  break;
				case 'faint':
					l_blob.setAnimation('l_fall');
					r_blob.setAnimation('r_strike');
					window.setTimeout(function(){
						l_blob.setAnimation('l_fallen');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'die':
					l_blob.setAnimation('l_die');
					r_blob.setAnimation('r_strike');
					window.setTimeout(function(){
						l_blob.setAnimation('l_dead');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				default:
					l_blob.setAnimation('l_idle');
					r_blob.setAnimation('r_idle');
				}
			}
			else {
				// right
				switch(action){
				case 'dmg_other':
					l_blob.setAnimation('l_flinch');
					r_blob.setAnimation('r_strike');
					
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'dmg_self':
					l_blob.setAnimation('l_block');
					r_blob.setAnimation('r_flinch');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'dodge':
					l_blob.setAnimation('l_block');
					r_blob.setAnimation('r_strike');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'deflect':
					l_blob.setAnimation('l_block');
					r_blob.setAnimation('r_strike');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'countered':
					l_blob.setAnimation('l_block');
					r_blob.setAnimation('r_strike');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'kick':
					l_blob.setAnimation('l_fall');
					r_blob.setAnimation('r_kick');
					window.setTimeout(function(){
						l_blob.setAnimation('l_fallen');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'trip':
					l_blob.setAnimation('l_fall');
					r_blob.setAnimation('r_trip');
					window.setTimeout(function(){
						l_blob.setAnimation('l_fallen');
						r_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'skip':
					l_blob.setAnimation('l_idle');
					r_blob.setAnimation('r_fallen');
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						l_blob.setAnimation('r_idle');
					},500);
				  break;
				case 'wait':
					l_blob.setAnimation('l_idle');
					r_blob.setAnimation('r_idle');
				  break;
				case 'faint':
					l_blob.setAnimation('l_strike');
					r_blob.setAnimation('r_fall');
					
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_fallen');
					},500);
				  break;
				case 'die':
					l_blob.setAnimation('l_strike');
					r_blob.setAnimation('r_die');
					
					window.setTimeout(function(){
						l_blob.setAnimation('l_idle');
						r_blob.setAnimation('r_dead');
					},500);
				  break;
				default:
					l_blob.setAnimation('l_idle');
					r_blob.setAnimation('r_idle');
				}
			}
			
			// add message to combat log
			if (message != '') {
				$("#log").append(name+': '+message+'<br />');
			}
			else {
				$("#log").append('<br />');
			}
			
			// scroll to last message in combat log
			scrollLog();
		}
		else if (bout_interval != '') {
			// render reward messages reward_messages
			if (reward_messages != false) {
				$.each(reward_messages, function(key, message) {
					$("#log").append(message+'<br />');
				});
			}
			// end bout, reset animation state
			scrollLog();
           	clearInterval(bout_interval);
           	bout_interval = '';
           	action_queue = new Array();
           	i = 0;
			//l_blob.setAnimation('l_idle');
			//r_blob.setAnimation('r_idle');
		}
	}
	
	var scrollLog = function() {
		$("#log").scrollTop($("#log")[0].scrollHeight);
	};

	var get_json = function(hist_hash) {
		var owner_1 = '';
		var owner_2 = '';
		var name_1 = '';
		var name_2 = '';
		
		if (bout_interval != '') {
           	clearInterval(bout_interval);
           	bout_interval = '';
           	action_queue = new Array();
           	i = 0;
		}
		
		if (hist_hash instanceof Array) {
			hist_hash = hist_hash.join(',')
		}

		$.ajax({
            url: '/request/get_bout_actions/'+hist_hash + '?token='+$.cookie('request_token'),
		    type: "GET",
		    success: function(resp){
		    	if (resp.status == 'success') {
			    	var last_bout = resp.data.bouts.length - 1;
	            	$.each(resp.data.bouts, function(k1, data) {
	            		bout = jQuery.parseJSON(data);
	            		var actions = jQuery.parseJSON(bout.json_text);
						$.each(actions, function(k2, action) {
							if (owner_1 == '') {
								owner_1 = action.owner;
								name_1 = action.name;
							}
							
							if (action.owner == owner_1) {
								action_queue.push({action: action.type, owner: 1, message: action.message, name: action.name});
							}
							else {
								if (owner_2 == '') {
									owner_2 = action.owner;
									name_2 = action.name;
								}
	
								action_queue.push({action: action.type, owner: 2, message: action.message, name: action.name});
							}
						});
						
						// interlude between bouts
						if (k1 != last_bout) {
							var wait_owner = '';
							var wait_name = '';
							if (bout.bout_history.winner_id == null) {
								if (bout.bout_history.winner_id == owner_1) {
									// owner 1 continues
									wait_owner = 1;
									wait_name = name_1;
								}
								else {
									// owner 2 continues
									wait_owner = 2;
									wait_name = name_2;
								}
							}
							else {
								if (bout.bout_history.loser == owner_1) {
									// owner 2 continues
									wait_owner = 2;
									wait_name = name_2;
								}
								else {
									// owner 1 continues
									wait_owner = 1;
									wait_name = name_1;
								}
							}
							
							action_queue.push({action: 'wait', owner: wait_owner, message: '', name: wait_name});
							action_queue.push({action: 'wait', owner: wait_owner, message: '', name: wait_name});
							action_queue.push({action: 'wait', owner: wait_owner, message: 'New round starting', name: wait_name});
							action_queue.push({action: 'wait', owner: wait_owner, message: '', name: wait_name});
						}
					});
					
					bout_interval = window.setInterval(animate_actions,1000);
		    	}
		    	else if (resp.message) {
		    		renderMessage(resp.status, resp.message);
		    	}
            }  
        });
	}
	