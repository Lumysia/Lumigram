load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "LumigramUI",
    module_name = "LumigramUI",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Display:Display",
        "//submodules/TelegramPresentationData:TelegramPresentationData",
        "//submodules/ItemListUI:ItemListUI",
        "//submodules/AccountContext:AccountContext",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//Lumigram/LumigramCore:LumigramCore",
    ],
    visibility = [
        "//visibility:public",
    ],
)
