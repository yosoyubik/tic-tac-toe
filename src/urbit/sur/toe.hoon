::
::::  /sur/toe/hoon
::
|%
::
+|  %data-structures
::
+$  game-room    [board=board-game =toers who=@p]
+$  game-rooms   (list [=ship room=(unit game-room)])
+$  grid         (list [%klr styx])
+$  outcome      (unit ?(%wins %tie))
+$  stone        ?(%'X' %'O')
+$  player       [=stone color=tint]
::  $players: each player has a stone (%x/%o) and color (%g/%r)
::
+$  toers        (map ship player)
+$  coord        ?(%1 %2 %3)
+$  spot         [coord coord]
::  $board-state: internal board for our game [@ @] -> icon
::
+$  board-game   (map spot player)
::  $game-state: current game state
::
+$  game-state   ?(%begin %wait %confirm %play %replay)
::
+$  action       ?(%accept %replay)
::
:: +$  toe-request  ship
::
+|  %marks
::  Marks sent in each move, as defined in %/mar/toe/
::
+$  toe-player   [msg=action per=player]
+$  toe-winner   [out=tape tur=toe-turno]
+$  toe-turno    [per=player spo=spot]
--
