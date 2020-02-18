// MESSAGE CONSTANTS
var ERROR_NO_PAGE = 'Could not find requested page.';
var ERROR_GENERIC = 'Something went wrong with your request. Please re-load the page and try again. If the problem persists contact customer support.';
var ERROR_TOKEN = 'There was an error collecting your authentication token. Please login again.';
var ERROR_INVALID_LOGIN = 'Invalid username/password. Please re-enter your login and password.';
var STATUS_SUCCESS = 'success';
var STATUS_ERROR = 'alert';
var STATUS_INFO = 'info';
var NOTI_TYPES = {
	reward : 'success',
	injury : 'alert'
};


// MODELS
var Noti = Backbone.Model.extend({
	view: function() {
	},
});

var Notis = Backbone.Collection.extend({
  	model: Noti
});


var Char = Backbone.Model.extend({
	view: function() {
	},
	
	// view_char, get wrapped data and display in .char_display
});

var Recruit = Backbone.Model.extend({
	view: function() {
	},
	
});

var Chars = Backbone.Collection.extend({
  	model: Char,
  	url: 'get_ludus_roster',
  	loaded: false,
  	fetch: function(params, render_after) {
  		console.log('executing: Roster.fetch()')
		Actions.api_request(this.url, params ? params : {}, function(resp) {
			if (resp && resp.status == 'success') {
				if (resp.data.chars != undefined) {
					_.each (resp.data.chars, function(char) {
						Roster.add(new Char(char));
					});
				
					console.log('roster loaded');
					console.log(Roster);
					Roster.loaded = true;
					if (render_after) {
						App.page.get_sub().render_after_collect('roster');
					}
				} else {
					App.page.get_sub().render_message(ERROR_TOKEN, STATUS_ERROR);
				}
			}
		});
  	},
});

var Roster = new Chars;

Roster.on("add", function(ship) {
	if (App.page.id == 'ludus') {
		// $('span.roster_count').text(Roster.length);
		$('span.roster_count').fadeOut('fast', function() {
			$(this).text(Roster.length).fadeIn('fast');
		});
	}
	
	// if (App.sub.id == 'roster') {
		// App.render_sub(); // re-render roster
	// }
});

// fetch function?

var Recruits = Backbone.Collection.extend({
  	model: Recruit,
  	url: 'get_ludus_recruits',
  	loaded: false,
  	fetch: function(params, render_after) {
  		console.log('executing: Recruit.fetch()')
		Actions.api_request(this.url, params ? params : {}, function(resp) {
			if (resp && resp.status == 'success') {
				if (resp.data.recruits != undefined) {
					_.each (resp.data.recruits, function(recruit) {
						RecruitPool.add(new Recruit(recruit));
					});
				
					console.log('recruits loaded');
					console.log(RecruitPool);
					RecruitPool.loaded = true;
					if (render_after) {
						App.page.get_sub().render_after_collect('recruits');
					}
				} else {
					App.page.get_sub().render_message(ERROR_TOKEN, STATUS_ERROR);
				}
			}
		});
  	},  	
});

var RecruitPool = new Recruits;

RecruitPool.on("add", function(ship) {
	if (App.page.id == 'ludus') {
		$('span.recruit_count').fadeOut('fast', function() {
			$(this).text(RecruitPool.length).fadeIn('fast');
		});
	}
});

// FullChar
var CurrentChar = {
	
	set: function(char) {
		this.id = char.id;
		this.data = char;
	},
	
	id: false,
	
	data: false,
	
	updates: false,
	
	view_change: {name: true, weapon: true, armour: true},
	
	db_change: {name: true, weapon_id: true, armour_id: true},
	
	update_fields: function(data) {
		var updates = {};
		_.each(data, function(v, k) {
			if (_.has(CurrentChar.view_change, k)) CurrentChar.data[k] = v;
			if (_.has(CurrentChar.db_change, k)) updates[k] = v;
		});

		if (!_.isEmpty(updates)) {
			// NOTE: update DB
			console.log('updating data');
			console.log(updates);
		}
	},
	
};

var EquipmentStore = false;


// what to use this for?

