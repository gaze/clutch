module CUDA where

import Types
import Spinner
import Data.Monoid
import Control.Monad

iiiz = re $ (ident 20 <> ident 20 <> ident 2 <> sz)
ixix = re $ (ident 20 <> sx <> ident 20 <> sx)
xiix = re $ (sx <> ident 20 <> ident 20 <> sx)

nameVar (V i) = "v" ++ show i ++ ""

cudafyExp :: Exp -> String
cudafyExp (Var v) = nameVar v
cudafyExp (Const i) = show i
cudafyExp (Add e1 e2) = "(" ++ cudafyExp e1 ++ "+" ++ cudafyExp e2 ++ ")"
cudafyExp (Mul e1 e2) = "(" ++ cudafyExp e1 ++ "*" ++ cudafyExp e2 ++ ")"
cudafyExp (Sqrt exp) = "(sqrt(" ++ cudafyExp exp ++ "))"

data Output = IndentIn | IndentOut | Line String deriving Show

cudafyStmt (Loop i st inc end b) =
    [Line $ "for(int " ++ nameVar i ++ " = " ++ cudafyExp st ++ "; " ++ 
            nameVar i ++ " < " ++ cudafyExp end ++ " ;" ++ 
            nameVar i ++ " += " ++ cudafyExp inc ++ "){",
    IndentIn] ++ 
    cudafyBlock b ++
    [IndentOut,
    Line "}"]
    
cudafyStmt (Annot x) = [Line x]

cudafyStmt (Set ii jj kk v) = [Line ("M_A(" ++ cudafyExp ii ++ ", " ++ cudafyExp jj ++ ") += " ++ cudafyExp v ++ "*M_B(" ++ cudafyExp ii ++ ", " ++ cudafyExp kk ++ ");")]

cudafyStmt (DoZero ii jj) = [Line ("M_A(" ++ cudafyExp ii ++ ", " ++ cudafyExp jj ++ ") = 0;")]

cudafyBlock (Block xs) = concat (map cudafyStmt xs)

stringifyOutput il ((Line x):xs) = spaces ++ x ++ "\n" ++ stringifyOutput il xs
    where
    spaces = take (4*il) . repeat $ ' ' 

stringifyOutput il (IndentIn:xs) = stringifyOutput (il+1) xs
stringifyOutput il (IndentOut:xs) = stringifyOutput (il-1) xs

stringifyOutput il [] = ""
