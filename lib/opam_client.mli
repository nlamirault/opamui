(** Interface to query OPAM packages *)

type package = {
  name : string;
  version : string;
  synopsis : string;
  installed : bool;
}

(** Get all available OPAM packages with their metadata *)
val get_all_packages : unit -> package list Lwt.t
