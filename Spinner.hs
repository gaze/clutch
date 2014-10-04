module Spinner where

import System.IO.Unsafe
import Types

sx = TMat [Mat 2 2 (SparseSmall [(0,1,1),(1,0,1)])]
sz = TMat [Mat 2 2 (SparseSmall [(0,0,1),(1,1,-1)])]
sI = TMat [Mat 2 2 (SparseSmall [(0,0,1),(1,1,1)])]

ident n = TMat [Mat n n Ident]

traverseMat :: Mat -> (Coord -> MatrixElement -> Clutch ()) -> Clutch ()
traverseMat (Mat w h (SparseSmall l)) enumeratee = mapM_ e l
    where
    e (i, j, v) = enumeratee (Coord (Const i) (Const j)) (MatrixElement (Const v))

traverseMat (Mat w h (Ident)) enumeratee = loop (Const 0) (Const 1) (Const w) e
    where
    e idx = enumeratee (Coord idx idx) (MatrixElement (Const 1))

recEnumerate :: Exp -> MatrixElement -> Coord -> TraversalOrder -> TMat -> Clutch ()
recEnumerate ii me'outer outerCoord to (TMat ((x@(Mat w h _):xs))) = traverseMat x f
    where
    startLocation = scale (Const w) (Const h) outerCoord
    po (Coord kk jj) (MatrixElement belem)  = Set ii jj kk belem
    f innerCoord me'inner = do
        let me = me'inner * me'outer
        case xs of
            [] -> emit $ po (startLocation `addc` innerCoord) me
            _  -> recEnumerate ii me (startLocation `addc` innerCoord) to (TMat xs)
        return ()

doMult m = loop (Const 0) (Const 1) (Const 1600) f
    where
    f ii = do
        loop (Const 0) (Const 1) (Const 1600) zeroing
        recEnumerate ii (MatrixElement 1) (Coord 0 0) RowFirst m
        where
        zeroing jj = do
            emit $ DoZero ii jj

re :: TMat -> Block
re = runClutch . doMult
