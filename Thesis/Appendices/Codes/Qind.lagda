\AgdaHide{
\begin{code}

module Qind where

-- Prove : qind : (m : (a : A) → P [ a ]) → ((q : Q) → P q)

-- open import Level
open import Data.Product
open import Relation.Binary.PropositionalEquality hiding ([_])
open import Function

{-
id : {X : Set} → X → X
id = λ x → x
-}
-- coequalizer in Set
\end{code}
}

\begin{code}
coequalise : {B Q : Set}(e : B → Q)(A : Set) → Set
coequalise {B} {Q} e A = (f g : A → B) →
                    ∀ (a : A) → e (f a) ≡ e (g a)

record Coequalizer : Set₁ where
  constructor B:_Q:_[]:_Eq:_Ce:_
  field
    B Q : Set
    [_] : B → Q

    Eq : ∀(A : Set) → coequalise [_] A

    lift-full
       : ∀ {A Z : Set}(f : B → Z) → 
           coequalise f A → 
           Σ[ f^ ∶ (Q → Z) ] 
           (∀ b → f^ [ b ] ≡ f b) ×
           (∀ (g : Q → Z) → coequalise (g ∘ [_]) A → g ≡ f^)


  lift : ∀ {A Z : Set}(f : B → Z) → 
           coequalise f A → 
           Q → Z
  lift f = proj₁ ∘ lift-full f

  lift-β : ∀ {A Z : Set}(f : B → Z){coe : coequalise f A} → 
           ∀ b → (lift f coe) [ b ] ≡ f b
  lift-β f {coe} = proj₁ ∘ proj₂ ∘ lift-full f coe
open Coequalizer

\end{code}

Theorem : coequalizer is an epi

\begin{code}

{-
cepi : (c : Coequalizer) →
       ∀ {X : Set}(w w' : Q c → X) →
       (∀ (b : B c) → w ([_] c b) ≡ w' ([_] c b)) → 
       ∀ (q : Q c) → w q ≡ w' q
cepi (B: B Q: Q []: [_] Eq: eq Ce: ce) {X} w w' eqwn q = trans (sym (w-uni w q)) (w-uni w' q)

         where
           
           eqq : ∀ (A : Set) → coequalise (λ b → w [ b ]) A
           eqq A f g a = cong w (eq A f g a)

           cewn : Σ[ u ∶ (Q → X) ] 
                  ((∀ (u' : (Q → X)) →
                    ∀ (q : Q) → u q ≡ u' q) × 
                  (∀ (b : B) → u [ b ] ≡ w [ b ]))
           cewn = ce (λ b → w [ b ]) (eqq B)

           u : Q → X
           u = proj₁ cewn

           w-uni : ∀ (u' : (Q → X)) →
                    ∀ (q : Q) → u q ≡ u' q
           w-uni = proj₁ (proj₂ cewn)

\end{code}

Coequalizer implies that quotient induction

-- Use data type declaration for Sigma type since the dot pattern of record type are not supported

\end{code}
data Sigma (A : Set)(P : A → Set) : Set where
  _,_ : (a : A) → (p : P a) → Sigma A P

fst : ∀{A P} → Sigma A P → A
fst (a , _) = a

snd : ∀{A P} → (s : Sigma A P) → P (fst s)
snd (_ , p) = p

Σelim : ∀ {A P}(a b : Sigma A P) →
         (p : fst a ≡ fst b) →
          (subst P p (snd a) ≡ snd b) → a ≡ b
Σelim (.a' , .p') (a' , p') refl refl = refl


-- axiom "prop" included : for any a, there are only one unique inhabitant of P a 

qind : (c : Coequalizer)(P : Q c → Set) →
       (∀ (a : Q c)(p q : P a) → p ≡ q) →
       (∀ (b : B c) → P ([_] c b)) →
       ∀ (q : Q c) → P q
qind (B: B Q: Q []: [_] Eq: eq Ce: ce) P prop m q = 
     subst P phq=q (snd (h' q))

     where
       X = Sigma Q P

       h : B → X
       h b = [ b ] , m b

       eqq : coequalise h B
       eqq f g b = Σelim (h (f b)) (h (g b))
                   (eq B f g b)
                   (prop [ g b ] (subst (λ x → P x) (eq B f g b) (m (f b)))
                   (m (g b)))

       ceh : Σ[ u ∶ (Q → X) ] 
         ((∀ (u' : (Q → X)) →
         ∀ (q : Q) → u q ≡ u' q) × 
         (∀ (b : B) → u [ b ] ≡ h b))
       ceh = ce h eqq

       h' : Q → X
       h' = proj₁ ceh

       h'uni : ∀ (u' : (Q → X)) → 
               ∀ (q' : Q) → h' q' ≡ u' q'
       h'uni = proj₁ (proj₂ ceh)

       h'ok : ∀ (b : B) → h' [ b ] ≡ h b
       h'ok = proj₂ (proj₂ ceh)

       phq[q]=[q] : ∀ b → fst (h' [ b ]) ≡ [ b ]
       phq[q]=[q] b = trans (cong fst (h'ok b)) refl

       epi : ∀ {X : Set}(w w' : Q → X) →
             (∀ (b : B) → w [ b ] ≡ w' [ b ]) → 
             ∀ (q : Q) → w q ≡ w' q
       epi = cepi (B: B Q: Q []: [_] Eq: eq Ce: ce)

       phq=q : fst (h' q) ≡ q
       phq=q = epi {Q} (λ x → fst (h' x)) id phq[q]=[q] q
-}
\end{code}