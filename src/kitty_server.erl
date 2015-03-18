-module (kitty_server).
-export ([start_link/0, order_cat/4, return_cat/2, close_shop/1]).

-record (cat, {name, color=green, description}).


start_link() ->
	spawn_link(fun init/0).

% 
order_cat(Pid, Name, Color, Description) ->
	Ref = erlang:monitor(process, Pid),
	Pid ! {self(), Ref, {order, Name, Color, Description}},
	receive
		{Ref, Cat} ->
			io:format("order_cat1~n"),
			erlang:demonitor(Ref, [flush]),
			Cat;
		{'DOWN', Ref, process, Pid, Reason} ->
			io:format("order_cat2~n"),
			erlang:error(Reason)
		after 5000 ->
			io:format("order_cat3~n"),
			erlang:error(timeout)
		end.

	return_cat(Pid, Cat = #cat{}) ->
		io:format("order_cat4~n"),
		Pid ! {return, Cat},
		ok.

	close_shop(Pid) ->
		io:format("order_cat5~n"),
		Ref = erlang:monitor(process, Pid),
		Pid ! {self(), Ref, terminate},
		receive
			{Ref, ok} ->
				io:format("order_cat6~n"),
				erlang:demonitor(Ref, [flush]),
				ok;
			{'DOWN', Ref, process, Pid, Reason} ->
				io:format("order_cat7~n"),
				erlang:error(Reason)
		after 5000 ->
			io:format("order_cat8~n"),
			erlang:error(timeout)
		end.

init() ->
	io:format("ここに来てる~n"),
	loop([]).

loop(Cats) ->
	io:format("looping~n"),

	receive
		{Pid, Ref, {order, Name, Color, Description}} ->
			io:format("create new Cat 1~n"),
			if Cats =:= [] ->
				Pid ! {Ref, make_cat(Name, Color, Description)},
				loop(Cats);

				Cats =/= [] ->
					Pid ! {Ref, hd(Cats)},
					loop(tl(Cats))
			end;
		{return, Cat = #cat{}} ->
			io:format("return created Cat 2~n"),
			loop([Cat | Cats]);
		{Pid, Ref, terminate} ->
			io:format("3~n"),
			Pid ! {Ref, ok},
			terminate(Cats);
		Unknown ->
			io:format("4~n"),
			io:format("Unknown message: ~p~n", [Unknown]),
			loop(Cats)
	end,
	io:format("5~n").

make_cat(Name, Col, Desc) ->
	io:format("make_cat~n"),
	#cat{name = Name, color = Col, description = Desc}.

terminate(Cats) ->
	[io:format("~p was set free.~n", [C#cat.name]) || C <- Cats],
	ok.

