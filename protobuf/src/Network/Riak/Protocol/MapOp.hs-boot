{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses, OverloadedStrings #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Network.Riak.Protocol.MapOp (MapOp) where
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified Data.Data as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data MapOp deriving Prelude'.Typeable

instance P'.MessageAPI msg' (msg' -> MapOp) MapOp

instance Prelude'.Show MapOp

instance Prelude'.Eq MapOp

instance Prelude'.Ord MapOp

instance Prelude'.Data MapOp

-- instance Prelude'.Generic MapOp 

instance P'.Mergeable MapOp

instance P'.Default MapOp

instance P'.Wire MapOp

instance P'.GPB MapOp

instance P'.ReflectDescriptor MapOp

instance P'.TextType MapOp

instance P'.TextMsg MapOp
