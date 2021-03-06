\AgdaHide{

\begin{code}

{-# OPTIONS --type-in-type --no-positivity-check --no-termination-check #-}

module Suspension where

open import AIOOG
open import AIOOGS2
open import Relation.Binary.PropositionalEquality 
open import Data.Product renaming (_,_ to _,,_)
open import Data.Empty


1-1cm : {Γ Δ : Con}{A : Ty Γ}{B : Ty Δ} → 
        (γ : Γ ⇒ Δ) → B [ γ ]T ≡ A → (Γ , A) ⇒ (Δ , B)
1-1cm γ eq = (γ +S _) , (var v0 ⟦ wk+S+T eq ⟫)


1-1cm-T : {Γ Δ : Con}{A : Ty Γ}{B : Ty Δ} → 
          {γ : Γ ⇒ Δ} → (eq : B [ γ ]T ≡ A) → (B +T B) [ 1-1cm γ eq ]T ≡ A +T A
1-1cm-T eq = trans +T[,]T (trans [+S]T (wk-T eq))



ht-IdCm : {Γ Δ : Con} → Γ ≡ Δ → Γ ⇒ Δ
ht-IdCm refl = IdCm _

1-1cm' : {Γ Δ : Con}{A : Ty Γ}{B : Ty Δ} → 
        (eq : Γ ≡ Δ) → subst Ty eq A ≡ B → (Γ , A) ⇒ (Δ , B)
1-1cm' refl refl = IdCm _

1-1cm-same : {Γ : Con}{A B : Ty Γ} → 
            B ≡ A → (Γ , A) ⇒ (Γ , B)
1-1cm-same eq = p1 , p2 ⟦ congT eq ⟫ 

1-1cm-same-T : {Γ : Con}{A B : Ty Γ} → 
               (eq : B ≡ A) → (A +T B) [ 1-1cm-same eq ]T ≡ A +T A
1-1cm-same-T eq = trans +T[,]T (trans [+S]T (wk-T (IC-T _)))


1-1cm-same-tm : ∀ {Γ : Con}{A : Ty Γ}{B : Ty Γ} → 
               (eq : B ≡ A)(a : Tm A) → (a +tm B) [ 1-1cm-same eq ]tm ≅ (a +tm A)
1-1cm-same-tm eq a = +tm[,]tm a ∾ [+S]tm a ∾ cong+tm2 (IC-tm a)

1-1cm-same-v0 : ∀ {Γ : Con}{A B : Ty Γ} → 
               (eq : B ≡ A) → var v0 [ 1-1cm-same eq ]tm ≅ var v0
1-1cm-same-v0 eq = wk-coh ∾ cohOp (congT eq) ∾ p2-v0


\end{code}
}


Even though we didn't choose suspension to generate the reflexivity, it should be still useful in the future work.

Like all the other definitions, we have to define a set of operations together. In addition we could also prove that the suspension of a contractible context is still contractible.

\begin{code}

ΣC : Con → Con
ΣT : {Γ : Con} → Ty Γ → Ty (ΣC Γ)
Σv : {Γ : Con}{A : Ty Γ} → Var A → Var (ΣT A)
Σtm : {Γ : Con}{A : Ty Γ} → Tm A → Tm (ΣT A)
Σs : {Γ Δ : Con} → Γ ⇒ Δ → ΣC Γ ⇒ ΣC Δ
ΣC-Contr : (Δ : Con) → isContr Δ → isContr (ΣC Δ)


\end{code}

The suspension of a context is to substitute the base type with the equality of two variables of base type for all occurences. So the base case for a suspension is a context contains two variables of base type. That means we can declare new variables whose type is the equality of these two variables. 

\begin{code}

ΣC ε = ε , * , *
ΣC (Γ , A) = ΣC Γ , ΣT A


*' : {Γ : Con} → Ty (ΣC Γ)
*' {ε} = var (vS v0) =h var v0
*' {Γ , A} = *' {Γ} +T _

ΣT {Γ} * = *' {Γ}
ΣT (a =h b) = Σtm a =h Σtm b

\end{code}

There are some lemmas which are neceesary for the definitions. The suspension of terms and context morphisms are too cumbersome to present here.


\begin{code}

ΣT[+T]   : {Γ : Con}(A : Ty Γ)(B : Ty Γ) 
         → ΣT (A +T B) ≡ ΣT A +T ΣT B
Σtm[+tm] : {Γ : Con}{A : Ty Γ}(a : Tm A)(B : Ty Γ) 
         → Σtm (a +tm B) ≅ Σtm a +tm ΣT B

ΣT[Σs]T : {Γ Δ : Con}(A : Ty Δ) → (δ : Γ ⇒ Δ) → (ΣT A) [ Σs δ ]T ≡ ΣT (A [ δ ]T)

\end{code}

\AgdaHide{
\begin{code}

ΣT[+T] * B = refl
ΣT[+T] (_=h_ {A} a b) B = hom≡ (Σtm[+tm] a B) (Σtm[+tm] b B)

Σv {.(Γ , A)} {.(A +T A)} (v0 {Γ} {A}) = subst Var (sym (ΣT[+T] A A)) v0
Σv {.(Γ , B)} {.(A +T B)} (vS {Γ} {A} {B} x) = subst Var (sym (ΣT[+T] {_} A B)) (vS (Σv x))


Σtm (var x) = var (Σv x)
Σtm (JJ x δ A) = JJ (ΣC-Contr _ x) (Σs δ) (ΣT A) ⟦ sym (ΣT[Σs]T A δ) ⟫


Σtm-p1 : {Γ : Con}(A : Ty Γ) → Σtm {Γ , A} (var v0) ≅ var v0 
Σtm-p1 A = cohOpV (sym (ΣT[+T] A A))

Σtm-p2 : {Γ : Con}(A : Ty Γ)(B : Ty (Γ , A)) → Σtm {Γ , A , B} (var (vS v0)) ≅ (var v0) +tm _
Σtm-p2 A B = cohOpV (sym (ΣT[+T] (A +T A) B))  ∾  cong+tm2 (Σtm-p1 A)



Σs• : ∀ (Γ : Con) → ΣC Γ ⇒ ΣC ε
Σs• ε = IdCm _
Σs• (Γ , A) = Σs• Γ +S _

Σs {Γ} {Δ , A} (γ , a) = (Σs γ) , Σtm a ⟦ ΣT[Σs]T A γ ⟫ 
Σs {Γ} • = Σs• Γ


cohOpΣtm : ∀ {Δ : Con}{A B : Ty Δ}(t : Tm B)(p : A ≡ B) → Σtm (t ⟦ p ⟫) ≅ Σtm t
cohOpΣtm t refl = refl _

Σs⊚ : ∀ {Δ Δ₁ Γ}(δ : Δ ⇒ Δ₁)(γ : Γ ⇒ Δ) → Σs (δ ⊚ γ) ≡ Σs δ ⊚ Σs γ

Σv-v0 : {Γ : Con}(A : Ty Γ) → var (Σv (v0 {Γ} {A})) ≅ var v0
Σv-v0 {Γ} A = cohOpV (sym (ΣT[+T] A A))


Σv-vS : {Γ : Con}(A B : Ty Γ)(x : Var A) → var (Σv (vS {B = B} x)) ≅ var (vS (Σv x))
Σv-vS {Γ} A B x = cohOpV (sym (ΣT[+T] A B))


Σv[Σs]v :  ∀ {Γ Δ : Con}{A : Ty Δ}(x : Var A)(δ : Γ ⇒ Δ) → Σv x [ Σs δ ]V ≅ Σtm (x [ δ ]V)
Σv[Σs]v (v0 {Γ} {A}) (δ , a) = congtm (Σv-v0 A) ∾ wk-coh ∾ cohOp (ΣT[Σs]T A δ) ∾ cohOpΣtm a +T[,]T -¹
Σv[Σs]v (vS {Γ} {A} {B} x) (δ , a) = congtm (Σv-vS A B x) ∾
                                       +tm[,]tm (Σtm (var x)) ∾
                                       Σv[Σs]v x δ ∾ cohOpΣtm (x [ δ ]V) +T[,]T -¹

Σtm[Σs]tm : ∀ {Γ Δ : Con}{A : Ty Δ}(a : Tm A)(δ : Γ ⇒ Δ) → 
              (Σtm a) [ Σs δ ]tm ≅ Σtm (a [ δ ]tm)
Σtm[Σs]tm (var x) δ = Σv[Σs]v x δ
Σtm[Σs]tm {Γ} {Δ} (JJ {Δ = Δ₁} x δ A) δ₁ = congtm (cohOp (sym (ΣT[Σs]T A δ))) 
                      ∾ cohOp (sym [⊚]T) 
                      ∾ JJ-eq (sym (Σs⊚ δ δ₁)) 
                      ∾ (cohOpΣtm (JJ x (δ ⊚ δ₁) A) (sym [⊚]T) 
                      ∾ cohOp (sym (ΣT[Σs]T A (δ ⊚ δ₁)))) -¹

Σs•-left-id : ∀{Γ Δ : Con}(γ : Γ ⇒ Δ) → Σs {Γ} • ≡ Σs {Δ} • ⊚ Σs γ
Σs•-left-id {ε} {ε} • = refl
Σs•-left-id {ε} {Δ , A} (γ , a) = trans (Σs•-left-id γ) (sym (⊚wk (Σs• Δ)))
Σs•-left-id {Γ , A} {ε} • = trans (cong (λ x → x +S ΣT A) (Σs•-left-id {Γ} {ε} •)) (cm-eq (cm-eq refl ([+S]V (vS v0) {Σs• Γ} -¹)) ([+S]V v0 {Σs• Γ} -¹))
Σs•-left-id {Γ , A} {Δ , A₁} (γ , a) = trans (Σs•-left-id γ) (sym (⊚wk (Σs• Δ))) 

Σs⊚ • γ = Σs•-left-id γ
Σs⊚ {Δ} (_,_ δ {A} a) γ = cm-eq (Σs⊚ δ γ) (cohOp (ΣT[Σs]T A (δ ⊚ γ)) ∾ cohOpΣtm (a [ γ ]tm) [⊚]T ∾ (cohOp [⊚]T ∾ congtm (cohOp (ΣT[Σs]T A δ)) ∾ Σtm[Σs]tm a γ) -¹) 


ΣT[+S]T : ∀{Γ Δ : Con}(A : Ty Δ)(δ : Γ ⇒ Δ)(B : Ty Γ) → ΣT A [ Σs δ +S ΣT B ]T ≡ ΣT (A [ δ ]T) +T ΣT B
ΣT[+S]T A δ B = trans [+S]T (wk-T (ΣT[Σs]T A δ))

ΣsDis : ∀{Γ Δ : Con}{A : Ty Δ}(δ : Γ ⇒ Δ)(a : Tm (A [ δ ]T))(B : Ty Γ) → (Σs {Γ} {Δ , A} (δ , a)) +S ΣT B ≡ Σs δ +S ΣT B , ((Σtm a) +tm ΣT B) ⟦ ΣT[+S]T A δ B ⟫
ΣsDis {Γ} {Δ} {A} δ a B = cm-eq refl (wk-coh+ ∾ (cohOp (trans [+S]T (wk-T (ΣT[Σs]T A δ))) ∾ cong+tm (ΣT[Σs]T A δ)) -¹)

ΣsΣT : ∀ {Γ Δ : Con}(δ : Γ ⇒ Δ)(B : Ty Γ) → Σs (δ +S B) ≡ Σs δ +S ΣT B
ΣsΣT • _ = refl
ΣsΣT (_,_ δ {A} a) B = cm-eq (ΣsΣT δ B) (cohOp (ΣT[Σs]T A (δ +S B)) ∾ cohOpΣtm (a +tm B) [+S]T ∾ Σtm[+tm] a B ∾ cong+tm (ΣT[Σs]T A δ) ∾ wk-coh+ -¹) 

*'[Σs]T : {Γ Δ : Con} → (δ : Γ ⇒ Δ) → *' {Δ} [ Σs δ ]T ≡ *' {Γ}
*'[Σs]T {ε} • = refl
*'[Σs]T {Γ , A} • = trans ([+S]T {A = *' {ε}} {δ = Σs {Γ} •}) (wk-T (*'[Σs]T {Γ} •))
*'[Σs]T {Γ} {Δ , A} (γ , a) = trans +T[,]T (*'[Σs]T γ)

ΣT[Σs]T * δ = *'[Σs]T δ
ΣT[Σs]T (_=h_ {A} a b) δ = hom≡ (Σtm[Σs]tm a δ) (Σtm[Σs]tm b δ)

Σtm[+tm] {A = A} (var x) B = cohOpV (sym (ΣT[+T] A B))
Σtm[+tm] {Γ} (JJ {Δ = Δ} x δ A) B = cohOpΣtm (JJ x (δ +S B) A) (sym [+S]T) ∾ cohOp (sym (ΣT[Σs]T A (δ +S B))) ∾ JJ-eq (ΣsΣT δ B) ∾ cohOp (sym [+S]T) -¹ ∾ cong+tm (sym (ΣT[Σs]T A δ))


ΣC-Contr .(ε , *) c* = ext c* v0
ΣC-Contr .(Γ , A , (var (vS x) =h var v0)) (ext {Γ} r {A} x) = subst (λ y → isContr (ΣC Γ , ΣT A , y))
                                                                 (hom≡ (cohOpV (sym (ΣT[+T] A A)) -¹)
                                                                  (cohOpV (sym (ΣT[+T] A A)) -¹))
                                                                 (ext (ΣC-Contr Γ r) {ΣT A} (Σv x))


congΣtm : {Γ : Con}{A B : Ty Γ}{a : Tm A}{b : Tm B} → a ≅ b → Σtm a ≅ Σtm b
congΣtm {Γ} {.B} {B} {.b} {b} (refl .b) = refl _

-- replace * with A, repeat same contruction in higher dimension

rep-C : {Γ : Con}(A : Ty Γ) → Con → Con

rep-T : {Γ Δ : Con}(A : Ty Γ) → Ty Δ → Ty (rep-C A Δ)

rep-tm : {Γ Δ : Con}(A : Ty Γ){B : Ty Δ} → Tm B → Tm (rep-T A B)

rep-cm : {Γ Δ Θ : Con}(A : Ty Γ) → Θ ⇒ Δ → (rep-C A Θ) ⇒ (rep-C A Δ)

rep-C * C = C
rep-C (_=h_ {A} a b) C = ΣC (rep-C A C) -- (rep-C A C) , rep-T A * ,  rep-T A * +T rep-T A *

rep-T * B = B
rep-T (_=h_ {A} a b) B = ΣT (rep-T A B)
  
rep-tm * t = t
rep-tm (_=h_ {A} a b) t = Σtm (rep-tm A t)


rep-cm * cm = cm
rep-cm (_=h_ {A} a b) cm = Σs (rep-cm A cm)



-- second version


loop-C : {Γ : Con}(A : Ty Γ) → Con
loop-T : {Γ : Con}(A : Ty Γ) → Ty (loop-C A)
loop-cm : {Γ : Con}(A : Ty Γ) → Γ ⇒ loop-C A
loop-p1 : {Γ : Con}(A : Ty Γ) → loop-T A [ loop-cm A ]T ≡ A

loop-C * = ε
loop-C (_=h_ {A} a b) = loop-C A , loop-T A , loop-T A +T _


loop-T * = *
loop-T (_=h_ {A} a b) = var (vS v0) =h var v0

loop-cm * = •
loop-cm (_=h_ {A} a b) = loop-cm A , a ⟦ loop-p1 A ⟫ , wk-tm (b ⟦ loop-p1 A ⟫)

loop-p1 * = refl
loop-p1 (_=h_ {A} a b) = trans wk-hom (trans wk-hom (cohOp-hom (loop-p1 A)))

{-
rep-C' :  {Γ : Con}(A : Ty Γ) → Con → Con

rep-T' : {Γ Δ : Con}(A : Ty Γ) → Ty Δ → Ty (rep-C' A Δ)


rep-tm' : {Γ Δ : Con}(A : Ty Γ)(B : Ty Δ) → Tm B → Tm (rep-T' A B)

