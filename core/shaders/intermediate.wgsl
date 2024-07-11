struct Uniform {
    viewport_size: vec2<f32>,
    viewport_pos: vec2<f32>,
}

@group(0) @binding(0)
var frame_texture: texture_2d<f32>;
@group(0) @binding(1)
var frame_sampler: sampler;
@group(0) @binding(2)
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

    let pos = uv * 2.0 - 1.0;
    out.pos = vec4(pos.x, -pos.y, 0.0, 1.0);

    out.uv = (ubo.viewport_pos + uv * ubo.viewport_size);

    return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return textureSample(frame_texture, frame_sampler, in.uv);
}