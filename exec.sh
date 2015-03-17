# compile then run

rebar compile && \
erl -noshell -pa $(pwd)/ebin/ -s kitty_server start_link
