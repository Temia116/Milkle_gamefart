extends Node

var score: int = 0
var orange_pegs_left: int = 0

signal score_changed(new_score: int)
signal orange_peg_hit()

func _ready():
	count_orange_pegs()

func add_score(points: int):
	score += points
	score_changed.emit(score)

func count_orange_pegs():
	# Count orange pegs in scene
	var pegs = get_tree().get_nodes_in_group("pegs")
	orange_pegs_left = 0
	for peg in pegs:
		if peg.is_orange:
			orange_pegs_left += 1

func peg_destroyed(was_orange: bool):
	if was_orange:
		orange_pegs_left -= 1
		orange_peg_hit.emit()
		
		if orange_pegs_left <= 0:
			print("Level Complete!")