// store roster beforehand to be used in summary / roster


// icons for activities


// remove summary and just show roster screen, then glad / recruit count in menu



var Actions = {
	
	// add a check that exits if still loading?
	
	// COLLECTIONS
	
	load_roster: function() {
		Roster.fetch();
	},
	
	load_recruits: function() {
		RecruitPool.fetch();
	},
	
	get_collection: function(c) {
		console.log('get collection: '+c);
		switch(c) {
			case 'roster':
				return Roster;
			break;
			case 'recruits':
				return RecruitPool;
			break;
		}
		
		return;
	},

	view_character: function(e) {
		$(this).closest('table').find('tr').removeClass('highlight_green');
		$(this).closest('tr').addClass('highlight_green');

		var char_id = $(this).data('char_id');
		console.log('current character: ', CurrentChar);
		if (CurrentChar.id && CurrentChar.id == char_id) {
	    	var template = _.template($('#view_char_details_tpl').html(), CurrentChar.data);
	    	App.page_el.find('.char-display').html(template);
		}
		else {
			Actions.api_request('get_char_details', {id: char_id}, function(resp) {
				if (resp && resp.status == 'success') {
					console.log('view char: '+char_id)
					if (resp.data.char != undefined) {
						CurrentChar.set(resp.data.char); // set current character
						Actions.show_view_char();
					} else {
						App.page.get_sub().render_message(ERROR_TOKEN, STATUS_ERROR);
					}
				}
			});
		}
	},
	
	show_view_char: function() {
    	var template = _.template($('#view_char_details_tpl').html(), CurrentChar.data);
    	App.page_el.find('.char-screen').html(template);
	},
	
	edit_character: function() {
		var char_id = $(this).data('char_id');
		if (!EquipmentStore) {
			// load equipment store, pass the rest through as a function?
			Actions.api_request('get_equipment_data', {}, function(resp) {
				console.log('load equipment');
				console.log(resp.data);
				if (resp && resp.status == 'success') {
					EquipmentStore = resp.data;
					Actions.show_edit_char(char_id);
				}
			});
		}
		else {
			Actions.show_edit_char(char_id);
		}
	},

	hide_action_screen: function() {
		App.page_el.find('.action-screen').hide();
		var target_el = $($(this).data('target'));
		this.scroll_to(target_el);
	},
	
	show_edit_char: function(char_id) {
		if (CurrentChar.id && CurrentChar.id == char_id) {
			console.log('edit char: '+char_id)
	    	var template = _.template($('#edit_char_details_tpl').html(), {char: CurrentChar.data, equipment: EquipmentStore});
	    	App.page_el.find('.action-screen').html(template);
		}
		else {
			App.page.get_sub().render_message(ERROR_GENERIC, STATUS_ERROR);
		}
	},
	
	update_char: function() {
		// NOTE: show loading animation
		var data = $('#customize_form').serializeObject();
		Actions.api_request('do_update_character', data, function(resp) {
			console.log('update char');
			if (resp && resp.status == 'success') {
				// update char object, re-render view
				
				
				// add names from equipment_data
				data.weapon = '';
				_.each(EquipmentStore.weap_store, function(w) {
					if (w.id == data.weapon_id) data.weapon = w.description;
				});
				
				data.armour = '';
				_.each(EquipmentStore.arm_store, function(a) {
					if (a.id == data.armour_id) data.armour = a.description;
				});
				
				CurrentChar.update_fields(data);
				//Roster.update_char(CurrentChar.id, 'name', data.name);
				
				// re-render roster, with shortcut for view character
				
				Actions.show_view_char();
			}
		});
	},

	render_bout: function(output_data) {
		console.log(output_data);
		// var template = _.template($('#bout_results_tpl').html());
		var template = _.template($('#view_bout_output_tpl').html(), output_data);
		// App.page_el.find('.action-screen').html(template);
		// Actions.scroll_to(App.page_el.find('.action-screen'));
		App.modal_el.find('.content').html(template);

		// instead render in modal

		// hist_hash, rewards, winner_id

		// App.settings.auto_watch?

		// Action.load_animations(output_data.hist_hash, output_data.rewards)


		// var template = _.template($('#bout_results_tpl').html());
		// $("#page_content_3").html(template);
		// loadAnimations(id, false);
	},

	random_bout: function() {
		console.log('random bout');

		var char_id = $(this).data('char_id');
		//App.page_el.find('.action-screen').html('Loading..');
		App.modal_el.html('Loading..');
		App.modal_el.foundation('reveal', 'open');
		Actions.api_request('do_random_bout', {char_id: char_id}, function(resp) {
			if (resp && resp.status == 'success') {
				Actions.render_bout(resp.data.output);
			}
	    	else if (resp.message != '') {
	    		App.page.get_sub().render_message(resp.status, resp.message);
	    	}
	    	else {
				App.page.get_sub().render_message(STATUS_ERROR, ERROR_GENERIC);
	    	}
		});
	},

	find_spar: function() {
		console.log('find spar');

		var char_id = $(this).data('char_id');
		App.page_el.find('.action-screen').html('Loading...');
		Actions.api_request('get_valid_spars', {char_id: char_id}, function(resp) {
			if (resp && resp.status == 'success') {
				var template = _.template($('#spar_list_tpl').html(), resp.data);
				$(".action-screen").html(template);
			}
	    	else if (resp.message != '') {
	    		App.page.get_sub().render_message(resp.status, resp.message);
	    	}
	    	else {
				App.page.get_sub().render_message(STATUS_ERROR, ERROR_GENERIC);
	    	}
		});
	},

	spar_bout: function() {
		console.log('spar bout');

		var char_1_id = $(this).data('char_1_id');
		var char_2_id = $(this).data('char_2_id');
		App.modal_el.html('Loading..');
		App.modal_el.foundation('reveal', 'open');
		Actions.api_request('do_spar_bout', {char_1_id: char_1_id, char_2_id: char_2_id}, function(resp) {
			if (resp && resp.status == 'success') {
				Actions.render_bout(resp.data.output);
			}
	    	else if (resp.message != '') {
	    		App.page.get_sub().render_message(resp.status, resp.message);
	    	}
	    	else {
				App.page.get_sub().render_message(STATUS_ERROR, ERROR_GENERIC);
	    	}
		});
	},

	send_to_pits: function() {
		console.log('send to pits');

		var char_id = $(this).data('char_id');
		App.modal_el.html('Loading..');
		App.modal_el.foundation('reveal', 'open');
		Actions.api_request('do_pit_bout', {char_id: char_id}, function(resp) {
			if (resp && resp.status == 'success') {
				Actions.render_bout(resp.data.output);
			}
	    	else if (resp.message != '') {
	    		App.page.get_sub().render_message(resp.status, resp.message);
	    	}
	    	else {
				App.page.get_sub().render_message(STATUS_ERROR, ERROR_GENERIC);
	    	}
		});
	},

	buy_recruit: function(e) {
		var recruit_id = $(this).data('recruit_id');
		Actions.api_request('do_buy_recruit', {id: recruit_id}, function(resp) {
			console.log('buy recruit');
			if (resp && resp.status == 'success') {
				console.log('remove: '+recruit_id);
				$('table#recruit_list tr[data-recruit_id="'+recruit_id+'"]').remove();
				if (resp.message != '') {
					App.page.get_sub().render_message(resp.message, resp.status);
				}
			}
		});
	},
	
	reject_recruit: function() {
		var recruit_id = $(this).data('recruit_id');
		Actions.api_request('do_reject_recruit', {id: recruit_id}, function(resp) {
			if (resp && resp.status == 'success') {
				$('table#recruit_list tr[data-recruit_id="'+recruit_id+'"]').remove();
				if (resp.message != '') {
					App.page.get_sub().render_message(resp.message, resp.status);
				}
			}
		});
	},

	show_tourney: function() {
		$(this).closest('table').find('tr').removeClass('highlight_green');
		$(this).closest('tr').addClass('highlight_green');

		console.log('show tourney');
		// render loading in action..
		var tourney_id = $(this).data('tourney_id');
		App.page_el.find('.action-screen').html('Loading...');
		Actions.api_request('get_tourney_eligible', {tourney_id: tourney_id}, function(resp) {
			if (resp && resp.status == 'success') {
				Actions.render_tourney(resp.data);
			}
	    	else if (resp.message != '') {
	    		App.page.get_sub().render_message(resp.status, resp.message);
	    	}
	    	else {
				App.page.get_sub().render_message(STATUS_ERROR, ERROR_GENERIC);
	    	}
		});


	},

	render_tourney: function(data) {
		console.log('render tourney');
    	var template = _.template($('#show_tourney_tpl').html(), data);
    	App.page_el.find('.action-screen').html(template);
	},

	enter_tourney: function() {
		console.log('enter_tourney');

		$(this).addClass('disabled');
		var tourney_id = $(this).data('tourney_id');
		var char_id = $(this).data('char_id');
		Actions.api_request('do_enter_tourney', {tourney_id: tourney_id, char_id: char_id}, function(resp) {
			if (resp.message != '') {
	    		App.page.get_sub().render_message(resp.message, resp.status);
	    	}
	    	else {
				App.page.get_sub().render_message(ERROR_GENERIC, STATUS_ERROR);
	    	}
		});

	},

	attempt_spy: function() {
		console.log('attempt spy');

		console.log(App.modal_el);
		App.modal_el.foundation('reveal', 'open');
		App.modal_el.find('.content').html('Loading...');

		$(this).addClass('disabled');
		var char_id = $(this).data('char_id');
		Actions.api_request('do_attempt_spy', {char_id: char_id}, function(resp) {
			if (resp && resp.status == 'success') {
				console.log('render spy results');
				console.log(resp.data.char);

		    	var template = _.template($('#spy_results_tpl').html(), resp.data);
		    	App.modal_el.find('.content').html(template);
			}
			else if (resp.message != '') {
	    		App.page.get_sub().render_message(resp.message, resp.status);
	    	}
	    	else {
				App.page.get_sub().render_message(ERROR_GENERIC, STATUS_ERROR);
	    	}
		});


//$('a.close-reveal-modal').trigger('click');


	},
	
	// UI
	
	check_has_token: function() {
		return $.cookie('request_token') != undefined;
	},
	
	scroll_to: function(el) {
		// $('html, body').animate({
		//     scrollTop: el.offset().top
		//  }, 500);
		$(App.page_el).animate({
		    scrollTop: el.offset().top
		 }, 400);
	},
	
	update_url: function() {
		console.log('update url: '+ $(this).data('route'));

		$(this).closest('dl').find('div.content').removeClass('active');
		$(this).closest('dd').find('div.content').addClass('active');

		Backbone.history.navigate($(this).data('route'), true);
	},

	// AUTH
	attempt_login: function() {
		Actions.api_request('do_attempt_login', $('#login_form').serialize(), function(resp) {
			if (resp && resp.status == 'success') {
				if (resp.token != undefined) {
					$.cookie('request_token', resp.token, {
						expires : 1
					});
					App.token = resp.token;
					$.cookie('username', resp.username, {
						expires : 1
					});
					App.username = resp.username;
					window.location = "/#/account"
				} else {
					App.render_message(ERROR_TOKEN, STATUS_ERROR);
				}
			}
			else {
				App.render_message(ERROR_TOKEN, STATUS_ERROR);
			}
		}, 'GET');
	},
	
	create_account: function() {
		Actions.api_request('do_create_account', $('#sign_up_form').serialize(), function(resp) {
			if (resp && resp.status == 'success') {
				if (resp.token != undefined) {
					$.cookie('request_token', resp.token, {
						expires : 1
					});
					App.token = resp.token;
					$.cookie('username', resp.username, {
						expires : 1
					});
					App.username = resp.username;
					window.location = "/#/account"
				} else {
					App.render_message(ERROR_TOKEN, STATUS_ERROR);
				}
			}
		});
	},
	
	// CORE
	api_request: function(action, data, respond, type) {
		api_loading = true;
		$.ajax({
			url : '/request/'+action+($.cookie('request_token') != undefined ? '?token='+$.cookie('request_token') : ''),
			type : (type == 'get' || type === undefined) ? 'get' : 'post',
			data : data,
			success : function(resp) {
				api_loading = false;
				if (resp && resp.errors && !_.isEmpty(resp.errors)) {
					App.render_messages(resp.errors, STATUS_ERROR);
				}
				else {
					respond(resp);
				}
			},
			error : function() {
				api_loading = false;
				App.render_message(ERROR_GENERIC, STATUS_ERROR);
			}
		});
	},
	
	
};



