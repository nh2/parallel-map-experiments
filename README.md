# parallel-map-experiments
Haskell experiments around monad-par, parallel, parMap and spark scheduling

Currently contains:

* Comparison of exception handling between `monad-par` and `parallel`
* Checking that `monad-par`'s Sparks scheduler makes it work just like `parallel`
* Checking how sparks are scheduled/computed (one after the other)

I read up a bit on `monad-par` vs `parallel` in Simon Marlow's book; he makes a direct comparison here: http://chimera.labs.oreilly.com/books/1230000000929/ch04.html#sec_par-monad-reflections

In the previous chapter that discusses `parallel`, he shows a graph of how the number of sparks affect performance for his problem: http://chimera.labs.oreilly.com/books/1230000000929/ch03.html#sec_par-kmeans-granularity

As he mentions, there is some overhead to using large numbers of sparks. The spark _creation_ overhead will probably be very low in cases where the function used in the parallel map does some substantial work (that takes significantly longer than to create a spark). What might be relevant is if the spark scheduler switched quickly between sparks and chose to push them across processor boundaries, but this doesn't seem to be what the spark scheduler does: According to https://ghc.haskell.org/trac/ghc/wiki/Commentary/Rts/Scheduler#Sparksandtheparoperator:

> The spark pool is a circular buffer, when it is full we have the choice of either overwriting the oldest entry or dropping the new entry - currently we drop the new entry (see code for newSpark). Each capability has its own spark pool, so this operation can be performed without taking a lock.
> So how does the spark turn into a thread? When the scheduler spots that the current capability has no runnable threads, it checks the spark pool, and if there is a valid spark (a spark that points to a THUNK), then the spark is turned into a real thread and placed on the run queue.


The `SparkSchedulingTest.hs` example demonstrates that sparks indeed have no thrashing / quick switching behaviour, but instead are worked down in order until completion:

Running the above with `ghc --make -O SparkSchedulingTest.hs -threaded && ./SparkSchedulingTest +RTS -N2` you can see two numbers appearing in the result list at a time.

In addition, one can probably often simply use `parListChunk 128` or `parListChunk (2 * numCapabilities)` to make sure the number of sparks is reasonable.

In summary, it seems to me that it is a good idea to move to spark-based parallelism instead of `unsafePerformIO + MVar` based parallelism where possible for simple parallel maps.
