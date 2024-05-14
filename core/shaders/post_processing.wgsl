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
var model_texture: texture_2d<f32>;
@group(0) @binding(6)
var noise_texture: texture_2d<f32>;

struct Uniform {
    world_matrix: mat4x4<f32>,
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

const SSAO_NOISE_SIZE: f32 = 64.0;
const STEP_COUNT: f32 = 4.0;

fn depth_edge(uv: vec2<f32>) -> vec3<f32> {
    let texture_dim = vec2<f32>(textureDimensions(model_texture));
    let texel_size = 1.0 / texture_dim;

    let  c = textureSample(model_texture, nonfiltering_sampler, uv).z;
    let  n = textureSample(model_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, 0.0)).z;
    let  w = textureSample(model_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(0.0, -1.0)).z;
    let nw = textureSample(model_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, -1.0)).z;

    if max(max(c, n), max(w, nw)) < 0.01 {
        return vec3(1.0);
    }

    let diff = (abs(n - c) + abs(w - c) + abs(nw - c)) / 3.0;
    if diff > 0.23 {
        return vec3(0.05, 0.17, 0.15);
    }

    return vec3(1.0);
}

fn normal_edge(uv: vec2<f32>) -> vec3<f32> {
    let texture_dim = vec2<f32>(textureDimensions(normal_texture));
    let texel_size = 1.0 / texture_dim;

    let  c = textureSample(normal_texture, nonfiltering_sampler, uv).xyz;
    let  n = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, 0.0)).xyz;
    let  w = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(0.0, -1.0)).xyz;
    let nw = textureSample(normal_texture, nonfiltering_sampler, uv + texel_size * vec2<f32>(-1.0, -1.0)).xyz;

    let diff = (acos(dot(n, c)) + acos(dot(w, c)) + acos(dot(nw, c))) / 3.0;
    if diff > 0.1 {
        return vec3(1.25 + diff * 0.25);
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
    let edge_darken = smoothstep(0.0, 1.0, (1.0 - distance)) * 0.5;

    let color = textureSample(frame_texture, filtering_sampler, in.uv);
    let chroma_abbr = vec4(
        textureSample(frame_texture, filtering_sampler, in.uv + vec2<f32>(offset_strength, -offset_strength)).r,
        textureSample(frame_texture, filtering_sampler, in.uv + vec2<f32>(-offset_strength, 0.0)).g,
        textureSample(frame_texture, filtering_sampler, in.uv + vec2<f32>(0.0, offset_strength)).b,
        0.0
    );

    return (color + chroma_abbr) * vec4(vec3(edge_darken) * depth_edge(in.uv) * normal_edge(in.uv), 1.0);
}