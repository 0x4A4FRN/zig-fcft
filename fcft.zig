const pixman = @import("pixman");

pub const Error = error{
    NoFont,
    NoGlyph,
    NoGrapheme,
    NoTextRun,
};

// Note that this is ignored if antialiasing has been disabled.
pub const Subpixel = enum(c_int) {
    default,
    none,
    horizontal_rgb,
    horizontal_bgr,
    vertical_rgb,
    vertical_bgr,
};

pub const Glyph = extern struct {
    cp: u32,
    cols: c_int,

    // Name of the font the glyph was loaded from.
    // Note that it is always null in text-runs glyphs.
    font_name: ?[*:0]const u8,
    pix: *pixman.Image,

    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,

    advance: extern struct {
        x: c_int,
        y: c_int,
    },

    // To be blended, instead of used as mask
    is_color_glyph: bool,
};

pub const Grapheme = extern struct {
    cols: c_int,
    count: usize,
    glyphs: [*]*const Glyph,
};

pub const TextRun = extern struct {
    glyphs: [*]*const Glyph,
    cluster: [*]c_int,
    count: usize,

    extern fn fcft_text_run_destroy(text_run: *const TextRun) void;
    pub const destroy = fcft_text_run_destroy;
};

pub const Font = extern struct {
    // Name of the primary font only.
    name: ?[*:0]const u8,

    height: c_int,
    descent: c_int,
    ascent: c_int,

    // Width/height of font's widest glyph.
    max_advance: extern struct {
        x: c_int,
        y: c_int,
    },

    underline: extern struct {
        position: c_int,
        thickness: c_int,
    },

    strikeout: extern struct {
        position: c_int,
        thickness: c_int,
    },

    antialias: bool,

    subpixel: Subpixel,

    extern fn fcft_from_name(
        count: usize,
        names: [*][*:0]const u8,
        attributes: ?[*:0]const u8,
    ) ?*Font;
    pub fn fromName(names: [][*:0]const u8, attributes: ?[*:0]const u8) !*Font {
        return fcft_from_name(names.len, names.ptr, attributes) orelse error.NoFont;
    }

    extern fn fcft_clone(font: *const Font) ?*Font;
    pub const clone = fcft_clone;

    extern fn fcft_destroy(font: *Font) void;
    pub const destroy = fcft_destroy;

    extern fn fcft_rasterize_char_utf32(font: *Font, cp: u32, subpixel: Subpixel) ?*const Glyph;
    pub fn rasterizeCharUtf32(font: *Font, cp: u32, subpixel: Subpixel) !*const Glyph {
        return fcft_rasterize_char_utf32(font, cp, subpixel) orelse error.NoGlyph;
    }

    extern fn fcft_rasterize_grapheme_utf32(
        font: *Font,
        len: usize,
        grapheme_cluster: [*]const u32,
        subpixel: Subpixel,
    ) ?*const Grapheme;
    pub fn rasterizeGraphemeUtf32(
        font: *Font,
        grapheme_cluster: []const u32,
        subpixel: Subpixel,
    ) !*const Grapheme {
        return fcft_rasterize_grapheme_utf32(
            font,
            grapheme_cluster.len,
            grapheme_cluster.ptr,
            subpixel,
        ) orelse error.NoGrapheme;
    }

    extern fn fcft_rasterize_text_run_utf32(
        font: *Font,
        len: usize,
        text: [*]const u32,
        subpixel: Subpixel,
    ) ?*const TextRun;
    pub fn rasterizeTextRunUtf32(font: *Font, text: []const u32, subpixel: Subpixel) !*const TextRun {
        return fcft_rasterize_text_run_utf32(font, text.len, text.ptr, subpixel) orelse error.NoTextRun;
    }

    extern fn fcft_kerning(
        font: *Font,
        left: u32,
        right: u32,
        noalias x: ?*c_long,
        noalias y: ?*c_long,
    ) bool;
    pub const kerning = fcft_kerning;

    extern fn fcft_precompose(
        font: *const Font,
        base: u32,
        comb: u32,
        base_is_from_primary: bool,
        comb_is_from_primary: bool,
        composed_is_from_primary: bool,
    ) u32;
    pub const precompose = fcft_precompose;

    // DEPRECATED in 3.2.0
    // Note: this function does not clear the glyph or grapheme caches, call
    // before rasterizing any glyphs.
    extern fn fcft_set_emoji_presentation(font: *Font, presentation: EmojiPresentation) void;
    pub const setEmojiPresentation = fcft_set_emoji_presentation;
};

pub const EmojiPresentation = enum(c_int) {
    default,
    text,
    emoji,
};

pub const ScalingFilter = enum(c_int) {
    none,
    nearest,
    bilinear,
    // Separable convolution filters
    cubic,
    lanczos3,
    // ADDED in 3.3.0
    impulse,
    box,
    linear,
    gaussian,
    lanczos2,
    lanczos3_stretched,
};

// ADDED in 3.2.0
pub const FontOptions = extern struct {
    emoji_presentation: EmojiPresentation,
    color_glyphs: extern struct {
        srgb_decode: bool,
        format: pixman.FormatCode,
    },
    scaling_filter: ScalingFilter,

    extern fn fcft_font_options_create() *FontOptions;
    pub const create = fcft_font_options_create;

    extern fn fcft_font_options_destroy(options: *FontOptions) void;
    pub const destroy = fcft_font_options_destroy;

    extern fn fcft_from_name2(
        count: usize,
        names: [*][*:0]const u8,
        attributes: ?[*:0]const u8,
        options: *const FontOptions,
    ) ?*Font;
    pub fn fromName2(options: *const FontOptions, names: [][*:0]const u8, attributes: ?[*:0]const u8) !*Font {
        return fcft_from_name2(names.len, names.ptr, attributes, options) orelse error.NoFont;
    }
};

pub const LogColorize = enum(c_int) {
    never,
    always,
    auto,
};

pub const LogClass = enum(c_int) {
    none,
    err,
    warning,
    info,
    debug,
};

// Must be called before instantiating fonts.
extern fn fcft_init(colorize: LogColorize, do_syslog: bool, log_level: LogClass) bool;
pub const init = fcft_init;

// Optional, but needed for clean valgrind runs.
extern fn fcft_fini() void;
pub const fini = fcft_fini;

pub const Capabilities = struct {
    pub const grapheme_shaping = 1 << 0;
    pub const text_run_shaping = 1 << 1;
    pub const svg = 1 << 2;
};

extern fn fcft_capabilities() u32;
pub const capabilities = fcft_capabilities;

// DEPRECATED in 3.3.0
// Note: this function does not clear any caches, call before
// rasterizing any glyphs.
extern fn fcft_set_scaling_filter(filter: ScalingFilter) bool;
pub const setScalingFilter = fcft_set_scaling_filter;