rep-cm' : {Γ Δ Θ : Con}(A : Ty Γ) → Θ ⇒ Δ → (rep-C' A Θ) ⇒ (rep-C' A Δ)


rep-C' A ε = loop-C A
rep-C' A (Γ , B) = rep-C' A Γ , rep-T' A B

loop-base-cm : {Γ : Con}(A : Ty Γ)(Δ : Con) → rep-C' A Δ ⇒ loop-C A
loop-base-cm A ε = IdCm _
loop-base-cm A (Δ , A₁) = loop-base-cm A Δ +S _

rep-T' {Γ} {ε} A * = loop-T A
rep-T' {Γ} {Δ , A} A₁ * = rep-T' {Γ} {Δ} A₁ * +T _
rep-T' A (_=h_ {B} a b) = rep-tm' A B a =h rep-tm' A B b


filter-cm' : ∀ {Γ : Con}(A : Ty Γ) → Γ ⇒ rep-C' A ε

filter-cm' A = loop-cm A
-}
-- the most important morphism for rep-C

filter-cm-p : ∀ {Γ : Con}(A : Ty Γ) → ΣC (rep-C A ε) ⇒ rep-C A ε
filter-cm-p * = •
filter-cm-p (_=h_ {A} a b) = Σs (filter-cm-p A)



