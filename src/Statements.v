Require Import String.
Require Import List.
Require Import BinNums.
Require Import BinInt.
Import ListNotations.
Require Import Cypher.
Import PropertyGraph.
Require Import KleeneTranslation.
Require Import PGMatrixExtraction.
Require Import Utils.
Require Import Lia.

From RelationAlgebra Require Import syntax matrix bmx ordinal.
From RelationAlgebra Require Import monoid boolean prop sups
  bmx rewriting sums.
Local Open Scope string_scope.
Local Open Scope list_scope.
Local Open Scope nat_scope.

From hahn Require Import HahnBase.

Definition eval_graph g :=
    let size := Datatypes.length(PropertyGraph.vertices g) in
    let size_pos := Pos.of_nat (Datatypes.length(PropertyGraph.vertices g))
    in
    let adj_m := e_var2matrix_real g in
    @eval Label (fun _ => size_pos) (fun _ => size_pos) bmx
      (fun _ => size) adj_m size_pos size_pos.

Lemma edge_pattern_to_matrix_tree_normalization (t1 t2: Pattern.tree) (g: PropertyGraph.t):
  let n   := (Datatypes.length (PropertyGraph.vertices g)) in
  let pn  := Pos.of_nat n in
  let pnf := (fun _ : Label => pn) in
  (@eval Label pnf pnf bmx
     (fun _ => n) (e_var2matrix_real g) pn pn
     (edge_pattern_to_matrix pn (Pattern.insert_tree_r t2 t1))
  )
  = mx_dot bool_ops bool_tt n n n (@eval Label pnf pnf bmx
                                   (fun _ => n) (e_var2matrix_real g) pn pn
                                   (edge_pattern_to_matrix pn t1))
  (@eval Label pnf pnf bmx
     (fun _ => n) (e_var2matrix_real g) pn pn
     (edge_pattern_to_matrix pn t2)) .
Proof.
  intros n.
  induction t1. simpl. reflexivity.
  ins.
  remember (@eval Label (fun _ => (Pos.of_nat n)) (fun _ => (Pos.of_nat n)) bmx
              (fun _ => n) (e_var2matrix_real g) (Pos.of_nat n) (Pos.of_nat n)) as EVAL.
  remember (mx_dot bool_ops bool_tt n n n) as MXDOT.
  rewrite IHt1_2.
  assert (forall a b c,
             MXDOT (MXDOT a b) c ≡
               MXDOT a (MXDOT b c))
    as MXDOT_ASSOC.
  { intros x y z. subst MXDOT.
    now rewrite mx_dotA with (M:=x) (N:=y) (P:=z). }
  assert (forall a b c,
             MXDOT (MXDOT a b) c =
               MXDOT a (MXDOT b c))
    as MXDOT_ASSOC2.
  2: { now rewrite MXDOT_ASSOC2. }
  intros a b c.
  apply functional_extensionality. intros.
  apply functional_extensionality. intros.
  now rewrite MXDOT_ASSOC.
Qed.

Theorem pattern_normalization_eq g v t :
    let p  := Pattern.mk v t in
    let np := Pattern.normalize p in
    let size_pos :=
      Pos.of_nat (Datatypes.length(PropertyGraph.vertices g)) in
    let p1_m := pattern_to_matrix size_pos p  in
    let p2_m := pattern_to_matrix size_pos np in
    eval_graph g p1_m ≡ eval_graph g p2_m.
Proof.
  unfold eval_graph. simpl.
  set (Datatypes.length (PropertyGraph.vertices g)) as n.
  intros a a0.
  remember (mx_dot bool_ops bool_tt n n n) as MXDOT.
  remember
    (MXDOT
       (eval (e_var2matrix_real g)
          (labels_to_expr
             (Pos.of_nat n)
             (Pattern.vlabels v)))) as VEVAL.
  assert (forall a b c,
             MXDOT (MXDOT a b) c ≡
               MXDOT a (MXDOT b c))
    as MXDOT_ASSOC.
  { intros a1 b c. subst MXDOT.
    now rewrite mx_dotA with (M:=a1) (N:=b) (P:=c). }

  match goal with
  | |- VEVAL ?X _ _  = VEVAL ?Y _ _ => enough (X = Y) as EQ
  end.
  { now rewrite EQ. }
  induction t; ins.
  rewrite IHt1, IHt2.
  unfold n.
  now rewrite <- edge_pattern_to_matrix_tree_normalization with
    (t2 := Pattern.tree_normalize t2) (t1 := Pattern.tree_normalize t1) (g := g).
Qed.
