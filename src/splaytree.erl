%%%-------------------------------------------------------------------
%%% @author Elton
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Dez 2018 20:05
%%%-------------------------------------------------------------------
-module(splaytree).
-author("Elton").

%% API
-export([isBT/1,initBT/0,isEmptyBT/1,equalBT/2,eqBT/2,insertBT/2,deleteBT/2,findBT/2,findTP/2,inOrderBT/1,printBT/2]).

initBT() ->
  util:countreset(leftrotate),
  util:countreset(rightrotate),
  util:countreset(ddleftrotate),
  util:countreset(ddrightrotate),
  {}.


isBT({}) ->
  true;
isBT({Elem,Height,LChild,RChild})when is_integer(Height) and is_integer(Elem) ->
  L = isBT(LChild),
  R = isBT(RChild),
  if
    L ->
      if
        R -> true;
        true -> false
      end;
    true ->
      false
  end;
isBT(_) ->
  false.

isEmptyBT({}) ->
  true;
isEmptyBT(_) ->
  false.

equalBT({_Elem1, _Height1, LTree1, RTree1}, {_Elem2, _Height2, LTree2, RTree2}) ->
  equalBT(LTree1, LTree2) and equalBT(RTree1, RTree2);
equalBT({}, {}) ->
  true;
equalBT(_BTree1,_BTree2) ->
  false.

eqBT(BTreeOne, BTreeTwo) ->
  inOrderBT(BTreeOne) == inOrderBT(BTreeTwo).

insertBT({}, Elem) ->
  {Elem,1,{},{}};
insertBT({Elm, H, LChild, RChild}, Elem) when Elm > Elem ->
  LEmpty = isEmptyBT(LChild),
  util:logging("asd", util:to_String(Elm) ++ " : " ++ util:to_String(Elem) ++ " Elm greater\n"),
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
  end;
insertBT({Elm, H, LChild, RChild}, Elem) when Elm < Elem ->
  REmpty = isEmptyBT(RChild),
  util:logging("asd", util:to_String(Elm) ++ " : " ++ util:to_String(Elem) ++ " Elem greater\n"),
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

zig({Elem, _Height, LTree={_,L_Height,_,_}, _RTree}, {R_Elem, RR_Height, R_LTree, R_RTree}, lft) ->
  NL_Height = L_Height+1,
  util:counting1(leftrotate),
  {R_Elem, RR_Height, {Elem, NL_Height, LTree, R_LTree}, R_RTree};
zig({Elem, _Height, _LTree, RTree={_,R_Height,_,_}}, {L_Elem, _L_Height, L_LTree, L_RTree}, rgt) ->
  NR_Height = R_Height+1,
  util:counting1(rightrotate),
  {L_Elem, NR_Height, L_LTree, {Elem, NR_Height, L_RTree, RTree}}.

findBT({}, _) ->
  {0,{}};
findBT(BTree={Elem, Height, _LTree, _RTree},Elem) ->
  {Height, BTree};
findBT(BTree, Elem)->
  case findBT(BTree, Elem, []) of
    {-1, [{_Dir, Node}|Path]} ->
      New_BTree = splay(Node, Path),
      {-1, New_BTree};
    {Height, Node, Path} ->
      New_BTree = splay(Node, Path),
      {Height, New_BTree}
  end.

findBT({}, _, Path) ->
  {0, Path};
findBT(Node={Elem, Height, _LTree, _RTree}, Elem, Path) ->
  {Height, Node, Path};
findBT(Node={Elem, Height, LTree, _RTree}, Ele, Path) when Elem > Ele ->
  case isEmptyBT(LTree) of
    false -> findBT(LTree, Ele, append({lft, {Elem, Height, LTree, _RTree}}, Path));
    true -> {Height, Node, Path}
  end;
findBT(Node={Elem, Height, _LTree, RTree}, Ele, Path) when Elem < Ele ->
  case isEmptyBT(RTree) of
    false -> findBT(RTree, Ele, append({rgt, {Elem, Height, _LTree, RTree}}, Path));
    true -> {Height, Node, Path}