ΣC-p1 :{Γ : Con}(A : Ty Γ) → ΣC (Γ , A) ≡ ΣC Γ , ΣT A
ΣC-p1 * = refl
ΣC-p1 (a =h b) = refl


rep-C-p1 : {Γ Δ : Con}(A : Ty Γ)(B : Ty Δ) → rep-C A (Δ , B) ≡ (rep-C A Δ , rep-T A B)
rep-C-p1 * B = refl
rep-C-p1 (_=h_ {A} a b) B = cong ΣC (rep-C-p1 A B)

-- to split rep-C

rep-C-cm-spl : {Γ Δ : Con}(A : Ty Γ)(B : Ty Δ) → 
               (rep-C A Δ , rep-T A B) ⇒ rep-C A (Δ , B)
rep-C-cm-spl * B = IdCm _
rep-C-cm-spl (_=h_ {A} a b) B = Σs (rep-C-cm-spl A B)



struct1 : {Γ : Con}(A : Ty Γ)
          → (ΣC (Γ , A) , ΣT A +T _) ⇒ ΣC (Γ , A , A +T _)
struct1 A = 1-1cm-same (ΣT[+T] A A)

rep-C-cm-spl2 : {Γ : Con}(A : Ty Γ)
              → (rep-C A ε , rep-T A * ,  rep-T A * +T _) ⇒ ΣC (rep-C A ε)
