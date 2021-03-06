\AgdaHide{
\begin{code}

module Quotient where

open import Data.Product
open import Function
open import Level using (_⊔_)
-- open import Relation.Binary
open import Data.Nat hiding (_⊔_)
open import Setoids
-- Setoid = RB.Setoid Level.zero Level.zero

open import Relation.Binary.PropositionalEquality as PE
  hiding ([_])

open import ThomasProperties

\end{code}
}

We first define the relation that "$f$ respects $\sim$" (f is compatible with $\sim$)

\begin{code}
_respects_ : {A : Set}{B : Set}(f : A → B) 
           → (_~_ : A → A → Set) → Set
f respects _~_ = ∀ {a a'} → a ~ a' → f a ≡ f a'
\end{code}

Prequotient

\begin{code}
record pre-Quotient (S : Setoid) : Set₁ where
  open Setoid S renaming (Carrier to A)
  field
    Q   : Set
    [_] : A → Q
    [_]⁼ : [_] respects _~_
\end{code}
\AgdaHide{
\begin{code}
  open Setoid S public renaming 
       (Carrier to A 
       ; refl to ~-refl; sym to ~-sym;
       trans to ~-trans)
\end{code}
}

We can assume UIP which will only be applied on quotient sets

\begin{code}
≡prop : {A : Set}{a b : A} → (p q : a ≡ b) → p ≡ q
≡prop {A} {a} {.a} refl refl = refl

subIrr : {S : Set}{A : S → Set}{a b : S}(p q : a ≡ b){m : A a}
       → subst A p m ≡ subst A q m
subIrr p q with ≡prop p q
subIrr p .p | refl = refl

subIrr2 : {S : Set}{A : Set}{a b : S}(p : a ≡ b){m : A}
       → subst (λ _ → A) p m ≡ m
subIrr2 refl = refl
\end{code}

Quotient with dependent eliminator

\begin{code}
record Quotient {S : Setoid}
       (PQ : pre-Quotient S) : Set₁ where
  open pre-Quotient PQ
  field
    qelim   : {B : Q → Set}
            → (f : (a : A) → B [ a ])
            → (∀ {a a'} → (p : a ~ a') 
            → subst B [ p ]⁼ (f a) ≡ f a')
            → (q : Q) → B q
    qelim-β : ∀ {B a f}
            (resp : (∀ {a a'} → (p : a ~ a') 
            → subst B [ p ]⁼ (f a) ≡ f a'))
            → qelim {B} f resp [ a ] ≡ f a
\end{code}

Quotient (Hofmann's)

\begin{code}
record Hof-Quotient {S : Setoid}
       (PQ : pre-Quotient S) : Set₁ where
  open pre-Quotient PQ
  field
    lift   : {B : Set}
           → (f : A → B)
           → f respects _~_
           → Q → B

    lift-β : ∀ {B a f}(resp : f respects _~_) 
           → lift {B} f resp [ a ] ≡ f a

    qind   : ∀ (P : Q → Set)
           → (∀{x} → (p q : P x) → p ≡ q)
           → (∀ a → P [ a ])
           → (∀ x → P x)
\end{code}


\begin{code}
record Hof-Quotient' {S : Setoid}
       (PQ : pre-Quotient S) : Set₁ where
  open pre-Quotient PQ
  field
    lift   : {B : Set}
           → (f : A → B)
           → f respects _~_
           → Q → B

    lift-β : ∀ {B a f}(resp : f respects _~_) 
           → lift {B} f resp [ a ] ≡ f a

    qind   : ∀ (P : Q → Set)
           → (∀{x} → (p q : P x) → p ≡ q)
           → (∀ a → P [ a ])
           → (∀ x → P x)
\end{code}

Exact quotient

\begin{code}
record exact-Quotient {S : Setoid}
       (PQ : pre-Quotient S) : Set₁ where
  open pre-Quotient PQ
  field
    Qu    : Quotient PQ
    exact : ∀ {a b : A} → [ a ] ≡ [ b ] → a ~ b
\end{code}

Definable quotient

\begin{code}
record def-Quotient {S : Setoid}
       (PQ : pre-Quotient S) : Set₁ where
  open pre-Quotient PQ
  field
    emb      : Q → A
    complete : ∀ a → emb [ a ] ~ a
    stable   : ∀ q → [ emb q ] ≡ q
\end{code}

\textbf{Proof :} Definable quotients are exact.

\begin{code}
  exact : ∀{a b} → [ a ] ≡ [ b ] → a ~ b
  exact {a} {b} p = 
    ~-trans (~-sym (complete a)) 
    (~-trans (subst (λ x → 
    emb [ a ] ~ emb x) 
    p ~-refl) (complete b))
\end{code}


\textbf{Equivalences and conversions among the quotient structures}

\AgdaHide{
\begin{code}
Σeq : {A : Set}{B : A → Set}{a a' : A}
      {b : B a}{b' : B a'}(p : a ≡ a') 
    → subst B p b ≡ b' → (a , b) ≡ (a' , b')
Σeq refl refl = refl


ind2dep : ∀ {Q : Set}{B : Q → Set}
        → (f : Q → Σ Q B)
        → (∀ q → proj₁ (f q) ≡ q)
        → (q : Q) → B q
ind2dep {Q} {B} f id' q = subst B (id' q) (proj₂ (f q))
\end{code}
}

\textbf{Proof :} Hofmann's definition of quotient is equivalent to Quotient.

\begin{code}
Hof-Quotient→Quotient : {S : Setoid}{PQ : pre-Quotient S} →
  (Hof-Quotient PQ) → (Quotient PQ)
Hof-Quotient→Quotient {S} {PQ} QuH = 
  record 
    { qelim   = λ {B} f resp 
    → proj₁ (qelim' f resp)
    ; qelim-β = λ {B} {a} {f} resp 
    → proj₂ (qelim' f resp)
    }
  where
    open pre-Quotient PQ
    open Hof-Quotient QuH

    qelim' : {B : Q → Set}
           → (f : (a : A) → B [ a ])
           → (∀ {a a'} → (p : a ~ a') 
           → subst B [ p ]⁼ (f a) ≡ f a')
           → Σ[ f^ ∶ ((q : Q) → B q) ] 
              (∀ {a} → f^ [ a ] ≡ f a)
    qelim' {B} f resp =  f^ , f^-β
          where

           f₀ : A → Σ Q B
           f₀ a = [ a ] , f a
    
           resp₀ : f₀ respects _~_
           resp₀ p = Σeq [ p ]⁼ (resp p)


           f' : Q → Σ Q B
           f' = lift f₀ resp₀

           id' : Q → Q
           id' = proj₁ ∘ f'
           
           P : Q → Set
           P q = id' q ≡ q

           f'-β : {a : A} → f' [ a ] ≡ [ a ] , f a
           f'-β = lift-β _

           isIda : ∀ {a} → id' [ a ] ≡ [ a ]
           isIda = cong proj₁ f'-β

           isIdq : ∀ {q} → id' q ≡ q
           isIdq {q} = qind P ≡prop (λ _ → isIda) q

           f^ : (q : Q) → B q
           f^ q = subst B isIdq (proj₂ (f' q))

           f'-sound2 : ∀ {a} → 
                     subst B isIda (proj₂ (f' [ a ])) ≡ f a
           f'-sound2 = cong-proj₂ _ _ f'-β
           
           f^-β : ∀ {a} → f^ [ a ] ≡ f a
           f^-β {a} = trans (subIrr isIdq isIda) f'-sound2
\end{code}

\begin{code}
Quotient→Hof-Quotient : 
  {S : Setoid}{PQ : pre-Quotient S}
  → (Quotient PQ)
  → (Hof-Quotient PQ)
Quotient→Hof-Quotient {S} {PQ} QU =
  record
  { lift   = λ f resp 
             → qelim f (resp' resp)
  ; lift-β = λ resp 
             → qelim-β (resp' resp)
  ; qind = λ P isP f 
           → qelim {P} f (λ _ → isP _ _)
  }
  where
    open pre-Quotient PQ
    open Quotient QU

    resp' : {B : Set}{a a' : A}
          {f : A → B}
          (resp : f respects _~_)
          (p : a ~ a')
          → subst (λ _ → B) [ p ]⁼ (f a) 
          ≡ f a'
    resp' resp p = 
          trans (subIrr2 [ p ]⁼)
          (resp p)
\end{code}

\textbf{Proof :} A definable quotient gives rise to a \emph{quotient}.

\begin{code}
def-Quotient→Quotient : 
  {S : Setoid}{PQ : pre-Quotient S}
  → (def-Quotient PQ) → (Quotient PQ)
def-Quotient→Quotient {S} {PQ} QuD = 
  record { qelim = 
         λ {B} f resp q → subst B (stable q) (f (emb q))
         ; qelim-β = 
         λ {B} {a} {f} resp → 
         trans (subIrr (stable [ a ]) 
         [ complete a ]⁼) (resp (complete a))

  }
    where
    open pre-Quotient PQ
    open def-Quotient QuD
\end{code}


\textbf{Proof :} A definable quotients gives rise to an \emph{exact (effective) quotient}.

\begin{code}
def-Quotient→exact-Quotient : 
  {S : Setoid}{PQ : pre-Quotient S}
  → def-Quotient PQ → exact-Quotient PQ
def-Quotient→exact-Quotient {S} {PQ} QuD =
  record { Qu = def-Quotient→Quotient QuD
         ; exact = exact
         }
  where
    open pre-Quotient PQ
    open def-Quotient QuD
\end{code}

\begin{code}
def-Quotient→Hof-Quotient 
  : {S : Setoid} 
  → {PQ : pre-Quotient S}
  → (def-Quotient PQ) 
  → (Hof-Quotient PQ)
def-Quotient→Hof-Quotient {S} {PQ} QuD =
  record 
  { lift   = λ f _ → f ∘ emb
  ; lift-β = λ resp → resp (complete _)
  ; qind   = λ P _ f _ → 
           subst P (stable _) (f (emb _))
  }
  where
    open pre-Quotient PQ
    open def-Quotient QuD
\end{code}


\begin{code}
def-Quotient→Hof-Quotient' : 
  {S : Setoid}{PQ : pre-Quotient S}
  → (def-Quotient PQ) → (Hof-Quotient PQ)
def-Quotient→Hof-Quotient' = 
  Quotient→Hof-Quotient ∘ def-Quotient→Quotient
\end{code}

