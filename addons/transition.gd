extends Node

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer
var is_transitioning: bool = false
var next_scene: String = ""
var transition_speed: float = 1.0
func _ready() -> void:
	# 初始化材质
	if not color_rect.material:
		var shader_material = ShaderMaterial.new()
		shader_material.shader = preload("res://shaders/transition_shader.gdshader")
		shader_material.set_shader_parameter("progress", 0.0)
		color_rect.material = shader_material
	
	# 创建默认动画
	_create_transition_animation()
	
	# 确保信号连接
	if not anim_player.is_connected("animation_finished", _on_animation_finished):
		anim_player.connect("animation_finished", _on_animation_finished)

func _create_transition_animation() -> void:
	# 创建新动画
	var animation = Animation.new()
	animation.length = transition_speed
	
	# 添加轨道
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "ColorRect:material:shader_parameter/progress")
	
	# 设置插值
	animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_LINEAR)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_CONTINUOUS)
	
	# 添加关键帧
	animation.track_insert_key(track_index, 0.0, 0.0)
	animation.track_insert_key(track_index, transition_speed, 1.0)
	
	# 创建动画库
	var lib = AnimationLibrary.new()
	lib.add_animation("transition", animation)
	
	# 添加到播放器
	anim_player.add_animation_library("transitions", lib)

func play_transition(target_scene: String) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	next_scene = target_scene
	
	# 重置材质参数
	color_rect.material.set_shader_parameter("progress", 0.0)
	
	# 显示ColorRect
	color_rect.show()
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # 阻止鼠标事件
	
	# 播放动画
	anim_player.play("transitions/transition")
	
	# 调试输出
	print("开始播放动画")
	print("当前progress值：", color_rect.material.get_shader_parameter("progress"))

func _process(_delta: float) -> void:
	if is_transitioning and color_rect.material:
		var progress = color_rect.material.get_shader_parameter("progress")
		print("Progress: ", progress)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "transitions/transition":
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
