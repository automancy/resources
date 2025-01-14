struct Uniform {
    light_color: vec4<f32>,
    light_pos: vec4<f32>,
}

struct MatrixData {
    model_matrix: mat4x4<f32>,
    normal_matrix: mat3x3<f32>,
}

struct AnimationMatrixData {
    animation_matrix: mat4x4<f32>,
}

struct WorldMatrixData {
    world_matrix: mat4x4<f32>,
}

@group(0) @binding(0)
var<uniform> ubo: Uniform;

@group(0) @binding(1)
var<storage, read> matrix_data: array<MatrixData>;

@group(0) @binding(2)
var<storage, read> animation_matrix_data: array<AnimationMatrixData>;

@group(0) @binding(3)
var<storage, read> world_matrix_data: array<WorldMatrixData>;


struct VertexInput {
    @location(0) pos: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) color: vec4<f32>,
}

struct InstanceInput {
    @location(3) color_offset: vec4<f32>,
    @location(4) alpha: f32,
    @location(5) matrix_index: u32,
    @location(6) animation_matrix_index: u32,
    @location(7) world_matrix_index: u32,
}

struct VertexOutput {
    @builtin(position) pos: vec4<f32>,
    @location(0) @interpolate(flat) normal: vec3<f32>,
    @location(1) color: vec4<f32>,
    @location(2) model_pos: vec3<f32>,
}

@vertex
fn vs_main(
    in: VertexInput,
    instance: InstanceInput,
) -> VertexOutput {
    var out: VertexOutput;

    let m = matrix_data[instance.matrix_index];
    let model_matrix = m.model_matrix;
    let normal_matrix = m.normal_matrix;

    let wm = world_matrix_data[instance.world_matrix_index];
    let world_matrix = wm.world_matrix;

    let am = animation_matrix_data[instance.animation_matrix_index];
    let animation_matrix = am.animation_matrix;
    let animation_normal_matrix = mat3x3(
        animation_matrix.x.xyz,
        animation_matrix.y.xyz,
        animation_matrix.z.xyz,
    );

    let model_pos = model_matrix * animation_matrix * vec4(in.pos, 1.0);

    out.model_pos = model_pos.xyz / model_pos.w;
    out.pos = world_matrix * model_pos;
    out.normal = normalize(normal_matrix * animation_normal_matrix * in.normal);

    out.color = vec4(mix(instance.color_offset.rgb, in.color.rgb, in.color.a - instance.color_offset.a), instance.alpha * in.color.a);

    return out;
}

struct FragmentOutput {
    @location(0) color: vec4<f32>,
    @location(1) normal: vec4<f32>,
    @location(2) model_depth: f32,
}

const TINT_DIR = vec3<f32>(0.3, 0.3, 0.65);

@fragment
fn fs_main(in: VertexOutput) -> FragmentOutput {
    var light_pos = ubo.light_pos.xyz;
    light_pos.z = max(light_pos.z, 4.0);
    let light_dir = normalize(light_pos - in.model_pos);

    let diff = round(smoothstep(0.0, 1.0, pow(clamp(dot(light_dir, in.normal) * 1.115, 0.0, 1.0), 1.75)) * 64.0) / 64.0;
    let tint = pow(max(0.0, dot(in.normal, normalize(TINT_DIR))), 32.0) * 4.0;

    let lighting = clamp(vec3(diff + tint), vec3(0.25, 0.21, 0.27), vec3(1.0)) * ubo.light_pos.w;

    var out: FragmentOutput;
    out.color = vec4(in.color.rgb * lighting, in.color.a);
    out.normal = vec4(in.normal, 0.0);
    out.model_depth = in.model_pos.z;
    return out;
}
