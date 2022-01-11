Require Import String.
Require Import List.
Import ListNotations.

Module Pattern.
  Inductive direction :=
  | OUT
  | IN
  | BOTH
  .
  
  Record vertex := {
      var    : string;
      labels : list string;
    }.
  
  (* TODO: fix names *)
  Record edge := {
      evar   : string;
      etypes : list string;
      edir   : direction;
      w      : vertex; (* TODO: at least this one *)
      low    : nat;
      up     : option nat;
    }.

  Record t := {
      start : vertex;
      edges : list edge;
    }.
End Pattern.

Module PatternNotations.
  Import Pattern.

  Declare Scope pat_scope.
  Delimit Scope pat_scope with pat.

  Notation "(| v # l1 , .. , ln |)" :=
  (pvertex v (cons l1 .. (cons ln nil) ..)) (at level 0) : pat_scope.
  Notation "(| v |)" := (pvertex v nil) (at level 0) : pat_scope.

  Notation "p -[ e # l1 | .. | ln ]- (| v |)" :=
  (pedge p e (cons l1 .. (cons ln nil) ..) BOTH v nil) (at level 40) : pat_scope.
  Notation "p -[ e # l1 | .. | ln ]-> (| v |)" :=
  (pedge p e (cons l1 .. (cons ln nil) ..) OUT v nil) (at level 40) : pat_scope.
  Notation "p <-[ e # l1 | .. | ln ]- (| v |)" :=
  (pedge p e (cons l1 .. (cons ln nil) ..) IN v nil) (at level 40) : pat_scope.
  Notation "p -[ e # l1 | .. | ln ]- (| v # vl1 , .. , vln |)" :=
  (pedge p e (cons l1 .. (cons ln nil) ..) BOTH
          v (cons vl1 .. (cons vln nil) ..)) (at level 40) : pat_scope.
  Notation "p -[ e # l1 | .. | ln ]-> (| v # vl1 , .. , vln |)" :=
  (pedge p e (cons l1 .. (cons ln nil) ..) OUT
          v (cons vl1 .. (cons vln nil) ..)) (at level 40) : pat_scope.
  Notation "p <-[ e # l1 | .. | ln ]- (| v # vl1 , .. , vln |)" :=
  (pedge p e (cons l1 .. (cons ln nil) ..) IN
          v (cons vl1 .. (cons vln nil) ..)) (at level 40) : pat_scope.

End PatternNotations.

(* TODO: refactor VVVVV this VVVVV *)

Module ProjectionExpr.
Inductive proj := AS (from : string) (to : string).

Definition t := list proj.
End ProjectionExpr.

Module Clause.
Inductive t := 
| MATCH (patterns : list Pattern.t)
| WITH (pexpr : ProjectionExpr.t)
.           
End Clause.

Module Query.
Record t := mk {
    clauses : list Clause.t;
    ret : ProjectionExpr.t;
}.
End Query.

(*
Missing features:
- UNION / UNION ALL
- WHERE
- EXPRESSIONS IN PROJECTION
- DISTINCT
- OPTIONAL MATCH

- UNWIND
- ORDER BY / SKIP / LIMIT
*)
