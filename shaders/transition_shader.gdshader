shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int effect_type : hint_range(0, 4) = 0; // 效果类型：0=柔和渐变，1=旋转渐隐，2=菱形扩展，3=水波纹，4=棱镜
uniform int transition_theme : hint_range(0, 9) = 0;    // 主题选择：0=深海蓝，1=酒红，2=森林绿，3=暮光紫，4=焦糖棕，5=青碧，6=梦幻紫，7=古铜，8=星空蓝，9=玫瑰红
uniform vec4 transition_color : source_color = vec4(0.05, 0.05, 0.08, 1.0); // 转场颜色

// 预设的转场颜色主题
vec4 get_theme_color(int theme_id) {
    switch(theme_id) {
        case 0: return vec4(0.07, 0.13, 0.17, 1.0);    // 深海蓝 Deep Ocean
        case 1: return vec4(0.18, 0.06, 0.12, 1.0);    // 酒红 Wine Red
        case 2: return vec4(0.08, 0.12, 0.05, 1.0);    // 森林绿 Forest Green
        case 3: return vec4(0.15, 0.10, 0.20, 1.0);    // 暮光紫 Twilight Purple
        case 4: return vec4(0.20, 0.15, 0.10, 1.0);    // 焦糖棕 Caramel Brown
        case 5: return vec4(0.05, 0.15, 0.15, 1.0);    // 青碧 Cyan
        case 6: return vec4(0.12, 0.08, 0.15, 1.0);    // 梦幻紫 Dream Purple
        case 7: return vec4(0.16, 0.12, 0.08, 1.0);    // 古铜 Antique Bronze
        case 8: return vec4(0.08, 0.10, 0.14, 1.0);    // 星空蓝 Starry Blue
        case 9: return vec4(0.14, 0.07, 0.07, 1.0);    // 玫瑰红 Rose Red
    }
    return transition_color;
}

// 获取主题的辅助色
vec4 get_accent_color(int theme_id) {
    switch(theme_id) {
        case 0: return vec4(0.2, 0.4, 0.5, 1.0);      // 深海蓝辅助色
        case 1: return vec4(0.5, 0.2, 0.3, 1.0);      // 酒红辅助色
        case 2: return vec4(0.3, 0.4, 0.2, 1.0);      // 森林绿辅助色
        case 3: return vec4(0.4, 0.3, 0.5, 1.0);      // 暮光紫辅助色
        case 4: return vec4(0.5, 0.4, 0.3, 1.0);      // 焦糖棕辅助色
        case 5: return vec4(0.2, 0.5, 0.5, 1.0);      // 青碧辅助色
        case 6: return vec4(0.3, 0.2, 0.4, 1.0);      // 梦幻紫辅助色
        case 7: return vec4(0.4, 0.3, 0.2, 1.0);      // 古铜辅助色
        case 8: return vec4(0.2, 0.3, 0.4, 1.0);      // 星空蓝辅助色
        case 9: return vec4(0.4, 0.2, 0.2, 1.0);      // 玫瑰红辅助色
    }
    return vec4(0.3, 0.3, 0.3, 1.0);
}

// 获取主题的光效颜色
vec4 get_glow_color(int theme_id) {
    switch(theme_id) {
        case 0: return vec4(0.3, 0.6, 0.8, 1.0);      // 深海蓝光效
        case 1: return vec4(0.8, 0.3, 0.4, 1.0);      // 酒红光效
        case 2: return vec4(0.4, 0.7, 0.3, 1.0);      // 森林绿光效
        case 3: return vec4(0.6, 0.4, 0.8, 1.0);      // 暮光紫光效
        case 4: return vec4(0.8, 0.6, 0.4, 1.0);      // 焦糖棕光效
        case 5: return vec4(0.3, 0.8, 0.8, 1.0);      // 青碧光效
        case 6: return vec4(0.5, 0.3, 0.7, 1.0);      // 梦幻紫光效
        case 7: return vec4(0.7, 0.5, 0.3, 1.0);      // 古铜光效
        case 8: return vec4(0.3, 0.4, 0.7, 1.0);      // 星空蓝光效
        case 9: return vec4(0.7, 0.3, 0.3, 1.0);      // 玫瑰红光效
    }
    return vec4(0.5, 0.5, 0.5, 1.0);
}

