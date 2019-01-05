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
-export([isBT/1,initBT/0,isEmptyBT/1,equalBT/2,eqBT/2,insertBT/2,deleteBT/2,findBT/2,findTP/2,inOrderBT/1,printBT/2]).

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
insertBT(BTree, Elem) ->
  {N_Elem, N_Height, N_LTree, N_RTree} = findBT(BTree, Elem),
  LEmpty = isEmptyBT(N_LTree),
  REmpty = isEmptyBT(N_RTree),
  case N_Elem > Elem of
    false when LEmpty ->
      {Elem, N_Height+1, {N_Elem, 1, {}, {}}, N_RTree};
    false ->
      {_E,H,_L,_R} = N_LTree,
      {Elem, N_Height, {N_Elem, H+1, N_LTree, {}}, N_RTree};
    true when REmpty ->
      {Elem, N_Height+1, N_LTree, {N_Elem, 1, {}, {}}};
    true ->
      {_E,H,_L,_R} = N_RTree,
      {Elem, N_Height, N_LTree, {N_Elem, H+1, {}, N_RTree}}
end.

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
    {-1, [{Dir, Node}|Path]} ->
      New_BTree = splay(Node, Path),
      {-1, New_BTree};
    {Height, Node, Path} ->
      New_BTree = splay(Node, Path),
      {Height, New_BTree}
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
  case findTP(BTree, Elem, []) of
    {-1, Path} ->
      {-1, {}};
    {Height, Node, Path} ->
      New_BTree = tp(Node, Path),
      {Height, New_BTree}
  end.

findTP({}, _, Dir) ->
  {-1, Dir};
findTP(Node={Elem, Height, _LTree, _RTree}, Elem, Path) ->
  {Height, Node, Path};
findTP({Elem, Height, LTree, _RTree}, Ele, Path) when Elem > Ele ->
  findTP(LTree, Ele, append({lft, {Elem, Height, LTree, _RTree}}, Path));
findTP({Elem, Height, _LTree, RTree}, Ele, Path) when Elem < Ele ->
  findTP(RTree, Ele, append({rgt, {Elem, Height, _LTree, RTree}}, Path))
.

tp(Node, [{Dir, Parent}|Path]) ->
  New_Node = zig(Parent, Node, Dir),
  tp_(New_Node, Path).

tp_(Node, []) ->
  Node;
tp_(Node, [{Dir, {Elem, Height, LTree, RTree}}|Path]) ->
  case Dir of
    lft ->
      New_Node = {Elem, Height, Node, RTree};
    rgt ->
      New_Node = {Elem, Height, LTree, Node}
  end,
  tp_(New_Node, Path)
.

splay(Node, [{Dir, Parent}]) ->
  zig(Parent, Node, Dir);
splay(Node, [{Dir, Parent},{Dir,Grandparent} | Path]) ->
  New_Node = zig_zig(Grandparent, Node, Dir),
  splay(New_Node, Path);
splay(Node, [{Dir, Parent},{_,Grandparent} | Path]) ->
  New_Node = zig_zag(Grandparent, Node, Dir),
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


printBT({}, Filename) ->
  util:logging(Filename, "digraph avltree {}");
printBT(BTree, Filename) ->
  util:logging(Filename, "digraph avltree {\n"),
  printBTNode(BTree, Filename),
  util:logging(Filename, "}").

printBTNode({Elem, _, {}, {}}, Filename) ->
  util:logging(Filename, "\"" ++ util:to_String(Elem) ++ "\"");
printBTNode({Elem, _, {}, RTree={R_Elem, R_Height, _, _}}, Filename) ->
  util:logging(Filename, "\"" ++ util:to_String(Elem) ++ "\" -> \"" ++ util:to_String(R_Elem) ++ "\" [label = " ++ util:to_String(R_Height) ++ "];\n"),
  printBTNode(RTree, Filename);
printBTNode({Elem, _, LTree={L_Elem, L_Height, _, _}, {}}, Filename) ->
  util:logging(Filename, "\"" ++ util:to_String(Elem) ++ "\" -> \"" ++ util:to_String(L_Elem) ++ "\" [label = " ++ util:to_String(L_Height) ++ "];\n"),
  printBTNode(LTree, Filename);
printBTNode({Elem, _, LTree={L_Elem, L_Height, _, _}, RTree={R_Elem, R_Height, _, _}}, Filename) ->
  util:logging(Filename, "\"" ++ util:to_String(Elem) ++ "\" -> \"" ++ util:to_String(R_Elem) ++ "\" [label = " ++ util:to_String(R_Height) ++ "];\n"),
  util:logging(Filename, "\"" ++ util:to_String(Elem) ++ "\" -> \"" ++ util:to_String(L_Elem) ++ "\" [label = " ++ util:to_String(L_Height) ++ "];\n"),
  printBTNode(RTree, Filename),
  printBTNode(LTree, Filename).

inOrderBT({}) ->
  [];
inOrderBT({Elem, _Height, {}, {}}) ->
  [Elem];
inOrderBT({Elem, _Height, {}, RTree}) ->
  [Elem] ++ inOrderBT(RTree);
inOrderBT({Elem, _Height, LTree, {}})->
  inOrderBT(LTree) ++ [Elem];
inOrderBT({Elem, _Height, LTree, RTree}) ->
  inOrderBT(LTree) ++ [Elem] ++ inOrderBT(RTree).

deleteBT({},_) ->
  {};
deleteBT(BTree, Elem) ->
  case deleteBT_(BTree, Elem) of
    ok ->
      findBT(BTree, Elem);
    fail ->
      BTree
  end
  .

deleteBT_({}, _) ->
  fail;
deleteBT_({Elem, _Height, _LTree, _RTree}, Elem) ->
  ok;
deleteBT_({Elem, Height, LTree, RTree}, Ele) ->
  case Elem > Ele of
    false ->;
    true ->
end
  deleteBT_({Elem, Height, LTree, RTree}, Ele).


  %New_BTree = findBT(BTree, Ele).

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

deleteBT({Atom, Grad, LinkerTeilBaum, RechterTeilBaum}, Element) when Element > Atom->
  NeuerRechterTeil = deleteBT(RechterTeilBaum, Element),
  case Grad-getHeight(NeuerRechterTeil) == 1 orelse Grad-getHeight(LinkerTeilBaum) == 1 of
    true ->
      {NeuBaumAtom, NeuBaumHoehe, NeuBaumLinks, NeuBaumRechts} = {Atom, Grad, LinkerTeilBaum, NeuerRechterTeil};
    false ->
      {NeuBaumAtom, NeuBaumHoehe, NeuBaumLinks, NeuBaumRechts} = {Atom, Grad-1, LinkerTeilBaum, NeuerRechterTeil}
  end,
  case (getHeight(NeuBaumRechts) - getHeight(NeuBaumLinks) < -1) orelse (getHeight(NeuBaumRechts) - getHeight(NeuBaumLinks) > 1) of
    true ->
      {_NBLAtom, _NBLHoehe, NBLLinks, NBLRechts} = NeuBaumLinks,
      case 	( getHeight(NBLLinks) >= getHeight(NBLRechts) ) of
        true ->
          rotateRight({NeuBaumAtom, NeuBaumHoehe, NeuBaumLinks, NeuBaumRechts});
        false ->
          rotateRight({NeuBaumAtom, NeuBaumHoehe, rotateLeft(NeuBaumLinks), NeuBaumRechts})
      end;
    false ->
      {NeuBaumAtom, NeuBaumHoehe, NeuBaumLinks, NeuBaumRechts}
  end.

