::
::::  /sur/toe/hoon
  ::
|%
+=  board     (map spot player)
+=  table     [%tan rows=(list row)]
+=  row       [%leaf tape]
+=  outcome   ?(%wins %tie ~)
+=  turno     [=player =spot]
+=  player    ?(%x %o ~)
+=  spot      [x=num y=num]
+=  num       ?(%1 %2 %3)
+=  opts      ?(%1 %2 %3 %4 %5)
+=  restart   (unit %0)
+=  invite    [player restart]
+=  winner    [out=tape tur=turno]
+=  request   [=bone =ship]
+=  requests  (list request)
--
