::  Tic-Tac-Toe
::
::  ~norsyr, the currently-canonical way to do that is to have the subscriber
::  add a unique id into the subscription path
::
::  i.e in tic tac toe, you could say, players subscribe on a game session id,
::  and then you just do per-game updates
::
/-  *toe, *sole
/+  default-agent, sole-lib=sole, *server, *toe, verb
::
:: This imports the tile's JS file from the file system as a variable.
::
/=  tile-js
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/toe/js/tile
  /|  /js/
      /~  ~
  ==
::
=,  format
::
=>  |%
    ::
    +|  %models
    ::
    +$  versioned-state
      $%  [%0 state-zero]
      ==
    ::
    +$  state-zero
      $:  ::  %rooms: Active/Pending games
          ::
          rooms=game-rooms
          ::  %active: room that receives console board moves
          ::
          active=(unit ship)
          ::  %next: flag to indicate a confirmed replay
          ::
          next=?
          ::  %game: game loop global state
          ::
          game=game-state
          ::  %cli: console state
          ::
          ::  TODO: allow for multiple console states
          ::
          cli=state=sole-share
      ==
    ::
    +$  card  card:agent:gall
    ::  FIXME: $spot has to be redefined even though it's already in sur...
    ::
    +$  spot  [coord coord]
    --
