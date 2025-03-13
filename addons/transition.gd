extends Node

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var is_transitioning: bool = false
var next_scene: String = ""
var transition_speed: float = 1.0
var force_effect_type: int = -1  # 强制使用的效果类型，-1表示随机
var old_scene: Node = null
var new_scene: Node = null

func _ready() -> void:
	# 初始化时设置随机种子
	randomize()
	# 确保 ColorRect 在最上层且不可交互
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.hide()

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

	# 保存当前场景引用
	old_scene = get_tree().current_scene
	
	# 预加载新场景
	var scene_res = load(next_scene)
	if scene_res:
		new_scene = scene_res.instantiate()
		get_tree().root.add_child(new_scene)
		new_scene.modulate.a = 0  # 初始时完全透明
	
	# 开始旧场景的淡出效果
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(old_scene, "modulate:a", 0.6, 0.8)
	
	# 显示 ColorRect 并开始淡入动画
	color_rect.show()
	anim_player.play("fade_in")

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"fade_in":
			if old_scene:
				# 平滑移除旧场景
				var final_fade = create_tween()
				final_fade.tween_property(old_scene, "modulate:a", 0.0, 0.4)
				final_fade.tween_callback(func(): old_scene.queue_free())
			
			# 设置新场景为当前场景
			if new_scene:
				get_tree().current_scene = new_scene
				
				# 开始新场景的淡入效果
				var fade_in_tween = create_tween()
				fade_in_tween.tween_property(new_scene, "modulate:a", 0.6, 0.4)
				fade_in_tween.tween_property(new_scene, "modulate:a", 1.0, 0.6)
				
				# 开始淡出动画
				anim_player.play("fade_out")
				
		"fade_out":
			# 转场结束，清理
			color_rect.hide()
			is_transitioning = false
			queue_free()  # 清理转场节点
