#!/bin/bash

MAKE_LENSES_FILE=app/MakeLenses.hs
LENS_FILE=src/Network/Riak/Protocol/Lens.hs

rm -f $MAKE_LENSES_FILE
rm -f $LENS_FILE

EXTENSIONS=(
  "{-# LANGUAGE FlexibleInstances #-}"
  "{-# LANGUAGE FunctionalDependencies #-}"
  "{-# LANGUAGE MultiParamTypeClasses #-}"
)

IMPORTS=(
  "import Data.ByteString.Lazy (ByteString)"
  "import Data.Sequence (Seq)"
  "import GHC.Int (Int64)"
  "import GHC.Word (Word32)"
)

# Modules to generate lenses for
LENS_MODULES=$( \
  find ../protobuf/src/Network/Riak/Protocol -name \*.hs \
    | sed \
        -e '/BucketProps.ReplMode/d' \
        -e '/DtFetchResponse.DataType/d' \
        -e '/GetClientIdRequest/d' \
        -e '/IndexRequest.IndexQueryType/d' \
        -e 's:../protobuf/src/::' -e 's/.hs//' -e 's:/:.:g' \
  )

# All protobuf modules
ALL_MODULES=$( \
  find ../protobuf/src/Network/Riak/Protocol -name \*.hs \
    | sed -e 's:../protobuf/src/::' -e 's/.hs//' -e 's:/:.:g' \
  )


################################################################################
## Generate, build, and dump splices of MakeLenses.hs

OUTFILE=$MAKE_LENSES_FILE

echo "-- THIS FILE WAS AUTO-GENERATED BY ./generate.sh" >> $OUTFILE

for extension in "${EXTENSIONS[@]}"; do
  echo $extension >> $OUTFILE
done

echo "{-# LANGUAGE TemplateHaskell #-}" >> $OUTFILE
echo "module Main where" >> $OUTFILE
echo "import TH" >> $OUTFILE
echo "import Lens.Micro (Lens')" >> $OUTFILE

for import in "${IMPORTS[@]}"; do
  echo $import >> $OUTFILE
done

for module in $LENS_MODULES; do
  echo "import qualified $module" >> $OUTFILE
done

echo "main = pure ()" >> $OUTFILE

for module in $LENS_MODULES; do
  type=$(sed -e 's/.*\.\(.*\)$/\1/' <<< $module)
  echo "makeLenses ''$module.$type" >> $OUTFILE
done

stack build riak-protobuf-lens:exe:generate --ghc-options="-ddump-splices -dppr-cols=200"

################################################################################
## Generate and build Network.Riak.Protocol.Lens with the dumped splices

OUTFILE=$LENS_FILE

echo "-- THIS FILE WAS AUTO-GENERATED BY ./generate.sh" >> $OUTFILE

for extension in "${EXTENSIONS[@]}"; do
  echo $extension >> $OUTFILE
done

echo "{-# LANGUAGE RankNTypes #-}" >> $OUTFILE
echo "module Network.Riak.Protocol.Lens where" >> $OUTFILE

for import in "${IMPORTS[@]}"; do
  echo $import >> $OUTFILE
done

for module in $ALL_MODULES; do
  echo "import qualified $module" >> $OUTFILE
done

echo "type Lens' s a = forall f. Functor f => (a -> f a) -> s -> f s" >> $OUTFILE

cat $(stack path --dist-dir)/build/generate/generate-tmp/app/MakeLenses.dump-splices \
  | sed \
      -e '/app\/MakeLenses\.hs/d' \
      -e '/makeLenses/d' \
      -e '/======>/d' \
      -e 's/^    //' \
  >> $OUTFILE

stack build
