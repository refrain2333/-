shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // 简单的淡入淡出效果
    COLOR = vec4(0.0, 0.0, 0.0, progress);
}