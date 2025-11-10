open Minttea

(* Message types for all UI events *)
type msg =
  | KeyPressed of Minttea.Event.key
  | SearchTextChanged of string
  | SelectionMoved of int
  | Quit

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
  view_mode : view_mode;
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
let init_model packages = {
  packages;
  filtered_packages = packages;
  selected_idx = 0;
  scroll_offset = 0;
  search_text = "";
  terminal_height = 24;
  view_mode = List;
}

let init _model = Command.Noop

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

(* Update function - handles all state transitions *)
let update event model =
  match event with
  | Event.KeyDown (Key "q" | Key "Q") ->
      (model, Command.Quit)

  | Event.KeyDown (Key "ctrl-c") ->
      (model, Command.Quit)

  | Event.KeyDown Up ->
      let new_idx = max 0 (model.selected_idx - 1) in
      let updated_model = adjust_scroll_offset { model with selected_idx = new_idx } in
      (updated_model, Command.Noop)

  | Event.KeyDown Down ->
      let max_idx = max 0 (List.length model.filtered_packages - 1) in
      let new_idx = min max_idx (model.selected_idx + 1) in
      let updated_model = adjust_scroll_offset { model with selected_idx = new_idx } in
      (updated_model, Command.Noop)

  | Event.KeyDown (Key "esc") ->
      if model.view_mode = Details then
        (* In details view, ESC goes back to list *)
        ({ model with view_mode = List }, Command.Noop)
      else
        let filtered = filter_packages model.packages "" in
        let updated_model = adjust_scroll_offset {
          model with
          search_text = "";
          selected_idx = 0;
          filtered_packages = filtered;
        } in
        (updated_model, Command.Noop)

  | Event.KeyDown Enter ->
      let new_mode = match model.view_mode with
        | List -> Details
        | Details -> List
      in
      ({ model with view_mode = new_mode }, Command.Noop)

  | Event.KeyDown Backspace ->
      if model.view_mode = Details then
        (* In details view, backspace goes back to list *)
        ({ model with view_mode = List }, Command.Noop)
      else
        let new_search =
          if String.length model.search_text > 0 then
            String.sub model.search_text 0 (String.length model.search_text - 1)
          else ""
        in
        let filtered = filter_packages model.packages new_search in
        let updated_model = adjust_scroll_offset {
          model with
          search_text = new_search;
          selected_idx = 0;
          filtered_packages = filtered;
        } in
        (updated_model, Command.Noop)

  | Event.KeyDown (Key c) when String.length c = 1 ->
      let ch = c.[0] in
      if ch >= ' ' && ch <= '~' then
        let new_search = model.search_text ^ String.make 1 ch in
        let filtered = filter_packages model.packages new_search in
        let updated_model = adjust_scroll_offset {
          model with
          search_text = new_search;
          selected_idx = 0;
          filtered_packages = filtered;
        } in
        (updated_model, Command.Noop)
      else
        (model, Command.Noop)

  | _ ->
      (model, Command.Noop)

(* Helper function to truncate string if too long *)
let truncate str max_len =
  if String.length str > max_len then
    String.sub str 0 (max_len - 3) ^ "..."
  else
    str

(* Render a single package line *)
let render_package ~selected pkg =
  let open Opam_client in
  let status_icon = if pkg.installed then "✓" else " " in
  let name_version = Printf.sprintf "%-40s %-15s" pkg.name pkg.version in
  let synopsis = truncate pkg.synopsis 50 in

  let line = Printf.sprintf "[%s] %s %s" status_icon name_version synopsis in

  if selected then
    let style = Spices.(default |> fg (color "#000000") |> bg (color "#00ff00") |> bold true) in
    Spices.build style "%s" line
  else if pkg.installed then
    let style = Spices.(default |> fg (color "#00ffff") |> bold true) in
    Spices.build style "%s" line
  else
    line

(* Render package details view *)
let render_details model =
  let selected_pkg =
    try List.nth model.filtered_packages model.selected_idx
    with _ -> { Opam_client.name = ""; version = ""; synopsis = ""; installed = false }
  in
  let open Opam_client in

  let title_style = Spices.(default |> bold true |> underline true |> fg (color "#00ff00")) in
  let label_style = Spices.(default |> bold true |> fg (color "#ffff00")) in
  let value_style = Spices.(default |> fg (color "#ffffff")) in
  let status_style = if selected_pkg.installed then
    Spices.(default |> bold true |> fg (color "#00ff00"))
  else
    Spices.(default |> fg (color "#ff0000"))
  in

  let title = Spices.build title_style "Package Details" in
  let separator = String.make 80 '-' in

  let name_line =
    (Spices.build label_style "Name: ") ^
    (Spices.build value_style "%s" selected_pkg.name) in

  let version_line =
    (Spices.build label_style "Version: ") ^
    (Spices.build value_style "%s" selected_pkg.version) in

  let status_line =
    (Spices.build label_style "Status: ") ^
    (Spices.build status_style "%s" (if selected_pkg.installed then "Installed ✓" else "Not installed")) in

  let synopsis_label = Spices.build label_style "Synopsis:" in
  let synopsis_text = Spices.build value_style "%s" selected_pkg.synopsis in

  let help_style = Spices.(default |> fg (color "#888888")) in
  let help = Spices.build help_style "Press Enter/Esc/Backspace to return | q: Quit" in

  let lines = [
    title;
    "";
    separator;
    "";
    name_line;
    version_line;
    status_line;
    "";
    synopsis_label;
    synopsis_text;
    "";
    separator;
    "";
    help;
  ] in

  String.concat "\n" lines

(* View function - renders the UI as a string *)
let view model =
  match model.view_mode with
  | Details -> render_details model
  | List ->
    let vh = visible_height model in
    let model = adjust_scroll_offset model in

    (* Header *)
    let total_packages = List.length model.filtered_packages in
    let header =
      let style = Spices.(default |> bold true |> underline true) in
      Spices.build style "OPAM Package Browser (%d packages)" total_packages in

    (* Search bar *)
    let search_bar =
      let style = Spices.(default |> fg (color "#ffff00")) in
      Spices.build style "Search: %s_" model.search_text in

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
    let package_lines =
      List.mapi (fun idx pkg ->
        let actual_idx = model.scroll_offset + idx in
        render_package ~selected:(actual_idx = model.selected_idx) pkg
      ) visible_packages
    in

    (* Add empty lines if needed to maintain consistent height *)
    let empty_lines = List.init (max 0 (vh - List.length package_lines)) (fun _ -> "") in

    (* Footer with help *)
    let footer =
      let style = Spices.(default |> fg (color "#ffffff")) in
      Spices.build style "↑/↓: Navigate | Enter: Details | Type to search | Backspace: Delete | Esc: Clear | q: Quit" in

    (* Combine all elements *)
    let lines = [
      header;
      "";
      search_bar;
      "";
    ] @ package_lines @ empty_lines @ [
      "";
      footer;
    ] in

    String.concat "\n" lines

(* Create and run the application *)
let run packages =
  let initial_model = init_model packages in
  let app = Minttea.app ~init ~update ~view () in
  let () = Minttea.start app ~initial_model in
  Lwt.return_unit
