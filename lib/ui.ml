open Lwt.Syntax
open Notty
open Notty_lwt

(* View mode *)
type view_mode =
  | List
  | Details

(* Model representing the application state *)
type model = {
  packages : Opam_client.package list;
  filtered_packages : Opam_client.package list;
  selected_idx : int;
  scroll_offset : int;
  search_text : string;
  terminal_height : int;
  terminal_width : int;
  view_mode : view_mode;
  running : bool;
}

(* Filter packages based on search text *)
let filter_packages packages search_text =
  if search_text = "" then packages
  else
    List.filter (fun pkg ->
      let open Opam_client in
      let name_lower = String.lowercase_ascii pkg.name in
      let search_lower = String.lowercase_ascii search_text in
      try
        let len = String.length search_lower in
        String.sub name_lower 0 len = search_lower
      with _ -> false
    ) packages

(* Initialize the model *)
let init_model packages =
  let width = match Terminal_size.get_columns () with
    | Some w -> w
    | None -> 80
  in
  let height = match Terminal_size.get_rows () with
    | Some h -> h
    | None -> 24
  in
  {
    packages;
    filtered_packages = packages;
    selected_idx = 0;
    scroll_offset = 0;
    search_text = "";
    terminal_height = height;
    terminal_width = width;
    view_mode = List;
    running = true;
  }

(* Calculate visible height for package list *)
let visible_height model =
  max 1 (model.terminal_height - 6)

(* Adjust scroll offset to keep selected item visible *)
let adjust_scroll_offset model =
  let vh = visible_height model in
  let scroll_offset =
    if model.selected_idx < model.scroll_offset then
      model.selected_idx
    else if model.selected_idx >= model.scroll_offset + vh then
      model.selected_idx - vh + 1
    else
      model.scroll_offset
  in
  let max_scroll = max 0 (List.length model.filtered_packages - vh) in
  { model with scroll_offset = max 0 (min scroll_offset max_scroll) }

(* Helper function to truncate string if too long *)
let truncate str max_len =
  if String.length str > max_len then
    String.sub str 0 (max_len - 3) ^ "..."
  else
    str

(* Render a single package line *)
let render_package ~selected ~width pkg =
  let open Opam_client in
  let status_icon = if pkg.installed then "✓" else " " in
  let name_width = 40 in
  let version_width = 15 in
  let synopsis_width = max 0 (width - name_width - version_width - 6) in

  let name = truncate pkg.name name_width in
  let version = truncate pkg.version version_width in
  let synopsis = truncate pkg.synopsis synopsis_width in

  let line = Printf.sprintf "[%s] %-40s %-15s %s" status_icon name version synopsis in

  let attr =
    if selected then
      A.(bg green ++ fg black ++ st bold)
    else if pkg.installed then
      A.(fg cyan ++ st bold)
    else
      A.empty
  in
  I.string attr line

(* Render package details view *)
let render_details model =
  let selected_pkg =
    try List.nth model.filtered_packages model.selected_idx
    with _ -> { Opam_client.name = ""; version = ""; synopsis = ""; installed = false }
  in
  let open Opam_client in

  let title_attr = A.(fg green ++ st bold ++ st underline) in
  let label_attr = A.(fg yellow ++ st bold) in
  let value_attr = A.fg A.white in
  let status_attr = if selected_pkg.installed then
    A.(fg green ++ st bold)
  else
    A.fg A.red
  in

  let title = I.string title_attr "Package Details" in
  let separator = I.string A.empty (String.make (min 80 model.terminal_width) '-') in
  let empty = I.empty in

  let name_line = I.hcat [
    I.string label_attr "Name: ";
    I.string value_attr selected_pkg.name
  ] in

  let version_line = I.hcat [
    I.string label_attr "Version: ";
    I.string value_attr selected_pkg.version
  ] in

  let status_text = if selected_pkg.installed then "Installed ✓" else "Not installed" in
  let status_line = I.hcat [
    I.string label_attr "Status: ";
    I.string status_attr status_text
  ] in

  let synopsis_label = I.string label_attr "Synopsis:" in
  let synopsis_text = I.string value_attr selected_pkg.synopsis in

  let help_attr = A.fg (A.gray 8) in
  let help = I.string help_attr "Press Enter/Esc/Backspace to return | q: Quit" in

  I.vcat [
    title;
    empty;
    separator;
    empty;
    name_line;
    version_line;
    status_line;
    empty;
    synopsis_label;
    synopsis_text;
    empty;
    separator;
    empty;
    help;
  ]

