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
isBT({Elem,Height,LNeighbour,RNeighbour})when is_integer(Height) ->
  L = isBT(LNeighbour),
  R = isBT(RNeighbour),
  if
    L == R == true ->
      true;
    true ->
      false
  end;
isBT(_) ->
  false.

isEmptyBT(BTree) ->
  if
    BTree == {} -> true;
    true -> false
  end.

equalBT(BTreeOne, BTreeTwo) ->
  if
    BTreeOne == BTreeTwo -> true;
    true -> false
  end.

eqBT(BTreeOne, BTreeTwo) ->
  ok.

insertBT({}, Elem) ->
  NewBTree;
insertBT(BTree, Elem) ->
  {Elm, Height,{}, {}} = BTree,
  if
    Elem =  -> ;
    true ->
  end,
splay(BTree,Elem).

deleteBT(BTree, Elem) ->
  splay(BTree,Elem).


findBT(BTree, Elem) ->
  splay(BTree,Elem).

findTP(BTree, Elem) ->
  splay(BTree,Elem).

inOrderBT(BTree) ->
  ok.

printBT(BTree, Filename) ->
  ok.

hoehe_von(BTree) ->
  ok.

splay(BTree,Elem) ->
  NewBTree =
  NewBTree.
