@group(0) @binding(0)
var filtering_sampler: sampler;
@group(0) @binding(1)
var nonfiltering_sampler: sampler;
@group(0) @binding(2)
var repeating_sampler: sampler;
@group(0) @binding(3)
var frame_texture: texture_2d<f32>;
@group(0) @binding(4)
var normal_texture: texture_2d<f32>;
@group(0) @binding(5)
var model_depth_texture: texture_2d<f32>;

const FLAG_SCREEN_EFFECT: u32 = 1;

struct Uniform {
    flags: vec4<u32>,
}

@group(1) @binding(0)
var<uniform> ubo: Uniform;

struct VertexInput {
    @builtin(vertex_index) idx: u32,
}

struct VertexOutput {
    @builtin(position) pos: vec4<f32>,
    @location(0) uv: vec2<f32>,
}

@vertex
fn vs_main(
    in: VertexInput,
) -> VertexOutput {
    var out: VertexOutput;

    let uv = vec2(
        f32((in.idx << 1u) & 2u),
        f32(in.idx & 2u)
    );

    out.pos = vec4(uv * 2.0 - 1.0, 0.0, 1.0);
    out.uv = vec2(uv.x, 1.0 - uv.y);

    return out;
}

fn depth_edge(uv: vec2<f32>) -> vec3<f32> {
    let texture_dim = vec2<f32>(textureDimensions(model_depth_texture));
    let texel_size = 1.0 / texture_dim;

    let  c = textureSample(model_depth_texture, nonfiltering_sampler, uv).x;
    let  n = textureSample(model_depth_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, 0.0)).x;
    let  s = textureSample(model_depth_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(1.0, 0.0)).x;
    let  w = textureSample(model_depth_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(0.0, -1.0)).x;
    let  e = textureSample(model_depth_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(0.0, 1.0)).x;

    let nw = textureSample(model_depth_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, -1.0)).x;
    let ne = textureSample(model_depth_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, 1.0)).x;
    let sw = textureSample(model_depth_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(1.0, -1.0)).x;
    let se = textureSample(model_depth_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(1.0, 1.0)).x;

    let edges = (abs(n - c) + abs(s - c) + abs(w - c) + abs(e - c)) / 4.0;
    let diags = (abs(nw - c) + abs(ne - c) + abs(sw - c) + abs(se - c)) / 4.0;
    let diff = edges + diags;

    if diff > 0.325 {
        return vec3(1.0 - diff * 0.825);
    }

    return vec3(1.0);
}

fn normal_edge(uv: vec2<f32>) -> vec3<f32> {
    let texture_dim = vec2<f32>(textureDimensions(normal_texture));
    let texel_size = 1.0 / texture_dim;

    let  c = textureSample(normal_texture, nonfiltering_sampler, uv).xyz;
    let  n = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, 0.0)).xyz;
    let  s = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(1.0, 0.0)).xyz;
    let  w = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(0.0, -1.0)).xyz;
    let  e = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(0.0, 1.0)).xyz;

    let nw = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, -1.0)).xyz;
    let ne = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, 1.0)).xyz;
    let sw = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(1.0, -1.0)).xyz;
    let se = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(1.0, 1.0)).xyz;

    let edges = (acos(dot(n, c)) + acos(dot(s, c)) + acos(dot(w, c)) + acos(dot(e, c))) / 4.0;
    let diags = (acos(dot(nw, c)) + acos(dot(ne, c)) + acos(dot(sw, c)) + acos(dot(se, c))) / 4.0;
    let diff = edges + diags;
    if diff > 0.65 {
        return vec3(1.0 + diff * 0.35);
    }

    return vec3(1.0);
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let texture_dim = vec2<f32>(textureDimensions(frame_texture));
    let texel_size = 1.0 / texture_dim;

    let distance_vector = in.uv - vec2(0.5);
    let distance = dot(distance_vector, distance_vector);
    let offset_strength = 0.005 * smoothstep(0.0, 1.0, distance);

    let color = textureSample(frame_texture, filtering_sampler, in.uv);

    let screen_effect_enabled = f32((ubo.flags.x & FLAG_SCREEN_EFFECT) != 0);

    let edge_darken = (1.0 - screen_effect_enabled) + screen_effect_enabled * smoothstep(0.0, 1.0, (1.0 - distance)) * 0.5;
    let chroma_abbr = screen_effect_enabled * vec4(
        textureSample(frame_texture, filtering_sampler, in.uv + vec2<f32>(offset_strength, -offset_strength)).r,
        textureSample(frame_texture, filtering_sampler, in.uv + vec2<f32>(-offset_strength, 0.0)).g,
        textureSample(frame_texture, filtering_sampler, in.uv + vec2<f32>(0.0, offset_strength)).b,
        0.0
    );

    return (color + chroma_abbr) * vec4(vec3(edge_darken) * depth_edge(in.uv) * normal_edge(in.uv), 1.0);
}