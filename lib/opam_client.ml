open Lwt.Syntax

type package = {
  name : string;
  version : string;
  synopsis : string;
  installed : bool;
}

(* Unused function - kept for reference *)
[@@@warning "-32"]
let _parse_package_line line =
  try
    (* OPAM list format: "name.version  synopsis" or "# name.version  synopsis" for installed *)
    let installed = String.length line > 0 && line.[0] = '#' in
    let line = if installed then String.sub line 2 (String.length line - 2) else line in
    let trimmed = String.trim line in

    (* Split by whitespace *)
    match String.split_on_char ' ' trimmed |> List.filter (fun s -> s <> "") with
    | name_version :: synopsis_parts ->
        (* Split name and version *)
        (match String.split_on_char '.' name_version with
        | [] -> None
        | [name] ->
            Some { name; version = ""; synopsis = String.concat " " synopsis_parts; installed }
        | parts ->
            let name = String.concat "." (List.rev parts |> List.tl |> List.rev) in
            let version = List.rev parts |> List.hd in
            Some { name; version; synopsis = String.concat " " synopsis_parts; installed })
    | [] -> None
  with _ -> None
[@@@warning "+32"]

let get_installed_packages () =
  let* status = Lwt_unix.system "opam list --installed --short > /tmp/opamui_installed.txt 2>&1" in
  match status with
  | Unix.WEXITED 0 ->
      let* ic = Lwt_io.open_file ~mode:Lwt_io.Input "/tmp/opamui_installed.txt" in
      let* lines = Lwt_io.read_lines ic |> Lwt_stream.to_list in
      let* () = Lwt_io.close ic in
      let installed_set =
        lines
        |> List.filter_map (fun line ->
            match String.split_on_char '.' (String.trim line) with
            | [] -> None
            | [name] -> Some name
            | parts -> Some (String.concat "." (List.rev parts |> List.tl |> List.rev)))
        |> List.fold_left (fun acc name -> Hashtbl.add acc name true; acc) (Hashtbl.create 100)
      in
      Lwt.return installed_set
  | _ ->
      Lwt.return (Hashtbl.create 0)

let get_all_packages () =
  let* installed_set = get_installed_packages () in
  let* status = Lwt_unix.system "opam list --all-versions --short --columns=name,version,synopsis > /tmp/opamui_all.txt 2>&1" in
  match status with
  | Unix.WEXITED 0 ->
      let* ic = Lwt_io.open_file ~mode:Lwt_io.Input "/tmp/opamui_all.txt" in
      let* lines = Lwt_io.read_lines ic |> Lwt_stream.to_list in
      let* () = Lwt_io.close ic in
      let packages = lines |> List.filter_map (fun line ->
        let trimmed = String.trim line in
        if trimmed = "" || trimmed.[0] = '#' then None
        else
          match String.split_on_char ' ' trimmed |> List.filter (fun s -> s <> "") with
          | name :: version :: synopsis_parts ->
              let synopsis = String.concat " " synopsis_parts in
              let installed = Hashtbl.mem installed_set name in
              Some { name; version; synopsis; installed }
          | _ -> None
      ) in
      Lwt.return packages
  | _ ->
      Lwt.return []
