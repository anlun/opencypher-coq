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
Require Import PGMatrixExtraction.
Require Import Utils.

Definition types_to_expr (n : positive) (etypes : list label) (tr : bool) :
expr (fun _ : Label => n) (fun _ : Label => n) n n :=
  List.fold_right 
    (fun x (y : expr (fun _ => n) (fun _  => n) n n) => 
      e_pls (if tr then e_cnv (e_var (elabel x)) else e_var (elabel x)) y)
    (e_zer n n)
    etypes.

Definition labels_to_expr (n : positive) (vlabels : list label) : 
expr (fun _ : Label => n) (fun _ : Label => n) n n :=
  List.fold_right 
    (fun x (y : expr (fun _ => n)  (fun _  => n) n n) => e_dot (e_var (vlabel x)) y)
    (e_one n)
    vlabels.

Fixpoint k_edges (n : positive) (etypes : list label) (tr : bool) (k : nat) :=
  match k with 
  | O => e_one n
  | S k' => e_dot (types_to_expr n etypes tr) (k_edges n etypes tr k')
  end.

Fixpoint edge_pattern_to_matrix (n : positive) (p : list Pattern.pedge) :
expr (fun _ : Label => n) (fun _ : Label => n) n n :=
  match p with
  | nil => e_one n
  | pedge :: l => 
    let e := match pedge.(edir) with 
      | IN => k_edges n pedge.(elabels) true pedge.(enum)
      | OUT => k_edges n pedge.(elabels) false pedge.(enum)
      | BOTH => e_pls (k_edges n pedge.(elabels) true pedge.(enum)) (k_edges n pedge.(elabels) false pedge.(enum))
      end in e_dot (e_dot e (labels_to_expr n pedge.(evertex).(vlabels)))
                            (edge_pattern_to_matrix n l)
end.

Definition pattern_to_matrix (n : positive) (p : Pattern.t) :
expr (fun _ : Label => n) (fun _ : Label => n) n n :=
  e_dot (labels_to_expr n p.(start).(vlabels)) (edge_pattern_to_matrix n p.(ledges)).

(* http://perso.ens-lyon.fr/damien.pous/ra/html/RelationAlgebra.syntax.html#s.e.f *)
(* Use as a variable f. *)
Definition e_var2matrix (g : PropertyGraph.t) (l : Label) :=
  match l with 
  | vlabel v => pg_extract_lmatrices (List.length g.(vertices)) g.(vlab) l
  | elabel e => pg_extract_tmatrices (List.length g.(vertices)) g.(edges) g.(elab) g.(st) l 
  end.





