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

const FRACT_PI_2: f32 = 1.5707963267948966192313216916398;
const PI: f32 = 3.1415926535897932384626433832795;

fn lanczos(x: vec4<f32>) -> vec4<f32> {
    if dot(x, x) <= 0.1 {
        return vec4(PI * FRACT_PI_2);
    }

    return sin(x * PI) * sin(x * PI) / (x * x);
}

fn d(a: vec2<f32>, b: vec2<f32>) -> f32 {
    return length(a - b);
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let texture_dim = vec2<f32>(textureDimensions(frame_texture));
    let texel_size = 1.0 / texture_dim;

    var weights: mat4x4<f32>;

    let pc = in.uv * texture_dim;

    var dx = vec2(1.0, 0.0);
    var dy = vec2(0.0, 1.0);
    var tc = (floor(pc - vec2(0.5, 0.5)) + vec2(0.5, 0.5));

    weights[0] = lanczos(vec4(1.0, d(pc, tc - dy), d(pc, tc + dx - dy), 1.0));
    weights[1] = lanczos(vec4(d(pc, tc - dx), d(pc, tc), d(pc, tc + dx), d(pc, tc + 2.0 * dx)));
    weights[2] = lanczos(vec4(d(pc, tc - dx + dy), d(pc, tc + dy), d(pc, tc + dx + dy), d(pc, tc + 2.0 * dx + dy)));
    weights[3] = lanczos(vec4(1.0, d(pc, tc + 2.0 * dy), d(pc, tc + dx + 2.0 * dy), 1.0));

    dx = dx * texel_size;
    dy = dy * texel_size;
    tc = tc * texel_size;
 
    // reading the texels
    let c10 = textureSample(frame_texture, frame_sampler, tc - dy);
    let c20 = textureSample(frame_texture, frame_sampler, tc + dx - dy);
    let c01 = textureSample(frame_texture, frame_sampler, tc - dx);
    let c11 = textureSample(frame_texture, frame_sampler, tc);
    let c21 = textureSample(frame_texture, frame_sampler, tc + dx);
    let c31 = textureSample(frame_texture, frame_sampler, tc + 2.0 * dx);
    let c02 = textureSample(frame_texture, frame_sampler, tc - dx + dy);
    let c12 = textureSample(frame_texture, frame_sampler, tc + dy);
    let c22 = textureSample(frame_texture, frame_sampler, tc + dx + dy);
    let c32 = textureSample(frame_texture, frame_sampler, tc + 2.0 * dx + dy);
    let c13 = textureSample(frame_texture, frame_sampler, tc + 2.0 * dy);
    let c23 = textureSample(frame_texture, frame_sampler, tc + dx + 2.0 * dy);

    let o = vec4(0.0);
    var color = vec4(0.0);
    color += mat4x4(o, c10, c20, o) * weights[0];
    color += mat4x4(c01, c11, c21, c31) * weights[1];
    color += mat4x4(c02, c12, c22, c32) * weights[2];
    color += mat4x4(o, c13, c23, o) * weights[3];

    // final sum and weight normalization
    color /= dot(weights * vec4(1.0), vec4(1.0));

    return color;
}