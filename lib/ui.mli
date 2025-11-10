(** UI module using Minttea for TUI *)

(** Message types for UI events *)
type msg =
  | KeyPressed of Minttea.Event.key
  | SearchTextChanged of string
  | SelectionMoved of int
  | Quit

(** View mode *)
type view_mode =
  | List
  | Details

(** Model representing the application state *)
type model = {
  packages : Opam_client.package list;
  filtered_packages : Opam_client.package list;
  selected_idx : int;
  scroll_offset : int;
  search_text : string;
  terminal_height : int;
  view_mode : view_mode;
}

(** Run the TUI application with the given list of packages *)
val run : Opam_client.package list -> unit Lwt.t