// background task once you've requested roster / notifications, that creates collection

// then tasks to update



// MODEL OBJECTS

var Page = Backbone.Model.extend({

	get_sub: function() {
		return this.get('subs').get(this.get('current_sub'));
	},
	
	get_tpl: function() {
		return this.get('tpl');
	},
	
	get_data: function() {
		// if (this.get('data')) {
		// 	return this.get('data');
		// }
		// else if (this.get('data_collection')) {
		// 	return Actions.get_collection(this.get('data_collection'));
		// }

		// if (this.get('data_url')) {
			// Actions.api_request(this.get('data_url'), {}, function(resp) {
				// if (resp && resp.status == 'success') {
					// if (resp.data != undefined) {
						// return resp.data;
					// } else if (resp.message != '') {
						// App.render_message(resp.message, resp.status);
					// } else {
						// App.render_message(ERROR_TOKEN, STATUS_ERROR);
					// }
				// }
			// });
		// }
		// else if (this.get('data')) {
			// return this.get('data');
		// }
	},
	
});

var Sub = Backbone.Model.extend({

    render_template: function(data) {
		console.log('render sub with: ', data);
		var template = _.template($(this.get('tpl')).html(), data);
		var sub_el = App.get_sub_el();
		console.log(sub_el);
		sub_el.html(template);
		App.bind_sub();
    },

    render_loading: function() {
    	var sub_el = App.get_sub_el();
    	sub_el.html('Loading...');
    },

    render_empty: function() {
    	var sub_el = App.get_sub_el();
    	sub_el.html('Empty');
    },

    render_failed: function() {
    	var sub_el = App.get_sub_el();
    	sub_el.html('Failed to load.');
    },

    render_message: function(message, status) {
    	console.log('sub: render message');
    	
		var template = _.template($('#alert_message_tpl').html(), {
			message : message,
			status : status ? status : '',
		});
    	var sub_el = App.get_sub_el();
    	//sub_el.html(template);
    	sub_el.prepend(template);
		Actions.scroll_to(sub_el);
    },

    render_after_load: function(url) {
		Actions.api_request(url, {}, function(resp) {
			if (resp && resp.status == 'success') {
				App.page.get_sub().render_template(resp.data);
			}
			else if (resp.message != '') {
				App.page.get_sub().render_message(resp.message, resp.status);
			}
			else {
				App.page.get_sub().render_message(ERROR_TOKEN, STATUS_ERROR);
			}
		});
    },

    render_after_collect: function(c) {
    	console.log('render after collect: '+c);
    	var collection = Actions.get_collection(c);
    	if (!collection) {
    		App.page.get_sub().render_failed();
    	}
    	else if (collection.loaded == true) {
    		App.page.get_sub().render_template({collection: collection});
    	}
    	else {
    		collection.fetch({}, true);
    	}
    },

});

