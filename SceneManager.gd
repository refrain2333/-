# SceneManager.gd
extends Node

var cg_images = []  # 存储CG图片路径
var rng = RandomNumberGenerator.new()
var current_cg_node = null  # 当前显示的CG节点

func _ready():
	print("SceneManager已初始化")
	load_cg_images()
	rng.randomize()

# 加载CG图片
func load_cg_images():
	var dir = DirAccess.open("res://转场图")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".jpg") or file_name.ends_with(".png"):
				cg_images.append("res://转场图/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	print("已加载 ", cg_images.size(), " 张CG图片")

# 获取随机CG图片路径
func get_random_cg() -> String:
	if cg_images.size() > 0:
		return cg_images[rng.randi() % cg_images.size()]
	return ""

# 场景切换方法
func change_scene(target: String) -> Node:
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
	
	# 如果存在之前的CG节点，先移除它
	if current_cg_node:
		current_cg_node.queue_free()
	
	get_tree().root.add_child(transition)
	current_cg_node = transition  # 保存当前CG节点的引用
	print("过渡场景已添加到场景树")
	
	# 等待一帧确保节点已准备好
	await get_tree().process_frame
	
	# 设置CG图片
	if transition.has_node("ColorRect"):
		var color_rect = transition.get_node("ColorRect")
		if color_rect and color_rect.material:
			var shader_material = color_rect.material
			
			# 加载随机CG图片
			var cg_path = get_random_cg()
			if cg_path != "":
				var cg_texture = load(cg_path)
				if cg_texture:
					shader_material.set_shader_parameter("cg_texture", cg_texture)
					print("使用CG图片：", cg_path)
	
	transition.play_transition(target)
	print("开始播放过渡动画")
	return transition