// 辅助函数：生成随机值
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    float alpha = 0.0;
    
    // 使用固定主题色
    vec4 main_color = get_theme_color(transition_theme);
    vec4 accent = get_accent_color(transition_theme);
    vec4 glow = get_glow_color(transition_theme);
    vec4 effect_color = main_color;
    
    switch(effect_type) {
        case 0: // 丝滑圆形渐变
            vec2 center = vec2(0.5);
            float dist = length(uv - center);
            
            float circle_size = mix(2.0, 0.3, smoothstep(0.0, 0.9, progress));
            float circle_edge = mix(0.0, 0.8, smoothstep(0.0, 0.9, progress));
            
            float circle = smoothstep(circle_size, circle_edge, dist);
            float wave = sin(dist * 8.0 - progress * 2.0) * 0.02 * (1.0 - progress);
            circle += wave;
            
            float fade_in = smoothstep(0.0, 0.2, progress);
            alpha = circle * fade_in;
            
            // 使用主题光效
            float glow_effect = pow(1.0 - dist, 2.0) * 0.3 * (1.0 - progress);
            effect_color = mix(main_color, glow, glow_effect);
            
            alpha *= smoothstep(0.8, 0.4, dist);
            break;
            
        case 1: // 旋转渐隐 - 添加主题色彩
            vec2 rotated_uv = uv - vec2(0.5);
            float angle = progress * 3.14159 * 0.5;
            vec2 final_uv = vec2(
                rotated_uv.x * cos(angle) - rotated_uv.y * sin(angle),
                rotated_uv.x * sin(angle) + rotated_uv.y * cos(angle)
            ) + vec2(0.5);
            
            float fade = smoothstep(0.0, 1.0, progress);
            float rot_dist = length(final_uv - vec2(0.5));
            alpha = smoothstep(0.0, 0.8, 1.0 - rot_dist) * fade;
            
            // 添加旋转光效
            effect_color = mix(main_color, accent, smoothstep(0.3, 0.7, rot_dist));
            effect_color = mix(effect_color, glow, pow(1.0 - rot_dist, 3.0) * 0.5);
            break;
            
        case 2: // 万花筒 - 使用主题配色
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
            
            // 使用主题配色
            effect_color = mix(
                main_color,
                accent,
                pattern * smoothstep(0.2, 0.8, progress)
            );
            effect_color = mix(
                effect_color,
                glow,
                reflection * 0.3
            );
            break;
            
        case 3: // 丝滑溶解 - 使用主题配色
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
            
            // 修改颜色混合:
            vec4 dissolve_color = mix(
                main_color,
                accent,
                noise * smoothstep(0.2, 0.8, progress)
            );
            effect_color = mix(
                dissolve_color,
                glow,
                edge * glow_intensity
            );
            
            // 最终alpha计算 - 确保开始时完全透明
            alpha = mix(0.0, alpha * main_color.a, smoothstep(0.0, 0.1, progress));
            
            break;
            
        case 4: // 扭曲漩涡效果 - 使用主题配色
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
            vec4 twist_base = mix(
                main_color,
                accent,
                smoothstep(0.3, 0.7, length(twisted_uv - center))
            );
            
            effect_color = mix(
                twist_base,
                glow,
                pow(1.0 - dist, 2.0) * progress * 0.5
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
    effect_color.rgb = mix(effect_color.rgb, effect_color.rgb * vignette, 0.2);
    
    COLOR = vec4(effect_color.rgb, alpha * main_color.a);
}