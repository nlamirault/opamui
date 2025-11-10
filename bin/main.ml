open Lwt.Syntax

let main () =
  let* () = Lwt_io.printl "Loading OPAM packages..." in
  let* packages = Opamui.Opam_client.get_all_packages () in
  let* opam_version = Opamui.Opam_client.get_opam_version () in
  let* opam_switch = Opamui.Opam_client.get_current_switch () in
  let* () =
    Lwt_io.printlf "Loaded %d packages. Starting TUI..." (List.length packages)
  in
  if List.length packages = 0 then
    Lwt_io.printl
      "No packages found. Make sure OPAM is installed and initialized."
  else Opamui.Ui.run packages opam_version opam_switch

let () = Lwt_main.run (main ())
