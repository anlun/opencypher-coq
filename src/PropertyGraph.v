Require Import String.
From hahn Require Import Hahn.

Module Property.
  Inductive t := 
  | p_int (i : nat)
  | p_string (s : string)
  | p_empty
  .
  
  Definition name := string.
  
  Definition eqb (p p' : t) : bool :=
    match p, p' with
    | p_int i, p_int i' => Nat.eqb i i'
    | p_string s, p_string s' => String.eqb s s'
    | p_empty, p_empty => true
    | _, _ => false
    end.

  Lemma eqP : Equality.axiom eqb.
  Proof.
    unfold eqb. red. ins. desf; try constructor; desf.
    all: apply Bool.iff_reflect.
    all: symmetry; etransitivity.
    all: try apply PeanoNat.Nat.eqb_eq; try apply String.eqb_eq.
    all: split; intros AA; subst; auto.
    all: inv AA.
  Qed.
End Property.

Module PropertyGraph.
  Definition vertex    := nat.
  Definition edge      := nat.
  Definition label     := string.

  Record t :=
    mk { vertices : list vertex;
         edges    : list edge;
         st       : edge -> vertex * vertex;
         vlab     : vertex -> list label;
         elab     : edge -> label;
         vprops   : list (Property.name * (vertex -> Property.t)); 
         eprops   : list (Property.name * (edge   -> Property.t)); 
      }.
End PropertyGraph.

Fixpoint get_properties_by_edge (e : edge) (eprops : list (Property.name * (edge -> Property.t))) : 
  list (Property.name * Property.t) :=
  match eprops with
  | [] => []
  | head :: tail => app [(fst head) * ((snd head) v)] [get_properties_by_edge v tail]
  end.

Fixpoint get_properties_by_vertex (v : vertex) (vprops : list (Property.name * (vertex -> Property.t))) : 
  list (Property.name * Property.t) :=
  match vprops with
  | [] => []
  | head :: tail => app [(fst head) * ((snd head) v)] [get_properties_by_vertex v tail]
  end.
 
Fixpoint get_info_about_vertices (vs : list vertex) (graph : PropertyGraph.t) :=
  match vs with
  | [] => []
  | head :: tail => app [rec ([("id" * head) ; ("vertex" * (mk head (vlab head) (get_properties_by_vertex head graph.(vprops))))])] 
                        [(get_info_about_vertices tail graph)] 
  end.

Definition graph_to_vertices_relation (graph : PropertyGraph.t) : list data := 
Definition graph_to_edges_relation (graph : PropertyGraph.t) : RelationOperation.t := 