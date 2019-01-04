%%%-------------------------------------------------------------------
%%% @author Elton
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Dez 2018 20:05
%%%-------------------------------------------------------------------
-module('Splay-Tree').
-author("Elton").

%% API
-export([isBT/1,initBT/0,isEmptyBT/1,equalBT/2,eqBT/2,insertBT/2,deleteBT/2,findBT/2,findTP/2,inOrderBT/1,printBT/2,hoehe_von/1]).

initBT() ->
  {}.


isBT({}) ->
  true;
isBT({Elem,Height,LChild,RChild})when is_integer(Height) ->
  L = isBT(LChild),
  R = isBT(RChild),
  if
    L == R == true ->
      true;
    true ->
      false
  end;
isBT(_) ->
  false.

isEmptyBT({}) ->
  true;
isEmptyBT(_) ->
  false.

equalBT(BTreeOne, BTreeTwo) ->
  if
    BTreeOne == BTreeTwo -> true;
    true -> false
  end.

eqBT(BTreeOne, BTreeTwo) ->
  ok.

insertBT({}, Elem) ->
  {Elem,1,{},{}};
insertBT({Elm, H, LChild, RChild}, Elem) when Elm < Elem ->
  LEmpty = isEmptyBT(LChild),
  if
    LEmpty == true ->
      if
        H > 1 ->
          {Elm, H, {Elem, 1, {}, {}}, RChild};
        true ->
          {Elm ,H+1, {Elem, 1, {}, {}}, RChild}
      end;
    true ->
      {ChildElem, ChildHeight, ChildLChild, ChildRChild} = insertBT(LChild, Elem),
      if
        H > ChildHeight ->
          {Elm, H, {ChildElem, ChildHeight, ChildLChild, ChildRChild}, RChild};
        true ->
          {Elm ,H+1, {ChildElem, ChildHeight, ChildLChild, ChildRChild}, RChild}
      end
  end,
  splay({Elm, H, LChild, RChild},Elem);
insertBT({Elm, H, LChild, RChild}, Elem) when Elm > Elem ->
  REmpty = isEmptyBT(RChild),
  if
    REmpty == true ->
      if
        H > 1 ->
          {Elm, H, LChild, {Elem, 1, {}, {}}};
        true ->
          {Elm ,H+1, LChild, {Elem, 1, {}, {}}}
      end;
    true ->
      {ChildElem, ChildHeight, ChildLChild, ChildRChild} = insertBT(LChild, Elem),
      if
        H > ChildHeight ->
          {Elm, H, LChild, {ChildElem, ChildHeight, ChildLChild, ChildRChild}};
        true ->
          {Elm ,H+1, LChild, {ChildElem, ChildHeight, ChildLChild, ChildRChild}}
      end
  end,
  splay({Elm, H, LChild, RChild},Elem).


deleteBT(B, Ele) -> deleteBT_reku(B, Ele).
deleteBT_reku({}, _Ele) -> {};
deleteBT_reku({ZuLoeschen, {}, {}, _H}, ZuLoeschen) -> {};
deleteBT_reku(_B={W, L, {}, _H}, W) -> L;
deleteBT_reku(_B={W, {}, R, _H}, W) -> R;
deleteBT_reku(_B={W, L, R, _H}, W) ->
  {Ersatzwert, NeuRechts} = getMinimumAndRemove(R),
  {Ersatzwert, L, NeuRechts, avltree:get_hoehe(L, NeuRechts)};
deleteBT_reku(_B={W, L, R, _H}, ZuLoeschen) when ZuLoeschen < W ->
  NeuLinks = deleteBT_reku(L, ZuLoeschen),
  {W, NeuLinks, R, avltree:get_hoehe(NeuLinks, R)};
deleteBT_reku(_B={W, L, R, _H}, ZuLoeschen) when ZuLoeschen > W ->
  NeuRechts = deleteBT_reku(R, ZuLoeschen),
  {W, L, NeuRechts, avltree:get_hoehe(L, NeuRechts)}.

%%deleteBT(BTree, Elem) ->
%%  splay(BTree,Elem).

%%findBT(B={E, _L, _R, H}, E) ->
%%  {H, B};
%%findBT(B, E) ->
%%  {B_neu={Bw, _Bl, _Br, Bh}, _} = findBT_(B, E, []),
%%  case Bw == E of
%%    true -> {Bh, B_neu};
%%    false -> {0, B}
%%  end.
%%findBT_(B={E, _L, _R, _H}, E, PStack) ->
%%  splay(B, PStack, []);
%%findBT_(B={}, _E, _PStack) ->
%%  {B, []};
%%findBT_(_B={W, L, R, H}, E, PStack) when E < W ->
%%  {L_neu, RStack} = findBT_(L, E, [l | PStack]),
%%  B_neu = {W, L_neu, R, H},
%%  splay(B_neu, PStack, RStack);
%%findBT_(_B={W, L, R, H}, E, PStack) when E > W ->
%%  {R_neu, RStack} = findBT_(R, E, [r | PStack]),
%%  B_neu = {W, L, R_neu, H},
%%  splay(B_neu, PStack, RStack)

