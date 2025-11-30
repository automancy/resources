@group(0) @binding(0)
var frame_texture: texture_2d<f32>;
@group(0) @binding(1)
var frame_sampler: sampler;

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

const FXAA_SPAN_MAX: f32 = 4.0;
const FXAA_REDUCE_MIN: f32 = 0.0078125;
const FXAA_REDUCE_MUL: f32 = 0.125;

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let texel_size = 1.0 / vec2<f32>(textureDimensions(frame_texture));

    let ne = textureSample(frame_texture, frame_sampler, in.uv + texel_size * vec2(1.0, 1.0)).rgb;
    let nw = textureSample(frame_texture, frame_sampler, in.uv + texel_size * vec2(-1.0, 1.0)).rgb;
    let c = textureSample(frame_texture, frame_sampler, in.uv);
    let se = textureSample(frame_texture, frame_sampler, in.uv + texel_size * vec2(1.0, -1.0)).rgb;
    let sw = textureSample(frame_texture, frame_sampler, in.uv + texel_size * vec2(-1.0, -1.0)).rgb;

    let luma = vec3(0.299, 0.587, 0.114);
    let luma_ne = dot(ne, luma);
    let luma_nw = dot(nw, luma);
    let luma_c = dot(c.rgb, luma);
    let luma_se = dot(se, luma);
    let luma_sw = dot(sw, luma);

    let luma_min = min(luma_c, min(min(luma_nw, luma_ne), min(luma_sw, luma_se)));
    let luma_max = max(luma_c, max(max(luma_nw, luma_ne), max(luma_sw, luma_se)));

    let dir = vec2(
        -((luma_nw + luma_ne) - (luma_sw + luma_se)),
        ((luma_nw + luma_sw) - (luma_ne + luma_se)),
    );
    let dir_reduce = max(
        (luma_nw + luma_ne + luma_sw + luma_se) * (0.25 * FXAA_REDUCE_MUL),
        FXAA_REDUCE_MIN
    );
    let inv_dir_min = 1.0 / (min(abs(dir.x), abs(dir.y)) + dir_reduce);

    let texel_dir = clamp(dir * inv_dir_min, vec2(-FXAA_SPAN_MAX), vec2(FXAA_SPAN_MAX)) * texel_size;

    let rgb_a = 0.5 * (textureSample(frame_texture, frame_sampler, in.uv + texel_dir * (1.0 / 3.0 - 0.5)).rgb
        + textureSample(frame_texture, frame_sampler, in.uv + texel_dir * (2.0 / 3.0 - 0.5)).rgb);

    let rgb_b = rgb_a * 0.5 + 0.25 * (textureSample(frame_texture, frame_sampler, in.uv + texel_dir * -0.5).rgb
        + textureSample(frame_texture, frame_sampler, in.uv + texel_dir * 0.5).rgb);

    let luma_b = dot(rgb_b, luma);
    if (luma_b < luma_min) || (luma_b > luma_max) {
        return vec4(rgb_a, c.a);
    } else {
        return vec4(rgb_b, c.a);
    }
}
