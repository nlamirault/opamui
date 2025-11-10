# OpamUI

A Terminal User Interface (TUI) for browsing and searching OCaml OPAM packages.

## Features

- **Browse Packages**: View all available OPAM packages in your repository
- **Search**: Type to filter packages by name in real-time
- **Installed Status**: Quickly see which packages are already installed (marked with ✓)
- **Navigation**: Use arrow keys to navigate through the package list
- **Scrolling**: Automatic scrolling for large package lists

## Installation

### Prerequisites

- OCaml >= 5.1
- Dune >= 3.11
- OPAM package manager

### Dependencies

```bash
opam install minttea leaves spices lwt
```

### Build

```bash
dune build
```

### Install

```bash
dune install
```

## Usage

Simply run the application:

```bash
opamui
```

Or directly with dune:

```bash
dune exec opamui
```

### Key Bindings

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate up/down through packages |
| `Type` | Search/filter packages by name |
| `Backspace` | Delete last character in search |
| `Esc` | Clear search and reset |
| `q` / `Q` / `Ctrl+C` | Quit the application |

## Architecture

The application follows the Elm Architecture pattern using the Minttea framework:

- **Model**: Represents the application state (packages, filters, selection)
- **Update**: Handles user input and state transitions
- **View**: Renders the UI based on current state

### Project Structure

```
opamui/
├── bin/
│   └── main.ml          # Application entry point
├── lib/
│   ├── opam_client.ml   # OPAM package data fetching
│   ├── opam_client.mli
│   ├── ui.ml            # TUI implementation
│   ├── ui.mli
│   └── dune
├── test/
│   └── test_opamui.ml   # Tests
├── dune-project
└── README.md
```

## Development

### Run Tests

```bash
dune runtest
```

### Format Code

```bash
dune build @fmt --auto-promote
```

### Clean Build

```bash
dune clean
```

## Technical Details

### Libraries Used

- **minttea**: Elm-like TUI framework for OCaml
- **spices**: Terminal styling and colors
- **leaves**: TUI rendering components
- **lwt**: Promises and async operations

### Data Flow

1. **Initialization**: Fetches package list from OPAM using system commands
2. **Rendering**: Displays packages with styling (installed packages highlighted)
3. **User Input**: Processes keyboard events and updates state
4. **Filtering**: Real-time search filtering as you type

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

Contributions are welcome! Please ensure:

1. Code follows OCaml best practices
2. Tests are added for new features
3. Documentation is updated

## License

See LICENSE file for details.

## Acknowledgments

Inspired by [github-tui](https://github.com/chshersh/github-tui) and built with the excellent [Minttea](https://github.com/leostera/minttea) framework.
