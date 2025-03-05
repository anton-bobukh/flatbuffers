"""Provides Bazel build rules for FlatBuffers."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:types.bzl", "types")

################################## providers ###################################

def _init_flatbuffers_info(*, direct_sources = [], direct_schemas = [], transitive_sources = depset(), transitive_schemas = depset()):
    """_init_flatbuffers_info is a public constructor for FlatBuffersInfo."""
    if not types.is_list(direct_sources):
        fail("direct_sources must be a list (got %s)" % type(direct_sources))

    if not types.is_list(direct_schemas):
        fail("direct_schemas must be a list (got %s)" % type(direct_schemas))

    if not types.is_depset(transitive_sources):
        fail("transitive_sources must be a depset (got %s)" % type(transitive_sources))

    if not types.is_depset(transitive_schemas):
        fail("transitive_schemas must be a depset (got %s)" % type(transitive_schemas))

    return {
        "direct_sources": direct_sources,
        "direct_schemas": direct_schemas,
        "transitive_sources": transitive_sources,
        "transitive_schemas": transitive_schemas,
    }

FlatBuffersInfo, _new_flatbuffers_info = provider(
    doc = "Encapsulates information provided by flatbuffers_library.",
    fields = {
        "direct_sources": "FlatBuffers sources (i.e. .fbs) from the \"srcs\" attribute that contain text-based schema.",
        "direct_schemas": "The binary serialized schema files (i.e. .bfbs) of the direct sources.",
        "transitive_sources": "FlatBuffers sources (i.e. .fbs) for this and all its dependent FlatBuffers targets.",
        "transitive_schemas": "A set of binary serialized schema files (i.e. .bfbs) for this and all its dependent FlatBuffers targets.",
    },
    init = _init_flatbuffers_info,
)

def _create_flatbuffers_info(*, srcs, schemas, deps = None):
    deps = deps or []
    return FlatBuffersInfo(
        direct_sources = srcs,
        direct_schemas = schemas,
        transitive_sources = depset(
            direct = srcs,
            transitive = [dep[FlatBuffersInfo].transitive_sources for dep in deps],
        ),
        transitive_schemas = depset(
            direct = schemas,
            transitive = [dep[FlatBuffersInfo].transitive_schemas for dep in deps],
        ),
    )

#################################### attrs #####################################

_flatc_attr = {
    "_flatc": attr.label(
        default = Label("//:flatc"),
        executable = True,
        cfg = "exec",
    ),
}

################################### actions ####################################

def _compile(*, ctx, srcs, deps = None):
    """Emits an action that triggers the compilation of the provided .fbs files.

    Args:
        ctx: Starlark context that is used to emit actions.
        srcs: a list of .fbs files to compile.
        deps: an optional list of targets that provide FlatBuffersInfo.

    Returns:
        FlatBuffersInfo that contains the result of compiling srcs.
    """
    deps = deps or []
    transitive_sources = depset(
        direct = srcs,
        transitive = [dep[FlatBuffersInfo].transitive_sources for dep in deps],
    )

    generated_schemas = []
    for src in srcs:
        schema = ctx.actions.declare_file(paths.replace_extension(src.basename, "") + ".bfbs")
        generated_schemas.append(schema)

    args = ctx.actions.args()
    args.add("--binary")
    args.add("--schema")
    args.add("-I", ".")
    args.add("-I", ctx.bin_dir.path)
    args.add("-I", ctx.genfiles_dir.path)
    args.add("-o", paths.join(ctx.bin_dir.path, ctx.label.package))
    args.add_all(srcs)

    ctx.actions.run(
        executable = ctx.executable._flatc,
        inputs = transitive_sources,
        outputs = generated_schemas,
        arguments = [args],
        progress_message = "Generating schemas for {0}".format(ctx.label),
        mnemonic = "CompileFlatBuffers",
    )

    return _create_flatbuffers_info(
        srcs = srcs,
        schemas = generated_schemas,
        deps = deps,
    )

#################################### rules #####################################

def _flatbuffers_library_impl(ctx):
    flatbuffers_info = _compile(
        ctx = ctx,
        srcs = ctx.files.srcs,
        deps = ctx.attr.deps,
    )

    return [
        flatbuffers_info,
        DefaultInfo(
            files = depset(flatbuffers_info.direct_schemas),
            runfiles = ctx.runfiles(files = flatbuffers_info.direct_schemas),
        ),
    ]

flatbuffers_library = rule(
    doc = """\
Use `flatbuffers_library` to define libraries of FlatBuffers which may be used from multiple
languages. A `flatbuffers_library` may be used in `deps` of language-specific rules, such as
`cc_flatbuffers_library`.

A `flatbuffers_library` can also be used in `data` for any supported target. In this case, the
binary serialized schema (i.e. `.bfbs`) for files directly mentioned by a `flatbuffers_library`
target will be provided to the target at runtime.

The code should be organized in the following way:

-  one `flatbuffers_library` target per `.fbs` file;
-  a file named `foo.fbs` should be the only source for a target named `foo_fbs`, which is located
   in the same package;
-  a `[language]_flatbuffers_library` that wraps a `flatbuffers_library` named `foo_fbs` should be
   called `foo_[language]_fbs`, and be located in the same package.

Example:

```build
load("@com_github_google_flatbuffers//:flatbuffers.bzl", "cc_flatbuffers_library", "flatbuffers_library")

flatbuffers_library(
    name = "bar_fbs",
    srcs = ["bar.fbs"],
)

flatbuffers_library(
    name = "foo_fbs",
    srcs = ["foo.fbs"],
    deps = [":bar_fbs"],
)

cc_flatbuffers_library(
    name = "foo_cc_fbs",
    deps = [":foo_fbs"],
)
```

The following rules provide language-specific implementation of FlatBuffers:

-  `cc_flatbuffers_library`
-  `cc_lite_flatbuffers_library`
-  `kt_flatbuffers_library`""",
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".fbs"],
        ),
        "deps": attr.label_list(
            providers = [FlatBuffersInfo],
        ),
    } | _flatc_attr,
    provides = [FlatBuffersInfo],
    implementation = _flatbuffers_library_impl,
)

flatbuffers_common = struct(
    actions = struct(
        compile = _compile,
    ),
    attrs = _flatc_attr,
)