(* Render list view *)
let render_list model =
  let model = adjust_scroll_offset model in
  let vh = visible_height model in

  (* Header *)
  let total_packages = List.length model.filtered_packages in
  let header_text = Printf.sprintf "OPAM Package Browser (%d packages)" total_packages in
  let header_attr = A.(st bold ++ st underline) in
  let header = I.string header_attr header_text in

  (* Search bar *)
  let search_text = Printf.sprintf "Search: %s_" model.search_text in
  let search_attr = A.fg A.yellow in
  let search_bar = I.string search_attr search_text in

  (* Get visible packages *)
  let visible_packages =
    model.filtered_packages
    |> (fun l ->
        let rec drop n = function
          | [] -> []
          | _ :: tl when n > 0 -> drop (n - 1) tl
          | l -> l
        in drop model.scroll_offset l)
    |> (fun l ->
        let rec take n = function
          | [] -> []
          | hd :: tl when n > 0 -> hd :: take (n - 1) tl
          | _ -> []
        in take vh l)
  in

  (* Render package list *)
  let package_images =
    List.mapi (fun idx pkg ->
      let actual_idx = model.scroll_offset + idx in
      render_package ~selected:(actual_idx = model.selected_idx) ~width:model.terminal_width pkg
    ) visible_packages
  in

  (* Add empty lines if needed *)
  let empty_lines = List.init (max 0 (vh - List.length package_images))
    (fun _ -> I.empty) in

  (* Footer with help *)
  let footer_attr = A.fg A.white in
  let footer = I.string footer_attr "↑/↓: Navigate | Enter: Details | Type to search | Backspace: Delete | Esc: Clear | q: Quit" in

  (* Combine all elements *)
  I.vcat ([
    header;
    I.empty;
    search_bar;
    I.empty;
  ] @ package_images @ empty_lines @ [
    I.empty;
    footer;
  ])

(* Render the current view *)
let render model =
  match model.view_mode with
  | Details -> render_details model
  | List -> render_list model

(* Handle keyboard input *)
let handle_key model key mods =
  match key, mods with
  | (`ASCII 'q' | `ASCII 'Q'), _ when model.view_mode = List && model.search_text = "" ->
      { model with running = false }
  | `Escape, _ when model.view_mode = List && model.search_text = "" ->
      { model with running = false }

  | `Escape, _ ->
      if model.view_mode = Details then
        { model with view_mode = List }
      else
        let filtered = filter_packages model.packages "" in
        adjust_scroll_offset {
          model with
          search_text = "";
          selected_idx = 0;
          filtered_packages = filtered;
        }

  | `Enter, _ ->
      let new_mode = match model.view_mode with
        | List -> Details
        | Details -> List
      in
      { model with view_mode = new_mode }

  | `Arrow `Up, _ when model.view_mode = List ->
      let new_idx = max 0 (model.selected_idx - 1) in
      adjust_scroll_offset { model with selected_idx = new_idx }

  | `Arrow `Down, _ when model.view_mode = List ->
      let max_idx = max 0 (List.length model.filtered_packages - 1) in
      let new_idx = min max_idx (model.selected_idx + 1) in
      adjust_scroll_offset { model with selected_idx = new_idx }

  | `Backspace, _ ->
      if model.view_mode = Details then
        { model with view_mode = List }
      else if String.length model.search_text > 0 then
        let new_search = String.sub model.search_text 0 (String.length model.search_text - 1) in
        let filtered = filter_packages model.packages new_search in
        adjust_scroll_offset {
          model with
          search_text = new_search;
          selected_idx = 0;
          filtered_packages = filtered;
        }
      else
        model

  | `ASCII ch, [] when model.view_mode = List && ch >= ' ' && ch <= '~' ->
      let new_search = model.search_text ^ String.make 1 ch in
      let filtered = filter_packages model.packages new_search in
      adjust_scroll_offset {
        model with
        search_text = new_search;
        selected_idx = 0;
        filtered_packages = filtered;
      }

  | _ -> model

(* Main event loop *)
let rec event_loop term events model =
  if not model.running then
    Lwt.return_unit
  else
    let* () = Term.image term (render model) in
    let* event = Lwt_stream.next events in
    match event with
    | `Key (key, mods) ->
        let new_model = handle_key model key mods in
        event_loop term events new_model
    | `Resize (width, height) ->
        let new_model = adjust_scroll_offset {
          model with
          terminal_width = width;
          terminal_height = height
        } in
        event_loop term events new_model
    | _ -> event_loop term events model

(* Run the TUI application *)
let run packages =
  let model = init_model packages in
  let term = Term.create () in
  let events = Term.events term in
  Lwt.finalize
    (fun () -> event_loop term events model)
    (fun () -> Term.release term)
