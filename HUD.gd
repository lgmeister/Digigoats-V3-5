extends CanvasLayer

var pop_bounds = 560 ### When does HUD come up based on where cursor iss

var heart_scene = preload("res://scenes/battles/health_heart.tscn")
var goat_grid_button = preload("res://scenes/UIUX/GoatButtonHUD.tscn")


onready var bottom_hud = $bottom_hud
onready var animation = $AnimationPlayer
onready var boss_animation = $BossAnimation
onready var tool_tip_animation = $ToolTipAnimation
onready var goat_grid = $GoatGrid


onready var file_button = $bottom_hud/file_button
onready var goat_button = $bottom_hud/goat_button
onready var time_label = $bottom_hud/time_label
onready var boss_label = $Boss_Bar/Label
onready var boss_bar_top = $Boss_Bar
onready var announcement_label = $CenterAnnouncementLabel
onready var health_grid = $health
onready var black_screen = $BlackScreen
onready var general_pop = $GenPop/GeneralPopupMenu ### used for whatever. Item right click etc
onready var tween = $Tween

### Tips ###
onready var tip_top = $tip_bar_top
onready var tip_bot = $tip_bar_bot
onready var tip_top_label = $tip_bar_top/Label
onready var tip_top_texture = $tip_bar_top/TextureRect
onready var tip_bot_label = $tip_bar_bot/Label
onready var tip_bot_texture = $tip_bar_bot/TextureRect

### Network ###
onready var game_info_label = $game_info_label
var chat_scene = load("res://scenes/network/chat.tscn")

### Bools ###
var tooltip_active = false ### Bottom only
var boss_bar_active = false ## health bar in?
var bottom_HUD = false
var menu_open = false
var middle_button = false

### Scenes ###
var chat

### Nodes ###
var file_popup_node
var goat_popup_node

var goat_nodes = [] ### All the local player's goats' nodes 

func _ready():
	file_popup_node = file_button.get_popup()
	file_popup_node.connect("id_pressed",self,"_on_file_button_choice")
	goat_popup_node = goat_button.get_popup()
	goat_popup_node.connect("id_pressed",self,"_on_goat_popup_item_selected")
	


func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("escape") and tooltip_active:
			tooltip_bot("hide",null)
			
	## Quick Choose Goat ##
	if not Global.in_battle and not Global.goat_in_training and Global.title_finished:
		if event.is_action_pressed("quick_1"): 
			if goat_nodes.size() >= 1: goat_nodes[0].select_goat()
		elif event.is_action_pressed("quick_2"): 
			if goat_nodes.size() >= 2: goat_nodes[1].select_goat()
		elif event.is_action_pressed("quick_3"): 
			if goat_nodes.size() >= 3: goat_nodes[2].select_goat()
		elif event.is_action_pressed("quick_4"): 
			if goat_nodes.size() >= 4: goat_nodes[3].select_goat()
		elif event.is_action_pressed("quick_5"): 
			if goat_nodes.size() >= 5: goat_nodes[4].select_goat()
		elif event.is_action_pressed("quick_6"): 
			if goat_nodes.size() >= 6: goat_nodes[5].select_goat()
		elif event.is_action_pressed("quick_7"): 
			if goat_nodes.size() >= 7: goat_nodes[6].select_goat()
		elif event.is_action_pressed("quick_8"): 
			if goat_nodes.size() >= 8: goat_nodes[7].select_goat()
		elif event.is_action_pressed("quick_9"): 
			if goat_nodes.size() >= 9: goat_nodes[8].select_goat()
		elif event.is_action_pressed("quick_0"): 
			if goat_nodes.size() >= 10: goat_nodes[9].select_goat()
		
	if event is InputEventMouseMotion:	
		if event.position.y >= pop_bounds and not bottom_HUD and not middle_button and not Global.in_battle:
			slide_in()
		if event.position.y < pop_bounds and bottom_HUD:
			slide_out()

func load_chat():
	var scene_instance = chat_scene.instance()
	chat = scene_instance
	add_child(scene_instance)
	
func load_goat_grid(node):
	var scene = goat_grid_button.instance()
	scene.goat_node = node
	scene.goat_number = goat_grid.get_child_count() + 1
	goat_grid.add_child(scene)

func update_network_info():
	if Global.multiplayer_active:
		game_info_label.show()
		game_info_label.text = "Game Name: Random Name\nGame IP Address: %s" %Global.game_ip_address
			
func slide_in(): ### Bottom HUD ####
	bottom_HUD = true
	tween.interpolate_property(bottom_hud,"rect_position",Vector2(0,40),Vector2(0,0),.3,Tween.TRANS_QUART)
	tween.start()
	
func slide_out(): ### Bottom HUD ####
	if menu_open:
		return
	bottom_HUD = false
	tween.interpolate_property(bottom_hud,"rect_position",Vector2(0,0),Vector2(0,40),.3,Tween.TRANS_QUART)
	tween.start()
	

