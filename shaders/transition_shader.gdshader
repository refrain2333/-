shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D cg_texture; // CG图片纹理

void fragment() {
    vec2 uv = UV;
    vec4 cg_color = texture(cg_texture, uv);
    
    // 只淡入，不淡出
    float alpha = smoothstep(0.0, 0.5, progress);
    
    // 添加柔和的光晕效果
    float vignette = 1.0 - length(uv - vec2(0.5)) * 0.3;
    cg_color.rgb *= mix(1.0, vignette, 0.2);
    
    COLOR = vec4(cg_color.rgb, alpha);
}