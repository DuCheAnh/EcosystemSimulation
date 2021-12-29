extends Node2D

var chicken_preload = preload("res://Scene/Chicken.tscn")
var food_preload = preload("res://Scene/Food.tscn")

export (float) var Add_Food_tick_time = 10
export (bool) var Add_Food = false

onready var chickens = $Chickens
onready var foods = $Foods
onready var Add_Food_timer = $AddFoodTimer

func _ready():
	randomize()
	Add_Food_timer.wait_time = Add_Food_tick_time
	add_chicken(10)
	add_food(30)

func _process(delta) -> void:
	if Add_Food:
		add_food(1)
		Add_Food = false


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
		chicken_ins.position = Vector2(rand_range(0,screen_size.x),rand_range(0,screen_size.y))
		chickens.add_child(chicken_ins)


func _on_AddFoodsTimer_timeout() -> void:
		Add_Food = true

