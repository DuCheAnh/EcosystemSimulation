extends Area2D

export (float) var speed
export (int) var hunger
export (int) var hunger_threshold
export (int) var hunger_decrement
export (int) var min_hunger
export (int) var max_hunger
export (float) var eat_time
export (float) var hunger_tick_time
export (float, 0, 1, 0.1) var reproductive_thrive
export (float, 0, 1, 0.1) var reproductive_thrive_threshold
export (int) var detection_range

var genes = []
export (float) var age = 0
export (int) var portion = 50
onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var direction_timer = $DirectionTimer
onready var hunger_timer = $HungerTimer
onready var eat_timer = $EatTimer
onready var status_label = $StatusLabel
onready var sprite = $Sprite

const ROTATION = {
	Vector2.UP: 0,
	Vector2.RIGHT: 90,
	Vector2.DOWN: 180,
	Vector2.LEFT: 270,
	Vector2(1, -1): 45,
	Vector2(1, 1): 135,
	Vector2(-1, 1): 225,
	Vector2(-1, -1): 315,
}

var direction = Vector2.ZERO
var target_food = null
var target_mate = null
var state = SEARCHING_FOOD

func apply_genes(new_genes):
	genes = new_genes
	speed = genes[0]
	hunger = genes[1]
	hunger_threshold = genes[2]
	hunger_decrement = genes[3]
	min_hunger = genes[4]
	max_hunger = genes[5]
	eat_time = genes[6]
	hunger_tick_time = genes[7]
	reproductive_thrive = genes[8]
	reproductive_thrive_threshold = genes[9]
	detection_range = genes[10]

func create_new_genes(partners_genes):
	var arr = []
	for i in range(genes.size()):
		if rand_range(0,1)<0.5:
			arr.append(genes[i])
		else:
			arr.append(partners_genes[i])
		if rand_range(0,1)<0.2:
			if rand_range(0,1)<0.5:
				arr[i]+=arr[i]*rand_range(0, 0.2)
			else:
				arr[i]-=arr[i]*0.1*rand_range(0, 0.2)
	return arr
enum {
	SEARCHING_FOOD,
	FOUND_FOOD,
	FOUND_MATE,
	EATING,
	MATING,
	ENJOYING_LIFE
}
func eaten():
	queue_free()
func _ready() -> void:
	randomize()
	direction = _new_direction()
	hunger_timer.wait_time = hunger_tick_time
	eat_timer.wait_time = eat_time
	$CollisionShape2D.shape.radius = detection_range

func _process(delta) -> void:
	match state:
		SEARCHING_FOOD:
			move_randomly(delta)
		FOUND_FOOD:
			go_to_food(delta)
		FOUND_MATE:
			go_to_food(delta)
	update_label()
	update_state()
	if starved() or age >= 10:
		queue_free()
func update_state() -> void:
	if hungry():
		sprite.modulate = Color(1, 0.5, 0.5)
	elif horny():
		sprite.modulate = Color(0.5,1,1)
	else:
		sprite.modulate = Color(1, 1, 1)


func update_label() -> void:
	var state_string
	match state:
		SEARCHING_FOOD:
			state_string = "SEARCHING"
		FOUND_FOOD:
			state_string = "FOUND FOOD"
		MATING:
			state_string = "MATING"
		EATING:
			state_string = "EATING"
		FOUND_MATE:
			state_string = "FOUNDMATE"
	status_label.text = "AGE: " + str(age)
	status_label.text += "\nHUNGER: " + str(int(max_hunger-hunger)) + "/" + str(int(max_hunger))
	status_label.text += "\nSPEED: " + str(int(speed))
	status_label.text += "\n STATE: " + str(state_string)
	status_label.text += "\n THRIVE: " + str(reproductive_thrive) + "/" + str(reproductive_thrive_threshold)
	status_label.text += "\n RANGE: " + str(detection_range)
func move_randomly(delta) -> void:
	_rotate_sprite()
	position += direction.normalized() * speed * delta
	_keep_sprite_on_screen()

func go_to_food(delta):
	if is_instance_valid(target_food):
		$Sprite.rotation_degrees = rad2deg(target_food.position.angle_to_point(position)) + 90
		position += position.direction_to(target_food.position) * speed * delta
	elif is_instance_valid(target_mate):
		$Sprite.rotation_degrees = rad2deg(target_mate.position.angle_to_point(position)) + 90
		position += position.direction_to(target_mate.position) * speed * delta
	else:
		state = SEARCHING_FOOD


func _keep_sprite_on_screen() -> void:
	if position.x <= 0 || position.x >= screen_width:
		direction.x *= -1
	if position.y <= 0 || position.y >= screen_height:
		direction.y *= -1
	position.x = clamp(position.x,0,screen_width)
	position.y = clamp(position.y,0,screen_height)

func _rotate_sprite() -> void:
	if direction == Vector2.ZERO:
		return
	$Sprite.rotation_degrees = ROTATION[direction]

func _new_direction() -> Vector2:
	var h_move = _choose([Vector2.RIGHT, Vector2.LEFT, Vector2.ZERO])
	var v_move = _choose([Vector2.UP, Vector2.DOWN, Vector2.ZERO])
	return h_move + v_move

func _choose(options):
	options.shuffle()
	return options.front()

func hungry() -> bool:
	return hunger < hunger_threshold

func starved() -> bool:
	return hunger == 0

func horny() ->bool:
	return reproductive_thrive > reproductive_thrive_threshold

func _on_Wolf_area_entered(area):
	if is_instance_valid(target_food):
		return
	if is_instance_valid(target_mate):
		return
	if hungry():
		if area.is_in_group("Chicken"):
			state = FOUND_FOOD
			target_food = area
	elif horny():
		if area.is_in_group("Wolf") and area.horny():
			state = FOUND_MATE
			target_mate = area


func _on_EatingArea_area_entered(area):
	if is_instance_valid(target_food):
		state = EATING
		target_food.stop_moving()
		eat_timer.start()
	elif is_instance_valid(target_mate):
		state = MATING
		eat_timer.start()

func _on_DirectionTimer_timeout() -> void:
	var time = _choose([1, 1.5, 2])
	direction_timer.set_wait_time(time)
	direction = _new_direction()

func _on_HungerTimer_timeout() -> void:
	hunger = clamp(hunger - hunger_decrement, min_hunger, max_hunger)
	reproductive_thrive = clamp(reproductive_thrive + 0.1, 0, 100)
	age+=0.1

func _on_EatTimer_timeout():
	if is_instance_valid(target_food):
		hunger += target_food.portion
		target_food.eaten()
	elif is_instance_valid(target_mate):
		var baby_genes = create_new_genes(target_mate.genes)
		get_parent().get_parent().add_cup_at_pos(baby_genes, position)
		reproductive_thrive = 0
		target_mate = null
	eat_timer.stop()
	state = SEARCHING_FOOD

