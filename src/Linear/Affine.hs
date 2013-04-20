{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeFamilies #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Linear.Vector
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  provisional
-- Portability :  portable
--
-- Operations on affine spaces.
-----------------------------------------------------------------------------
module Linear.Affine where

import Control.Applicative
import Control.Monad
import Data.Complex (Complex)
import Data.Foldable as Foldable
import Data.Functor.Identity (Identity)
import Data.HashMap.Lazy (HashMap)
import Data.Hashable
import Data.IntMap (IntMap)
import Data.Map (Map)
import Data.Vector (Vector)
import Linear.Plucker
import Linear.Quaternion
import Linear.V
import Linear.V0
import Linear.V2
import Linear.V3
import Linear.V4
import Linear.Vector

-- | An affine space is roughly a vector space in which we have
-- forgotten or at least pretend to have forgotten the origin.
--
-- > a .+^ (b .-. a)  =  b@
-- > (a .+^ u) .+^ v  =  a .+^ (u ^+^ v)@
-- > (a .-. b) ^+^ v  =  (a .+^ v) .-. q@
class Additive (Diff p) => Affine p where
  type Diff p
  (.-.) :: Num a => p a -> p a -> Diff p a
  (.+^) :: Num a => p a -> Diff p a -> p a

  (.-^) :: Num a => p a -> Diff p a -> p a
  p .-^ v = p .+^ negated v
  {-# INLINE (.-^) #-}

-- | Squared distance between two points
distanceSq :: (Affine p, Foldable (Diff p), Num a) => p a -> p a -> a
distanceSq a b = Foldable.sum (fmap (join (*)) (a .-. b))

-- | Distance between two points
distance :: (Floating a, Foldable (Diff p), Affine p) => p a -> p a -> a
distance a b = sqrt (distanceSq a b)

#define ADDITIVEC(CTX,T) instance (CTX) => Affine (T) where type Diff (T) = T ; \
  (.-.) = (^-^) ; {-# INLINE (.-.) #-} ; (.+^) = (^+^) ; {-# INLINE (.+^) #-} ; \
  (.-^) = (^-^) ; {-# INLINE (.-^) #-}
#define ADDITIVE(T) ADDITIVEC(, T)

ADDITIVE([])
ADDITIVE(Complex)
ADDITIVE(ZipList)
ADDITIVE(Maybe)
ADDITIVE(IntMap)
ADDITIVE(Identity)
ADDITIVE(Vector)
ADDITIVE(V0)
ADDITIVE(V2)
ADDITIVE(V3)
ADDITIVE(V4)
ADDITIVE(Plucker)
ADDITIVE(Quaternion)
ADDITIVE((->) b)
ADDITIVEC(Ord k, Map k)
ADDITIVEC((Eq k, Hashable k), HashMap k)
ADDITIVEC(Dim n, V n)
