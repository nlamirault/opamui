open Lwt.Syntax

let main () =
  let* () = Lwt_io.printl "Loading OPAM packages..." in
  let* packages = Opamui.Opam_client.get_all_packages () in
  let* () = Lwt_io.printlf "Loaded %d packages. Starting TUI..." (List.length packages) in
  if List.length packages = 0 then
    Lwt_io.printl "No packages found. Make sure OPAM is installed and initialized."
  else
    Opamui.Ui.run packages

let () =
  Lwt_main.run (main ())
