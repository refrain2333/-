extends Node
# 从 transition.gd 复制枚举定义，保持一致
enum TransitionEffect {
	RADIAL_GLOW,      # 带光晕的径向扩展
	HEX_MOSAIC,       # 六边形马赛克
	DOUBLE_ROTATE,    # 双重旋转切割
	RAINBOW_WAVE,     # 彩虹波浪
	FRACTAL_KALEID,   # 分形万花筒
	LIQUID_FLOW,      # 液态流动
	PIXEL_DISSOLVE,   # 像素化溶解
	LIGHTNING,        # 闪电效果
	KALEID_FOLD,      # 万花筒折叠
	CHROMA_VORTEX     # 炫彩漩涡
}
# 更丰富的颜色方案
var color_schemes = [
	# 深色系
	{
		"main": Color(0.05, 0.05, 0.1, 1.0),      # 深蓝黑
		"accent": Color(0.3, 0.5, 1.0, 1.0)       # 亮蓝色
	},
	{
		"main": Color(0.1, 0.02, 0.02, 1.0),      # 深红黑
		"accent": Color(1.0, 0.3, 0.3, 1.0)       # 亮红色
	},
	{
		"main": Color(0.02, 0.1, 0.02, 1.0),      # 深绿黑
		"accent": Color(0.3, 1.0, 0.3, 1.0)       # 亮绿色
	},
	{
		"main": Color(0.1, 0.05, 0.15, 1.0),      # 深紫黑
		"accent": Color(0.8, 0.3, 1.0, 1.0)       # 亮紫色
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
func change_scene_with_effect(target_scene: String, effect: int):
	var color_scheme = color_schemes.pick_random()
	var scene_manager = get_node("/root/SceneManager")
	var transition = await scene_manager.change_scene(target_scene, "")
	if transition:
		transition\
			.set_effect(effect)\
			.set_speed(randf_range(1.2, 1.8))\
			.set_color(color_scheme.main)

		# 设置强调色
		if transition.color_rect.material:
			transition.color_rect.material.set_shader_parameter("accent_color", color_scheme.accent)
			
	print("场景切换请求已发送1222")


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
	await change_scene_with_effect(SCENES[target_index], TransitionEffect.RADIAL_GLOW)
