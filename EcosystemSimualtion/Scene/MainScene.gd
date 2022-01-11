extends Node2D

var chicken_preload = preload("res://Scene/Chicken.tscn")
var food_preload = preload("res://Scene/Food.tscn")
var wolf_preload = preload("res://Scene/Wolf.tscn")
onready var chickens = $Chickens
onready var foods = $Foods
onready var animals_data = $Chickens
var food_amount = 5
var content = ""
var day_passed = 0
var basic_genes = [150, 100, 40, 5, 0, 100, 2, 3, 0, 1, 80]
var wolf_basic_genes = [200, 100, 60, 5, 0, 100, 2, 3, 0, 1, 200]
func _ready():
	randomize()
	add_chicken(10)
	add_wolf(3)
	add_food(30)
func average_speed(Chickens):
	if Chickens.get_child_count()<1:
		return 0
	var sum = 0
	for chicken in Chickens.get_children():
		sum += chicken.speed
	return sum/Chickens.get_child_count()
func average_range(Chickens):
	if Chickens.get_child_count()<1:
		return 0
	var sum = 0
	for chicken in Chickens.get_children():
		sum += chicken.detection_range
	return sum/Chickens.get_child_count()
func average_age(Chickens):
	if Chickens.get_child_count()<1:
		return 0
	var sum = 0
	for chicken in Chickens.get_children():
		sum += chicken.age
	return sum/Chickens.get_child_count()

func average_max_hunger(Chickens):
	if Chickens.get_child_count()<1:
		return 0
	var sum = 0
	for chicken in Chickens.get_children():
		sum += chicken.max_hunger
	return sum/Chickens.get_child_count()

func average_hunger_decrement(Chickens):
	if Chickens.get_child_count()<1:
		return 0
	var sum = 0
	for chicken in Chickens.get_children():
		sum += chicken.hunger_decrement
	return sum/Chickens.get_child_count()
func average_reproductive_thrive_threshold(Chickens):
	if Chickens.get_child_count()<1:
		return 0
	var sum = 0
	for chicken in Chickens.get_children():
		sum += chicken.reproductive_thrive_threshold
	return sum/Chickens.get_child_count()
func update_status_board_of(animals):
	$Label.text = "Days passed: "+ str(day_passed) + "\n"
	$Label.text += "Amount: " + str(animals.get_child_count())
	$Label.text += "\nAverage age: " + str(average_age(animals))
	$Label.text += "\nAverage speed: " + str(average_speed(animals))
	$Label.text += "\nAverage range: " + str(average_range(animals))
	$Label.text += "\nAverage hunger threshold: " + str(average_max_hunger(animals))
	$Label.text += "\nAverage hunger decrement: " + str(average_hunger_decrement(animals))
	$Label.text += "\nAverage repro threshold: " + str(average_reproductive_thrive_threshold($Chickens)) + "\n"
func get_data(animals):
	var tx = ""
	tx = str(day_passed) + "	"
	tx += str(animals.get_child_count())
	tx += "	" + str(average_age(animals))
	tx += "	" + str(average_speed(animals))
	tx += "	" + str(average_range(animals))
	tx += "	" + str(average_max_hunger(animals))
	tx += "	" + str(average_hunger_decrement(animals))
	tx += "	" + str(average_reproductive_thrive_threshold($Chickens)) + "\n"
	return tx
func save(content):
	var file = File.new()
	file.open("res://saved_data.txt", File.WRITE)
	file.store_string(content)
	file.close()
func _process(delta):
	update_status_board_of(animals_data)
	$Control/SpeedLabel.text = str(Engine.time_scale)

func add_food(amount) -> void:
	var screen_size = get_viewport_rect().size
	for i in range(amount):
		var food_ins = food_preload.instance()
		food_ins.position = Vector2(rand_range(0,screen_size.x),rand_range(0,screen_size.y))
		foods.add_child(food_ins)

func add_chicken(amount) -> void:
	var screen_size = get_viewport_rect().size
	for i in range(amount):
		var chicken_ins = chicken_preload.instance()
		chicken_ins.apply_genes(basic_genes)
		chicken_ins.position = Vector2(rand_range(0,screen_size.x),rand_range(0,screen_size.y))
		chickens.add_child(chicken_ins)
func add_wolf(amount) -> void:
	var screen_size = get_viewport_rect().size
	for i in range(amount):
		var wolf_ins = wolf_preload.instance()
		wolf_ins.apply_genes(wolf_basic_genes)
		wolf_ins.position = Vector2(rand_range(0,screen_size.x),rand_range(0,screen_size.y))
		$Wolves.add_child(wolf_ins)

func add_baby_at_pos(genes, pos):
	if rand_range(0,1)<0.3:
		return
	var chicken_ins = chicken_preload.instance()
	chicken_ins.apply_genes(genes)
	chicken_ins.position = pos
	chickens.add_child(chicken_ins)
func add_cup_at_pos(genes, pos):
	if rand_range(0,1)<0.5:
		return
	var wolf_ins = wolf_preload.instance()
	wolf_ins.apply_genes(genes)
	wolf_ins.position = pos
	$Wolves.add_child(wolf_ins)


func _on_FoodTimer_timeout():
	add_food(food_amount)
	content+=get_data($Chickens)
	save(content)
	day_passed += 0.5


func _on_AddWolfBtn_pressed():
	add_wolf(1)


func _on_AddChickenBtn_pressed():
	add_chicken(1)


func _on_IncreaseSpeedBtn_pressed():
	Engine.time_scale+=1


func _on_DecreaseSpeedBtn_pressed():
	Engine.time_scale = clamp(Engine.time_scale - 1, 0,10000)


func _on_ShowCDataBtn_pressed():
	animals_data = $Chickens

func _on_ShowCDataBtn2_pressed():
	animals_data = $Wolves


func _on_RMChickenBtn_pressed():
	for chicken in $Chickens.get_children():
		chicken.queue_free()


func _on_RMWolfBtn_pressed():
	for wolf in $Wolves.get_children():
		wolf.queue_free()


func _on_SetFoodBtn_pressed():
	food_amount = int($Control/FoodAmountTE.text)




func _on_ResetButton_pressed():
	Engine.time_scale = 1