var Pages = Backbone.Collection.extend({ model: Page });

var Subs = Backbone.Collection.extend({ model: Sub });

var PageList = new Pages([
	new Page({
			id: "home", 
			auth: false,
			url: '/#/',
			tpl: '#home_tpl',
			subs: new Subs([
				{id: 'news', tpl: '#news_tpl'},
				{id: 'about', tpl: '#about_tpl'},
				{id: 'contact', tpl: '#contact_tpl'},
				{id: 'login', tpl: '#login_tpl'},
				{id: 'signup', tpl: '#signup_tpl'},
			]),
			events: [
				{s: '.section-link', a: 'click', f: Actions.update_url},
				{s: '#btn-login', a: 'click', f: Actions.attempt_login},
				{s: '#btn-create-account', a: 'click', f: Actions.create_account}
			],
			current_sub: 'news'
	}),
	new Page({
			id: "account", 
			auth: true,
			url: '/#/account',
			tpl: '#account_shell_tpl',
			subs: new Subs([
				{id: 'summary', tpl: '#account_summary_tpl', data: {type: 'url', value: 'get_summary'}},
				{id: 'settings', tpl: '#account_settings_tpl'},
				{id: 'notifications', tpl: '#account_notifications_tpl', data: {type: 'url', value: 'get_notifications'}}
			]),
			events: [
				{s: '.section-link', a: 'click', f: Actions.update_url},
			],
			use_sections: true,
			current_sub: 'summary'
	}),
	new Page({
			id: "ludus", 
			auth: true,
			url: '/#/ludus',
			tpl: '#ludus_shell_tpl',
			pre_tasks: [Actions.load_roster, Actions.load_recruits],
			subs: new Subs([
				{id: 'summary', tpl: '#account_ludus_summary_tpl', data: {type: 'url', value: 'get_ludus_summary'}},
				{id: 'roster', tpl: '#account_ludus_roster_tpl', data: {type: 'collection', value: 'roster'}}, // data_url: 'get_ludus_roster'
				{id: 'recruits', tpl: '#account_ludus_recruits_tpl', data: {type: 'collection', value: 'recruits'}}, // data_url: 'get_ludus_recruits'
				{id: 'history', tpl: '#account_ludus_history_tpl', data: {type: 'url', value: 'get_ludus_history'}},
			]),
			events: [
				{s: '.section-link', a: 'click', f: Actions.update_url},
				{s: '.btn-view-char', a: 'click', f: Actions.view_character},
				{s: '.btn-edit-char', a: 'click', f: Actions.edit_character},
				{s: '#btn-save-char', a: 'click', f: Actions.update_char},
				{s: '.btn-random-bout', a: 'click', f: Actions.random_bout},
				{s: '.btn-find-spar', a: 'click', f: Actions.find_spar},
				{s: '.btn-spar-bout', a: 'click', f: Actions.spar_bout},
				{s: '.btn-pits', a: 'click', f: Actions.send_to_pits},
				{s: '.btn-buy-recruit', a: 'click', f: Actions.buy_recruit},
				{s: '.btn-reject-recruit', a: 'click', f: Actions.reject_recruit},
				{s: '.btn-hide-action', a: 'click', f: Actions.hide_action_screen},
			],
			use_sections: true,
			//current_sub: 'summary'
	}),
	new Page({
			id: "arena", 
			auth: true,
			url: '/#/arena', 
			tpl: '#arena_shell_tpl',
			subs: new Subs([
				{id: 'summary', tpl: '#account_arena_summary_tpl', data: {type: 'url', value: 'get_arena_summary'}, expire: '20'},
				{id: 'watch', tpl: '#account_arena_watch_tpl', data: {type: 'url', value: 'get_arena_watch'}, expire: '20'},
				{id: 'games', tpl: '#account_arena_games_tpl', data: {type: 'url', value: 'get_arena_games'}, expire: '20'},
				{id: 'tourney', tpl: '#account_arena_tourney_tpl', data: {type: 'url', value: 'get_arena_tourney'}, expire: '20'},
			]),
			events: [
				{s: '.btn-login', a: 'click', f: Actions.attempt_login},
				{s: '.section-link', a: 'click', f: Actions.update_url},
				{s: '.btn-show-tourney', a: 'click', f: Actions.show_tourney},
				{s: '.btn-enter-tourney', a: 'click', f: Actions.enter_tourney},
				{s: '.btn-attempt-spy', a: 'click', f: Actions.attempt_spy},
			],
			use_sections: true,
			current_sub: 'summary'
	}),
]);