::
=|  state-zero
=*  state  -
::  Main
::
%+  verb  |
^-  agent:gall
=<  |_  =bowl:gall
    +*  this      .
        toe-core  +>
        tc        ~(. toe-core bowl)
        def       ~(. (default-agent this %|) bowl)
    ::
    ++  on-init
      ^-  (quip card _this)
      =.  state  wipe:tc
      :_  this
      :~  [%pass /bind/toe %arvo %e %connect [~ /'~toe'] %toe]
          ~&  poking-launch+our.bowl
          :*  %pass  /launch/toe  %agent  [our.bowl %launch]  %poke
              %launch-action  !>([%toe /toetile '/~toe/js/tile.js'])
      ==  ==
    ::
    ++  on-save   !>(state)
    ++  on-load
      |=  old=vase
      `this(state !<(state-zero old))
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      =^  cards  state
        ?+    mark  (on-poke:def mark vase)
            %handle-http-request
           ~&  poked+[mark vase src.bowl]
          =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
          :_  state
          %+  give-simple-payload:app  eyre-id
          %+  require-authorization:app  inbound-request
          handle-http-request:fe:view:tc
        ::
            %json
           ~&  poked+[mark vase src.bowl]
          (poke-json:fe:view:tc !<(json vase))
        ::
            %sole-action
          (poke-sole-action:co:view:tc !<(sole-action vase))
        ::
            %toe-player
           ~&  poked+[mark vase src.bowl]
          (receive:room-core:tc src.bowl)
        ::
            %toe-cancel
           ~&  poked+[mark vase src.bowl]
          ?~  rooms  `state
          (cancel:room-core:tc src.bowl)
        ::
            %urbit
           ~&  poked+[mark vase src.bowl]
          ::  TODO: Don't block when receiving a request to play
          ::
          (receive:room-core:tc !<(@p vase))
        ==
      [cards this]
    ::
    ++  on-watch
      |=  pax=path
      ^-  (quip card _this)
      ~&  [watch+pax src.bowl]
      =^  cards  state  (connect:tc pax)
      [cards this]
    ::
    ++  on-leave
    |=  =path
    ~&  leaving+[path src.bowl]
    `this
    ::
    ++  on-peek   on-peek:def
    ++  on-agent
      |=  [=wire =sign:agent:gall]
      ^-  (quip card _this)
      ~&  connected+[wire src.bowl sign]
      ?-    -.sign
          %poke-ack   (on-agent:def wire sign)
          %watch-ack  ~&  "conf {<wire>}"  (on-agent:def wire sign)
        ::
          %kick
        =^  cards  state
          (close:room-core:tc %.y)
        [cards this]
      ::
          %fact
        =^  cards  state
          =*  vase  q.cage.sign
          ^-  (quip card _state)
          ?+    p.cage.sign  ~|([%toe-bad-sub-mark wire vase] !!)
              %toe-winner
            (update:room-core:tc spo:tur:!<(toe-winner vase))
          ::
              %toe-turno
            (update:room-core:tc spo:!<(toe-turno vase))
          ==
        [cards this]
      ==
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  (quip card:agent:gall _this)
      ~&  arvoed+[wire src.bowl]
      ?:  ?=(%bound +<.sign-arvo)
        [~ this]
      (on-arvo:def wire sign-arvo)
    ::
    ++  on-fail   on-fail:def
    --
::
|_  bol=bowl:gall
+*  me  our.bol
::  +wipe: resets the state of the game
::
++  wipe
  ^-  _state
  %_  state
      rooms   ~
      next    %.n
      game    %begin
      active  ~
  ==
::  +game-loop: processes user input based on current state
::
++  game-loop
  =<  |_  command=tape
      ++  action
        ^-  (quip card _state)
        =^  edit  state.cli  (to-sole:co:view reset)
        =^  cards  state
          ?-    game
            ::  Game Engine Step 1: sends invitation to play
            ::
            %begin    (begin command)
            ::  Game Engine Step 2: blocks dojo for confirmation
            ::
            %wait     [~ state]
            ::  Game Engine Step 2.1: blocks dojo for confirmation
            ::
            %confirm  (confirm command)
            ::  Game Engine Step 3: game starts
            ::
            %play     (play command)
            ::  Game Engine Step 4: game ends, waits for end/continue?
            ::
            %replay   (confirm command)
          ==
        :_  state
        [(send:co:view det+edit) cards]
      --
  |%
  ++  begin
      |=  command=tape
      ^-  (quip card _state)
      =/  req=(unit @p)  (rust command ;~(pfix sig fed:ag))
      ?~  req
        [~ state]
      ?:  =(u.req me)
        [not-allowed:updates:view state]
      =,  room-core
      [(invite u.req) (create [u.req %wait])]
  ::
  ++  play
    |=  command=tape
    ^-  (quip card _state)
    =/  pos=(unit [@ @])
      =-  (rust command ;~((glue fas) - -))
      (cook |=(a=@t (rash a dem)) (shim '1' '3'))
    ?~  pos  [~ state]
    ?.   =(me who:current:room-core)
      :_  state
      [(send:co:view wait-your-turn)]~
    =/  bc  ~(. board-core [room:current:room-core (spot u.pos)])
    ?:  has:bc
      :_  state
      [(send:co:view spot-taken)]~
    =/  who=@p  who:current:room-core
    =^  cards  state  (update:room-core (spot u.pos))
    :_  state
    %+  weld
      cards
    ^-  (list card)
    :~  =-  [%give %fact `/room/(scot %p ship:current:room-core) -]
        ?:  =(~ out:bc)  [%toe-turno !>(turno:bc)]
        [%toe-winner !>([(end:co:view [out:bc who]) turno:bc])]
    ==
  ::
  ++  confirm
    |=  command=tape
    ^-  (quip card _state)
    =/  answer=(unit @t)  (rust (cass command) (mask "yn"))
    ?~  answer  [~ state]
    =,  room-core
    ?:(=(u.answer 'n') (close %.n) confirm)
  --
