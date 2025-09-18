extends Node2D

var score = 0


func _ready():
	# Connect all pegs to score function
	for peg in get_tree().get_nodes_in_group("pegs"):
		peg.connect("peg_hit", _on_peg_hit)

func _on_peg_hit(points):
	score += points
	print("Total Score: ", score)
