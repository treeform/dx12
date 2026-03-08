<img src="docs/dx12Banner.svg">

# dx12 - DirectX 12 wrapper for Nim on Windows.

`nimby install dx12`

![Build](https://img.shields.io/badge/build-Github%20Actions-blue)
![Language](https://img.shields.io/badge/language-Nim-ffc200)
![Platform](https://img.shields.io/badge/platform-Windows-0078d4)
![License](https://img.shields.io/badge/license-MIT-green)

[API reference](https://treeform.github.io/dx12)

## About

`dx12` is a Windows-focused DirectX 12 wrapper for Nim.
It provides the low-level DXGI and D3D12 types, constants, COM wrappers, and
small context helpers used by the examples in this repository.

The library package itself depends on `windy` for Win32 handle types.
Some examples also depend on sibling graphics libraries such as `pixie` and
`vmath`, which are not required to import the core `dx12` module.

## Documentation

API docs are generated from `src/dx12.nim` by
`.github/workflows/docs.yml`.

## Examples

The `examples/` directory includes:

- Basic triangle and shader examples.
- Textured quad and textured cube examples.
- A sprite sheet batcher example.
- An OBJ viewer example.

The examples are intended for local development in a multi-repo workspace.
See `examples/nim.cfg` for the extra example-only paths used during
development.

### Example Screenshots

#### `basic_screen`

![basic_screen](docs/basic_screen.png)

#### `basic_triangle`

![basic_triangle](docs/basic_triangle.png)

#### `basic_quad`

![basic_quad](docs/basic_quad.png)

#### `basic_cube`

![basic_cube](docs/basic_cube.png)

#### `spritesheet`

![spritesheet](docs/spritesheet.png)

#### `viewer_obj`

![viewer_obj](docs/viewer_obj.png)

## Notes

- This project is intended to build and test on Windows.
- The package surface is `import dx12` and `import dx12/context`.
- The `headers/` and `tools/` directories are kept in the repo for wrapper
  maintenance and experiments.
