-module(trees).
-include_lib("eqc/include/eqc.hrl").
-compile({parse_transform,eqc_cover}).
-compile(export_all).

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

prop_ordered() ->
  ?FORALL(T,tree(),
          ordered(to_list(T))).

ordered(Xs) ->
  lists:usort(Xs) == Xs.

to_list(leaf) ->
  [];
to_list({node,L,X,R}) ->
  to_list(L) ++ [X] ++ to_list(R).

%% member

prop_member() ->
  ?FORALL({X,T},{nat(),tree()},
          equals(member(X,T),lists:member(X,to_list(T)))).

member(_,leaf) ->
  false;
member(X,{node,L,Y,R}) ->
  if 
    X<Y ->
      member(X,L);
    X==Y ->
      true;
    X>Y ->
      member(X,R)
  end.

%% %% insert

%% prop_insert() ->
%%   ?FORALL({X,T},{nat(),tree()},
%%     begin
%%       L = to_list(insert(X,T)),
%%       equals(L,lists:umerge([X],to_list(T)))
%%     end).

%% insert(X,leaf) ->
%%   {node,leaf,X,leaf};
%% insert(X,{node,L,Y,R}) ->
%%   if X<Y ->
%%       {node,insert(X,L),Y,R};
%%      X>=Y ->
%%       {node,L,Y,insert(X,R)}
%%   end.