rep-C-cm-spl2 * = IdCm _
rep-C-cm-spl2 (_=h_ {A} a b) = Σs (rep-C-cm-spl2 A) ⊚ 1-1cm-same (ΣT[+T] (rep-T A *) (rep-T A *))


filter-cm : ∀ {Γ : Con}(A : Ty Γ) → Γ ⇒ rep-C A ε


rep-T-wk : {Γ Δ : Con}(A : Ty Γ)(B : Ty Δ) → (rep-T A *) [ rep-C-cm-spl A B ]T ≡ rep-T A * +T _
rep-T-wk * B = refl
rep-T-wk (_=h_ {A} a b) B = trans (ΣT[Σs]T (rep-T A *) (rep-C-cm-spl A B)) (trans (cong ΣT (rep-T-wk A B)) (ΣT[+T] (rep-T A *) (rep-T A B)))

rep-T-p1 : ∀ {Γ : Con}(A : Ty Γ) → rep-T A * [ filter-cm A ]T ≡ A

rep-T-p2 : {Γ Δ : Con}(A : Ty Γ){B : Ty Δ}{a b : Tm B} → rep-T A (a =h b) ≡ (rep-tm A a =h rep-tm A b)
rep-T-p2 * = refl
rep-T-p2 (_=h_ {A} _ _) = cong ΣT (rep-T-p2 A)


