Require Import BinNums.
Require Import BinInt.
Require Import List.
Require Import String.
Require Import Bool.
Import ListNotations.

Require Import Notations.
Require Import Ltac.
Require Import Logic.
(* From RelationAlgebra Require Import kleene boolean sups matrix.*)
From RelationAlgebra Require Import syntax matrix bmx ordinal.

Require Import Cypher.
Require Import PropertyGraph.
Import PropertyGraph.
Import Pattern.

Definition label_neq (a b : label) : bool := negb (String.eqb a b).

Fixpoint list_unique (l : list label) :=
  match l with
  | nil => nil
  | cons h l =>
    h :: filter (fun x => label_neq x h)
      (list_unique l)
  end.

Fixpoint list_inb (e : string) (l : list string) : bool :=
  match l with
  | nil => false 
  | h :: tl => match String.eqb e h with
    | true => true
    | false => list_inb e tl
    end
  end.

Fixpoint list_inb_b (e : bool) (l : list bool) : bool :=
  match l with
  | nil => false 
  | h :: tl => match Bool.eqb e h with
    | true => true
    | false => list_inb_b e tl
    end
  end.

Definition get_labels_matrices (n : nat) (vlab : vertex -> list label) : 
  list (label * (ord n -> ord n -> bool)) :=
  let labels := list_unique (List.concat (map (fun i => vlab i) (List.seq 0 n))) in
  (* TODO: List.In in boolean form *)
  map (fun lbl => let mtx (x y : ord n) := 
    if eqb_ord x y then list_inb lbl (vlab x) else false in
    ((append "l_" lbl), mtx)) labels.

Definition ord_to_nat (n : nat) (o : ord n) : nat :=
  match o with 
  | Ord k _ => k
  end.

Definition get_types_matrices (n : nat) (edges : list edge) (elab : edge -> label) 
  (st : edge -> vertex * vertex) : list (label * (ord n -> ord n -> bool)) :=
  let labels := list_unique (map (fun edge => elab edge) edges) in
  map (fun lbl => 
    let mtx (x y : ord n) := list_inb_b 
      true 
      (map (fun edge => 
        andb (andb (eqb (fst (st edge)) (ord_to_nat n x)) (eqb (snd (st edge)) (ord_to_nat n y))) (String.eqb (elab edge) lbl)) 
        edges) in ((append "t_" lbl), mtx)) 
    labels.

Definition get_all_matrices (n : nat) (g : PropertyGraph.t) := 
  (get_labels_matrices n g.(vlab)) ++ (get_types_matrices n g.(edges) g.(elab) g.(st)).

Fixpoint get_types (n : positive) (etypes : list label) (tr : bool) :=
  match etypes with
  | [] => e_zer n n
  | h :: tl => e_pls (get_types n tl tr)
                     (if tr
                      then e_cnv (e_var h)
                      else e_var h)
  end.

Fixpoint k_edges (n : positive) (etypes : list label) (tr : bool) (k : nat) :=
  match k with 
  | O => e_one n
  | S k' => e_dot (get_types n etypes tr) (k_edges n etypes tr k')
  end.

(* TODO: Learn from functional programming basic operations on lists:
         - map
         - foldl (fold_left), foldr (fold_right)
         - filter
*)

(* TODO: move to a file w/ basic definitions *)
Fixpoint sum
         {A : Set}
         (s t : A -> positive)
         {m n : positive}
         (els : list (expr s t m n))
         : expr s t m n :=
  List.fold_left (fun m h => e_pls h m) els (e_zer m n).
  (* match els with  *)
  (* | []      => e_zer m n *)
  (* | h :: tl => e_pls h (sum s t tl) *)
  (* end. *)

Fixpoint pattern_to_matrix
         (n : positive)
         (p : Pattern.t) :
  expr (fun _ : string => n) (fun _ : string => n) n n :=
  match p with 
  | pvertex vvar vlabels =>
    List.fold_left (fun (m : expr (fun _ => n) (fun _  => n) n n) vlabel =>
                      e_dot (e_var vlabel) m)
                   vlabels
                   (e_one n)
    (* match vlabels with *)
    (* | []      => e_one n *)
    (* | h :: tl => *)
    (*   e_dot (e_var h) *)
    (*         (pattern_to_matrix n (pvertex vvar tl)) *)
    (* end *)
  (* | pedge p evar etypes edir wvar wlabels => *)
  (*   let e := match edir with *)
  (*     | IN => get_types n etypes true *)
  (*     | OUT => get_types n etypes false *)
  (*     | BOTH => e_pls (get_types n etypes true) (get_types n etypes false) *)
  (*   end in e_dot (e_dot (pattern_to_matrix n p) e) (pattern_to_matrix n (pvertex wvar wlabels)) *)
  | _ => e_one n
  (* | pmultiedge p evar etypes edir low up wvar wlabels => *)
  (*   let e := match up with  *)
  (*     | None =>  match edir with *)
  (*       | IN => e_dot (k_edges n etypes true (low - 1)) (e_itr (get_types n etypes true) *)
  (*       | OUT =>  e_dot (k_edges n etypes false (low - 1)) (e_itr (get_types n etypes false) *)
  (*       | BOTH => e_pls (e_dot (k_edges n etypes true (low - 1)) (e_itr (get_types n etypes true)) *)
  (*         ((k_edges n etypes false (low - 1)) (e_itr (get_types n etypes false)) *)
  (*       end *)
  (*     | Some up' => match edir with *)
  (*     | IN => sum n (map (fun k => k_edges n etypes true k) (List.seq low (up' - low))) *)
  (*     | OUT =>  sum n (map (fun k => k_edges n etypes false k) (List.seq low (up' - low))) *)
  (*     | BOTH => e_pls (sup n (map (fun k => k_edges n etypes true k) (List.seq low (up' - low)))) *)
  (*       (sum n (map (fun k => k_edges n etypes false k) (get_seq low up'))) *)
  (*     end *)
  (*   in *)
  (*     e_dot (e_dot (pattern_to_matrix n p) e) (pattern_to_matrix n (pvertex wvar wlabels)) *)
  end.

































Definition labels := get_labels_matrices 
Fixpoint get_current_label (n : nat) (cur : )

Fixpoint get_labels (n : nat) (vlab : vertex -> list label) : list (label * (ord n -> ord n -> boolean)) :=
    let a := [] in 



Definition ord0 {n}: ord (S n) := @Ord (S n) 0 eq_refl.

Print ord_lt.

Open Scope positive_scope.

Definition var := nat.
Definition s (_ : var) : positive := 1.
Definition t (_ : var) : po

Definition f' (_ : positive) :

Definition example_bmx (i j : ord 1) : bool := true.

Definition var_assignment (v : var) :

Definition e := eval 1 1.


(*

(10) ----> (7)

*)
 *)