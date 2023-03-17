from conan import ConanFile


class iwasmcr_recipe(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeToolchain", "CMakeDeps"

    def requirements(self):
        self.requires("boost/1.81.0")
        self.requires("protobuf/3.21.9")
