@group(0) @binding(0)
var tex_sampler: sampler;
@group(0) @binding(1)
var textures: binding_array<texture_2d<f32>>;

@group(1) @binding(0)
var<uniform> texture_len: u32;

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

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    var r = textureSample(textures[0], tex_sampler, in.uv);

    for (var i = 1u; i < texture_len; i++) {
        let o = textureSample(textures[i], tex_sampler, in.uv);

        r = r * (1.0 - o.a) + o;
    }

    return r;
}
