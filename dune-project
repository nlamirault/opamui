(lang dune 3.20)

(name opamui)

(generate_opam_files true)

(source
 (github nlamirault/opamui))

(authors "Nicolas Lamirault <nicolas.lamirault@gmail.com>")

(maintainers "Nicolas Lamirault <nicolas.lamirault@gmail.com>")

(license Apache-2.0)

(documentation https://github.com/nlamirault/opamui)

(package
 (name opamui)
 (synopsis "TUI for listing OPAM packages")
 (description "A terminal user interface for browsing and searching OCaml OPAM packages")
 (depends
  ocaml
  dune
  (notty (>= 0.2.3))
  (terminal_size (>= 0.2.0))
  (lwt (>= 5.0.0))
  emoji)
 (tags
  ("opam" "tui" "terminal" "packages")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
