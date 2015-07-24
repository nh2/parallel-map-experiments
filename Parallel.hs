import           Control.Parallel.Strategies (parMap, rdeepseq)

main :: IO ()
main = do

  let l = [1..10::Int]

  let f 7 = error "error on 7"
      f n = n * 2

  let l2 = parMap rdeepseq f l

  print l2
