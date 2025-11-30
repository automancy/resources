struct Uniform {
    camera_pos: vec3<f32>,
    camera_bounds: vec4<f32>,
}

struct ModelMatrixData {
    model_matrix: mat4x4<f32>,
}

struct WorldMatrixData {
    world_matrix: mat4x4<f32>,
}

struct AnimationMatrixData {
    animation_matrix: mat4x4<f32>,
}

@group(0) @binding(0)
var<uniform> ubo: Uniform;

@group(1) @binding(0)
var<storage, read> model_matrix_data: array<ModelMatrixData>;

@group(1) @binding(1)
var<storage, read> world_matrix_data: array<WorldMatrixData>;

@group(1) @binding(2)
var<storage, read> animation_matrix_data: array<AnimationMatrixData>;


struct VertexInput {
    @location(0) pos: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) color: vec4<f32>,
}

struct InstanceInput {
    @location(3) color_offset: vec4<f32>,
    @location(4) model_matrix_index: u32,
    @location(5) world_matrix_index: u32,
    @location(6) animation_matrix_index: u32,
}

struct VertexOutput {
    @builtin(position) pos: vec4<f32>,
    @location(0) albedo: vec4<f32>,
    @location(1) @interpolate(flat) normal: vec3<f32>,
    @location(2) model_pos: vec3<f32>,
}

@vertex
fn vs_main(
    in: VertexInput,
    instance: InstanceInput,
) -> VertexOutput {
    var out: VertexOutput;

    let mmd = model_matrix_data[instance.model_matrix_index];
    let wmd = world_matrix_data[instance.world_matrix_index];
    let amd = animation_matrix_data[instance.animation_matrix_index];

    let animation_matrix = amd.animation_matrix;

    let model_pos = mmd.model_matrix * animation_matrix * vec4(in.pos, 1.0);

    out.model_pos = model_pos.xyz / model_pos.w;
    out.pos = wmd.world_matrix * model_pos;
    out.normal = normalize(
        (mmd.model_matrix * animation_matrix * vec4(in.normal, 0.0)).xyz
    );

    out.albedo = vec4(mix(instance.color_offset.rgb, in.color.rgb, in.color.a - instance.color_offset.a), in.color.a);

    return out;
}

struct FragmentOutput {
    @location(0) albedo: vec4<f32>,
    @location(1) normal: vec4<f32>,
    @location(2) model_pos: vec4<f32>,
}

@fragment
fn fs_main(in: VertexOutput) -> FragmentOutput {
    var out: FragmentOutput;
    out.albedo = in.albedo;
    out.normal = vec4(in.normal, 0.0);

    let view_pos = ubo.camera_bounds.xy;
    let view_size = ubo.camera_bounds.zw - ubo.camera_bounds.xy;

    // [0~1]
    var model_xy = (in.model_pos.xy - view_pos) / view_size;
    model_xy = model_xy + (vec2(0.5) - (ubo.camera_pos.xy - view_pos) / view_size);

    // [-1~1]
    model_xy = model_xy * 2.0 - vec2(1.0);

    out.model_pos = vec4(
        model_xy,
        in.model_pos.z,
        0.0
    );
    return out;
}
