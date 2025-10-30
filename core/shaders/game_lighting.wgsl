struct Uniform {
    light_color: vec4<f32>,
    light_strength: f32,
}

@group(0) @binding(0)
var<uniform> ubo: Uniform;

@group(1) @binding(0)
var filtering_sampler: sampler;
@group(1) @binding(1)
var nonfiltering_sampler: sampler;
@group(1) @binding(2)
var repeating_sampler: sampler;

@group(2) @binding(0)
var albedo_texture: texture_2d<f32>;
@group(2) @binding(1)
var normal_texture: texture_2d<f32>;
@group(2) @binding(2)
var model_pos_texture: texture_2d<f32>;

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

const TINT_DIR = vec3<f32>(0.3, 0.3, 0.65);

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let albedo = textureSample(albedo_texture, nonfiltering_sampler, in.uv).rgba;
    let normal = textureSample(normal_texture, nonfiltering_sampler, in.uv).xyz;
    let model_pos = textureSample(model_pos_texture, nonfiltering_sampler, in.uv).xyz;

    // model pos is relative to camera position
    let light_dir = normalize(vec3(0.0, 0.0, 1.0) - model_pos);

    let diff = round(smoothstep(0.0, 1.0, pow(clamp(dot(light_dir, normal) * 1.115, 0.0, 1.0), 1.75)) * 64.0) / 64.0;
    let tint = pow(max(0.0, dot(normal, normalize(TINT_DIR))), 32.0) * 4.0;

    let lighting = clamp(vec3(diff + tint), vec3(0.25, 0.21, 0.27), vec3(1.0)) * ubo.light_strength;

    return vec4(albedo.rgb * lighting, albedo.a);
}
