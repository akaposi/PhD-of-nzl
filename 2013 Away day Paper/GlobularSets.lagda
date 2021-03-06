
\AgdaHide{

\begin{code}
module GlobularSets where

open import Data.Product
open import Coinduction
open import Relation.Binary.PropositionalEquality

\end{code}
}

To interpret the syntax, we need globular sets. Globular sets are defined coinductively as follows.

\begin{code}
record Glob : Set₁ where
  constructor _∣∣_
  field
    ∣_∣   : Set
    homo : ∣_∣ →  ∣_∣ → ∞ Glob
open Glob public
\end{code}

Indeed we should assume the 0-level object to be an h-set, namely the equality of any two terms of it should be unique. 

As an example, we could contruct the identity globular set called $Idω$.

\begin{code}
Idω : (A : Set) → Glob
Idω A = A ∣∣ (λ a b → ♯ Idω (a ≡ b))
\end{code}



\AgdaHide{


\begin{code}

EqGlob : (A B : Glob) → (A ≡ B) → Σ (∣ A ∣ ≡ ∣ B ∣) (λ p → subst (λ x → x → x → ∞ Glob) p (homo A) ≡ homo B)
EqGlob .B B refl = refl , refl

EqHomo : {A B : Glob} → (p : A ≡ B) → {x y : ∣ A ∣} → {m n : ∣ B ∣} → (subst ∣_∣ p x ≡ m) → (subst ∣_∣ p y ≡ n) → ♭ (homo A x y) ≡ ♭ (homo B m n)
EqHomo {.B} {B} refl {.m} {.n} {m} {n} refl refl = refl


data [_]_≅s_ {A : Glob}
         : (B : Glob) → ∣ A ∣ → ∣ B ∣ → Set where
  refl : (b : ∣ A ∣) → [ A ] b ≅s b

-- universe definition

module UniverseGS (U : Set)(El : U → Set) where

  record uGlob : Set where
    field
      ∣_∣u   : U
      uhomo : El ∣_∣u → El ∣_∣u → ∞ uGlob
  open uGlob


{-
  Π : (A : uGlob)(B : A → uGlob) → uGlob
  Π A B = 
    record 
    { ∣_∣u = {!El ∣ A ∣u !}
    ; uhomo = {!!} 
    }
-}
-- Globular Sets indexed by Types

Π : (A : Set)(B : A → Glob) → Glob
Π A B = 
  record 
  { ∣_∣ = (a : A) → ∣ B a ∣
  ; homo = λ f g → ♯ Π A (λ x → ♭ (homo (B x) (f x) (g x)))
  }

-- Globular Sets indexed by Globular Sets

-- looks good but we may require it covertible to some Glob
record _⇒Glob (A : Glob) : Set₁ where
  field
    ∣_∣f   : ∣ A ∣ → Set
    homof : (a a' : ∣ A ∣) → ∣_∣f a → ∣_∣f a' → ♭ (homo A a a') ⇒Glob
open _⇒Glob


\end{code}

}