rep-T-p3 : {Γ Δ : Con}(A : Ty Γ){B C : Ty Δ} → rep-T A (C +T B) [ rep-C-cm-spl A B ]T ≡ rep-T A C +T _ 
rep-T-p3 * = trans +T[,]T (wk+S+T (IC-T _))
rep-T-p3 (_=h_ {A} a b) {B} {C} = trans (ΣT[Σs]T (rep-T A (C +T B)) (rep-C-cm-spl A B)) (trans (cong ΣT (rep-T-p3 A)) (ΣT[+T] (rep-T A C) (rep-T A B)))


filter-cm * = •
filter-cm {Γ} (_=h_ {A} a b) = rep-C-cm-spl2 A ⊚ ((filter-cm A , (a ⟦ rep-T-p1 A ⟫)) , (wk-tm (b ⟦ rep-T-p1 A ⟫)))



fci-l1 : ∀ {Γ : Con}(A : Ty Γ) → ΣT (rep-T A *) [ rep-C-cm-spl2 A ]T ≡ (var (vS v0) =h var v0)

fci-l1 * = refl
fci-l1 {Γ} (_=h_ {A} a b) = trans [⊚]T (trans
                                      (congT
                                       (trans (ΣT[Σs]T (ΣT (rep-T A *)) (rep-C-cm-spl2 A))
                                        (cong ΣT (fci-l1 A))))
                                      (hom≡
                                         (congtm (Σtm-p2 (rep-T A *) (rep-T A * +T rep-T A *)) ∾
                                          1-1cm-same-tm (ΣT[+T] (rep-T A *) (rep-T A *)) (var v0))
                                         (congtm (Σtm-p1 (rep-T A * +T rep-T A *)) ∾
                                            1-1cm-same-v0 (ΣT[+T] (rep-T A *) (rep-T A *)))) )


