# SceneManager.gd
extends Node

func _ready():
	print("SceneManager已初始化")

# 场景切换方法
func change_scene(target: String, pattern: String = "", effect_type: int = -1) -> Node:
	# 先尝试加载转场场景
	var transition_scene = load("res://addons/transition.tscn")
	if not transition_scene:
		printerr("错误：无法加载转场场景文件！")
		return null
		
	var transition = transition_scene.instantiate()
	if not transition:
		printerr("错误：无法实例化过渡场景！")
		return null
		
	print("过渡场景已实例化")
	get_tree().root.add_child(transition)
	print("过渡场景已添加到场景树")
	
	# 等待一帧确保节点已准备好
	await get_tree().process_frame
	
	# 如果提供了纹理路径，则设置遮罩纹理
	if pattern != "":
		var pattern_texture = load(pattern)
		if pattern_texture:
			transition.color_rect.material.set_shader_parameter("mask_texture", pattern_texture)
	
	# 如果指定了效果类型，则使用指定的效果
	if effect_type >= 0:
		transition.set_effect_type(effect_type)
	
	transition.play_transition(target)
	print("开始播放过渡动画")
	return transition