end
.

findTP({}, _) ->
  {-1,{}};
findTP(BTree={Elem, Height, _LTree, _RTree},Elem) ->
  {Height, BTree};
findTP(BTree, Elem)->
  case findTP(BTree, Elem, []) of
    {-1, _Path} ->
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

splay(Node, []) ->
  Node;
splay(Node, [{Dir, Parent}]) ->
  zig(Parent, Node, Dir);
splay(Node, [{Dir, _Parent},{Dir,Grandparent} | Path]) ->
  New_Node = zig_zig(Grandparent, Node, Dir),
  splay(New_Node, Path);
splay(Node, [{Dir, _Parent},{_,Grandparent} | Path]) ->
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
  util:logging(Filename, "digraph BTREE {}");
printBT(BTree, Filename) ->
  util:logging(Filename, "digraph BTREE\n{\n"),
  printBTNode(BTree, Filename),
  util:logging(Filename, "}").

printBTNode({Elem, _, {}, {}}, Filename) ->
  ok;
printBTNode({Elem, _, {}, RTree={R_Elem, R_Height, _, _}}, Filename) ->
  util:logging(Filename, util:to_String(Elem) ++ " -> " ++ util:to_String(R_Elem) ++ " [label = " ++ util:to_String(R_Height) ++ "];\n"),
  printBTNode(RTree, Filename);
printBTNode({Elem, _, LTree={L_Elem, L_Height, _, _}, {}}, Filename) ->
  util:logging(Filename, util:to_String(Elem) ++ " -> " ++ util:to_String(L_Elem) ++ " [label = " ++ util:to_String(L_Height) ++ "];\n"),
  printBTNode(LTree, Filename);
printBTNode({Elem, _, LTree={L_Elem, L_Height, _, _}, RTree={R_Elem, R_Height, _, _}}, Filename) ->
  util:logging(Filename, util:to_String(Elem) ++ " -> " ++ util:to_String(R_Elem) ++ " [label = " ++ util:to_String(R_Height) ++ "];\n"),
  util:logging(Filename, util:to_String(Elem) ++ " -> " ++ util:to_String(L_Elem) ++ " [label = " ++ util:to_String(L_Height) ++ "];\n"),
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
      {Height,{_N_Elem, _N_Height, N_LTree, _N_RTree}} = findBT(BTree, Elem),
      {{Elem, Height, _LTree, {}}, Path} = findMax(N_LTree, []),
      updateTree({Elem, Height, _LTree, {}}, {Elem, Height, _LTree, {}}, Path);
    fail ->
      BTree
  end
  .

deleteBT_({}, _) ->
  fail;
deleteBT_({Elem, _Height, _LTree, _RTree}, Elem) ->
  ok;
deleteBT_({Elem, _Height, LTree, RTree}, Ele) ->
  case Elem > Ele of
    false -> deleteBT_(RTree, Ele);
    true -> deleteBT_(LTree, Ele)
  end.

updateTree({Elem, _Height, _LTree, {}}, {_N_Elem, N_Height, N_LTree, N_RTree}, []) ->
  {Elem, N_Height, N_LTree, N_RTree};
updateTree({Elem, Height, LTree, {}},{_N_Elem, _N_Height, _N_LTree, {}}, [{_Dir, _Parent={P_Elem, P_Height, P_LTree, _P_R_Tree}}|Path]) ->
  New_Node = {P_Elem, P_Height, P_LTree, LTree},
  updateTree({Elem, Height, LTree, {}}, New_Node, Path).

findMax({Elem, Height, _LTree, {}}, Path) ->
  {{Elem, Height, _LTree, {}}, Path};
findMax({_Elem, _Height, _LTree, RTree}, Path) ->
  findMax(RTree, append({rgt, {_Elem, _Height, _LTree, RTree}},Path)).