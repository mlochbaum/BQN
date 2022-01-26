*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/fromDyalog.html).*

# BQN–Dyalog APL dictionary

A few tables to help users of Dyalog APL (or similar) get started quickly on BQN. For a higher-level comparison, check [Why BQN?](../commentary/why.md#versus-apl-and-j). Here we assume `⎕ML` is 1 for Dyalog.

## Terminology

### Array model

BQN uses the [based array model](based.md), so that a Dyalog simple scalar corresponds to many BQN values: an atom, its enclose, and so on.

| Dyalog        | BQN   |
|---------------|-------|
| Simple scalar | Atom  |
| Scalar        | Unit  |
| Vector        | List  |
| Matrix        | Table |

BQN shares the terms "cell" and "major cell" with Dyalog, and uses
"element" (which may mean different things to different Dyalog users) *not* for a 0-cell but for the value it contains.

### Roles

Dyalog uses value types (array, function, and so on) to determine syntax while BQN uses a separate concept called syntactic roles. See [context-free grammar](context.md).

| Dyalog type      | BQN role   |
|------------------|------------|
| Array            | Subject    |
| Function         | Function   |
| Monadic operator | 1-modifier |
| Dyadic operator  | 2-modifier |
| Niladic function | *go away*  |

## Syntax

BQN comments are written with `#`, not `⍝`. BQN strings use double quotes `""` while single quotes `''` enclose a character.

BQN's functions use `{}`, like Dyalog's dfns. The names for inputs and self-reference are different:

| Dyalog | BQN |
|--------|-----|
| `⍺`    | `𝕨` |
| `⍵`    | `𝕩` |
| `∇`    | `𝕊` |
| `⍺⍺`   | `𝔽` |
| `⍵⍵`   | `𝔾` |
| `∇∇`   | `𝕣` |

BQN doesn't have guards: it uses modifiers or [control structures](control.md) instead. However, BQN function and modifier blocks have headers that allow pattern matching. See the [block](block.md) documentation.

The assignment arrow `←` defines a new variable in a block, while `↩` modifies an existing one.

BQN uses the ligature character `‿` for stranding, instead of plain juxtaposition. It also has a [list notation](arrayrepr.md#brackets) using `⟨⟩`.

## For reading

Here are some closest equivalents in Dyalog APL for the BQN functions that don't use the same glyphs as APL. Correspondence can be approximate, and `⌽` is just used as a decorator to mean "reverse some things".

| BQN   | `⋆` | `√`      | `∧`   | `∨`   | `¬`   | `=`   | `≠` | `<` | `>` | `≢` | `⥊` |
|:-----:|:---:|:--------:|:-----:|:-----:|:-----:|:-----:|:---:|:---:|:---:|:---:|:---:|
| Monad | `*` | `*∘(÷2)` | `[⍋]` | `[⍒]` | `~`   | `≢⍤⍴` | `≢` | `⊂` | `↑` | `⍴` | `,` |
| Dyad  | `*` | `*∘÷⍨`   | `∧`   | `∨`   | `1+-` | `=`   | `≠` | `<` | `>` | `≢` | `⍴` |

| BQN   | `∾`   | `≍`    | `⋈`   | `↑`  | `↓`     | `↕`  | `»`          | `«`           |
|:-----:|:-----:|:------:|:-----:|:----:|:-------:|:----:|:------------:|:-------------:|
| Monad | `⊃,⌿` | `↑,⍥⊂` | `,⍥⊂` | `,⍀` | `⌽,⌽⍀⌽` | `⍳`  | `≢↑(¯1-≢)↑⊢` | `-⍤≢↑(1+≢)↑⊢` |
| Dyad  | `⍪`   | `↑,⍥⊂` | `,⍥⊂` | `↑`  | `↓`     | `,⌿` | `≢⍤⊢↑⍪`      | `-⍤≢⍤⊢↑⍪⍨`    |

| BQN   | `/` | `⍋` | `⍒`   | `⊏`  | `⊑` | `⊐`   | `⊒` | `∊` | `⍷` | `⊔`        |
|:-----:|:---:|:---:|:-----:|:----:|:---:|:-----:|:---:|:---:|:---:|:----------:|
| Monad | `⍸` | `⍋` | `⍒`   | `⊣⌿` | `⊃` | `∪⍳⊢` | `…` | `≠` | `∪` | `⌸`        |
| Dyad  | `⌿` | `⍸` | `⌽⍸⌽` | `⌷`  | `⊃` | `⍳`   | `…` | `∊` | `⍷` | `⌸` or `⊆` |

Modifiers are a little harder. Many have equivalents in some cases, but Dyalog sometimes chooses different functionality based on whether the operand is an array. In BQN an array is always treated as a constant function.

| BQN    | `¨` | `⌜`  | `˝` | `⎉` | `⍟` | `˜` | `∘` | `○` | `⟜` |
|:------:|:---:|:----:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Dyalog | `¨` | `∘.` | `⌿` | `⍤` | `⍣` | `⍨` | `⍤` | `⍥` | `∘` |

In BQN `⎉` is Rank and `∘` is Atop. Dyalog's Atop (`⍤`) and Over (`⍥`) were added in version 18.0.

## For writing

The tables below give approximate implementations of Dyalog primitives for the ones that aren't the same. First- and last-axis pairs are also mostly omitted. BQN just has the first-axis form, and you can get the last-axis form with `⎉1`.

The form `F⍣G` (Power with a function right operand; Power limit) must be implemented with recursion instead of primitives because it performs unbounded iteration. The modifier `_while_ ← {𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}` provides similar functionality without risk of stack overflow. It's discussed [here](control.md#low-stack-version) and called as `Fn _while_ Cond arg`.

<table>
<tr><th colspan=3>Functions</th></tr>
<tr><th> Glyph          </th><th> Monadic                      </th><th> Dyadic </th>               </tr>
<tr><td> <code>*</code> </td><td colspan=2><code>⋆</code></td>                                      </tr>
<tr><td> <code>⍟</code> </td><td colspan=2><code>⋆⁼</code></td>                                     </tr>
<tr><td> <code>!</code> </td><td><code>×´1+↕</code>            </td><td> <code>-˜(+÷○(×´)⊢)1+↕∘⊣</code></td></tr>
<tr><td> <code>○</code> </td><td> <code>π⊸×</code>             </td><td> <code>•math</code></td>    </tr>
<tr><td> <code>~</code> </td><td> <code>¬</code>               </td><td> <code>¬∘∊/⊣</code></td>    </tr>
<tr><td> <code>?</code> </td><td> <code>•rand.Range⚇0</code>   </td><td> <code>•rand.Deal</code></td></tr>
<tr><td> <code>⍲</code> </td><td>                              </td><td> <code>¬∘∧</code></td>      </tr>
<tr><td> <code>⍱</code> </td><td>                              </td><td> <code>¬∘∨</code></td>      </tr>
<tr><td> <code>⍴</code> </td><td> <code>≢</code>               </td><td> <code>⥊</code></td>        </tr>
<tr><td> <code>,</code> </td><td> <code>⥊</code>               </td><td> <code>∾⎉1</code></td>      </tr>
<tr><td> <code>⍪</code> </td><td> <code>⥊˘</code>              </td><td> <code>∾</code></td>        </tr>
<tr><td> <code>⌽</code> </td><td colspan=2><code>⌽⎉0‿1</code></td>                                  </tr>
<tr><td> <code>↑</code> </td><td> <code>></code>               </td><td> <code>↑</code></td>        </tr>
<tr><td> <code>↓</code> </td><td> <code><˘</code>              </td><td> <code>↑</code></td>        </tr>
<tr><td> <code>⊂</code> </td><td> <code><</code>               </td><td> <code>+`⊸⊔</code></td>     </tr>
<tr><td> <code>⊆</code> </td><td> <code><⍟(0<≡)</code>         </td><td> <code>(¬-˜⊢×·+`»⊸>)⊸⊔</code></td></tr>
<tr><td> <code>∊</code> </td><td> <code>{(∾𝕊¨)⍟(0<≡𝕩)⥊𝕩}</code></td><td> <code>∊</code></td>        </tr>
<tr><td> <code>⊃</code> </td><td colspan=2><code>⊑</code></td>                                      </tr>
<tr><td> <code>⍀</code> </td><td>                              </td><td> <code>{𝕩⌾(𝕨⊸/)𝕨≠⊸↑0↑𝕩}</code></td></tr>
<tr><td> <code>∩</code> </td><td>                              </td><td> <code>∊/⊣</code></td>      </tr>
<tr><td> <code>∪</code> </td><td> <code>⍷</code>               </td><td> <code>⊣∾∊˜¬⊸/⊢</code></td> </tr>
<tr><td> <code>⍳</code> </td><td> <code>↕</code>               </td><td> <code>⊐</code></td>        </tr>
<tr><td> <code>⍸</code> </td><td> <code>/</code>               </td><td> <code>⍋</code></td>        </tr>
<tr><td> <code>⍋</code> </td><td> <code>⍋</code>               </td><td> Give up </td>              </tr>
<tr><td> <code>⍒</code> </td><td> <code>⍒</code>               </td><td> Give up </td>              </tr>
<tr><td> <code>≢</code> </td><td> <code>≠</code>               </td><td> <code>≢</code></td>        </tr>
<tr><td> <code>⍎</code> </td><td colspan=2><code>•BQN</code></td>                                   </tr>
<tr><td> <code>⍕</code> </td><td colspan=2><code>•Fmt</code></td>                                   </tr>
<tr><td> <code>⊥</code> </td><td>                              </td><td> <code>{+⟜(𝕨⊸×)´⌽𝕩}</code>    </td></tr>
<tr><td> <code>⊤</code> </td><td>                              </td><td> <code>{>𝕨|⌊∘÷`⌾⌽𝕨«˜<𝕩}</code></td></tr>
<tr><td> <code>⌹</code> </td><td><code>Inverse</code> from <a href="https://github.com/mlochbaum/bqn-libs/blob/master/matrix.bqn">here</a></td><td><code>Solve</code></td></tr>
<tr><td> <code>⌷</code> </td><td> N/A                          </td><td> <code>⊏</code></td>        </tr>
</table>

<table>
<tr><th colspan=3>Operators</th></tr>
<tr><th> Syntax           </th><th> Monadic          </th><th> Dyadic                </th></tr>
<tr><td> <code>⌿</code>   </td><td> <code>¨˝</code>  </td><td> <code>↕</code>        </td></tr>
<tr><td> <code>⍀</code>   </td><td colspan=2> <code>↑</code>, or <code>`</code> if associative </td></tr>
<tr><td> <code>¨</code>   </td><td colspan=2> <code>¨</code>                         </td></tr>
<tr><td> <code>⍨</code>   </td><td colspan=2> <code>˜</code>                         </td></tr>
<tr><td> <code>⍣</code>   </td><td colspan=2> <code>⍟</code>                         </td></tr>
<tr><td> <code>f.g</code> </td><td>                  </td><td> <code>f˝∘g⎉1‿∞</code> </td></tr>
<tr><td> <code>∘.f</code> </td><td>                  </td><td> <code>f⌜</code>       </td></tr>
<tr><td> <code>A∘g</code> </td><td> <code>A⊸g</code> </td><td>                       </td></tr>
<tr><td> <code>f∘B</code> </td><td> <code>f⟜B</code> </td><td>                       </td></tr>
<tr><td> <code>f∘g</code> </td><td colspan=2> <code>f⟜g</code>                       </td></tr>
<tr><td> <code>f⍤B</code> </td><td colspan=2> <code>f⎉B</code>                       </td></tr>
<tr><td> <code>f⍤g</code> </td><td colspan=2> <code>f∘g</code>                       </td></tr>
<tr><td> <code>f⍥g</code> </td><td colspan=2> <code>f○g</code>                       </td></tr>
<tr><td> <code>f@v</code> </td><td colspan=2> <code>f⌾(v⊸⊏)</code>                   </td></tr>
<tr><td> <code>f⍠B</code> </td><td colspan=2> Uh                                     </td></tr>
<tr><td> <code>f⌸</code>  </td><td><code>⊐⊔↕∘≠</code></td><td><code>⊐⊸⊔</code>       </td></tr>
<tr><td> <code>f⌺B</code> </td><td colspan=2> <code>↕</code>                         </td></tr>
<tr><td> <code>A⌶</code>  </td><td colspan=2> <code>•Something</code>                </td></tr>
<tr><td> <code>f&</code>  </td><td colspan=2> Nothing yet                            </td></tr>
</table>
