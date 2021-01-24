

-module(calling).
-export([callBack/4]).

callBack(Key,Values,Main_Pid,Flag)->

  if

    Flag == 1 ->
      timer:sleep(250),
      lists:foreach(
      fun(Key_Value) -> whereis(Key_Value)!{Key,intro,element(3,now())}
      end, Values
      ),
      callBack(Key,Values, Main_Pid, Flag + 2);

    Flag > 1 ->

      receive

        {Exisiting_Key,intro,T} ->
          Main_Pid!{Key,Exisiting_Key,intro,T},
          whereis(Exisiting_Key)!{Key,reply,T},
          callBack(Key,Values, Main_Pid, Flag + 2);

        {Exisiting_Key,reply,T} ->
          Main_Pid!{Key,Exisiting_Key,reply,T},
          callBack(Key,Values, Main_Pid, Flag + 2)
      after
        1500->
          io:fwrite("Process ~p has received no calls for 5 seconds, ending...~n",[Key])

      end

  end.