::  +room-core: handles actions to a game room
::
++  room-core
  |%
  ::  %create: appends new room with a player (e.g. ~zod)
  ::
  ++  create
    |=  [guest=@p =game-state]
    ^-  _state
    ~&  create+guest
    state(rooms (snoc rooms [guest ~]), game game-state)
  ::  %invite: sends an invite to play with opponent (e.g. ~zod)
  ::
  ++  invite
    |=  guest=@p
    ^-  (list card)
    =,  view
    ^-  (list card)
    :~  [%pass /request %agent [guest %toe] %poke %urbit !>(me)]
        (waiting:updates:co guest)
        (waiting:updates:fe guest)
    ==
  ::  %receive: a guest ship sends an invite to play/replay
  ::
  ++  receive
    |=  guest=@p
    ^-  (quip card _state)
    ~&  active+active
    =/  enqueue
      =,  updates:view
      :-  (receive guest)
      (create [guest ?~(active %confirm game)])
    ?~  active  enqueue
    ?.  =(guest u.active)  enqueue
    :_  state(next %.y)
    (notify:updates:view guest)
  ::  %confirm:  innitializes room state and starts game
  ::
  ++  confirm
    ::  TODO: not only handle oldest room invite (i.rooms)
    ::
    ^-  (quip card _state)
    ?>  ?=(^ rooms)
    =/  ze=@p  ship.i.rooms
    =/  =toers
      %-  ~(gas by *toers)
      ?.(=(%.y ^next) (player-a me ze) (player-b me ze))
    =/  who=@p
      ?~  active  me
      ?:(=(%.y ^next) me ze)
    =/  request=(list card)
      ?.  =(game %replay)
        ~&  in-confirm+[ze /play]
        [%pass /play %agent [ze %toe] %watch /room/(scot %p me)]~
      ::  Next is activated if our opponent already confirmed the replay
      ::
      ?:  =(%.y next)  ~
      =/  =toe-player  [%replay [%'X' %g]]
      [%pass /replay %agent [ze %toe] %poke %toe-player !>(toe-player)]~
    =.  rooms  [[ze `[*board-game toers who=who]] t.rooms]
    :_  state(active `ze, game %play)
    =,  view
    %+  weld
      request
    :~  (playing:updates:co ze)
        (playing:updates:fe ze)
    ==
  ::  +close: leaves the current rooms and closes subscriptions
  ::
  ++  close
    |=  kicked=?
    ~&  kicked
    ~&  wex+wex.bol
    ~&  sup+sup.bol
    ^-  (quip card _state)
    ?~  rooms
       =.  rooms  ~
       [restart:updates:view wipe]
    =/  disconnect=(list card)
      =*  ze  ship:current
      ?~  room.i.rooms
        ?:  =(kicked %.y)  ~
        [%pass /cancel %agent [ze %toe] %poke %toe-cancel !>(%bye)]~
      %+  weld
        ::  we leave our subscription
        ::
        ~&  in-close+[ze /leave/play]
        ?.  (~(has by wex.bol) [/play ze %toe])
          ~&  "none"  ~
        ^-  (list card)  [%pass /play %agent [ze %toe] %leave ~]~
      ::  ...and kick our subscriber
      ::
      ^-  (list card)  [%give %kick `/room/(scot %p ze) ~]~
    =.  room.i.rooms   ~
   ~&  disconnect+disconnect
    ?~  t.rooms
      :_  wipe
      (weld disconnect restart:updates:view)
    :-  (weld disconnect confirm:updates:view)
    state(rooms t.rooms, game %confirm, next %.n, active ~)
  ::  +crash: forced close a room from console's "!" command
  ::
  ++  crash
    =^  edit  state.cli  (to-sole:co:view reset)
    =^  cards  state  (close %.n)
    :_  state
    [(send:co:view det+edit) cards]
  ::  +cancel: cancels a /request %poke to play
  ::
  ++  cancel
    |=  guest=@p
    ~&  "cancelled"
    ~&  [guest ship:current]
    ?:  =(guest ship:current)
      (close %.n)
    ::  we get a cancel from someone waiting in the queue
    ::  the current game needs to keep going, the queue is updated
    ::  silently, and we inform the app of the event
    ::
    :-  ~[(send:co:view (left (cite:title guest)))]
    %_    state
        rooms
      %+  skip  rooms
      |=([ze=@p *] =(ze guest))
    ==
  ::  +restart: goes back to %begin state
  ::
  ++  restart
    ^-  (quip card _state)
    =.  rooms  ~
    [restart:updates:view wipe]
  ::  +join:  subscribes back to our guest so the logic to send board moves
  ::  (i.e. %give a %gift) is the same for both players
  ::
  ++  join
    |=  ze=@p
    ^-  (quip card _state)
    ~&  "{<ze>} joined"
    ?>  ?=(^ rooms)
    ::  toers.rooms needs to be modifed before we send the new state
    ::    since create dial can't access a future state
    ::
    =/  =toers  (~(gas by *toers) (player-b me ze))
    ::  Getting pokes while being in %wait/confirm state appends
    ::  new rooms at the end, so we can deal with the head
    ::  (oldest request) easily.
    ::  TODO: A future version will search for the proper room in the list.
    ::
    =:  active  `ze
        rooms   [[ze `[*board-game toers who=ze]] t.rooms]
    ==
    :_  state(game %play)
    =,  view
    :~  (playing:updates:co ze)
        (playing:updates:fe ze)
        ~&  in-join+[ze /play]
        [%pass /play %agent [ze %toe] %watch /room/(scot %p me)]
    ==
  ::  +start: the requester subscribes back and the game starts
  ++  start
    |=  ze=@p
    ^-  (quip card _state)
    ~&  "{<ze>} is ready. start!"
    =.  active  `ze
    :_  state
    =,  view
    ~[(playing:updates:co ze) (playing:updates:fe ze)]
  ::  +current: room that the user interacts with
  ::
  ++  current
    :: =<  |=  =term
    ::     :: *(map spot player)
    ::     ?+  term  !!
    ::       %b  board
    ::       %r  room
    ::       %s  ship
    ::       %w  who
    ::     ==
    |%
    ++  board
      ?>  ?=(^ rooms)
      ^-  board-game
      =*  r  room.i.rooms
      ?~(r ~ board.u.r)
    ::
    ++  room
      ::  TODO: add feature to choose current room
      ::
      ?>  ?=([[@ ^] *] rooms)
      ^-  game-room
      u.room.i.rooms
    ::
    ++  toers
      ?>  ?=(^ rooms)
      ^-  ^toers
      =*  r  room.i.rooms
      ?~(r ~ toers.u.r)
    ::
    ++  ship
      ?>  ?=(^ rooms)
      ship.i.rooms
    ::
    ++  who
      ?>  ?=(^ rooms)
      =*  r  room.i.rooms
      who:(need room.i.rooms)
    --
  ::  +next: next room waiting for confirmation
  ::
  ++  next
    |%
    ++  room
      ::  TODO: add feature to choose next room
      ::
      ?>  ?=([^ ^] rooms)
      (need room.i.t.rooms)
    ::
    ++  guest
      ?>  ?=([^ ^] rooms)
      ship.i.t.rooms
    --
  ::  +update: puts a new move on the current room's board
  ::
  ++  update
    |=  pos=spot
    ^-  (quip card _state)
    ?>  ?=([[@p ^] *] rooms)
    =*  room  u.room.i.rooms
    =/  bc  ~(. board-core [room:current pos])
    =^  out  board.room  play:bc
    =?  game  .?(out)  %replay
    =.  who.room  switch
    :_  state
    =,  updates:view
    ?~  out
      (playing turno:bc)
    (wins [out turno:bc switch])
  ::  +switch:  sets next player allowed to perform game moves
  ::
  ++  switch
    ^-  @p
    ?:(=(who:current me) ship:current me)
  ::  +stones: gets player's icons
  ::
  ++  stones
    ^-  [me=tape ze=tape]
    =/  p=player
      (~(got by toers:current) me)
    :-  (trip stone.p)
    ?:(=(stone.p %'O') "X" "O")
  --
::  +board-core: puts a new move on the board
::
++  board-core
  =<  |_  [room=game-room pos=spot]
      ++  play
        ^-  [outcome board-game]
        =.  board.room  (~(put by board.room) [pos player])
        [out board.room]
      ::
      ++  has     (~(has by board.room) pos)
      ++  player  (~(got by toers.room) who.room)
      ++  turno   ^-(toe-turno [player pos])
      ++  out     (outcome-check player board.room)
      --
  |%
  ++  outcome-check
    |=  [per=player =board-game]
    ^-  outcome
    ?:  (wins per board-game)
      `%wins
    ?.  (ties board-game)
      ~
    `%tie
  ::
  ++  wins
    |=  [per=player =board-game]
    ^-  ?
    %+  lien  winning-rows
    |=  a=(list spot)
    ^-  ?
    %+  levy  a
    |=  b=spot
    =/  p=(unit player)  (~(get by board-game) b)
    ?~(p %.n =(stone.per stone.u.p))
  ::
  ++  ties
    |=(=board-game =(~(wyt in board-game) 9))
  ::
  ++  winning-rows
    ^-  (list (list spot))
    :~  ~[[%1 %1] [%2 %1] [%3 %1]]
        ~[[%1 %2] [%2 %2] [%3 %2]]
        ~[[%1 %3] [%2 %3] [%3 %3]]
        ~[[%1 %1] [%1 %2] [%1 %3]]
        ~[[%2 %1] [%2 %2] [%2 %3]]
        ~[[%3 %1] [%3 %2] [%3 %3]]
        ~[[%1 %3] [%2 %2] [%3 %1]]
        ~[[%1 %1] [%2 %2] [%3 %3]]
    ==
  --
::  +connect: handles subscriptions and updates
::
++  connect
  |=  pax=path
  ^-  (quip card _state)
  ~&  who-connect+pax
  |^  ?+    pax  ~|([%peer-toe-strange pax] !!)
          [%sole *]           sole
          [%toetile ~]        tile
          [%room ^]           (room i.t.pax)
          [%http-response *]  [~ state]
      ==
  ::  +tile
  ::
  ++  tile
    ^-  (quip card _state)
    ~&  tiled+src.bol
    :_  state
    [%give %fact ~ %json !>(*json)]~
  ::  +sole: innitializes the console's state
  ::
  ++  sole
    ^-  (quip card _state)
    ~&  sole+[me src.bol]
    ?.  (team:title me src.bol)  ~|([%strange-sole src.bol] !!)
    :_  state(state.cli *sole-share)
    =,  co:view
    [(send mor+~[clear welcome wopr grid shall-we (prompt choose)])]~
  ::  +room: receives a subscription to connecto to a room
  ::
  ++  room
    |=  id=@t
    ^-  (quip card _state)
    =,  room-core
    ?~  rooms  [~ state]
    =/  ze=@p  (slav %p id)
    ~&  [ze ship:current]
    ?.  =(ze ship:current)  [~ state]
    ?:  =(%wait game)
      (join ze)
    ?.  =(%play game)  [~ state]
    (start ze)
  --
::  +view
::  TODO: please make me into a %view app!
::
++  view
  |%
  ::  TODO: move other view updates here
  ::
  ++  updates
    |%
    ++  restart
      ^-  (list card)
      :~  (send:co mor+all-effects:co)
          (send:fe [%status s+'null']~)
      ==
    ::
    ++  receive
      |=  guest=@p
      =/  room-name=tape  (cite:title guest)
      ?^  rooms
        (notify guest)
      :~  (send:fe ~[[%message s+(crip room-name)] [%status s+'confirm']])
          =,  co
          (send (prompt "{confirm}{room-name}? (Y/N) | "))
      ==
    ::
    ++  confirm
      =/  next=@p  guest:next:room-core
      :~  (confirm:updates:fe next)
          (confirm:updates:co next)
      ==
    ::
    ++  playing
      |=  move=toe-turno
      ^-  (list card)
      =/  [ze=@p who=@p]   =,  current:room-core
        [ship who]
      :~  ::  If the move originated in the frontend, this is redundant
          ::  so this move is ignored on the frontend (via %next)
          ::
          %-  send:fe  ^-  (list [@t json])
          :~  [%status s+'play']
              [%next s+(scot %p who)]
              [%stone s+`@t`stone.per.move]
              [%move a+~[n+(scot %u -.spo.move) n+(scot %u +.spo.move)]]
          ==
        ::
          =,  co
          %-  send  ^-  sole-effect
          :~  %mor
              grid
              %-  prompt
              %-  dial
              [ze stones:room-core ?:(=(who me) "<-" "->")]
      ==  ==
    ::
    ++  wins
      |=  [out=outcome move=toe-turno winner=@p]
      ^-  (list card)
      ~[(wins:updates:fe out move winner) (wins:updates:co [out winner])]
    ::
    ++  notify
      |=  guest=@p
      :_  ~
      (send:co klr+~[[[```%b] " [ {<guest>} wants to play ]"]])
    ::
    ++  not-allowed
      :~  (send:co frowned-upon)
        ::
          %-  send:fe
          :~  [%status s+'error']
              [%message (tape:enjs:format txt:frowned-upon)]
      ==  ==
    --
  ::  %fe: frontend
  ::
  ++  fe
    |%
    ::  +handle-http-request: serve pages from file system based on URl path
    ::
    ++  handle-http-request
      |=  =inbound-request:eyre
      ^-  simple-payload:http
      =/  request-line  (parse-request-line url.request.inbound-request)
      ~&  request-line
      ?+  request-line  not-found:gen
            [[[~ %js] [%'~toe' %js %tile ~]] ~]
          :: ~&  "loading..."
          (js-response:gen tile-js)
      ==
    ::
    ++  poke-json
      |=  jon=json
      ^-  (quip card _state)
      ~&  jon
      ?.  ?=(%o -.jon)
        ::  ignores non-object json
        ::
        [~ state]
      =/  object=(map @t json)  +.jon
      =/  data=json  (~(got by object) 'data')
      =-  ~(action game-loop (tufa -))
      ^-  (list @c)
      ?+    -.data  !!
        %a  =-  (tuba "{-<}/{->}")
            =-  :-  (scow %u (snag 0 -))
                (scow %u (snag 1 -))
            ((ar:dejs ni:dejs) data)
        %s  (tuba (trip (so:dejs data)))
      ==
    ::  +send: new data to the frontend
    ::
    ++  send
      |=  pairs=(list [@t json])
      ^-  card
      [%give %fact `/toetile %json !>((pairs:enjs:format pairs))]
    ::
    ++  updates
      |%
      ++  playing
        |=  guest=@p
        :: =/  who=@p
        ::   ?~  active  me
        ::   ?:(=(%.y ^next) me guest)
        %-  send  ^-  (list [@t json])
        :~  [%stone s+(crip me:stones:room-core)]
            [%next s+(scot %p who:current:room-core)]
            [%status s+'start']
        ==
      ::
      ++  waiting
        |=  guest=@p
        %-  send  ^-  (list [@t json])
        :~  [%message s+(scot %p guest)]
            [%status s+'select-opponent']
        ==
      ::
      ++  cancel
        ~
      ::
      ++  confirm
        |=  guest=@p
        %-  send  ^-  (list [@t json])
        :~  [%message s+(crip (cite:title guest))]
            [%status s+'confirm']
        ==
      ::
      ++  wins
        |=  [out=outcome move=toe-turno winner=@p]
        ^-  card
        %-  send  ^-  (list [@t json])
        :~  [%status s+'replay']
            [%winner ?:(=((need out) %tie) s+'tie' s+(scot %p winner))]
            [%stone s+`@t`stone.per.move]
            [%move a+~[n+(scot %u -.spo.move) n+(scot %u +.spo.move)]]
        ==
      --
    --
  ::  %co: console
  ::
  ++  co
    |%
    ++  all-effects
      ^-  (list sole-effect)
      :~  clear
          welcome
          new-line
          grid
          shall-we
          (prompt choose)
      ==
    ::
    ++  clean
      =^  edit  state.cli  (to-sole reset)
      [%det edit]
    ::
    ++  dial
      |=  [guest=ship stones=[me=tape ze=tape] arrow=tape]
      ^-  styx
      ::  +cite:title compresses the ship's name if we are dealing with a comet
      ::
      :~  [[~ ~ ~] " | "]
          [[~ ~ ~] "{(cite:title me)}"]
          [[~ ~ ~] ":["]
          [[```%g] "{me.stones}"]
          [[~ ~ ~] "] {arrow} "]
          [[~ ~ ~] "{(cite:title guest)}"]
          [[~ ~ ~] ":["]
          [[```%r] "{ze.stones}"]
          [[~ ~ ~] "] |  "]
      ==
    ::
    ++  end
      |=  [out=outcome who=@p]
      ^-  tape
      ?:(=((need out) %tie) " stalemate..." " | {<who>} wins!")
    ::  +grid: pretty prints the board displayed on the console
    ::
    ++  grid
      ^-  sole-effect
      :-  %mor
      :~  (row %1)  row-sep
          (row %2)  row-sep
          (row %3)
          empty-style
      ==
    ::
    ++  list-subscribers
      ^-  (quip card _state)
      =^  edit  state.cli  (to-sole:co:view reset)
      :_  state
      :_  ~
      %-  send
      mor+~[det+edit ?~(rooms no-subscribers print-rooms)]
    ::
    ++  poke-sole-action
      |=  act=sole-action
      ^-  (quip card _state)
      ?+    -.dat.act  [~ state]
          ::  $ret: enter key pressed
          ::
          %ret
        ?~  buf.state.cli  [~ state]
        ::  checks for a restart game command
        ::
        =/  crash=(unit @t)  (rust (tufa buf.state.cli) ;~(just zap))
        ?^  crash  crash:room-core
        ::  checks for a "list waiting opponents" command
        ::
        =/  list=(unit @t)  (rust (tufa buf.state.cli) ;~(just (just 'l')))
        ?^  list  list-subscribers
        ::  %egg (?)
        ::
        =/  egg=(unit @t)
          (rust (tufa buf.state.cli) ;~(just (jest (crip "joshua"))))
        ?^  egg  easter-egg
        ::  based on the current state, a different engine arm is called
        ::
        ~(action game-loop (tufa buf.state.cli))
      ::
          ::  $det: key press
          ::  pressed key is stored in the console state
          ::
          %det
        =^  inv  state.cli  (~(transceive sole-lib state.cli) +.dat.act)
        [~ state]
      ==
    ::
    ++  print-rooms
      =/  c  1
      :-  %tan
      %-  flop
      :-  leaf+".............."
      |-  ^-  (list [%leaf tape])
      ?~  rooms
        ~[leaf+".............."]
      :_  $(rooms t.rooms, c +(c))
      leaf+"{<c>}. {(cite:title ship.i.rooms)}"
    ::  +prompt: default game input that modifies the prompt
    ::
    ++  prompt
      |=  dial=styx
      ^-  sole-effect
      pro+[& %$ dial]
    ::  +row: pretty prints a row of the board displayed on the console
    ::
    ++  row
      |=  row=coord
      ^-  sole-effect
      =/  col=coord  %1
      =/  board=board-game  ?~(active ~ board:current:room-core)
      :-  %klr
      |-  ^-  styx
      =/  symbol=(unit player)
        (~(get by board) [row col])
      :-  ?:  =(col %1)
            [[~ ~ ~] "    "]
          [[~ ~ ~] "| "]
      :_  ?:  =(col %3)
            ~
          $(col (coord +(col)))
      ?~  symbol
        [[~ ~ ~] "  "]
      :-  [~ ~ `color.u.symbol]
      "{(trip stone.u.symbol)} "
    ::
    ++  send
      |=  effect=sole-effect
      ^-  card
      [%give %fact [~ /sole/drum] %sole-effect !>(effect)]
    ::
    ++  updates
      |%
      ++  playing
        |=  guest=@p
        %-  send  ^-  sole-effect
        :~  %mor
            instruct
            %-  prompt  =,  room-core
            (dial [guest stones ?:(=(who:current me) "<-" "->")])
        ==
      ::
      ++  waiting
        |=  guest=@p
        (send mor+~[(prompt "{^waiting}{<guest>} {abort} | ")])
      ::
      ++  confirm
        |=  guest=@p
        ^-  card
        %-  send  ^-  sole-effect
        :~  %mor
            (prompt "{^confirm}{(cite:title guest)} (Y/N)? | ")
        ==
      ::
      ++  wins
        |=  [out=outcome winner=@p]
        ^-  card
        %-  send  ^-  sole-effect
        :~  %mor
            grid
            ?:(=(out `%tie) falken bel+~)
            new-line
            (prompt "{(end [out winner])}{keep-on}")
        ==
      --
    ::
    ++  to-sole
      |=  inv=sole-edit
      ^-  [sole-change sole-share]
      (~(transmit sole-lib state.cli) inv)
    ::
    ++  easter-egg
      ^-  (quip card _state)
      =^  edit  state.cli  (to-sole reset)
      :_  state
      ~[(send mor+~[joshua det+edit])]
    --
  --
--
