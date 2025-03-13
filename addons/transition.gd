extends Node

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer
var is_transitioning: bool = false
var next_scene: String = ""
var transition_speed: float = 1.0
var force_effect_type: int = -1  # 强制使用的效果类型，-1表示随机

func _ready() -> void:
	# 初始化时设置随机种子
	randomize()

func set_effect_type(effect: int) -> void:
	force_effect_type = effect

func get_random_effect() -> int:
	return randi() % 5  # 随机选择0-4之间的效果

func play_transition(target_scene: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	next_scene = target_scene

	# 设置效果类型
	var effect = force_effect_type if force_effect_type >= 0 else get_random_effect()
	color_rect.material.set_shader_parameter("effect_type", effect)
	print("使用转场效果：", effect)

	# 显示ColorRect
	color_rect.show()
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # 阻止鼠标事件
	# 播放动画
	anim_player.play("fade_in")
	print("开始播放动画")

#func _process(_delta: float) -> void:
	#if is_transitioning and color_rect.material:
		#var progress = color_rect.material.get_shader_parameter("progress")
		#print("Progress: ", progress)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		print("动画完成")
		# 加载新场景
		var new_scene = load(next_scene).instantiate()
		get_tree().root.add_child(new_scene)
		
		# 切换当前场景
		var old_scene = get_tree().current_scene
		get_tree().current_scene = new_scene
		
		# 清理
		if old_scene:
			old_scene.queue_free()
		
		color_rect.hide()
		is_transitioning = false
		queue_free()
