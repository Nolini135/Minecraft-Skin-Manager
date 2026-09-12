shader_type canvas_item;

uniform float radius : hint_range(0.01, 0.2) = 0.05;

uniform float ring_radius : hint_range(0.1, 1.0) = 0.35;

uniform float speed : hint_range(0.1, 10.0) = 1.0;

uniform int count : hint_range(1, 32) = 9;

uniform float fade_power : hint_range(1.0, 10.0) = 0.2;

uniform vec4 circle_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    
    vec2 uv = (UV - vec2(0.5)) * 2.0;
    float alpha = 0.0;
    
    float head = fract(TIME * speed) * float(count);


    for (int i = 0; i < count; i++) {
        
        float angle = float(i) * 2.0 * PI / float(count);

        vec2 center = vec2(cos(angle), sin(angle)) * ring_radius;

        float dist = distance(uv, center);

        float circle = smoothstep(radius, radius - 0.01, dist);

        float offset = mod(float(i) - head + float(count), float(count));

        float fade = 1.0 - exp(-fade_power * (1.0 - offset / float(count)));

        fade = 1.0 - fade;

        alpha += circle * fade;
    }


    COLOR = vec4(circle_color.rgb, alpha * circle_color.a);
}
