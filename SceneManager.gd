# SceneManager.gd
extends Node

var current_theme_id = 0  # 当前使用的主题ID

func _ready():
	print("SceneManager已初始化")

# 设置转场主题
func set_transition_theme(new_theme_id: int) -> void:
	current_theme_id = clamp(new_theme_id, 0, 9)  # 确保ID在有效范围内
	print("设置转场主题：", get_theme_name(current_theme_id))

# 获取主题名称
func get_theme_name(id: int) -> String:
	var theme_names = [
		"深海蓝 Deep Ocean",
		"酒红 Wine Red",
		"森林绿 Forest Green",
		"暮光紫 Twilight Purple",
		"焦糖棕 Caramel Brown",
		"青碧 Cyan",
		"梦幻紫 Dream Purple",
		"古铜 Antique Bronze",
		"星空蓝 Starry Blue",
		"玫瑰红 Rose Red"
	]
	return theme_names[id] if id >= 0 and id < theme_names.size() else "未知主题"

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
	
	# 设置主题色
	if transition.has_node("ColorRect"):
		var color_rect = transition.get_node("ColorRect")
		if color_rect and color_rect.material:
			var shader_material = color_rect.material
			shader_material.set_shader_parameter("transition_theme", current_theme_id)
	
	# 如果提供了纹理路径，则设置遮罩纹理
	if pattern != "":
		var pattern_texture = load(pattern)
		if pattern_texture and transition.has_node("ColorRect"):
			var color_rect = transition.get_node("ColorRect")
			if color_rect and color_rect.material:
				color_rect.material.set_shader_parameter("mask_texture", pattern_texture)
	
	# 如果指定了效果类型，则使用指定的效果
	if effect_type >= 0:
		transition.set_effect_type(effect_type)
	
	transition.play_transition(target)
	print("开始播放过渡动画，使用主题：", get_theme_name(current_theme_id))
	return transition
