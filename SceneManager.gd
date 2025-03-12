extends Node

func change_scene(target: String, _pattern: String = "") -> void:
	print("开始场景切换")
	var transition = preload("res://addons/transition.tscn").instantiate()
	get_tree().root.add_child(transition)
	# 等待一帧以确保节点已准备好
	await get_tree().process_frame
	# 开始过渡
	transition.play_transition(target)
