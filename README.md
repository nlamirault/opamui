# OpamUI

A Terminal User Interface (TUI) for browsing and searching OCaml OPAM packages.

![opamui screenshot](assets/main-view.png)

## Features

- 🖥️ **Browse Packages**: Terminal-based UI to view all available OPAM packages in your repository
- 🔍 **Search**: Type to filter packages by name in real-time
- ✅ **Installed Status**: Quickly see which packages are already installed
- 🧭 **Navigation**: Use arrow keys to navigate through the package list
- 📜 **Scrolling**: Automatic scrolling for large package lists
- 📋 **Package Details**: Press Enter to view detailed information about any package

## Prerequisites

- OCaml >= 4.08
- Dune >= 3.20
- OPAM package manager

### Key Bindings

| Key                  | Action                                  |
| -------------------- | --------------------------------------- |
| `↑` / `↓`            | Navigate up/down through packages       |
| `Enter`              | View package details / Return to list   |
| `Type`               | Search/filter packages by name          |
| `Backspace`          | Delete last character OR return to list |
| `Esc`                | Clear search OR return to list          |
| `q` / `Q` / `Ctrl+C` | Quit the application                    |

## Future Enhancements

Potential features to add:

- [x] Package details view (press Enter on a package) ✨
- [ ] Install/remove packages directly from TUI
- [ ] Multiple column layout
- [ ] Sort options (name, installed, version)
- [ ] Show package dependencies
- [ ] Show package authors and maintainers
- [ ] Export filtered list
- [ ] Configuration file support
- [ ] Mouse support (Notty supports it!)

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) file for details

## License

See [LICENSE](LICENSE) file for details.