rep-T-p1  * = refl
rep-T-p1 (_=h_ {A} a b) = trans [⊚]T (trans (congT (fci-l1 A)) (hom≡ (wk-coh ∾ wk-coh ∾ cohOp (rep-T-p1 A)) (wk-coh ∾ wk-coh ∾ cohOp (rep-T-p1 A))))
 


rep-tm-p1 : {Γ Δ : Con}(A : Ty Γ) → rep-tm A (var v0) [ rep-C-cm-spl A (* {Δ}) ]tm ≅ var v0
rep-tm-p1 * = refl _
rep-tm-p1 (_=h_ {A} a b) = Σtm[Σs]tm (rep-tm A (var v0)) (rep-C-cm-spl A *) ∾ congΣtm (rep-tm-p1 A) ∾ cohOpV (sym (ΣT[+T] (rep-T A *) (rep-T A *)))


rep-tm-p2 : {Γ Δ : Con}(A : Ty Γ){B : Ty Δ}(x : Var B) → (rep-tm A (var (vS x))) [ rep-C-cm-spl A * ]tm ≅ rep-tm A (var x) +tm _
rep-tm-p2 * x = wk-coh ∾ [+S]V x ∾ cong+tm2 (IC-v _)
rep-tm-p2 {Γ} {Δ} (_=h_ {A} a b) {B} x = Σtm[Σs]tm (rep-tm A (var (vS x))) (rep-C-cm-spl A *) ∾ congΣtm (rep-tm-p2 {Γ} {Δ} A {B} x) ∾ Σtm[+tm] (rep-tm A (var x)) (rep-T A *)


