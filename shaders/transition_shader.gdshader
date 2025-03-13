shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int effect_type : hint_range(0, 4) = 0; // 效果类型：0=柔和渐变，1=旋转渐隐，2=菱形扩展，3=水波纹，4=棱镜
uniform vec4 transition_color : source_color = vec4(0.05, 0.05, 0.08, 1.0); // 转场颜色

// 辅助函数：生成随机值
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    float alpha = 0.0;
    vec4 effect_color = vec4(transition_color.rgb, 1.0);
    
    switch(effect_type) {
        case 0: // 丝滑圆形渐变
            vec2 center = vec2(0.5);
            float dist = length(uv - center);
            
            // 添加渐进出现的效果
            float circle_size = mix(2.0, 0.3, smoothstep(0.0, 0.9, progress));
            float circle_edge = mix(0.0, 0.8, smoothstep(0.0, 0.9, progress));
            
            // 计算基础圆形
            float circle = smoothstep(circle_size, circle_edge, dist);
            
            // 添加柔和的波纹
            float wave = sin(dist * 8.0 - progress * 2.0) * 0.02 * (1.0 - progress);
            circle += wave;
            
            // 渐进的透明度控制
            float fade_in = smoothstep(0.0, 0.2, progress);
            alpha = circle * fade_in;
            
            // 添加光晕效果
            float glow = pow(1.0 - dist, 2.0) * 0.3 * (1.0 - progress);
            effect_color += vec4(0.2, 0.2, 0.3, 0.0) * glow;
            
            // 确保边缘平滑
            alpha *= smoothstep(0.8, 0.4, dist);
            break;
            
        case 1: // 旋转渐隐
            vec2 rotated_uv = uv - vec2(0.5);
            float angle = progress * 3.14159 * 0.5;
            vec2 final_uv = vec2(
                rotated_uv.x * cos(angle) - rotated_uv.y * sin(angle),
                rotated_uv.x * sin(angle) + rotated_uv.y * cos(angle)
            ) + vec2(0.5);
            float fade = smoothstep(0.0, 1.0, progress);
            alpha = smoothstep(0.0, 0.8, 1.0 - length(final_uv - vec2(0.5))) * fade;
            break;
            
        case 2: // 万花筒
            vec2 center = vec2(0.5);
            vec2 p = (uv - center) * 1.2; // 保持大图案
            
            // 基础万花筒变换
            float angle = atan(p.y, p.x);
            float radius = length(p);
            
            // 万花筒镜像
            const float sides = 8.0;  // 八重对称
            float section = 3.14159 * 2.0 / sides;
            angle = mod(angle + section * 0.5, section) - section * 0.5;
            vec2 mirror_p = vec2(cos(angle), sin(angle)) * radius;
            
            // 快速旋转动画
            float spin = progress * 3.14159 * 2.0; // 保持快速旋转
            vec2 rotated = vec2(
                mirror_p.x * cos(spin) - mirror_p.y * sin(spin),
                mirror_p.x * sin(spin) + mirror_p.y * cos(spin)
            );
            
            // 创建万花筒图案 - 添加动态效果
            float pattern = 0.0;
            
            // 主要花纹 - 添加更快的变化
            float main_pattern = sin(rotated.x * 3.0 + progress * 2.0) * 
                               cos(rotated.y * 3.0 - progress * 2.0);
            
            // 同心圆纹理 - 快速扩散
            float rings = sin(radius * 6.0 - progress * 4.0) * 0.5;
            
            // 放射状纹理 - 添加旋转律动
            float rays = sin(angle * sides + progress * 3.0) * 0.5;
            
            // 混合所有图案
            pattern = main_pattern * 0.5 + rings * 0.3 + rays * 0.2;
            pattern = pattern * 0.5 + 0.5; // 归一化
            
            // 添加动感的呼吸效果
            float breath = 1.0 + sin(progress * 3.14159 * 3.0) * 0.08;
            float scaled_radius = radius * breath;
            
            // 创建更大的边界过渡
            float edge = smoothstep(1.2, 0.4, scaled_radius);
            float center_fade = smoothstep(0.0, 0.1, scaled_radius);
            
            // 计算最终alpha
            alpha = pattern * edge * center_fade;
            
            // 添加动态的镜面反射
            float reflection = pow(1.0 - abs(dot(normalize(rotated), vec2(cos(progress * 3.0), sin(progress * 3.0)))), 4.0);
            alpha += reflection * 0.2;
            
            // 只保留淡入效果
            float fade_in = smoothstep(0.0, 0.2, progress); // 快速淡入
            alpha *= fade_in;
            
            // 确保边缘平滑
            alpha = smoothstep(0.2, 0.8, alpha);
            break;
            
        case 3: // 丝滑溶解
            vec2 center = vec2(0.5);
            vec2 noise_uv = uv * 1.2;
            
            // 生成更丝滑的噪声
            float noise = 0.0;
            float amplitude = 1.0;
            float frequency = 0.8;
            vec2 shift = vec2(0.0);
            
            // 使用三层噪声，让过渡更加丝滑
            for(int i = 0; i < 3; i++) {
                float t = progress * 0.5;
                vec2 time_shift = vec2(sin(t * 3.14159), cos(t * 3.14159)) * 0.1;
                noise += random(noise_uv * frequency + shift + time_shift) * amplitude;
                amplitude *= 0.5;
                frequency *= 1.8;
                shift += vec2(1.234, 5.678) * progress;
            }
            noise = noise * 0.5 + 0.5;
            
            // 更柔和的径向渐变
            float dist_center = length(uv - center);
            float radial_gradient = smoothstep(0.7, 0.0, dist_center);
            float dynamic_mix = mix(0.1, 0.3, sin(progress * 3.14159) * 0.5 + 0.5);
            noise = mix(noise, radial_gradient, dynamic_mix * smoothstep(0.0, 0.3, progress));
            
            // 创建丝滑的溶解过渡
            float dissolve_start = 0.0;
            float dissolve_end = 0.9;
            float adjusted_progress = smoothstep(dissolve_start, dissolve_end, progress);
            
            // 柔和的方向性溶解
            float angle = atan(uv.y - 0.5, uv.x - 0.5);
            float angle_influence = sin(angle * 2.0 + progress * 6.28318) * 0.05;
            float dissolve_value = noise - (adjusted_progress - angle_influence);
            
            // 创建柔和的边缘
            float edge_width = mix(0.1, 0.15, smoothstep(0.0, 1.0, progress));
            float edge = smoothstep(0.0, edge_width, dissolve_value) - 
                        smoothstep(edge_width, edge_width * 1.2, dissolve_value);
            
            // 更温和的发光颜色
            vec4 glow_color = vec4(0.95, 0.4, 0.1, 1.0);
            float glow_intensity = (1.0 - smoothstep(0.7, 1.0, progress));
            
            // 更柔和的脉冲
            float pulse = sin(progress * 3.14159 * 3.0) * 0.5 + 0.5;
            glow_intensity *= mix(0.9, 1.1, pulse);
            
            // 计算基础alpha
            alpha = smoothstep(-0.05, 0.05, dissolve_value);
            
            // 添加柔和光效
            float dynamic_glow = sin(progress * 3.14159 * 2.0 + dist_center * 4.0) * 0.5 + 0.5;
            
            // 新的颜色混合逻辑
            vec4 base_color = vec4(transition_color.rgb, 0.0); // 初始完全透明
            vec4 edge_color = mix(
                vec4(glow_color.rgb, edge * glow_intensity),
                vec4(transition_color.rgb, edge * glow_intensity),
                smoothstep(0.0, 0.3, progress)
            );
            
            // 最终颜色混合
            effect_color = mix(
                base_color,
                edge_color,
                edge * (1.0 + dynamic_glow * 0.2)
            );
            
            // 最终alpha计算 - 确保开始时完全透明
            alpha = mix(0.0, alpha * transition_color.a, smoothstep(0.0, 0.1, progress));
            
            break;
            
        case 4: // 扭曲漩涡效果
            vec2 center = vec2(0.5);
            vec2 toCenter = center - uv;
            float dist = length(toCenter);
            float angle = atan(toCenter.y, toCenter.x);
            
            // 创建动态扭曲
            float twist_strength = 6.0 * progress; // 降低扭曲强度
            float twist_scale = 2.5; // 降低扭曲的密度
            
            // 添加更柔和的波浪扭曲
            float wave_x = sin(uv.y * 8.0 + progress * 4.0) * 0.08;
            float wave_y = cos(uv.x * 8.0 + progress * 4.0) * 0.08;
            
            // 计算扭曲偏移
            vec2 twisted_uv = uv + vec2(
                sin(dist * twist_scale + progress * 6.28318) * twist_strength * wave_x,
                cos(dist * twist_scale + progress * 6.28318) * twist_strength * wave_y
            ) * smoothstep(1.0, 0.0, dist * 2.0);
            
            // 添加柔和的径向渐变
            float radial = 1.0 - smoothstep(0.0, 0.9, dist);
            
            // 计算更柔和的扭曲颜色
            vec4 twist_color = vec4(
                smoothstep(0.3, 0.7, twisted_uv.x),
                smoothstep(0.4, 0.6, twisted_uv.y),
                smoothstep(0.45, 0.55, length(twisted_uv - center)),
                1.0
            );
            
            // 使用更温和的混合
            effect_color = mix(
                vec4(transition_color.rgb, 1.0),
                twist_color * vec4(0.8, 0.85, 0.9, 1.0), // 添加柔和的色调
                smoothstep(0.3, 0.7, progress)
            );
            
            // 控制透明度
            alpha = smoothstep(0.0, 0.4, progress) * 
                   (1.0 - smoothstep(0.6, 1.0, progress)) * 
                   smoothstep(0.0, 0.4, 1.0 - dist);
            
            // 添加更柔和的发光效果
            float glow = pow(1.0 - dist, 2.5) * progress * 0.7;
            effect_color += vec4(0.2, 0.15, 0.25, 0.0) * glow;
            
            break;
    }
    
    // 添加柔和的光晕效果
    float vignette = 1.0 - length(uv - vec2(0.5)) * 0.3;
    effect_color.rgb *= mix(1.0, vignette, 0.2);
    
    COLOR = vec4(effect_color.rgb, alpha * transition_color.a);
}