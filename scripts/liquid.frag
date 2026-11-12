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
    vec2 p = (gl_FragCoord.xy / resolution - 0.5) * vec2(resolution.x / resolution.y, 1.0);
    vec2 path = orbit * (0.25 * speed);
    vec2 counter = vec2(-orbit.y, orbit.x) * (0.17 * speed);
    vec2 sample_point = p * 2.8 + seed_offset;
    vec2 flow = vec2(fbm(sample_point + path), fbm(sample_point + counter + 8.7)) - 0.5;
    vec2 q = p + flow * (0.34 * intensity);
    q += vec2(path.x, counter.x) * 0.16;

    // Each sheet has a rounded cross-section and changing width along its centerline.
    float top = q.y - (0.31 + 0.13 * sin(4.3 * q.x + path.x)
                       + 0.10 * sin(7.2 * q.x - path.y + seed_offset.x));
    float bottom = q.y - (-0.32 + 0.14 * sin(3.9 * q.x - counter.x + 0.7)
                          - 0.09 * sin(8.4 * q.x + path.y + seed_offset.y));
    top /= 0.068 + 0.110 * fbm(vec2(q.x * 3.3, 4.2) + seed_offset + path);
    bottom /= 0.055 + 0.089 * fbm(vec2(q.x * 4.0, 7.3) + seed_offset - counter);
    vec2 top_gradient = vec2(dFdx(top), dFdy(top));
    vec2 bottom_gradient = vec2(dFdx(bottom), dFdy(bottom));
    bool front = abs(top) < abs(bottom);
    float across = front ? top : bottom;
    vec2 contour_gradient = front ? top_gradient : bottom_gradient;
    float aa = max(length(contour_gradient), 0.0001);
    float mask = 1.0 - smoothstep(1.0 - 1.4 * aa, 1.0 + 1.4 * aa, abs(across));
    vec2 sideways = contour_gradient / aa;
    vec2 along = vec2(-sideways.y, sideways.x);
    float cross = clamp(across, -1.0, 1.0);
    float dome = sqrt(max(0.0, 1.0 - cross * cross));
    vec2 bend = 0.34 * (sideways * sin(8.2 * q.x + path.x)
                        + along * sin(5.2 * q.x + 3.7 * q.y + path.y));
    vec3 normal = normalize(vec3(sideways * cross + bend * dome, max(dome, 0.001)));
    vec3 reflected = reflect(vec3(0.0, 0.0, -1.0), normal);

    // Simulated strip lights reflected by the surface, with dark space between them.
    float light = dot(reflected, normalize(vec3(0.30, 0.83, 0.47)));
    float edge_light = dot(reflected, normalize(vec3(-0.66, 0.49, 0.43)));
    float blur = mix(0.8, 1.8, softness);
    float broad = 0.52 * smoothstep(-0.48, 0.90, light)
                  + 0.18 * smoothstep(-0.36, 0.82, edge_light);
    float strip_distance = abs(light - 0.38);
    float stripe = exp(-pow(strip_distance / (0.12 * blur), 2.0));
    float fill = exp(-pow(abs(edge_light + 0.49) / (0.12 * blur), 2.0));
    float edge = 0.09 * smoothstep(0.79, 0.995, abs(cross));
    float energy = 0.05 + broad + 0.58 * stripe + 0.37 * fill + edge;
    float reflected_light = 1.0 - exp(-1.65 * energy);
    vec3 metal = gradient(reflected_light) * mix(0.40, 1.0, reflected_light);
    vec3 highlight = palette[color_count - 1];
    float white_level = max(highlight.r, max(highlight.g, highlight.b));
    vec3 strip_color = mix(vec3(white_level), highlight, 0.17);
    float strip_core = exp(-pow(strip_distance / (0.040 * blur), 2.0));
    strip_core *= 1.0 - smoothstep(0.74, 0.98, abs(cross));
    metal = mix(metal, strip_color, 0.96 * strip_core);
    float center = exp(-6.0 * dot(p * vec2(1.2, 1.0), p));
    vec3 background = palette[0] * (0.44 - 0.22 * center);
    vec3 color = mix(background, metal * (1.0 - 0.42 * center), mask);
    color += (hash(gl_FragCoord.xy + seed_offset * 171.0) - 0.5) * (0.039 * grain);
    pixel = vec4(clamp(color, 0.0, 1.0), 1.0);
}
