
-module(exchange).
-export([print/1, start/0]).

print(Flag)->
  receive
    {Key,Value,intro,T} ->
      io:fwrite("~p received intro message from ~p [~p]~n",[Key,Value,T]),
      print(Flag+2);
    {Key,Value,reply,T} ->
      io:fwrite("~p received reply message from ~p [~p]~n",[Key,Value,T]),
      print(Flag+2)
  after
    2500->
      io:fwrite("Master has received no replies for 10 seconds, ending...\n",[])
  end.


start() ->
  Storage = file:consult("calls.txt"),
  Call_file=element(2,Storage),
  io:fwrite("~n"),
  io:fwrite("** Calls to be made ** ~n" ),
  io:fwrite("~n"),
  Disp=maps:from_list(Call_file),
  maps:fold(fun(K, V, ok) -> io:format("~p: ~p~n", [K, V]) end, ok, Disp),

  lists:foreach( fun(List)->
    {Key,Values} = List,
    Pid = spawn(calling,callBack,[Key, Values,self(),1]),
    register(Key,Pid) end,Call_file
  ),
  io:format("~n",[]),

  print(1).