-- reconstruct in higher dimension without lose the original context

_++_ : Con → Con → Con


cor : {Γ : Con}(Δ : Con) → (Γ ++ Δ) ⇒ Δ

repeat-p1 : {Γ : Con}(Δ : Con) → (Γ ++ Δ) ⇒ Γ


Γ ++ ε = Γ
Γ ++ (Δ , A) = Γ ++ Δ , A [ cor Δ ]T


repeat-p1 ε = IdCm _
repeat-p1 (Δ , A) = repeat-p1 Δ ⊚ p1


cor ε = •
cor (Δ , A) = (cor Δ +S _) , var v0 ⟦ [+S]T ⟫



_++cm_ : ∀ {Γ Δ Θ} → Γ ⇒ Δ → Γ ⇒ Θ → Γ ⇒ (Δ ++ Θ)
cor-inv : ∀ {Γ Δ Θ} → {γ : Γ ⇒ Δ}(δ : Γ ⇒ Θ) → cor Θ ⊚ (γ ++cm δ) ≡ δ

γ ++cm • = γ
γ ++cm (δ , a) = γ ++cm δ , a ⟦ trans (sym [⊚]T) (congT2 (cor-inv _)) ⟫ 

cor-inv • = refl
cor-inv (δ , a) = cm-eq (trans (⊚wk _) (cor-inv δ)) 
        (cohOp [⊚]T ∾ congtm (cohOp [+S]T) 
        ∾ cohOp +T[,]T 
        ∾ cohOp (trans (sym [⊚]T) (congT2 (cor-inv _))))


id-cm++ : {Γ : Con}(Δ Θ : Con) → (Δ ⇒ Θ) → (Γ ++ Δ) ⇒ (Γ ++ Θ)
id-cm++ Δ Θ γ = repeat-p1 Δ ++cm (γ ⊚ cor _)

rpl : (Γ Δ : Con)(B : Ty Γ)
    → Con


rpl-T : {Γ : Con}(Δ : Con)(B : Ty Γ) →
      (A : Ty Δ)
      → Ty (rpl Γ Δ B)


rpl-tm : (Γ Δ : Con)(B : Ty Γ) →
      {A : Ty Δ}(a : Tm A)
      → Tm (rpl-T Δ B A)

rpl Γ Δ B = Γ ++ rep-C B Δ

rpl-T Δ B A = rep-T B A [ cor _ ]T

rpl-tm Γ Δ B a = rep-tm B a [ cor _ ]tm

-- an alternative way to define replace

rpl' : {Γ : Con} → (Δ : Con) → (A : Ty Γ) → Con


rpl'-p1  : {Γ : Con}(Δ : Con)(A : Ty Γ) → rpl' Δ A ⇒ Γ

rpl'-p2 : {Γ : Con}(Δ : Con)(A : Ty Γ) → rpl' Δ A ⇒  rep-C A Δ


rpl' {Γ} ε A = Γ
rpl' (Δ , B) A = rpl' Δ A , rep-T A B [ rpl'-p2 Δ A ]T


rpl'-p1 ε A = IdCm _
rpl'-p1 (Δ , A) A₁ = rpl'-p1 Δ A₁ +S _

rpl'-p2 ε A = filter-cm A
rpl'-p2 (Δ , A) A₁ = rep-C-cm-spl A₁ A ⊚ ((rpl'-p2 Δ A₁ +S _) , var v0 ⟦ [+S]T ⟫)



