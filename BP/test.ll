ll = object( "LinkedList.class" )
ll->append( "a" )
ll->append( "b" )
ll->append( "c" )
ll->append( "d" )
loop
    v = ll->next()
until (v->isNil()) 
    crt v->store()
repeat
crt
v = ll->search( "c" )
crt v->store()
crt
ll->delete()
ll->current = ll->head()
loop
    v = ll->next()
until (v->isNil()) 
    crt v->store()
repeat
ll->dispose()
end
