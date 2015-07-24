import qualified Control.Monad.Par as P
import qualified Data.Vector as V


main :: IO ()
main = do

  let v = V.fromList [1..10::Int]

  let f 7 = error "error on 7"
      f n = n * 2

  let v2 = P.runPar $ P.parMap f v

  print v2
