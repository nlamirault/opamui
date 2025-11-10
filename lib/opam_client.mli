(** Interface to query OPAM packages *)

type package = {
  name : string;
  version : string;
  synopsis : string;
  installed : bool;
}

val strip_ansi : string -> string
(** Strip ANSI escape sequences and control characters from a string.
    This is necessary because some OPAM package descriptions contain
    ANSI color codes that would cause Notty to fail with:
    "Invalid_argument: Notty: control char"

    Example problematic input:
    "\027[01;04mPackage\027[0m description with \027[01;35mcolors\027[0m"

    After stripping:
    "Package description with colors" *)

val get_opam_version : unit -> string Lwt.t
(** Get the current OPAM version. Returns "unknown" if unable to determine. *)

val get_current_switch : unit -> string Lwt.t
(** Get the current OPAM switch name. Returns "unknown" if unable to determine.
*)

val get_all_packages : unit -> package list Lwt.t
(** Get all available OPAM packages with their metadata. All text fields are
    automatically sanitized to remove ANSI codes. *)
