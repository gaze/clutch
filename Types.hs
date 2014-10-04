module Types where

import Data.Monoid
import System.IO.Unsafe
import Control.Monad.State
import Control.Monad.Writer

-- The IR

data V = V !Int deriving Show

data Exp
  = Var V
  | Const !Int
  | Add Exp Exp
  | Mul Exp Exp
  | Sqrt Exp
  | Mod Exp Exp
  | Div Exp Exp deriving Show

opt (Add x (Const 0)) = x
opt (Add (Const 0) y) = y
opt (Add (Const x) (Const y)) = Const (x+y)
opt (Add x y) = (Add (opt x) (opt y))

opt (Mul x (Const 1)) = x
opt (Mul (Const 1) y) = y
opt (Mul (Const x) (Const y)) = Const (x*y)

opt (Mul (Const x) (Mul (Const y) e)) = mul (Const (x*y)) (opt e)
opt (Mul (Const x) (Mul e (Const y))) = mul (Const (x*y)) (opt e)
opt (Mul (Mul (Const y) e) (Const x)) = mul (Const (x*y)) (opt e)
opt (Mul (Mul e (Const y)) (Const x)) = mul (Const (x*y)) (opt e)

opt (Mul x y) = (Mul (opt x) (opt y))

opt z = z

mul x y = opt $ Mul x y
add x y = opt $ Add x y

instance Num Exp where
        (*) = mul
        (+) = add
        abs = undefined
        signum = undefined
        fromInteger = Const . fromIntegral

data Stmt
  = Loop V Exp Exp Exp Block
  | Set Exp Exp Exp Exp
  | DoZero Exp Exp
  | Annot String deriving Show
data Block = Block [Stmt] deriving Show
singleStatement x = Block [x]

instance Monoid Block where
        mempty = Block []
        mappend (Block a) (Block b) = Block (a ++ b)
 
-- The IR Generation Monad

type Clutch = WriterT Block (State Int)

runClutch :: Clutch () -> Block
runClutch = snd . fst . (flip runState (0::Int)) . runWriterT

newVar :: Clutch V
newVar = do
   i <- get
   put $! i + 1
   return (V i)

defVar :: Exp -> Clutch ()
defVar = undefined

collect :: Clutch a -> Clutch (a, Block)
collect = lift . runWriterT

emit :: Stmt -> Clutch ()
emit = tell . singleStatement

loop :: Exp -> Exp -> Exp -> (Exp -> Clutch ()) -> Clutch ()
loop st inc stop body = do
    i <- newVar
    g <- collect (body (Var i))
    emit $ Loop i st inc stop (snd g)
    return ()

-- Matrix Reprs

-- The contents of a matrix
data MatContents = SparseSmall [(Int,Int,Int)] | Skyline !Int Exp | Ident deriving Show
data Mat = Mat !Int !Int (MatContents) deriving Show

-- A matrix given by a tensor product of several Mats
data TMat = TMat [Mat] deriving Show

-- Tensor products are a monoid
instance Monoid TMat where
        mempty = TMat []
        mappend (TMat x) (TMat y) = TMat (x ++ y)

data TraversalOrder = RowFirst | ColumnFirst
data Coord = Coord Exp Exp deriving Show
data MatrixElement = MatrixElement Exp deriving Show

instance Num MatrixElement where
        (*) (MatrixElement x) (MatrixElement y) = MatrixElement (x*y)
        (+) = undefined
        abs = undefined
        signum = undefined
        fromInteger = MatrixElement . fromIntegral

addc (Coord i j) (Coord k l) = Coord (i+k) (j+l)
scale w h (Coord i j) = Coord (w*i) (h*j)

data Shit = Shit