rpl-split : {Γ : Con}(Δ : Con)(A : Ty Γ)(B : Ty Δ) → (rpl Γ Δ A , rpl-T Δ A B) ⇒ rpl Γ (Δ , B) A
rpl-split Δ A B = id-cm++ _ _ (rep-C-cm-spl A B)


rpl-T' : {Γ : Con}(Δ : Con)(A : Ty Γ) →
      (B : Ty Δ)
      → Ty (rpl' Δ A)
rpl-T' Δ A B = rep-T A B [ rpl'-p2 Δ A ]T

rpl-T'-p1 : {Γ : Con}(Δ : Con)(A : Ty Γ) → rpl-T' Δ A * ≡ A [ rpl'-p1 Δ A ]T
rpl-T'-p1 ε A = trans (rep-T-p1 A) (sym (IC-T _))
rpl-T'-p1 (Δ , A) A₁ = trans [⊚]T (trans (congT (rep-T-wk A₁ A)) (trans +T[,]T (trans [+S]T (trans (wk-T (rpl-T'-p1 Δ A₁)) (sym [+S]T)))))

rpl-tm' : {Γ : Con}(Δ : Con)(A : Ty Γ) →
      {B : Ty Δ}(a : Tm B)
      → Tm (rpl-T' Δ A B)
rpl-tm' Δ A a = rep-tm A a [ rpl'-p2 Δ A ]tm



rpl-T'-p2 : {Γ : Con}(Δ : Con)(A : Ty Γ){B : Ty Δ}{a b : Tm B}  → rpl-T' Δ A (a =h b) ≡ (rpl-tm' Δ A a =h rpl-tm' Δ A b)
rpl-T'-p2 Δ A = congT (rep-T-p2 A)


rpl-T'-p3 : {Γ Δ : Con}(A : Ty Γ){B C : Ty Δ}
          → rpl-T' (Δ , B) A (C +T B) ≡ rpl-T' Δ A C +T _
rpl-T'-p3 A = trans [⊚]T (trans (congT (rep-T-p3 A)) (trans +T[,]T [+S]T))

rpl'-rpl : {Γ : Con}(Δ : Con)(A : Ty Γ) → rpl' Δ A ⇒ rpl Γ Δ A
rpl'-rpl Δ A =  rpl'-p1 Δ A ++cm rpl'-p2 Δ A

rpl'-rpl-eval : {Γ : Con}(Δ : Con)(A : Ty Γ)(B : Ty Δ) → rpl-T Δ A B [ rpl'-rpl Δ A ]T ≡ rep-T A B [ rpl'-p2 Δ A ]T
rpl'-rpl-eval Δ A B = trans (sym [⊚]T) (congT2 (cor-inv _))


--  rep-tm-p2 : {Γ Δ : Con}(A : Ty Γ){B : Ty Δ}(x : Var B) → (rep-tm A (var (vS x))) [ rep-C-cm-spl A * ]tm ≅ rep-tm A (var x) +tm _

{-
rpl-T'-p5 : {Γ Δ : Con}(A : Ty Γ)(B C : Ty Δ)→ rpl-T' (Δ , B) A (C +T B) ≡ rep-T A * [ filter-cm A ]T +T _ -- rpl-T' Δ A C +T _   -- rep-T A B [ rpl'-p2 Δ A ]T ≡ {!A +T _ !} -- A +T _ 
rpl-T'-p5 {Γ} {Δ} A B * = {!rpl-T'-p1 Δ A !}
rpl-T'-p5 A B (a =h b) = {!!}
-}

-- rpl-T'-p5 (_=h_ {A} a b) B = {!!} -- trans [⊚]T (trans (congT ( (ΣT[Σs]T (rep-T A *) (rep-C-cm-spl A *)) )) {!trans (sym [⊚]T) ?!}) -- trans [⊚]T {!trans (congT (rep-T-p1 A)) ? !}



-- (Γ , A , A +T A , (var (vS v0) =h var v0)) ≡ rpl' (ε , * , * , (var (vS v0) =h var v0)) A


\end{code}
}