{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module Language.PlutusCore.Constant.Dynamic.BuiltinName
    ( dynamicCharToStringName
    , dynamicCharToStringMeaning
    , dynamicCharToStringDefinition
    , dynamicCharToString
    , dynamicAppendName
    , dynamicAppendMeaning
    , dynamicAppendDefinition
    , dynamicAppend
    , dynamicTraceName
    ) where

import           Language.PlutusCore.Constant.Dynamic.Instances ()
import           Language.PlutusCore.Constant.Make
import           Language.PlutusCore.Constant.Typed
import           Language.PlutusCore.Lexer.Type
import           Language.PlutusCore.Type

dynamicCharToStringName :: DynamicBuiltinName
dynamicCharToStringName = DynamicBuiltinName "charToString"

dynamicCharToStringMeaning :: DynamicBuiltinNameMeaning
dynamicCharToStringMeaning = DynamicBuiltinNameMeaning sch pure where
    sch =
        TypeSchemeBuiltin (TypedBuiltinDyn @Char) `TypeSchemeArrow`
        TypeSchemeBuiltin (TypedBuiltinDyn @String)

dynamicCharToStringDefinition :: DynamicBuiltinNameDefinition
dynamicCharToStringDefinition =
    DynamicBuiltinNameDefinition dynamicCharToStringName dynamicCharToStringMeaning

dynamicCharToString :: Term tyname name ()
dynamicCharToString = dynamicBuiltinNameAsTerm dynamicCharToStringName

dynamicAppendName :: DynamicBuiltinName
dynamicAppendName = DynamicBuiltinName "append"

dynamicAppendMeaning :: DynamicBuiltinNameMeaning
dynamicAppendMeaning = DynamicBuiltinNameMeaning sch (++) where
    sch =
        TypeSchemeBuiltin (TypedBuiltinDyn @String) `TypeSchemeArrow`
        TypeSchemeBuiltin (TypedBuiltinDyn @String) `TypeSchemeArrow`
        TypeSchemeBuiltin (TypedBuiltinDyn @String)

dynamicAppendDefinition :: DynamicBuiltinNameDefinition
dynamicAppendDefinition =
    DynamicBuiltinNameDefinition dynamicAppendName dynamicAppendMeaning

dynamicAppend :: Term tyname name ()
dynamicAppend = dynamicBuiltinNameAsTerm dynamicAppendName

dynamicTraceName :: DynamicBuiltinName
dynamicTraceName = DynamicBuiltinName "trace"
