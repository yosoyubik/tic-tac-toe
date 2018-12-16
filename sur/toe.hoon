::
::::  /sur/toe/hoon
  ::
|%
+=  spot        [num num]
+=  board       (map spot player)
+=  table       [%tan rows=(list row)]
+=  row         [%leaf tape]
+=  outcome     ?(%wins %tie ~)
+=  player      ?(%x %o ~)
+=  num         ?(%1 %2 %3)
+=  opts        ?(%1 %2 %3 %4)
+=  sub         [? bo=bone wir=wire ze=ship]
+=  subs        (qeu sub)
+=  message     ?(%accept %rematch)
+=  toe-player  [msg=message per=player]              :: mark types
+=  toe-winner  [out=tape tur=toe-turno]              :: same name as the marks
+=  toe-turno   [per=player spo=spot]                 :: ?
--
