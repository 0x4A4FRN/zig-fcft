const pixman = @import("pixman");

pub const Error = error {
    Generic,
};

pub const Subpixel = extern enum {
    default,
    none,
    horizontal_rgb,
    horizontal_bgr,
    vertical_rgb,
    vertical_bgr,
};

pub const Font = extern struct {
    height: c_int,
    descent: c_int,
    ascent: c_int,

    max_advance: extern struct { x: c_int, y: c_int },
    space_advance: extern struct { x: c_int, y: c_int },
    underline: extern struct { position: c_int, thickness: c_int },
    strikeout: extern struct { position: c_int, thickness: c_int },

    antialias: bool,

    subpixel: Subpixel,

    extern fn fcft_from_name(count: usize, names: [*][*:0]const u8, attributes: ?[*:0]u8) ?*Font;
    pub fn fromName(names: [][*:0]const u8, attributes: ?[*:0]u8) !*Font {
        const res = fcft_from_name(names.len, names.ptr, attributes);
        return if (res) |font| font else error.Generic;
    }

    extern fn fcft_clone(self: *const Font) ?*Font;
    pub const clone = fcft_clone;

    extern fn fcft_destroy(self: *Font) void;
    pub const destroy = fcft_destroy;
};

pub const Capabilities = extern enum {
    grapheme_shaping = 0x1,
    text_run_shaping = 0x2,
};

pub const Glyph = extern struct {
    wc: c_int,
    cols: c_int,

    pix: *pixman.Image,

    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,

    advance: extern struct { x: c_int, y: c_int },

    extern fn fcft_glyph_rasterize(font: *Font, wc: c_int, subpixel: Subpixel) ?*Glyph;
    pub fn rasterize(font: *Font, wc: c_int, subpixel: Subpixel) !*Glyph {
        const res = fcft_glyph_rasterize(font, wc, subpixel);
        return if (res) |glyph| glyph else error.Generic;
    }
};

pub const Grapheme = extern struct {
    cols: c_int,

    count: usize,
    glyphs: [*]const *Glyph,

    extern fn fcft_grapheme_rasterize(font: *Font, len: usize, grapheme_cluster: [*]const c_int, tag_count: usize, tags: [*]const Tag, subpixel: Subpixel) ?*Grapheme;
    pub fn rasterize(font: *Font, grapheme_cluster: []const c_int, tags: []const Tag, subpixel: Subpixel) !*Grapheme {
        const res = fcft_grapheme_rasterize(font, grapheme_cluster.len, grapheme_cluster.ptr, tags.len, tags.ptr, subpixel);
        return if (res) |grapheme| grapheme else error.Generic;
    }
};

pub const Tag = extern struct {
    tag: [4]u8,
    value: c_uint,
};

pub const TextRun = extern struct {
    glyphs: [*]const *Glyph,
    cluster: [*]c_int,
    count: usize,

    extern fn fcft_text_run_rasterize(font: *Font, len: usize, text: [*]const c_int, subpixel: Subpixel) ?*TextRun;
    pub fn rasterize(font: *Font, text: []const c_int, subpixel: Subpixel) !*TextRun {
        const res = fcft_text_run_rasterize(font, text.len, text.ptr, subpixel);
        return if (res) |run| run else error.Generic;
    }

    extern fn fcft_text_run_destroy(run: *TextRun) void;
    pub const destroy = fcft_text_run_destroy;
};

extern fn fcft_kerning(font: *Font, left: c_int, right: c_int, noalias x: ?*c_long, noalias y: ?*c_long) bool;
pub const kerning = fcft_kerning;

extern fn fcft_precompose(font: *const Font, base: c_int, comb: c_int, base_is_from_primary: bool, comb_is_from_primary: bool, composed_is_from_primary: bool) c_int;
pub const precompose = fcft_precompose;

pub const ScalingFilter = extern enum {
    none,
    nearest,
    bilinear,
    cubic,
    lanczos3,
};

extern fn fcft_set_scaling_filter(filter: ScalingFilter) bool;
pub const setScalingFilter = fcft_set_scaling_filter;

pub const LogColorize = extern enum {
    never,
    always,
    auto,
};

pub const LogClass = extern enum {
    none,
    err,
    warning,
    info,
    debug,
};

extern fn fcft_log_init(colorize: LogColorize, do_syslog: bool, log_level: LogClass) void;
pub const logInit = fcft_log_init;