%%TODO: Funktion implementieren
inOrderBT(BTree) ->
  ok.
%%TODO: Funktion implementieren
printBT(BTree, Filename) ->
  ok.


zig_zag({Elem, Height, LTree, RTree}, Node, Direction) ->
  case Direction of
    lft ->
      New_RTree = zig(RTree, Node, rgt),
      zig({Elem, Height, LTree, New_RTree}, New_RTree, lft);
    rgt ->
      New_LTree = zig(LTree, Node, lft),
      zig({Elem, Height, New_LTree, RTree}, New_LTree, rgt)
  end.

zig_zig(BTree={_Elem, _Height, _LTree, RTree}, Node, lft) ->
  zig(zig(BTree, RTree, lft), Node, lft);
zig_zig(BTree={_Elem, _Height, LTree, _RTree}, Node, rgt) ->
  zig(zig(BTree, LTree, rgt), Node, rgt)
.

zig({Elem, _Height, LTree={_,L_Height,_,_}, _RTree}, {R_Elem, RR_Height, R_LTree={_,RL_Height,_,_}, R_RTree}, lft) ->
  NL_Height = erlang:max(RL_Height, L_Height)+1,
  {R_Elem, erlang:max(NL_Height, RR_Height), {Elem, NL_Height, LTree, R_LTree}, R_RTree};
zig({Elem, _Height, _LTree, RTree={_,R_Height,_,_}}, {L_Elem, _L_Height, L_LTree={_,LL_Height,_,_}, L_RTree={_,LR_Height,_,_}}, rgt) ->
  NR_Height = erlang:max(LR_Height, R_Height)+1,
  {L_Elem, erlang:max(NR_Height, LL_Height), L_LTree, {Elem, NR_Height, L_RTree, RTree}}.

findBT({}, _) ->
  {-1,{}};
findBT(BTree={Elem, Height, _LTree, _RTree},Elem) ->
  {Height, BTree};
findBT(BTree, Elem)->
  case findBT(BTree, Elem, []) of
    {-1, Path} ->
      {-1, {}};
    {Height, Node, Path} ->
      splay(Node, Path)
  end.

findBT({}, _, Path) ->
  {-1, Path};
findBT(Node={Elem, Height, _LTree, _RTree}, Elem, Path) ->
  {Height, Node, Path};
findBT({Elem, Height, LTree, _RTree}, Ele, Path) when Elem > Ele ->
  findBT(LTree, Ele, append({lft, {Elem, Height, LTree, _RTree}}, Path));
findBT({Elem, Height, _LTree, RTree}, Ele, Path) when Elem < Ele ->
  findBT(RTree, Ele, append({rgt, {Elem, Height, _LTree, RTree}}, Path))
.

findTP({}, _) ->
  {-1,{}};
findTP(BTree={Elem, Height, _LTree, _RTree},Elem) ->
  {Height, BTree};
findTP(BTree, Elem)->
  case findBT(BTree, Elem, []) of
    {-1, Path} ->
      {-1, {}};
    {Height, Node, Path} ->
      splay(Node, Path)
  end.

findTP({}, _, Path) ->
  {-1, Path};
findTP(Node={Elem, Height, _LTree, _RTree}, Elem, Path) ->
  {Height, Node, Path};
findTP({Elem, Height, LTree, _RTree}, Ele, Path) when Elem > Ele ->
  findBT(LTree, Ele, append(Path, {lft, {Elem, Height, LTree, _RTree}}));
findTP({Elem, Height, _LTree, RTree}, Ele, Path) when Elem < Ele ->
  findBT(RTree, Ele, append(Path, {rgt, {Elem, Height, _LTree, RTree}}))
.

splay(Node, [{Dir, Parent}]) ->
  zig(Parent, Dir);
splay(Node, [{Dir, Parent},{Dir,Grandparent} | Path]) ->
  New_Node = zig_zig(Grandparent, Dir),
  splay(New_Node, Path);
splay(Node, [{Dir, Parent},{_,Grandparent} | Path]) ->
  New_Node = zig_zag(Grandparent, Dir),
  splay(New_Node, Path).

append([], []) ->
  [];
append([],[H|T]) ->
  [H|T];
append([],Elem) ->
  [Elem];
append([H|T], []) ->
  [H|T];
append(Elem, []) ->
  [Elem];
append([H1|T1],[H2|T2]) ->
  append([H1|T1] ++ [H2], T2);
append([H|T],Elem) ->
  [H|T] ++ [Elem];
append(L,[H|T]) ->
  append([L] ++ [H], T);
append(E1,E2) ->
  [E1] ++ [E2].
