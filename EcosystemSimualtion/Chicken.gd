extends Area2D

export (float) var speed = 150
export (int) var hunger = 100
export (int) var hunger_threshold = 40
export (int) var hunger_decrement = 5
export (float, 0, 1, 0.1) var thrive_for_food = 0.1
export (int) var min_hunger = 0
export (int) var max_hunger = 100
export (float) var eat_time = 2
export (float) var hunger_tick_time = 2
export (float, 0, 1, 0.1) var reproductive_thrive = 0


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

enum {
	SEARCHING_FOOD,
	FOUND_FOOD,
	EATING,
	ENJOYING_LIFE
}
func _ready() -> void:
	randomize()
	direction = _new_direction()
	hunger_timer.wait_time = hunger_tick_time
	eat_timer.wait_time = eat_time

func _process(delta) -> void:
	match state:
		SEARCHING_FOOD:
			move_randomly(delta)
		FOUND_FOOD:
			go_to_food(delta)

	update_label()
	update_state()

func update_state() -> void:
	if hungry():
		sprite.modulate = Color(1, 0.5, 0.5)
	else:
		sprite.modulate = Color(1,1,1)


func update_label() -> void:
	var state_string
	match state:
		SEARCHING_FOOD:
			state_string = "SEARCHING"
		FOUND_FOOD:
			state_string = "FOUND FOOD"
		EATING:
			state_string = "EATING"
		ENJOYING_LIFE:
			state_string = "ENJOYING LIFE"
	status_label.text = "HUNGER: " + str(hunger) + "/" + str(max_hunger)
	status_label.text += "\nDIRECTION: " + str(direction)
	status_label.text += "\n STATE: " + str(state_string)
	status_label.text += "\n THRIVE: " + str(reproductive_thrive)

func move_randomly(delta) -> void:
	_rotate_sprite()
	position += direction.normalized() * speed * delta
	_keep_sprite_on_screen()

func go_to_food(delta):
	if is_instance_valid(target_food):
		$Sprite.rotation_degrees = rad2deg(target_food.position.angle_to_point(position)) + 90
		position += position.direction_to(target_food.position) * speed * delta
	else:
		state = SEARCHING_FOOD


func _keep_sprite_on_screen() -> void:
	if position.x <= 0 || position.x >= screen_width:
		direction.x *= -1
	if position.y <= 0 || position.y >= screen_height:
		direction.y *= -1

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


func _on_DirectionTimer_timeout() -> void:
	var time = _choose([1, 1.5, 2])
	direction_timer.set_wait_time(time)
	direction = _new_direction()


func _on_HungerTimer_timeout() -> void:
	hunger = clamp(hunger - hunger_decrement, min_hunger, max_hunger)
	reproductive_thrive = clamp(reproductive_thrive + 0.1, 0, 1)

func hungry() -> bool:
	return hunger < hunger_threshold

func horny() ->bool:
	return reproductive_thrive > 0.5

func want_a_full_belly() -> bool:
	return rand_range(0,1) <= thrive_for_food
func _on_Chicken_area_entered(area):
	if is_instance_valid(target_food):
		return
	if area.is_in_group("Food") and (hungry() or want_a_full_belly()):
		state = FOUND_FOOD
		target_food = area




func _on_EatingArea_area_entered(area):
	if is_instance_valid(target_food):
		state = EATING
		eat_timer.start()


func _on_EatTimer_timeout():
	if is_instance_valid(target_food):
		hunger += target_food.portion
		target_food.eaten()
	eat_timer.stop()
	state = SEARCHING_FOOD
