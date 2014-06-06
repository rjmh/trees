-module(trees).
-include_lib("eqc/include/eqc.hrl").
-compile(export_all).

to_list(leaf) ->
  [];
to_list({node,L,X,R}) ->
  to_list(L) ++ [X] ++ to_list(R).

prop_ordered() ->
  ?FORALL(T,tree(),
          ordered(to_list(T))).

ordered(Xs) ->
  lists:sort(Xs) == Xs.

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
