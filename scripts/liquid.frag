#version 330 core

uniform vec2 resolution;
uniform vec2 orbit;
uniform vec2 seed_offset;
uniform float speed;
uniform float intensity;
uniform float grain;
uniform float softness;
uniform int color_count;
uniform vec3 palette[6];
out vec4 pixel;

float hash(vec2 p) {
    vec3 q = fract(p.xyx * vec3(0.1031, 0.1030, 0.0973));
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

float noise(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    // Quintic interpolation keeps derivatives continuous across lattice cells.
    vec2 w = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    return mix(
        mix(hash(cell), hash(cell + vec2(1.0, 0.0)), w.x),
        mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0)), w.x),
        w.y
    );
}

float fbm(vec2 p) {
    mat2 turn = mat2(1.6, 1.2, -1.2, 1.6);
    return 0.62 * noise(p) + 0.26 * noise(turn * p) + 0.12 * noise(turn * turn * p);
}

vec3 gradient(float t) {
    float position = clamp(t, 0.0, 1.0) * float(color_count - 1);
    int index = min(int(position), color_count - 2);
    return mix(palette[index], palette[index + 1], smoothstep(0.0, 1.0, position - float(index)));
}

void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    vec2 p = (uv - 0.5) * vec2(resolution.x / resolution.y, 1.0);
    vec2 path = orbit * (0.23 * speed);
    vec2 counter = vec2(-orbit.y, orbit.x) * (0.13 * speed);
    vec2 sample_point = p * 2.1 + seed_offset;
    vec2 warp = vec2(fbm(sample_point + path), fbm(sample_point + counter + 9.71)) - 0.5;
    vec2 fold = vec2(fbm(sample_point + warp * 2.0 + counter - 5.0),
                     fbm(sample_point + warp * 1.7 - path + 6.8)) - 0.5;
    vec2 surface = p + intensity * (warp * 0.75 + fold * 0.47);
    float sweep = dot(surface, vec2(0.64, -0.92)) + 0.24 * path.x;
    float folds = sin(8.5 * sweep + 3.2 * fbm(sample_point + fold * 2.1 + path));
    float broad = fbm(surface * 2.7 + seed_offset - counter);
    float width = mix(0.16, 0.67, softness);
    float wash = smoothstep(-width, width, folds);
    float ridge = (folds - 0.18) / (0.20 + 0.55 * softness);
    float sheen = exp(-ridge * ridge);
    float strength = 0.13 + 0.46 * broad + 0.22 * wash + 0.12 * sheen;

    // Keep the login area subdued while retaining color at the edges.
    float center = exp(-4.1 * dot(p * vec2(1.25, 1.0), p));
    vec3 color = mix(palette[0], gradient(strength), 0.60 - 0.34 * center);
    color += (hash(gl_FragCoord.xy + seed_offset * 171.0) - 0.5) * (0.075 * grain);
    pixel = vec4(clamp(color, 0.0, 1.0), 1.0);
}