func _on_file_button_pressed():
	menu_open = true
	file_popup_node.rect_position = Vector2(file_button.rect_position.x-24,file_button.rect_position.y-60)
	file_popup_node.clear()
	file_popup_node.add_item("Exit")
	file_popup_node.add_item("Settings")
	
func _on_file_button_choice(id):
	menu_open = false
	print(file_popup_node.get_item_text(id))



func _on_goat_button_pressed():
	menu_open = true
	goat_popup_node.rect_position = Vector2(goat_button.rect_position.x,goat_button.rect_position.y-500)
	goat_popup_node.rect_scale = Vector2(.2,.2) 
	goat_popup_node.clear()
	
	goat_populate()

func goat_populate(): ### populate goat_menu with each goat
	for goat in Global.loaded_goats:
		
		goat_popup_node.add_icon_item\
		(Global.loaded_goats[goat]["image"],
		Global.loaded_goats[goat]["id"] + " - " + \
		Global.loaded_goats[goat]["name"])
		
func _on_goat_popup_item_selected(index):
	var goat_number = goat_popup_node.get_item_text(index).left(5) ### Maybe change this to an array variable
	for goat in get_tree().get_nodes_in_group("player"):
		if goat.goat_id == goat_number:
			goat.select_goat()
			

	goat_popup_node.hide()
	menu_open = false
	


func boss_bar(direction,title):
	if direction == "in":
		boss_label.text = title
		boss_animation.play("boss_bar_in")
		boss_bar_active = true
	elif direction == "out" and boss_bar_active:
		boss_animation.play("boss_bar_out")
		boss_bar_active = false
		
#	if title != null: announcement(title,"long")
		
func announcement(title,length):
	announcement_label.text = ""
	if length == "long":
		animation.playback_speed = 1
	elif length == "medium":
		animation.playback_speed = 2
	elif length == "short":
		animation.playback_speed = 3
	
	announcement_label.text = title
	animation.play("annoucement")
	
func chat_announcement(message):
	chat.announcement(message)
		
		
func add_health_bar(max_health,health):
	var odd = true
	if health % 2 == 0: odd = false
	var health_range = ceil(float(health)/2)

	for number in range(health_range):
		var scene_instance = heart_scene.instance()
		scene_instance.health_number = number
		health_grid.add_child(scene_instance)
		if number == health_range-1:
			scene_instance.current_heart = true
			if odd: scene_instance.initialize_odd()
		
	for _number in range(floor((max_health-health)/2)): ## for empty hearts (missing HP)
		var scene_instance = heart_scene.instance()
		health_grid.add_child(scene_instance)
		scene_instance.initialize_none()

func add_armor_bar(armor):
	Global.armor = 0
	var odd = true
	if armor % 2 == 0: odd = false
	var armor_range = ceil(float(armor)/2)
	Global.armor = armor
	
	for number in range(armor_range):
#		Global.armor += 1
		var scene_instance = heart_scene.instance()
		scene_instance.health_number = number
		scene_instance.type = "armor"
		health_grid.add_child(scene_instance)
		if number == armor_range-1:
			scene_instance.current_heart = true
			if odd: scene_instance.initialize_odd()

		
func remove_health_bar():
	for health in health_grid.get_children():
		health.queue_free()
		
		
func tooltip_top(type,value):
	if type == "currancy":
		tip_top_texture.texture = preload("res://visual/GUI/icons/individual_32x32/icon010.png")
	elif type == "hide":
		tip_top.hide()
		return
	elif type == "shake":
		tool_tip_animation.play("money_shake")
	elif type == "money_add":
		tip_top_label.text = str(value)
		tip_top.show()
		tool_tip_animation.play("money_add")
		yield(tool_tip_animation,"animation_finished")
		
	if type == "money_add":
		tip_top_label.text = str(Global.currancy_1)
	else:
		tip_top_label.text = str(value)
		tip_top.show()
	
	
func tooltip_bot(type,value):
	if type == "tip":
		tip_bot_texture.texture = preload("res://visual/GUI/icons/individual_32x32/icon374.png")
	elif type == "hide":
		tip_bot.hide()
		tooltip_active = false
		return
	
	tip_bot_label.text = str(value)
	tip_bot.show()
	tooltip_active = true
	tool_tip_animation.play("tip_bot")
	yield(tool_tip_animation,"animation_finished")
	tooltip_active = false
	
func set_cursor(type):
	var normal_cursor = load("res://visual/GUI/cursors/Arrow_Rounded_Blue.png")
	var cross_cursor = load("res://visual/character/crosshair/convergence-target.png")
	if type == "normal": Input.set_custom_mouse_cursor(normal_cursor)
	elif type == "crosshair": Input.set_custom_mouse_cursor(cross_cursor)
	