// VIEW OBJECTS

// The main view of the application
var App = Backbone.View.extend({

	loading: false,
	
	menu_el: $('#menu_dynamic'),
	
	main_el: $('#page'),

	page_el: $('#page_content_1'),
	
	sub_el: $('#page_content_2'),
	
	action_el: $('#page_content_3'),
	
	message_el: $('#message_content'),

	modal_el: $('#modal_box'),
	
	top_menu_el: $('#menu_top'),

	menu_content_el: $('#menu_dynamic'),

	username: null,

	token: null,
	
    initialize: function() {menu_dynamic
    	if ($.cookie('username') != undefined) {
			App.username = $.cookie('username');
    	}
    	if ($.cookie('request_token') != undefined) {
			App.token = $.cookie('request_token');
    	}
    },

    get_sub_el: function() {
		if (this.page.get('use_sections')) {
			//return this.main_el.find('section.active .content');
			return this.main_el.find('div.content[data-sub_id="'+this.page.get('current_sub')+'"]');
		}
		else {
			return this.sub_el;
		}
    },
    
    load_page: function(page_id, sub_id) {
    	console.log('load page: ' + page_id + ' : ' + sub_id);

    	if (Actions.check_has_token()) {
    		console.log('show account menu');
    		this.menu_el.html(_.template($('#account_menu_tpl').html()));
    	}

    	App.menu_content_el.find('li').removeClass('active');
    	App.menu_content_el.find('li[data-page="'+page_id+'"]').addClass('active');
    	
    	this.message_el.empty();
    	this.top_menu_el.removeClass('expanded');
    	if (!this.page || this.page.id != page_id) {
    		// change page
    		this.page = PageList.get(page_id);
    		this.page.set('current_sub', sub_id);
    		this.render_page();
    	}

    	console.log('sub_id: '+sub_id);
    	if (sub_id !== undefined) {
    		this.page.set('current_sub', sub_id);
    		this.sub = this.page.get_sub();
    		this.activate_sub();
    	}
    	else {
    		console.log('render empty');
    		if (this.page.use_sections) {
	    		var sub = this.get_sub_el()
	    		sub.html('');
    		}
    		else {
    			this.sub_el.html('');
    		}
    	}
    },

    render_page: function(){
    	console.log('render page:' + this.page.get('tpl'));
    	
		if (this.page.get('pre_tasks')) {
			_.each(this.page.get('pre_tasks'), function (task) {
				console.log('running task: '+task);
				task();
			});
		}
		
    	//var data = this.page.get_data();
    	var data = {current_sub: this.page.get('current_sub')};

    	console.log(data);
    	var template = _.template($(this.page.get('tpl')).html(), data);
    	this.page_el.html(template);
    	
    	// bind page_wide events
    	App.main_el.unbind();
    	_.each(this.page.get('events'), function(e) {
    		App.main_el.on( e.a, e.s, e.f);
    		//$( e.s ).bind( e.a, e.f);
    	});
    },
    
    activate_sub: function() {
    	var sub = this.sub;
    	
    	console.log('render sub: ' + sub.id);
    	this.sub_el.empty();

    	var sub_el = this.get_sub_el(); // normal sub_el or current_section sub_el

    	var data = this.sub.get('data');

    	if (data === undefined) {
    		console.log('render sub: '+sub.get('tpl'));
    		sub.render_template();
    	}
    	else {
    		// render loading
    		console.log('render loading');
    		sub.render_loading();
    		if (data.type == 'url') {
    			console.log('data_type: url');
    			sub.render_after_load(data.value)
    		}
    		else if (data.type == 'collection') {
    			console.log('data_type: collection');
    			sub.render_after_collect(data.value);
    		}
    		else {
    			alert('no data type');
    		}
    	}

    },
    
    bind_sub: function() {
    	// bind sub wide events
    	_.each(this.page.get_sub().get('events'), function(e) {
    		$( e.s ).bind( e.a, e.f);
    	});
    },
    
   	// when page.sub_loaded, render_sub
    
    // this.on("change:name", function(model){
    
    logout: function() {
		$.get('/request/do_logout');
		$.removeCookie('request_token');
		App.token = null;
		$.removeCookie('username');
		App.username = null;
		App.render_message('You have been logged out.', STATUS_INFO);
    	if (Actions.check_has_token()) {
    		console.log('show public menu');
    		this.menu_el.html(_.template($('#public_menu_tpl').html()));
    	}
    },
    
    render_message: function(message, status) {
    	console.log('render message');
    	
		var template = _.template($('#alert_message_tpl').html(), {
			message : message,
			status : status ? status : '',
		});
		this.message_el.html(template);
		Actions.scroll_to(this.message_el);
    },
    
    render_messages: function(messages, status) {
    	console.log('render message list');
    	
		var template = _.template($('#alert_message_list_tpl').html(), {
			messages : messages,
			status : status ? status : '',
		});
		this.message_el.html(template);
		Actions.scroll_to(this.message_el);
    },
    
});


