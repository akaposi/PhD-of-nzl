module Quotient where

open import Relation.Binary
open import Relation.Binary.Core
open Setoid renaming (refl to reflexive; sym to symmetric; trans to transitive)
open import Relation.Binary.PropositionalEquality.Core

open import Data.Nat hiding (zero)
open import Data.Nat.Properties

open import Data.Product

open import Level hiding (lift)

open import Relation.Binary.PropositionalEquality hiding ([_])
open ≡-Reasoning

-- Project modules
open import ThomasProperties

-- SECION 1
-- 
-- Quotient signature
--

record QuSig (S : Setoid zero zero) : Set₁ where
             constructor _,_,_
             field
                Q     : Set
                [_]   : Carrier S → Q        -- [_] is not required to be surjective.
                                             -- In particular, Q could be S and [_] a normal form function. Note that stability in Nf below requires surjectivity.
                sound : ∀ { a b : Carrier S} → (_≈_ S a b) → [ a ] ≡ [ b ] -- injectivity of [_] modulo _≈_

             -- What is added below is not used. This to show that lift (see Qu below) can be defined at this stage as a function from  the image of the projection [_]
             -- However, I haven't seen any benefit yet. Could lift' and liftok' render the definitions of lift and liftok "better"? 
             private S₀      = Carrier S
                     _∼_     = _≈_ S
             lift'    : { B : Q → Set }
                        → (f : (a : S₀) → (B [ a ]))
                        → ((a b : S₀) → (p : a ∼ b) → subst B (sound p)  (f a)  ≡  f b)
                        → (c : Q) → (Image [_] ∋ c) → B c
             lift' f q .([ x ]) (im x) = f x
             liftok'  : ∀ {B a f q}    → lift' {B} f q [ a ] (im a)  ≡ f a
             liftok' {B} {a} {f} {q } = refl
             -- End of superfluous addition. Erase later.  
             -- ------------------------------------------------------------------------ -- 
              
open QuSig


-- SECTION 2
-- 
-- Different quotient definitions over a quotient signature
--


