{-# LANGUAGE NamedFieldPuns #-}

module GHC.Util.HsDecl (declName,bindName,isForD',isNewType',isDerivD',isClsDefSig')
where

import HsSyn
import OccName
import SrcLoc

isNewType' :: NewOrData -> Bool
isNewType' NewType = True
isNewType' DataType = False

isForD', isDerivD' :: LHsDecl GhcPs -> Bool
isForD' (LL _ ForD{}) = True; isForD' _ = False
isDerivD' (LL _ DerivD{}) = True; isDerivD' _ = False

-- | @declName x@ returns the \"new name\" that is created (for
-- example a function declaration) by @x@.  If @x@ isn't a declaration
-- that creates a new name (for example an instance declaration),
-- 'Nothing' is returned instead.  This is useful because we don't
-- want to tell users to rename binders that they aren't creating
-- right now and therefore usually cannot change.
declName :: LHsDecl GhcPs -> Maybe String
declName (LL _ x) = occNameString . occName <$> case x of
    TyClD _ FamDecl{tcdFam=FamilyDecl{fdLName}} -> Just $ unLoc fdLName
    TyClD _ SynDecl{tcdLName} -> Just $ unLoc tcdLName
    TyClD _ DataDecl{tcdLName} -> Just $ unLoc tcdLName
    TyClD _ ClassDecl{tcdLName} -> Just $ unLoc tcdLName
    ValD _ FunBind{fun_id}  -> Just $ unLoc fun_id
    ValD _ VarBind{var_id}  -> Just var_id
    ValD _ (PatSynBind _ PSB{psb_id}) -> Just $ unLoc psb_id
    SigD _ (TypeSig _ (x:_) _) -> Just $ unLoc x
    SigD _ (PatSynSig _ (x:_) _) -> Just $ unLoc x
    SigD _ (ClassOpSig _ _ (x:_) _) -> Just $ unLoc x
    ForD _ ForeignImport{fd_name} -> Just $ unLoc fd_name
    ForD _ ForeignExport{fd_name} -> Just $ unLoc fd_name
    _ -> Nothing
declName _ = Nothing {- COMPLETE LL-}


bindName :: LHsBind GhcPs -> Maybe String
bindName (LL _ FunBind{fun_id}) = Just $ occNameString $ occName $ unLoc fun_id
bindName (LL _ VarBind{var_id}) = Just $ occNameString $ occName var_id
bindName _ = Nothing

isClsDefSig' :: Sig GhcPs -> Bool
isClsDefSig' (ClassOpSig _ True _ _) = True; isClsDefSig' _ = False
