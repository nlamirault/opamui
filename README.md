# OpamUI

A Terminal User Interface (TUI) for browsing and searching OCaml OPAM packages.

## Features

- **Browse Packages**: View all available OPAM packages in your repository
- **Search**: Type to filter packages by name in real-time
- **Installed Status**: Quickly see which packages are already installed (marked with ✓)
- **Navigation**: Use arrow keys to navigate through the package list
- **Scrolling**: Automatic scrolling for large package lists

### Prerequisites

- OCaml >= 5.1
- Dune >= 3.11
- OPAM package manager

### Key Bindings

| Key                  | Action                            |
| -------------------- | --------------------------------- |
| `↑` / `↓`            | Navigate up/down through packages |
| `Type`               | Search/filter packages by name    |
| `Backspace`          | Delete last character in search   |
| `Esc`                | Clear search and reset            |
| `q` / `Q` / `Ctrl+C` | Quit the application              |

## Future Enhancements

Potential features to add:

- [ ] Package details view (press Enter on a package)
- [ ] Install/remove packages directly from TUI
- [ ] Multiple column layout
- [ ] Sort options (name, installed, version)
- [ ] Show package dependencies
- [ ] Show package authors and maintainers
- [ ] Export filtered list
- [ ] Configuration file support

## Contributing

See CONTRIBUTING file for details

## License

See LICENSE file for details.
