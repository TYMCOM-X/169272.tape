module optimize_cluster_lists;

$include clustr.typ
$PAGE external declarations
external procedure trace_direction( way  : direction;
                                    proc : string[30] );

external var  trace    : boolean;
              level    : integer;

public var    opt_list : opt_ptr := nil;




$PAGE init_opt_list
(* INIT_OPT_LIST empties the opt_list and sets last to nil *)

procedure init_opt_list( var  last : opt_ptr );

  var  this_one : opt_ptr;   (* used to dispose of a node *)

  begin
    if trace  then trace_direction( enter_proc, 'init_opt_list' );


    if opt_list <> nil  then begin

      this_one := opt_list;

      while this_one^.next <> nil
	do this_one := this_one^.next;

      while this_one^.pred <> nil  do begin
	this_one := this_one^.pred;
	dispose( this_one^.next );
      end (* while do *);

    end (* then begin *);


    last := nil;


    if trace  then trace_direction( exit_proc, 'init_opt_list' );
  end (* init_opt_list *);
$PAGE remove
(* REMOVE will remove a opt_node from the opt_list *)

procedure remove( var  opt  : opt_ptr;
                  var  last : opt_ptr );

  var  this_one : opt_ptr;   (* used to dispose of a node *)

  begin
    if trace  then trace_direction( enter_proc, 'remove' );


    this_one := opt;  (* this_one marks the one to be disposed *)

    opt := opt^.next; (* move to next one *)

    if opt <> nil
      then opt^.pred := this_one^.pred  (* adjust pred pointer *)
      else last := this_one^.pred;      (* new last on list    *)

    if this_one^.pred <> nil
      then this_one^.pred^.next := opt  (* adjust next pointer *)
      else opt_list := opt;             (* new first on list   *)

    dispose( this_one );  (* say good-bye to this_one *)


    if trace  then trace_direction( exit_proc, 'remove' );
  end (* remove *);
$PAGE add_p_to_list
(* ADD_P_TO_LIST will put the cost node pointed to by p
   on the end of the opt_list                            *)

procedure add_p_to_list(      p    : cost_ptr;
                         var  last : opt_ptr );

  begin
    if trace  then trace_direction( enter_proc, 'add_p_to_list' );


    if last = nil

      then (* start the opt_list *) begin
        new( opt_list );
        last := opt_list;
        last^.pred := nil;
      end (* then begin *)

      else (* list already exists - put p^ on the list *) begin
        new( last^.next );
        last^.next^.pred := last;
        last := last^.next;
      end (* else begin *);


      last^.keeper := p;  (* put p^ on the list *)
      last^.next   := nil;


    if trace  then trace_direction( exit_proc, 'add_p_to_list' );
  end (* add_p_to_list *);
$PAGE optimize
(* OPTIMIZE will build an opt_list by putting on the list those 
   cost_nodes who have either their d_of_ii or their cost values
   lower than a node already on the list. If a node's d_of_ii
   and cost values are both lower than one already on the list,
   the one already on the list will be taken off the list.       *)

public procedure optimize( parent : entity_ptr );

   type keep_stat = ( keep, eliminate );

   var  p         : cost_ptr;  (* moving pointer to clusterings *)
        opt       : opt_ptr;   (* pointer into optimizing list  *)
        last      : opt_ptr;   (* last opt_node on list *)
        keep_flag : keep_stat; (* flag indicating whether to keep node *)

  begin
    if trace  then trace_direction( enter_proc, 'optimize' );


    p   := parent^.cluster_list;       (* start with the first one *)
    init_opt_list( last );             (* init list - set last to nil *)
    add_p_to_list( p, last );          (* put first cost node on list *)
    p := p^.next_choice;


    (* compare each clustering to those on the opt_list *)

    while p <> nil  do begin

      opt := opt_list;
      keep_flag := keep;

      while opt <> nil  do begin

        if ( p^.d_of_ii >= opt^.keeper^.d_of_ii ) and
	   ( p^.cost    >= opt^.keeper^.cost    )

          then begin
            keep_flag := eliminate;  (* should not be kept *)
            opt := opt^.next;        (* move to next *)
          end (* then begin *)

          else (* this node should be on the opt_list *) begin

            if (p^.d_of_ii <= opt^.keeper^.d_of_ii) and
	       (p^.cost    <= opt^.keeper^.cost   )

              then remove ( opt, last )

              else opt := opt^.next;  (* move to next one *)

          end (* else begin *)

      end (* while opt <> nil *);

      if keep_flag = keep  then add_p_to_list ( p, last );

      p := p^.next_choice;   (* move to next one *)

    end (* while p <> nil *);


    if trace  then trace_direction( exit_proc, 'optimize' );
  end (* optimize *).
 