-module(trees).
-include_lib("eqc/include/eqc.hrl").
-compile({parse_transform,eqc_cover}).
-compile(export_all).

to_list(leaf) ->
  [];
to_list({node,L,X,R}) ->
  to_list(L) ++ [X] ++ to_list(R).

prop_ordered() ->
  ?FORALL(T,tree(),
          ordered(to_list(T))).

ordered(Xs) ->
  lists:usort(Xs) == Xs.

tree() ->
  ?SIZED(Size,tree(-Size,Size)).

tree(Lo,Hi) when Hi < Lo ->
  leaf;
tree(Lo, Hi) ->
  frequency([{1,leaf},
             {2,?LET(X,choose(Lo,Hi),
                     ?LET({L,R},{tree(Lo,X-1),tree(X+1,Hi)},
                          ?SHRINK({node,L,X,R},
                                   [leaf,L,R])))}]).

insert(X,leaf) ->
  {node,leaf,X,leaf};
insert(X,{node,L,Y,R}) ->
  if X<Y ->
      {node,insert(X,L),Y,R};
     X>Y ->
      {node,L,Y,insert(X,R)};
     X==Y ->
      {node,L,Y,R}
  end.

prop_insert() ->
  ?FORALL({X,T},{nat(),tree()},
    begin
      L = to_list(insert(X,T)),
      ?WHENFAIL(io:format("L: ~p\n",[L]),
                conjunction([{ordered,ordered(L)},
                             {elements,L==lists:umerge([X],to_list(T))}]))
    end).

member(X,leaf) ->
  false;
member(X,{node,L,Y,R}) ->
  if X<Y ->
      member(X,R);
     X==Y ->
      true;
     X>Y ->
      member(X,R)
  end.

prop_member() ->
  ?FORALL({X,T},{nat(),tree()},
          equals(member(X,T),lists:member(X,to_list(T)))).

prop_delete() ->
  ?FORALL(T,tree(),
          ?IMPLIES(T/=leaf,
                   ?FORALL(X,elements(to_list(T)),
    begin
      L = to_list(delete(X,T)),
      ?WHENFAIL(io:format("L: ~p\n",[L]),
                collect(with_title("present"),lists:member(X,to_list(T)),
                        conjunction([{ordered,ordered(L)},
                                     {elements,L==lists:delete(X,to_list(T))}])))
    end))).

delete(_,leaf) ->
  leaf;
delete(X,{node,L,Y,R}) ->
  if X<Y ->
      {node,delete(X,L),Y,R};
     X>Y ->
      {node,L,Y,delete(X,R)};
     X==Y ->
      merge(L,R)
  end.

merge(leaf,R) ->
  R;
merge(L,leaf) ->
  L;
merge({node,L,X,R},T) ->
  {node,L,X,merge(R,T)}.