// ROUTING

var App = new App();


var AppRouter = Backbone.Router.extend({

	routes : {
		// public pages
		"": "news",
		"login" : "login",
		"logout" : "logout",
		"signup" : "signup",
		"news" : "news",
		"about" : "about",
		"contact" : "contact",
		//"verify/:code" : "verify",
		// account pages
		"account" : "account",
		"account/:sub" : "account",
		"ludus": "ludus",
		"ludus/edit/:id": "ludus",
		"ludus/:sub": "ludus",
		"arena": "arena",
		"arena/:sub": "arena",
		// "account/arena/watch/:id" : "account_arena_watch",
		// "account/bout/spar/:id" : "account_arena_watch",
		// "account/ludus/:sub" : "account_ludus",
		// "account/ludus/view/:id" : "view_char",
		// "account/ludus/edit/:id" : "edit_char",
		// "account/notification/:id" : "account_notification",
		// "account/:page" : "account_page",
	},

	news : function() {
		App.load_page('home', 'news');
	},

	login : function() {
		App.load_page('home', 'login');
	},
	
	logout : function() {
		App.logout();
		App.load_page('home', 'login');
	},

	signup : function() {
		App.load_page('home', 'signup');
	},

	about : function() {
		App.load_page('home', 'about');
	},

	contact : function() {
		App.load_page('home', 'contact');
	},

	// verify : function(code) {
		// $.ajax({
			// url : "/request/do_verify_code/" + this.params['code'],
			// type : "GET",
			// success : function(resp) {
				// if (resp.message != '') {
					// renderMessage(resp.status, resp.message);
				// }
				// loadStaticPage('login', true);
			// }
		// });
	// },

	account : function(sub) {
		if (Actions.check_has_token()) {
			App.load_page('account', sub);
		}
		else {
			this.login();
		}
	},
	
	arena : function(sub) {
		if (Actions.check_has_token()) {
			App.load_page('arena', sub);
		}
		else {
			this.login();
		}
	},
	
	ludus : function(sub) {
		if (Actions.check_has_token()) {
			App.load_page('ludus', sub);
		}
		else {
			this.login();
		}
	},

	// view_char : function(id) {
		// $('#menu_top').removeClass('expanded');
		// $("#message_content").html('');
		// if ($.cookie('request_token') != undefined) {
			// loadLudusSub('roster');
			// loadChar(id, false);
		// } else {
			// AppRouter.login
			// this.navigate("login");
		// }
	// },
// 	
	// edit_char : function(id) {
		// $('#menu_top').removeClass('expanded');
		// $("#message_content").html('');
		// if ($.cookie('request_token') != undefined) {
			// loadLudusSub('roster');
			// editChar(id, false);
		// } else {
			// AppRouter.login
			// this.navigate("login");
		// }
	// },

	account_notification : function(id) {
		$('#menu_top').removeClass('expanded');
		$("#message_content").html('');
		if ($.cookie('request_token') != undefined) {
			loadNotification(id);
		} else {
			AppRouter.login
			this.navigate("login");
		}
	},
});

// Instantiate the router
var app_router = new AppRouter;

// Start page history
Backbone.history.start();


// HELPER FUNCTIONS

function h_time_ago(time_ms) {
	return moment(time_ms).fromNow()
}

function h_time_until(time_ms) {
	if (time_ms == 0) {
		return '';
	}
	return moment(time_ms).from(moment(), true)
}

function h_att_colour(base_att, att) {
	if (base_att == att) {
		return '<span class="radius label secondary">' + att + '</span>';
	} else if (att > base_att) {
		return '<span class="radius label success">' + att + '</span>';
	} else {
		return '<span class="radius label alert">' + att + '</span>';
	}
}
