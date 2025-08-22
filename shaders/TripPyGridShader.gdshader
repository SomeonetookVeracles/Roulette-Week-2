shader_type canvas_item;

// Simple trippy shimmer shader - no conflicts
uniform float intensity : hint_range(0.0, 3.0) = 1.0;
uniform float speed : hint_range(0.1, 10.0) = 2.0;
uniform int effect_type : hint_range(0, 3) = 0;
uniform vec2 grid_size = vec2(20.0, 15.0);

void fragment() {
    vec2 grid_uv = UV * grid_size;
    float time = TIME;
    vec4 shimmer_color = vec4(0.0);
    
    if (effect_type == 0) {
        // Wave effect
        float wave = sin(time * speed + grid_uv.x * 0.5) * intensity;
        float alpha = (wave + 1.0) * 0.5;
        float hue = mod(time * 0.1 + grid_uv.x * 0.1, 1.0);
        shimmer_color = vec4(sin(hue * 6.28), cos(hue * 6.28), 1.0, alpha * 0.4);
        
    } else if (effect_type == 1) {
        // Ripple effect
        vec2 center = grid_size * 0.5;
        float distance = length(grid_uv - center);
        float ripple = sin(time * speed * 2.0 - distance * 0.8) * intensity;
        float alpha = (ripple + 1.0) * 0.5;
        shimmer_color = vec4(0.0, 1.0, 1.0, alpha * 0.5);
        
    } else if (effect_type == 2) {
        // Breathing grid
        float pulse = sin(time * speed * 0.5) * intensity;
        float alpha = (pulse + 1.0) * 0.5;
        float hue = mod(time * 0.1, 1.0);
        shimmer_color = vec4(1.0, sin(hue * 6.28), 0.0, alpha * 0.3);
        
    } else {
        // Chaos mode
        float noise_x = sin(grid_uv.x * 1.7 + time * 3.0) * cos(grid_uv.y * 2.3 + time * 2.0);
        float noise_y = cos(grid_uv.x * 2.1 + time * 2.5) * sin(grid_uv.y * 1.9 + time * 3.5);
        float alpha = abs(noise_x * noise_y) * intensity;
        float hue = mod(abs(noise_x + noise_y + time * 0.5), 1.0);
        shimmer_color = vec4(sin(hue * 6.28), cos(hue * 4.0), sin(hue * 2.0), clamp(alpha * 0.4, 0.0, 0.7));
    }
    
    // Get the original texture and blend
    vec4 original = texture(TEXTURE, UV);
    COLOR = mix(original, shimmer_color, shimmer_color.a);
}