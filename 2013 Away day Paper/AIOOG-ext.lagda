\AgdaHide{
\begin{code}
{-# OPTIONS --type-in-type --no-positivity-check --no-termination-check #-}


module AIOOG-ext where 


open import Relation.Binary.PropositionalEquality
open import Function
open import Data.Product renaming (_,_ to _,,_)


infix 4 _≅_
infix 4 _=h_

\end{code}
}

\paragraph{Basic Objects}

We first declare the syntax of our type theory which is
called \tig{} namely the internal language of \wog. The following declarations in order are contexts as sets,
types are sets dependent on contexts, terms and variables are sets
dependent on types, Contexts morphisms and the contractible contexts.

\begin{code}

data Con           : Set
data Ty (Γ : Con)  : Set
data Tm            : {Γ : Con}(A : Ty Γ) → Set
data Var           : {Γ : Con}(A : Ty Γ) → Set
data _⇒_           : Con → Con → Set

data isContr       : Con → Set
\end{code}

Altenkirch also suggests to use Higher Inductive-Inductive definitions for these sets which he coined as Quotient Inductive-Inductive Types (QIIT), in other words, to given an equivalence relation for each of them as one constructor. However we do not use it here.

It is possible to complete the definition of contexts and types first. Contexts are inductively defined as either an empty context or a context with a type of it. Types are defined as either $*$ which we call it 0-cell, or a morphism between two terms of
some type A. If the type A is n-cell then we call the morphism $n+1$-cell. 

\begin{code}
data Con where
  ε   : Con
  _,_ : (Γ : Con)(A : Ty Γ) → Con


data Ty Γ where
  *   : Ty Γ
  _=h_ : {A : Ty Γ}(a b : Tm A) → Ty Γ
\end{code}

\paragraph{Heterogeneous Equality for Terms}

One of the big challenge we encountered at first is the difficulty to formalise and to reason about the equalities of terms.
When we used the common identity types which is homogeneous, we had to use $subst$ function in Agda to unify the types on both sides of the equation. It created a lot of technical issues that made the encoding too involved to proceed. However we found that the syntactic equality of types of given context which will be introduced later, is decidable which means that it is an h-set. In other words, the equalities of types is unique, so that it is safe to use the JM equality (heterogeneous equality) for terms of different types. The equality is inhabited only when they are definitionally equal.

\begin{code}
data _≅_ {Γ : Con}{A : Ty Γ} 
         : {B : Ty Γ} → Tm A → Tm B → Set where
  refl : (b : Tm A) → b ≅ b
\end{code}

\AgdaHide{
\begin{code}
--  We also use different notations for symmetry and transitivity. 

-- sym

_-¹ : ∀{Γ : Con}{A B : Ty Γ}{a : Tm A}{b : Tm B} → a ≅ b → b ≅ a
(refl _) -¹ = refl _

infixr 4 _∾_ 

_∾_ : ∀{Γ : Con}{A B C : Ty Γ}{a : Tm A}{b : Tm B}{c : Tm C} → a ≅ b → b ≅ c → a ≅ c
_∾_ {Γ} {.C} {.C} {C} {.c} {.c} {c} (refl .c) (refl .c) = refl c


\end{code}
}

Once we have the heterogeneous equality for terms, we could define a proof-irrelevant substitution which we call coercion here
since it gives us a term of type A if we have a term of type B and the
two types are equal. We can also prove that the coerced term is heterogeneously equal to the
original term. Combined these definitions, it is much
more convenient to formalise and to reason about term equations.

\begin{code}
_⟦_⟫ : {Γ : Con}{A B : Ty Γ}(a : Tm B) → A ≡ B → Tm A
a ⟦ refl ⟫ = a

cohOp : {Γ : Con}{A B : Ty Γ}{a : Tm B}(p : A ≡ B) 
      → a ⟦ p ⟫ ≅ a
cohOp refl = refl _
\end{code}

% could delete the explanation of this lemma

%It is sufficient to prove the original terms are equal if we coerced them using the same proof. This lemma is useful later.

\AgdaHide{
\begin{code}

cohOp-eq : {Γ : Con}{A B : Ty Γ}{a b : Tm B}{p : A ≡ B} → (a ≅ b) 
         → (a ⟦ p ⟫ ≅ b ⟦ p ⟫)
cohOp-eq (refl _) = refl _

\end{code}
}


\paragraph{Substitutions}

With context morphism, we could define substitutions for types variables and terms. Indeed the
composition of contexts can be understood as substitution for context morphisms as well.

\begin{code}
_[_]T  : {Γ Δ : Con}(A : Ty Δ)           (δ : Γ ⇒ Δ) → Ty Γ
_[_]V  : {Γ Δ : Con}{A : Ty Δ}(a : Var A)(δ : Γ ⇒ Δ) → Tm (A [ δ ]T)
_[_]tm : {Γ Δ : Con}{A : Ty Δ}(a : Tm A) (δ : Γ ⇒ Δ) → Tm (A [ δ ]T)
_⊚_    : {Γ Δ Θ : Con}            →  Δ ⇒ Θ → Γ ⇒ Δ → Γ ⇒ Θ
\end{code}


\AgdaHide{
\begin{code}

infixl 7 _,_

\end{code}
}

\paragraph{Weakening Rules}

we could freely add types to the contexts of given any type
judgments, term judgments or context morphisms. We call these rules
weakening rules.

\begin{code}
_+T_  : {Γ : Con}(A : Ty Γ)           → (B : Ty Γ) → Ty (Γ , B)
_+tm_ : {Γ : Con}{A : Ty Γ}(a : Tm A) → (B : Ty Γ) → Tm (A +T B)
_+S_  : {Γ : Con}{Δ : Con}(δ : Γ ⇒ Δ) → (B : Ty Γ) → (Γ , B) ⇒ Δ
\end{code}

%We could first define the weakening rule and substitution for types.

\AgdaHide{
\begin{code}

*        +T B = *
(a =h b) +T B = a +tm B =h b +tm B


*        [ δ ]T = * 
(a =h b) [ δ ]T = a [ δ ]tm =h b [ δ ]tm

\end{code}
}

To define the variables and terms we have to use the weakening rules.
A Term can be either a variable or a J-term. We use the unnamed way
to define variables as either the immediate variable at the right most
of the context, or some variable in the context which can be found by
cancelling the right most variable along with each $vS$. The J-terms are one of the major part of this syntax, which are primitive terms of the primitive types in
contractible contexts which will be introduced later. Since contexts, types, variables and
terms are all mutually defined, most of the properties of them have to be
proved simultaneously as well.


\begin{code}
data Var where
  v0 : {Γ : Con}{A : Ty Γ}              → Var (A +T A)
  vS : {Γ : Con}{A B : Ty Γ}(x : Var A) → Var (A +T B)

data Tm where
  var : {Γ : Con}{A : Ty Γ} → Var A → Tm A
  JJ  : {Γ Δ : Con} → isContr Δ → (δ : Γ ⇒ Δ) → (A : Ty Δ) 
      → Tm (A [ δ ]T)
\end{code}

\AgdaHide{
\begin{code}
JJ-eq : {Γ Δ : Con}{isc : isContr Δ}{γ δ : Γ ⇒ Δ}{A : Ty Δ} → γ ≡ δ → JJ isc γ A ≅ JJ isc δ A 
JJ-eq refl = refl _

\end{code}
}

Another core part of the syntactic framework is contractible
contexts. Intuitively speaking, a context is contractible if its geometric
realization is contractible to a point. It either contains one variable of the 0-cell $*$ which is the base case, or we can extend a contractible context with a
variable of an existing type and an n-cell, namely a morphism, between the new variable and some existing variable.

\begin{code}
data isContr where
  c*  : isContr (ε , *)
  ext : {Γ : Con} 
      → isContr Γ → {A : Ty Γ}(x : Var A) 
        → isContr ((Γ , A) , (var (vS x) =h var v0))
\end{code}

Context morphisms are defined inductively similar to contexts. A context morphism is a list of terms corresponding to the list of types in the context on the right hand side of this morphism.

\begin{code}
data _⇒_ where
  •    : {Γ : Con} → Γ ⇒ ε
  _,_ : {Γ Δ : Con}(δ : Γ ⇒ Δ){A : Ty Δ}(a : Tm (A [ δ ]T)) 
      → Γ ⇒ (Δ , A)
\end{code}

\AgdaHide{
\begin{code}

hom≡ : {Γ : Con}{A A' : Ty Γ}
                {a : Tm A}{a' : Tm A'}(q : a ≅ a')
                {b : Tm A}{b' : Tm A'}(r : b ≅ b')
                → (a =h b) ≡ (a' =h b')
hom≡ (refl _) (refl _) = refl


cm-eq : {Γ Δ : Con}{γ δ : Γ ⇒ Δ}{A : Ty Δ}
        {a : Tm (A [ γ ]T)}{a' : Tm (A [ δ ]T)} 
        → γ ≡ δ → a ≅ a' 
        → _≡_ {_} {Γ ⇒ (Δ , A)} (γ , a) (δ , a')
cm-eq refl (refl _) = refl

\end{code}
}


\paragraph{Lemmas}

The following four lemmas state that to
substitute a type, a variable, a term, or a context morphism with two
context morphisms consecutively, is equivalent to substitute with the
composition of substitution.

\begin{code}
[⊚]T : {Γ Δ Θ : Con}
       {θ : Δ ⇒ Θ}{δ : Γ ⇒ Δ}{A : Ty Θ}
       → A [ θ ⊚ δ ]T ≡ (A [ θ ]T)[ δ ]T

[⊚]v : {Γ Δ Θ : Con}
          (θ : Δ ⇒ Θ)(δ : Γ ⇒ Δ)(A : Ty Θ)(x  : Var A)
          → x [ θ ⊚ δ ]V ≅ (x [ θ ]V) [ δ ]tm

[⊚]tm : {Γ Δ Θ : Con}
        (θ : Δ ⇒ Θ)(δ : Γ ⇒ Δ)(A : Ty Θ)(a : Tm A)
        →  a [ θ ⊚ δ ]tm ≅ (a [ θ ]tm) [ δ ]tm

⊚assoc : {Γ Δ Θ Δ₁ : Con}
        (γ : Θ ⇒ Δ₁)(θ : Δ ⇒ Θ)(δ : Γ ⇒ Δ)
        → (γ ⊚ θ) ⊚ δ ≡ γ ⊚ (θ ⊚ δ)


\end{code}


\AgdaHide{
\begin{code}

•       ⊚ δ = •
(δ , a) ⊚ δ' = (δ ⊚ δ') , a [ δ' ]tm ⟦ [⊚]T ⟫

\end{code}
}

Weakening inside substitution is equivalent to weakening outside.

\begin{code}
[+S]T : {Γ Δ : Con}
        {A : Ty Δ}{δ : Γ ⇒ Δ}
        {B : Ty Γ} 
        → A [ δ +S B ]T ≡ (A [ δ ]T) +T B 

[+S]tm : {Γ Δ : Con}{A : Ty Δ}
         (a : Tm A){δ : Γ ⇒ Δ}
         {B : Ty Γ}
         → a [ δ +S B ]tm ≅ (a [ δ ]tm) +tm B
\end{code}

They are useful to derive some auxiliary functions. The following is one of them which is used a lot in proofs.

\begin{code}
wk-tm+ : {Γ Δ : Con}
         {A : Ty Δ}{δ : Γ ⇒ Δ}
         (B : Ty Γ) 
         → Tm (A [ δ ]T +T B) → Tm (A [ δ +S B ]T)
wk-tm+ B t = t ⟦ [+S]T ⟫
\end{code}

\AgdaHide{

\begin{code}
•       +S B = •
(δ , a) +S B = (δ +S B) , wk-tm+ B (a +tm B)


[+S]T {A = *}     = refl
[+S]T {A = a =h b} = hom≡ ([+S]tm a) ([+S]tm b)

\end{code}
}

We could cancel the last term in the substitution for weakened objects
since weakening doesn't introduce new variables in types and terms.

\begin{code}
+T[,]T : {Γ Δ : Con}
         {A : Ty Δ}{δ : Γ ⇒ Δ}
         {B : Ty Δ}{b : Tm (B [ δ ]T)} 
         → (A +T B) [ δ , b ]T ≡ A [ δ ]T

+tm[,]tm : {Γ Δ : Con}{A : Ty Δ}
         (a : Tm A)(δ : Γ ⇒ Δ)(B : Ty Δ)
         (c : Tm (B [ δ ]T))
         → (a +tm B) [ δ , c ]tm ≅ a [ δ ]tm 
\end{code}

\AgdaHide{
\begin{code}

(var x)     +tm B = var (vS x)
(JJ cΔ δ A) +tm B = JJ cΔ (δ +S B) A ⟦ sym [+S]T ⟫ 


wk-T : {Δ : Con}
       {A B C : Ty Δ}
       → A ≡ B → A +T C ≡ B +T C
wk-T refl = refl

wk-tm : {Γ Δ : Con}
         {A : Ty Δ}{δ : Γ ⇒ Δ}
         {B : Ty Δ}{b : Tm (B [ δ ]T)}  
         → Tm (A [ δ ]T) → Tm ((A +T B) [ δ , b ]T)
wk-tm t = t ⟦ +T[,]T ⟫

v0   [ δ , a ]V = wk-tm a
vS x [ δ , a ]V = wk-tm (x [ δ ]V)


wk-coh : {Γ Δ : Con}
         {A : Ty Δ}{δ : Γ ⇒ Δ}
         {B : Ty Δ}{b : Tm (B [ δ ]T)}  
         {t : Tm (A [ δ ]T)} 
         → wk-tm {B = B} {b = b} t ≅ t
wk-coh = cohOp +T[,]T

wk-coh+ : {Γ Δ : Con}
         {A : Ty Δ}{δ : Γ ⇒ Δ}
         {B : Ty Γ} 
         {x : Tm (A [ δ ]T +T B)}
          → wk-tm+ B x ≅ x
wk-coh+ = cohOp [+S]T

wk-hom : {Γ Δ : Con}
         {A : Ty Δ}{δ : Γ ⇒ Δ}
         {B : Ty Δ}{b : Tm (B [ δ ]T)}  
         {x y : Tm (A [ δ ]T)}
         → (wk-tm {B = B} {b = b} x =h wk-tm {B = B} {b = b} y) ≡ (x =h y)
wk-hom = hom≡ wk-coh wk-coh -- +T[,]T


wk-hom+ : {Γ Δ : Con}
         {A : Ty Δ}{δ : Γ ⇒ Δ}
         {B : Ty Γ} 
         {x y : Tm (A [ δ ]T +T B)}
         → (wk-tm+ B x =h wk-tm+ B y) ≡ (x =h y)
wk-hom+ = hom≡ wk-coh+ wk-coh+  -- [+S]T

wk-⊚ : {Γ Δ Θ : Con}
       {θ : Δ ⇒ Θ}{δ : Γ ⇒ Δ}{A : Ty Θ}
       → Tm ((A [ θ ]T)[ δ ]T) → Tm (A [ θ ⊚ δ ]T)
wk-⊚ t = t ⟦ [⊚]T ⟫

[⊚]T {A = *} = refl
[⊚]T {A = _=h_ {A} a b} = hom≡ ([⊚]tm _ _ _ _) ([⊚]tm _ _ _ _) --   [⊚]T

+T[,]T {A = *} = refl
+T[,]T {A = _=h_ {A} a b} = hom≡  (+tm[,]tm _ _ _ _) (+tm[,]tm _ _ _ _) -- +T[,]T

\end{code}
}

Most of the substitutions are defined as usual, except the one for J-terms. We do
substitution in the context morphism part of the J-terms.

\begin{code}

var x     [ δ ]tm = x [ δ ]V
JJ cΔ γ A [ δ ]tm = JJ cΔ (γ ⊚ δ) A ⟦ sym [⊚]T ⟫

\end{code}


\AgdaHide{
\begin{code}

-- congruence


_◃V_ : {Γ Δ : Con}{A B : Ty Δ}{a : Var A}{b : Var B} →
     var a ≅ var b → 
     (δ : Γ ⇒ Δ) 
     → a [ δ ]V ≅ b [ δ ]V
_◃V_ {Γ} {Δ} {.B} {B} {.b} {b} (refl .(var b)) δ  = refl _


_◃_ : {Γ Δ : Con}{A B : Ty Γ}{a : Tm A}{b : Tm B}
      (p : a ≅ b) → 
      (δ : Δ ⇒ Γ) 
      → a [ δ ]tm ≅ b [ δ ]tm
(refl _) ◃ _ = refl _ 


⊚assoc • θ δ = refl
⊚assoc (_,_ γ {A} a) θ δ =
  cm-eq (⊚assoc γ θ δ) 
    (cohOp [⊚]T 
    ∾ ((cohOp [⊚]T ◃ δ) 
    ∾ ((cohOp [⊚]T 
    ∾ [⊚]tm θ δ (A [ γ ]T) a) -¹)))



[⊚]v (θ , a) δ .(A +T A) (v0 {Γ₁} {A}) = wk-coh ∾ cohOp [⊚]T ∾ (cohOp +T[,]T -¹) ◃ δ
[⊚]v (θ , a) δ .(A +T B) (vS {Γ₁} {A} {B} x) = 
  wk-coh
  ∾ ([⊚]v θ δ A x 
    ∾ ((cohOp +T[,]T ◃ δ) -¹))



[⊚]tm θ δ A (var x) = [⊚]v θ δ A x
[⊚]tm θ δ .(A [ γ ]T) (JJ c γ A) = cohOp (sym [⊚]T) ∾ (JJ-eq (sym (⊚assoc γ θ δ)) ∾ cohOp (sym [⊚]T) -¹) ∾ (cohOp (sym [⊚]T) -¹) ◃ δ


⊚wk : ∀{Γ Δ Δ₁}(B : Ty Δ)(γ : Δ ⇒ Δ₁)(δ : Γ ⇒ Δ)(c : Tm (B [ δ ]T)) → (γ +S B) ⊚ (δ , c) ≡ γ ⊚ δ
⊚wk B • δ c = refl
⊚wk B (_,_ γ {A} a) δ c = cm-eq (⊚wk B γ δ c) (cohOp [⊚]T ∾ (cohOp [+S]T ◃ (δ , c) ∾ +tm[,]tm a δ B c) ∾ cohOp [⊚]T -¹)

+tm[,]tm (var x) δ B c = cohOp +T[,]T
+tm[,]tm (JJ x γ A) δ B c = cohOp (sym [+S]T) ◃ (δ , c) ∾ cohOp (sym [⊚]T) ∾ JJ-eq (⊚wk B γ δ c) ∾ cohOp (sym [⊚]T) -¹


--lemma
cong+tm : ∀ {Γ : Con}{A B C : Ty Γ}{a : Tm B}(p : A ≡ B) → a +tm C ≅ a ⟦ p ⟫ +tm C
cong+tm refl = refl _

[+S]V : {Γ Δ : Con}{A : Ty Δ}
         (x : Var A){δ : Γ ⇒ Δ}
         {B : Ty Γ}
         → x [ δ +S B ]V ≅ (x [ δ ]V) +tm B
[+S]V v0 {_,_ δ {A} a} = wk-coh ∾ wk-coh+ ∾ cong+tm +T[,]T
[+S]V (vS x) {δ , a} = wk-coh ∾ [+S]V x ∾ cong+tm +T[,]T

lem+Stm : ∀{Γ Δ Δ₁ : Con}(δ : Δ ⇒ Δ₁)(γ : Γ ⇒ Δ)(B : Ty Γ) → δ ⊚ (γ +S B) ≡ (δ ⊚ γ) +S B
lem+Stm • γ B = refl
lem+Stm (_,_ δ {A} a) γ B = cm-eq (lem+Stm δ γ B) (cohOp [⊚]T ∾ ([+S]tm a ∾ cong+tm [⊚]T) ∾ wk-coh+ -¹)


cong+tm2 : ∀ {Γ : Con}{A B C : Ty Γ}{a : Tm A}{b : Tm B}→ a ≅ b → a +tm C ≅ b +tm C
cong+tm2 (refl _) = refl _

[+S]tm (var x) {δ} {B} = [+S]V x
[+S]tm (JJ x δ A) {γ} {B} = cohOp (sym [⊚]T) ∾ JJ-eq (lem+Stm δ γ B) ∾ cohOp (sym [+S]T) -¹ ∾ cong+tm (sym [⊚]T)

\end{code}
}
