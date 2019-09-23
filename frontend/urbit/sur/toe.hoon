::
::::  /sur/toe/hoon
::
|%
::
+|  %data-structures
::
+$  grid         (list [%klr styx])
+$  outcome      ?(%wins %tie ~)
+$  stone        ?(%x %o ~)
+$  player       [=stone color=tint]
::  $players: each player has a stone (%x/%o) and color (%g/%r)
::
+$  players      (map ship player)
+$  coord        ?(%1 %2 %3)
+$  spot         [coord coord]
::  $board-state: internal board for our game [@ @] -> icon
::
+$  board-state  (map spot player)
::  $game-state: current game state
::
+$  game-state   ?(%select-opponent %confirm %start %replay)
+$  remote-app   [ze=ship =conns]
+$  conns
  $:  ::  $in: for incoming connections
      ::    used when a ship sends a %peer
      ::
      in=bone
      ::  $out: for outgoing connections
      ::    used when we %peer a ship
      ::
      out=bone
  ==
::  $subscribers: queue of players waiting to play
::
+$  subscribers
  ::  Gall has prey:pubsub:userlib to get the list
  ::  of subscribers.
  ::  It uses a
  ::    $bitt: (map bone (pair ship path))
  ::  to track  incoming subs
  ::  TODO: don't reinvent the wheel and just use
  ::        the queue to track the order or subs.
  ::
  (list remote-app)
+$  message      ?(%accept %rematch)
::
+|  %marks
::  Marks sent in each move, as defined in %/mar/toe/
::
+$  toe-player   [msg=message per=player]
+$  toe-winner   [out=tape tur=toe-turno]
+$  toe-turno    [per=player spo=spot]
+$  toe-cancel   %bye
::
+|  %intro-text
::
++  welcome
  :-  %klr
  :~  [[~ ~ ~] "   "]
      [[`%un ~ ~] "Tic-Tac-Toe"]
      [[~ ~ ~] "   "]
  ==
++  brought-by      "brought to you by W.O.P.R {copyright}  "
++  wopr            txt+(weld empties brought-by)
++  shall-we        klr+~[[[`%un ~ ~] "shall we play a game?"]]
++  show-list       klr+~[[[`%un ~ ~] "shall we play a game?"]]
::
+|  %prompt-messages
::
++  choose          " | enter @p (e.g. ~zod) | "
++  waiting         " | waiting for "
++  abort           "(!=quit)"
++  keep-on         " continue? (Y/N) | "
++  confirm         " | play with "
::
+|  %action-messages
::
++  no-subscribers  klr+~[no-klr [[```%b] "* no players yet..."]]
++  spot-taken      klr+~[no-klr [[```%r] "* spot taken"]]
++  wait-your-turn  klr+~[no-klr [[```%r] "* wait for your turn"]]
++  instruct
  klr+~[no-klr [[```%b] "* choose a board position (e.g. 2/2)"]]
++  frowned-upon
  :-  %klr
  :~  [[~ ~ ~] " * "]
      :-  [```%y]
      "playing with yourself is frowned upon... "
  ==
::
+|  %text-helpers
::
++  row-sep         klr+~[[[~ ~ ~] "    ---------"]]
++  new-line        txt+""
++  empties         "                 "
++  no-klr          [[~ ~ ~] "    "]
++  unline          [`%un ~ ~]
++  empty-style     klr+~[no-klr]
++  copyright       (trip (tuft `@c`169))
++  clear     clr+~
++  reset     set+~
::
+|  %easter-eggs
++  falken
  :-  %mor
  :~  klr+~[[[`%un ~ ~] "Greetings professor Falken."]]
      klr+~[[[`%un ~ ~] "A strange game."]]
      klr+~[[[`%un ~ ~] "They only winning move is not to play."]]
      empty-style
      klr+~[[[`%un ~ `%b] "How about a nice game of chess?"]]
  ==
++  joshua
  :-  %mor
  :~  klr+~[no-klr [unline "FALKEN'S MAZE"]]
      klr+~[no-klr [unline "BLACK JACK"]]
      klr+~[no-klr [unline "GIN RUMMY"]]
      klr+~[no-klr [unline "HEARTS"]]
      klr+~[no-klr [unline "BRIDGE"]]
      klr+~[no-klr [unline "CHECKERS"]]
      klr+~[no-klr [unline "CHESS"]]
      klr+~[no-klr [unline "POKER"]]
      klr+~[no-klr [unline "FIGHTER COMBAT"]]
      klr+~[no-klr [unline "GUERRILLA ENGAGEMENT"]]
      klr+~[no-klr [unline "DESERT WARFARE"]]
      klr+~[no-klr [unline "AIR-TO-GROUND ACTIONS"]]
      klr+~[no-klr [unline "THEATERWIDE TACTICAL WARFARE"]]
      klr+~[no-klr [unline "THEATERWIDE BIOTOXIC AND CHEMICAL WARFARE"]]
      empty-style
      klr+~[no-klr [[`%un ~ `%r] "GLOBAL THERMONUCLEAR WAR"]]
   ==
--
