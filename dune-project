(lang dune 3.20)

(name opamui)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name opamui)
 (synopsis "TUI for listing OPAM packages")
 (description "A terminal user interface for browsing and searching OCaml OPAM packages")
 (depends
  ocaml
  dune
  (minttea (>= 0.0.1))
  (leaves (>= 0.0.1))
  (spices (>= 0.0.1))
  (lwt (>= 5.0.0)))
 (tags
  ("opam" "tui" "terminal" "packages")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
