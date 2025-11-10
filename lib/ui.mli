(** UI module using Notty for TUI *)

(** View mode *)
type view_mode = List | Details

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
(** Model representing the application state *)

val run : Opam_client.package list -> unit Lwt.t
(** Run the TUI application with the given list of packages *)
