{-# LANGUAGE DeriveGeneric #-}
{-# OPTIONS -Wall #-}





-- | This module defines what it means to be a program in Plutus Core.

module PlutusCore.Program where

import Utils.ABT
import Utils.Pretty
import PlutusCore.Term

import Data.List (isPrefixOf)

-- import GHC.Generics







data KindSig = KindSig String Kind

prettyKindSig :: KindSig -> String
prettyKindSig (KindSig x k) =
  "("
    ++ x
    ++ " "
    ++ prettyKind k
    ++ ")"

data Alt = Alt String [Scope PlutusSig]

prettyAlt :: Alt -> String
prettyAlt (Alt c tscs) =
  "("
    ++ c
    ++ " "
    ++ unwords (map (parenthesize Nothing . body) tscs)
    ++ ")"


data Declaration = DataDeclaration String [KindSig] [Alt]
                 | TypeDeclaration String Term
                 | TermDeclaration String Term
                 | TermDefinition String Term

declarationName :: Declaration -> String
declarationName (DataDeclaration n _ _) = n
declarationName (TypeDeclaration n _) = n
declarationName (TermDeclaration n _) = n
declarationName (TermDefinition n _) = n

prettyDeclaration :: Declaration -> String
prettyDeclaration (DataDeclaration c ks alts) =
  "(data "
    ++ c
    ++ " "
      ++ "("
      ++ unwords (map prettyKindSig ks)
      ++ ")"
    ++ " "
    ++ unwords (map prettyAlt alts)
    ++ ")"
prettyDeclaration (TypeDeclaration n tv) =
  "(type "
    ++ n
    ++ " "
    ++ parenthesize Nothing tv
    ++ ")"
prettyDeclaration (TermDeclaration n tv) =
  "(define "
    ++ n
    ++ " "
    ++ parenthesize Nothing tv
    ++ ")"

prettyDeclaration (TermDefinition n v) =
  "(define "
    ++ n
    ++ " "
    ++ parenthesize Nothing v
    ++ ")"








-- | A `Program` is a collection of modules.

data Program =
  Program [Declaration]

prettyProgram :: Program -> String
prettyProgram (Program decls) =
  "(program " ++ unwords (map prettyDeclaration decls) ++ ")"



firstJust :: [Maybe a] -> Maybe a
firstJust [] = Nothing
firstJust (Nothing:xs) = firstJust xs
firstJust (Just x:_) = Just x

typeForName :: Program -> String -> Maybe Type
typeForName (Program decls) n =
  firstJust (map typeForNameDecl decls)
  where
    typeForNameDecl :: Declaration -> Maybe Type
    typeForNameDecl (TermDeclaration n' t) | n == n' = Just t
    typeForNameDecl _ = Nothing




definitionForName :: Program -> String -> Maybe Type
definitionForName (Program decls) n =
  firstJust (map definitionForNameDecl decls)
  where
    definitionForNameDecl :: Declaration -> Maybe Type
    definitionForNameDecl (TermDefinition n' m) | n == n' = Just m
    definitionForNameDecl _ = Nothing




namesWithNameAsPrefix :: Program -> String -> [String]
namesWithNameAsPrefix (Program decls) n =
  decls >>= namesWithNameAsPrefixDecl
  where
    namesWithNameAsPrefixDecl :: Declaration -> [String]
    namesWithNameAsPrefixDecl (TermDefinition n' _)
      | isPrefixOf n n' = [n']
    namesWithNameAsPrefixDecl _ = []






data NameInfo = TypeConstructor String
              | TypeName String
              | TermConstructor String
              | TermName String

nameInfoName :: NameInfo -> String
nameInfoName (TypeConstructor n) = n
nameInfoName (TypeName n)        = n
nameInfoName (TermConstructor n) = n
nameInfoName (TermName n)        = n

prettyNameInfo :: NameInfo -> String
prettyNameInfo (TypeConstructor n) =
  n ++ " (type constructor)"
prettyNameInfo (TypeName n) =
  n ++ " (type name)"
prettyNameInfo (TermConstructor n) =
  n ++ " (term constructor)"
prettyNameInfo (TermName n) =
  n ++ " (term name)"

nameInfo :: Program -> [NameInfo]
nameInfo (Program decls) =
  do decl <- decls
     case decl of
       DataDeclaration n _ alts ->
         TypeConstructor n :
           [ TermConstructor n'
           | Alt n' _ <- alts
           ]
       TypeDeclaration n _ ->
         [TypeName n]
       TermDeclaration n _ ->
         [TermName n]
       TermDefinition _ _ ->
         []