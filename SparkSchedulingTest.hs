import           Control.Parallel.Strategies (parMap, rseq)
import           Data.List (foldl')
import           System.IO (hPutStrLn, stderr)

fun :: Int -> Int
fun n = foldl' (+) 0 [1..n]


main :: IO ()
main = do

  -- Print to stderr which is usually not LineBuffered so that we
  -- can see the numbers appear as they are calculated.

  hPutStrLn stderr $ show $ parMap rseq fun (replicate 20 (100000000 :: Int))
