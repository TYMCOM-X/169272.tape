module eval_costs;

$include clustr.typ
$PAGE external declarations
external procedure trace_direction( way  : direction;
                                    proc : string[30] );

external var  trace : boolean;
              ebks  : real;




$PAGE  and & pba
(* ANC computes the Average Number of Children ("kids") occurences
   per parent occurance.  This is computed from the formula:

       ANC ( i, j )  =  NR(j) / NR(i),

   where NR(x) is the number of records of type x.                 *)


function anc( parent : entity_ptr;
              kid    : entity_ptr ) : real;

  begin
    if trace  then trace_direction( enter_proc, 'anc' );

    anc := kid^.nr / parent^.nr;      (* compute anc *)

    if trace  then trace_direction( exit_proc, 'anc' );
  end (* anc *);





(* PBA computes the Physical Block Access associated with a transition
   from I to J, where "dist" is the distance from I to J [ D(I,J) ], and

        PBA  =  minimum [ D(I,J) / EBKS, 1 ].

   ( PBA is used to calculate PBAs for nodes within the same clustering )
   ( group only; across different groups are always 1.                  ) *)


function pba( distance : real ) : real;

  begin
    if trace  then trace_direction( enter_proc, 'pba' );

    pba := min ( ( distance / ebks ), 1 ); (* compute pba *)

    if trace  then trace_direction( exit_proc, 'pba' );
  end (* pba *);
$PAGE cost_of_cluster
(* COST_OF_CLUSTER will compute the cost of one of the clusterings
   of a parent node.                                               *)


function cost_of_cluster( first_node : cost_ptr ) : real;

  var  parent      : entity_ptr;     (* parent of the cost node *)
       kid         : entity_ptr;     (* a kid of the parent *)
       ij_freq_ptr : child_ptr;      (* used to get kids' info *)
       pointer     : cost_ptr;       (* moves across cluster list *)
       dist        : real   ;        (* holds D( parent, kid )  *)
       temp_cost   : real;           (* holds cost as it builds *)
       add_in      : real;           (* amt to add to temp_cost *)

  begin
    if trace  then trace_direction( enter_proc, 'cost_of_cluster' );


    (* initialize the local variables before entering loop *)

    parent      := first_node^.cost_owner;
    ij_freq_ptr := parent^.first_child;
    pointer     := first_node^.join_clustered;
    temp_cost   := parent^.ii_freq * pba( first_node^.d_of_ii );
    dist        := parent^.srs;


    (* begin loop to calculate add_in to add on to temp_cost *)
	   (*  add_in = [ f(f,p) * pba(f,p) + c(p) ]  *)

    while pointer <> nil  do begin

      add_in := ( ij_freq_ptr^.ij_freq * pba( dist ) ) + pointer^.cost;

      temp_cost := temp_cost + add_in;

      kid := pointer^.cost_owner;

      pointer := pointer^.join_clustered;  (* move to next in cluster *)



      if pointer <> nil
        then begin

          dist := dist + ( anc( parent, kid) * kid^.srs );

	  while ij_freq_ptr^.ij_ptr <> pointer^.cost_owner
	    do ij_freq_ptr := ij_freq_ptr^.next_child; (* get next child node *)

        end (* then *);

    end (* while do *);


    cost_of_cluster := temp_cost;  (* final cost of cluster *)


    if trace  then trace_direction( exit_proc, 'cost_of_cluster' );
  end (* cost_of_cluster *);
$PAGE cost_of_separates
(* COST_OF_SEPARATES will compute the cost of the nodes joined
   separately to the first_node.                                *)


function cost_of_separates( first_node : cost_ptr ) : real;

  const pba_diff   = 1; (* pba(i,j) if i and j in diff groups =1 *)

  var  parent      : entity_ptr;     (* parent of the cost node *)
       kid         : entity_ptr;     (* a kid of the parent *)
       ij_freq_ptr : child_ptr;      (* used to get kids' info *)
       pointer     : cost_ptr;       (* moves across cluster list *)
       dist        : real   ;        (* holds D( parent, kid )  *)
       temp_cost   : real;           (* holds cost as it builds *)
       add_in      : real;           (* amt to add to temp_cost *)

  begin
    if trace  then trace_direction( enter_proc, 'cost_of_separates' );


    (* initialize the local variables before entering loop *)

    parent      := first_node^.cost_owner;
    ij_freq_ptr := parent^.first_child;
    pointer     := first_node^.join_separate;
    temp_cost   := 0;


    (* enter loop and add in cost of each separate node *)
    (* cost of each node = [ f(f,p) * pba_diff ] + c(p) *)

    while pointer <> nil  do begin

      add_in := ( ij_freq_ptr^.ij_freq * pba_diff ) + pointer^.cost;

      temp_cost := temp_cost + add_in;

      pointer := pointer^.join_separate;  (* move to next in list *)




      if pointer <> nil
        then (* get next child node *) begin
	  while ij_freq_ptr^.ij_ptr <> pointer^.cost_owner
	    do ij_freq_ptr := ij_freq_ptr^.next_child;
        end (* then *);

    end (* while do *);


    cost_of_separates := temp_cost;  (* final cost of cluster *)


    if trace  then trace_direction( exit_proc, 'cost_of_separates' );
  end (* cost_of_separates *);
$PAGE dist_of_i_to_i
(* DIST_OF_I_TO_I calculates the distance from one parent to the next
   parent taking into account the clustered children inbetween.      *)


function dist_of_i_to_i( pointer : cost_ptr ) : real;

  var  mover  : cost_ptr;   (* moves along clustered nodes *)
       dist   : real   ;    (* holds distance as partially computed *)
       parent : entity_ptr; (* owner of pointer's cost_node *)
       kid    : entity_ptr; (* owner of mover's cost_node *)

  begin
    if trace  then trace_direction( enter_proc, 'dist_of_i_to_i' );


    (* initialize the local variables before entering loop *)

    mover  := pointer^.join_clustered;  (* start with first child clustered *)
    dist   := pointer^.cost_owner^.srs; (* start with parent's srs *)
    parent := pointer^.cost_owner;


    (* begin loop and add the distance next child generates to dist *)

    while mover <> nil  do begin

      kid := mover^.cost_owner;

      dist := dist + ( anc( parent, kid ) * mover^.d_of_ii );

      mover := mover^.join_clustered;

    end (* while do *);


    dist_of_i_to_i := dist;  (* final distance *)


    if trace  then trace_direction( exit_proc, 'dist_of_i_to_i' );
  end (* dist_of_i_to_i *);
$PAGE eval_costs
(* EVAL_COSTS evaluates the costs of the all the clusterings on a
   parent's cluster_list.                                         *)


public procedure eval_costs( parent : entity_ptr );

  var  cur_cluster     : cost_ptr;       (* moves down cluster list *)

  begin
    if trace  then trace_direction( enter_proc, 'eval_costs' );


    (* initialize the cur_cluster before entering loop *)

    cur_cluster := parent^.cluster_list;


    (* begin loop to calculate add_in to add on to temp_costs *)

    while cur_cluster <> nil  do begin

      with cur_cluster^  do begin

	d_of_ii := dist_of_i_to_i( cur_cluster );

	cost := cost_of_cluster( cur_cluster );

	cost := cost + cost_of_separates( cur_cluster );

      end (* with cur_cluster^ *);

      cur_cluster := cur_cluster^.next_choice;

    end (* while do *);


    if trace  then trace_direction( exit_proc, 'eval_costs' );
  end (* eval_costs *).
 