shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int effect_type : hint_range(0, 4) = 0; // 效果类型：0=淡入淡出，1=百叶窗，2=圆形扩散，3=菱形，4=像素化

// 辅助函数：生成随机值
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    float alpha = 0.0;
    
    switch(effect_type) {
        case 0: // 淡入淡出
            alpha = progress;
            break;
            
        case 1: // 百叶窗效果
            float blinds = 10.0; // 百叶窗数量
            float x = uv.x * blinds;
            float wave = step(progress, fract(x));
            alpha = wave;
            break;
            
        case 2: // 圆形扩散
            float dist = distance(uv, vec2(0.5));
            alpha = step(progress, dist);
            break;
            
        case 3: // 菱形
            float diamond = abs(uv.x - 0.5) + abs(uv.y - 0.5);
            alpha = step(progress * 1.5, diamond);
            break;
            
        case 4: // 像素化
            float pixels = 50.0 * (1.0 - progress); // 像素数量随进度变化
            if (pixels > 0.0) {
                vec2 pixelUV = floor(uv * pixels) / pixels;
                alpha = random(pixelUV) < progress ? 1.0 : 0.0;
            } else {
                alpha = 1.0;
            }
            break;
    }
    
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}