-- 2.1
-- Quotient by dependent lifting
--
-- if ~ is a congruence for f : S → B then f can be lifted to Q → B
record Qu { S : Setoid zero zero} (QS : QuSig S) : Set₁ where   
              private S₀      = Carrier S
                      _∼_     = _≈_ S
                      Q₀      = Q QS
                      [_]₀    = [_] QS
                      sound₀  : ∀ { a b : S₀} → (a ∼ b) → [ a ]₀ ≡ [ b ]₀
                      sound₀  = sound QS
              field
                lift    : { B : Q₀ → Set }
                        → (f : (a : S₀) → (B [ a ]₀))
                        → ((a a' : S₀) → (p : a ∼ a') → subst B (sound₀ p)  (f a)  ≡  f a')
                        → (c : Q₀) → B c
                liftok  : ∀ {B a f q}    → lift {B} f q [ a ]₀  ≡ f a
                liftIrr : ∀ {B a f q q'} → lift {B} f q [ a ]₀  ≡ lift {B} f q' [ a ]₀
            
open Qu



-- 2.2
-- Effective quotients
--

record QuE {S : Setoid zero zero} {QS : QuSig S} (QU : Qu QS) : Set₁ where
       private S₀      = Carrier S
               _∼_     = _≈_ S
               Q₀      = Q QS
               [_]₀    = [_] QS
               sound₀  : ∀ { a b : S₀} → (a ∼ b) → [ a ]₀ ≡ [ b ]₀
               sound₀  = sound QS
       field
         complete : ∀ {a b : S₀} → [ a ]₀ ≡ [ b ]₀ → a ∼ b   -- provable from compl in Nf but not provable so far.
open QuE

-- 2.3
-- Normal forms
-- 
record Nf {S : Setoid zero zero} (QS : QuSig S) : Set₁ where
       constructor _,_,_
       private S₀      = Carrier S
               _∼_     = _≈_ S
               Q₀      = Q QS
               [_]₀    = [_] QS
       field
         emb    : Q₀ → S₀                           -- embedding, choice of a representative for each class
         compl  : ∀ a → emb [ a ]₀ ∼ a              -- completeness (because it implies the implication: [a]≡[b] ⇒ a∼b and, in presence of stability, is equivalent to it)
         stable : ∀ x → [ emb x ]₀  ≡ x             -- stability
open Nf

-- 2.4
-- Non-dependent lift à la Hofmann
--

record QuH { S : Setoid zero zero} (QS : QuSig S) : Set₁ where   
              private S₀      = Carrier S
                      _∼_     = _≈_ S
                      Q₀      = Q QS
                      [_]₀    = [_] QS
                      sound₀  : ∀ { a b : S₀} → (a ∼ b) → [ a ]₀ ≡ [ b ]₀
                      sound₀  = sound QS
              field
                liftH    : { B : Set }
                        → (f : S₀ → B)                                                   -- B does not depent on a : S₀
                        → ((a a' : S₀) → (a ∼ a') →  (f a)  ≡  f a')
                        → Q₀ → B
                liftHok  : ∀ {B a f q}    → liftH {B} f q [ a ]₀  ≡ f a                  -- same as in lift
                -- quotient induction
                qind : (P : Q₀ → Set)  
                       → (∀ {x} → (p p' : P x) → p ≡ p')
                       → (∀ {a} → P [ a ]₀) 
                       → (∀ {x} → P x )

open QuH

-- SECTION 3
--
-- Translation between quotient definitions
--


nf2quE : {S : Setoid zero zero} → {QS : QuSig S} → {QU : Qu QS} → (Nf QS) → (QuE QU)
nf2quE {S} {QS} {QU} nf = record { complete =  λ {a} {b} [a]≡[b] → ⟨ compl₀ a ⟩₀    ▶₀    subst (λ x → x ∼ b) (emb₀ ⋆ ⟨ [a]≡[b] ⟩) (compl₀ b) }
                          where
                          private S₀      = Carrier S
                                  _∼_     = _≈_ S
                                  Q₀      = Q QS
                                  [_]₀    = [_] QS
                                  emb₀    = emb    nf
                                  compl₀  = compl  nf
                                  ⟨_⟩₀    : Symmetric _∼_
                                  ⟨_⟩₀    = symmetric S
                                  _▶₀_    : Transitive _∼_
                                  _▶₀_    = transitive S 

-- Remark that stability would be a consequence of the surjectivity of [_], soundness and completeness. However, the map [_] is not required to be surjective.
nf2qu : {S : Setoid zero zero} → {QS : QuSig S} → (Nf QS) → (Qu QS)
nf2qu {S} {QS} nf = 
        record {
        lift    =  λ {B} f q a⁻ → subst B (stable₀ a⁻) (f (emb₀ a⁻));   -- λ {B} f q a⁻ → lift' QS f q a⁻ (subst (λ x → Image [_]₀ ∋ x) (stable₀ a⁻) (im (emb₀ a⁻))) ;
        liftok  = λ {B} {a} {f} {q} → substIrr B (stable₀ [ a ]₀) (sound₀ (compl₀ a))  (f (emb₀ [ a ]₀)) ▶ q _ _ (compl₀ a) ;     -- λ {B} {a} {f} {q}  → liftok' QS {B} {a} {f} {q} ; 
        liftIrr = refl
        }
        where   S₀      = Carrier S
                _∼_     = _≈_ S
                [_]₀    = [_] QS
                sound₀  : ∀ { a b : S₀} → a ∼ b → [ a ]₀ ≡ [ b ]₀
                sound₀  = sound  QS
                compl₀  = compl  nf
                stable₀ = stable nf
                emb₀    = emb    nf


quH2qu : {S : Setoid zero zero} → {QS : QuSig S} → (QuH QS) → (Qu QS)
quH2qu {S} {QS} quh = 
             record { lift    = λ {B} f q c →  lift₁ {B} f q c ; 
                      liftok  = λ {B} {a} {f} {q} → liftok₁ {B} a f q ; 
                      liftIrr = λ {B} {a} {f} {q} {q'} → trans (liftok₁ {B} a f q ) (sym (liftok₁ {B} a f q')) }
             where
               
               -- notation
               S₀      = Carrier S
               _∼_     = _≈_ S
               Q₀      = Q QS
               [_]₀    = [_] QS
               sound₀  : ∀ { a b : S₀} → (a ∼ b) → [ a ]₀ ≡ [ b ]₀
               sound₀  = sound QS
               liftH₀ : { B : Set } → (f : S₀ → B) → ((a a' : S₀) → (a ∼ a') →  (f a)  ≡  f a') → Q₀ → B
               liftH₀ = liftH quh 
               liftHok₀ : ∀ {B a f q}    → liftH₀ {B} f q [ a ]₀  ≡ f a 
               liftHok₀ = liftHok quh
               qind₀ = qind quh
               -- the dependent function f is made independent
               indep : {B : Q₀ → Set}  → ((a : S₀) → B [ a ]₀) → S₀ → Σ Q₀ B
               indep f a = [ a ]₀ , f a
               indepok :  {B : Q₀ → Set}  → (f : (a : S₀) → B [ a ]₀) 
                                          → ((a a' : S₀) → (p : a ∼ a') → subst B (sound₀ p)  (f a)  ≡  f a') 
                                          → (a a' : S₀) 
                                          → (a ∼ a') 
                                          → indep {B} f a  ≡  indep f a'          
               indepok f q a a' p = trans (cong_,_ [ a ]₀ [ a' ]₀ (sound₀ p) (f a)) (cong (λ b → [ a' ]₀ , b) (q a a' p))

               -- quotient induction                     
               qind₁   :  {B : Q₀ → Set}  → (f : (a : S₀) → B [ a ]₀) 
                                          → (q : (a a' : S₀) → (p : a ∼ a') → subst B (sound₀ p)  (f a)  ≡  f a') 
                                          → ∀ (c : Q₀) → proj₁ {zero} {zero} {Q₀} {B} (liftH₀ (indep f) (indepok f q) c) ≡ c
               qind₁ {B} f q c = qind₀ P heredity base 
                                          where 
                                          P : Q₀ → Set
                                          P c = proj₁ {zero} {zero} {Q₀} {B} (liftH quh (indep f) (indepok f q) c) ≡ c
                                          heredity : ∀ {x} → (p p' : P x) → p ≡ p' 
                                          heredity     {x}    p p'          = ≡-prfIrr ((liftH₀ (indep f) (indepok f q) x)₁) x p p'  
                                          base : ∀ {a} → P [ a ]₀
                                          base = cong proj₁ liftHok₀

               -- definitions of lift and liftok
               liftH₁ : { B : Q₀ → Set } → (f : (a : S₀) → (B [ a ]₀)) → ((a a' : S₀) → (p : a ∼ a') → subst B (sound₀ p)  (f a)  ≡  f a') → S₀ → Σ Q₀ B 
               liftH₁ f q a = liftH₀ (indep f) (indepok f q) [ a ]₀

               lift₁  : { B : Q₀ → Set }
                        → (f : (a : S₀) → (B [ a ]₀))
                        → ((a a' : S₀) → (p : a ∼ a') → subst B (sound₀ p)  (f a)  ≡  f a')
                        → (c : Q₀) → B c 
               lift₁ {B} f q c =  subst B (qind₁ f q c) (proj₂ {zero} {zero} {Q₀} {B} (liftH₀ (indep f) (indepok f q)  c))

               liftok₁  : ∀ {B} a f q    → lift₁ {B} f q [ a ]₀  ≡ f a
               liftok₁   {B} a f q = trans (substIrr B (qind₁ f q [ a ]₀) 
                                                       (cong-proj₁ {Q₀} {B} (liftH₁ f q a) (indep f a) liftHok₀) 
                                                            (proj₂ {zero} {zero} {Q₀} {B} (liftH₁ f q a)))
                                                       (cong-proj₂ {Q₀} {B} (liftH₁ f q a) (indep f a) liftHok₀ )

