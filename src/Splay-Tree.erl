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
-export([]).

initBT() ->
  {}.

isBT(BTree) ->
  ok.

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

insertBT(BTree, Elem) ->
  ok.

deleteBT(BTree, Elem) ->
  ok.

findBT(BTree, Elem) ->
  ok.

findTP(BTree, Elem) ->
  ok.

inOrderBT(BTree) ->
  ok.

printBT(BTree, Filename) ->
  ok.

hoehe_von(BTree) ->
  ok.