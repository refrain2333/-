extends Node
# 从 transition.gd 复制枚举定义，保持一致
enum TransitionEffect {
	RADIAL_GLOW    # 带光晕的径向扩展
}
# 更丰富的颜色方案
var color_schemes = [
	# 深色系
	{
		"main": Color(0.05, 0.05, 0.1, 1.0),      # 深蓝黑
		"accent": Color(0.3, 0.5, 1.0, 1.0)       # 亮蓝色
	}
]
# 场景路径数组
var SCENES = [
	"res://scenes/scene_1.tscn",
	"res://scenes/scene_2.tscn",
	"res://scenes/scene_3.tscn"
]

# 获取当前场景索引
func get_current_scene_index() -> int:
	var current_scene_path = get_tree().current_scene.scene_file_path
	return SCENES.find(current_scene_path)

# 用于切换场景并应用指定的过渡效果
func change_scene_with_effect(target_scene: String, _effect: int):
	var _color_scheme = color_schemes.pick_random()
	var _transition = await SceneManager.change_scene(target_scene, "",4)
	#if transition:
		#transition\
			#.set_effect(effect)\
			#.set_speed(randf_range(1.2, 1.8))\
			#.set_color(color_scheme.main)
		## 设置强调色
		#if transition.color_rect.material:
			#transition.color_rect.material.set_shader_parameter("accent_color", color_scheme.accent)
	print("场景切换请求已发送222")


func _on_next_button_pressed() -> void:
	print("点击了下一个按钮")
	var current_index = get_current_scene_index()
	var target_index = (current_index + 1) % SCENES.size()
	print("目标场景索引: ", target_index)
	await change_scene_with_effect(SCENES[target_index], TransitionEffect.RADIAL_GLOW)
	


func _on_prev_button_pressed() -> void:
	print("点击了上一个按钮")
	var current_index = get_current_scene_index()
	var target_index = (current_index - 1 + SCENES.size()) % SCENES.size()
	print("目标场景索引: ", target_index)
	await SceneManager.change_scene(SCENES[target_index], "")#随机
