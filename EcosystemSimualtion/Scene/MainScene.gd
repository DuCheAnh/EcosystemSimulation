extends Node2D

var chicken_preload = preload("res://Scene/Chicken.tscn")
var food_preload = preload("res://Scene/Food.tscn")

onready var chickens = $Chickens
onready var foods = $Foods

func _ready():
	randomize()
	add_chicken(10)
	add_food(30)


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
