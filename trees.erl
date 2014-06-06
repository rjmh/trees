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
             {2,?SHRINK(
                   ?LET(X,choose(Lo,Hi),
                        {node,tree(Lo,X-1),X,tree(X+1,Hi)}),
                   [leaf])}]).

insert(X,leaf) ->
  {node,leaf,X,leaf};
insert(X,{node,L,Y,R}) ->
  if X<Y ->
      {node,insert(X,L),Y,R};
     X>=Y ->
      {node,L,Y,insert(X,R)}
  end.

prop_insert() ->
  ?FORALL({X,T},{nat(),tree()},
          ordered(to_list(insert(X,T)))).
