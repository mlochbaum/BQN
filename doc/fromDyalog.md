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

BQN shares the terms "[cell](array.md#cells)" and "major cell" with Dyalog, and uses "element" (which may mean different things to different Dyalog users) *not* for a 0-cell but for the value it contains.

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

BQN's [block](block.md) functions use `{}`, like Dyalog's dfns. The names for inputs and self-reference are different:

| Dyalog | BQN |
|--------|-----|
| `⍺`    | `𝕨` |
| `⍵`    | `𝕩` |
| `∇`    | `𝕊` |
| `⍺⍺`   | `𝔽` |
| `⍵⍵`   | `𝔾` |
| `∇∇`   | `𝕣` |

Blocks don't have guards exactly, but headers and predicates support some similar functionality (first-class functions can also be used for [control structures](control.md)). Headers can also be used to make a block more explicit about its inputs, more like a tradfn.

The assignment arrow `←` defines a new variable in a block, while `↩` modifies an existing one.

BQN uses the ligature character `‿` for stranding, instead of plain juxtaposition. It also has a [list notation](arrayrepr.md#brackets) using `⟨⟩`, and `[]` for higher-rank arrays.

## For reading

Glyphs `+-×÷⌊⌈|⊣⊢⍉` have nearly the same meaning in BQN as APL. The other primitive functions (except `!`, Assert) are translated loosely to Dyalog APL below.

| BQN | Monad         | Dyad
|-----|---------------|-----
| `⋆` | `*`           | `*`
| `√` | `*∘(÷2)`      | `*∘÷⍨`
| `∧` | `{⍵[⍋⍵]}`     | `∧`
| `∨` | `{⍵[⍒⍵]}`     | `∨`
| `¬` | `~`           | `1+-`
| `=` | `≢⍤⍴`         | `=`
| `≠` | `≢`           | `≠`
| `<` | `⊂`           | `<`
| `>` | `↑`           | `>`
| `≢` | `⍴`           | `≢`
| `⥊` | `,`           | `⍴`
| `∾` | `⊃,⌿`         | `⍪`
| `≍` | `↑,⍥⊂`        | `↑,⍥⊂`
| `⋈` | `,⍥⊂`         | `,⍥⊂`
| `↑` | `,⍀`          | `↑`
| `↓` | `{⌽,⍨⍀⌽⍵}`    | `↓`
| `↕` | `⍳`           | `,⌿`
| `»` | ` ≢↑(¯1-≢)↑⊢` | `  ≢⍤⊢↑⍪`
| `«` | `-⍤≢↑(1+≢)↑⊢` | `-⍤≢⍤⊢↑⍪⍨`
| `⌽` | `⊖`           | `⊖`
| `/` | `⍸`           | `⌿`
| `⍋` | `⍋`           | `⍸`
| `⍒` | `⍒`           | `⍸`, reversed order
| `⊏` | `⊣⌿`          | `⌷`
| `⊑` | `⊃`           | `⊃`
| `⊐` | `∪⍳⊢`         | `⍳`
| `⊒` | `+⌿∘.≡⍨∧∘.<⍨∘(⍳≢)` | `{R←≢⍤⊢⍴∘⍋∘⍋⍺⍳⍪⍨⋄⍺(R⍨⍳R)⍵}`
| `∊` | `≠`           | `∊`
| `⍷` | `∪`           | `⍷`
| `⊔` | `{⊂⍵}⌸`       | `{⊂⍵}⌸` or `⊆`

Modifiers are a little harder. Many have equivalents in some cases, but Dyalog sometimes chooses different functionality based on whether the operand is an array. In BQN an array is always treated as a constant function.

| BQN    | `¨` | `⌜`  | `˝` | `` ` `` | `˘`   | `⎉`  |
|:------:|:---:|:----:|:---:|:-------:|:-----:|:----:|
| Dyalog | `¨` | `∘.` | `⌿` |   `⍀`   | `⍤¯1` | `⍤A` |

| BQN    | `⁼`   | `⍟` | `˜` | `∘`  | `○` | `⟜` |
|:------:|:-----:|:---:|:---:|:----:|:---:|:---:|
| Dyalog | `⍣¯1` | `⍣` | `⍨` | `⍤f` | `⍥` | `∘` |

Some other BQN modifiers have been proposed as future Dyalog extensions:

| BQN             | `⌾` | `⚇` | `⊸` |
|:---------------:|:---:|:---:|:---:|
| Dyalog proposed | `⍢` [Under](https://aplwiki.com/wiki/Under) | `⍥` [Depth](https://aplwiki.com/wiki/Depth_(operator)) | `⍛` [Reverse Compose](https://aplwiki.com/wiki/Reverse_Compose)

## For writing

The tables below give approximate implementations of Dyalog primitives for the ones that aren't the same. First- and last-axis pairs are also mostly omitted. BQN just has the first-axis form, and you can get the last-axis form with `⎉1`.

The form `F⍣G` (Power with a function right operand; Power limit) can't be implemented with primitives alone because it performs unbounded iteration. Typically `Fn •_while_ Cond arg` should be used for this functionality. The definition `_while_ ← {𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}` also works; it's more complicated than you might expect to avoid stack overflow, as discussed [here](control.md#low-stack-version).

<table>
<tr><th colspan=3>Functions</th></tr>
<tr><th> Glyph          </th><th> Monadic                      </th><th> Dyadic </th>               </tr>
<tr><td> <code>*</code> </td><td colspan=2><code>⋆</code></td>                                      </tr>
<tr><td> <code>⍟</code> </td><td colspan=2><code>⋆⁼</code></td>                                     </tr>
<tr><td> <code>!</code> </td><td><code>×´1+↕</code>            </td><td> <code>(-÷○(×´)1⊸+)⟜↕˜</code></td></tr>
<tr><td> …              </td><td><code>•math.Fact</code>       </td><td> <code>•math.Comb˜</code></td></tr>
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
<tr><td> <code>↓</code> </td><td> <code><˘</code>              </td><td> <code>↓</code></td>        </tr>
<tr><td> <code>⊂</code> </td><td> <code><</code>               </td><td> <code>+`⊸⊔</code></td>     </tr>
<tr><td> <code>⊆</code> </td><td> <code><⍟(1≥≡)</code>         </td><td> <code>(¬-˜⊢×·+`»⊸>)⊸⊔</code></td></tr>
<tr><td> <code>∊</code> </td><td> <code>{(∾𝕊¨)⍟(1<≡)⥊𝕩}</code> </td><td> <code>∊</code></td>        </tr>
<tr><td> <code>⊃</code> </td><td colspan=2><code>⊑</code></td>                                      </tr>
<tr><td> <code>⌿</code> </td><td>                              </td><td> <code>/</code></td>        </tr>
<tr><td> <code>⍀</code> </td><td>                              </td><td> <code>{𝕩⌾(𝕨⊸/)𝕨≠⊸↑0↑𝕩}</code></td></tr>
<tr><td> <code>∩</code> </td><td>                              </td><td> <code>∊/⊣</code></td>      </tr>
<tr><td> <code>∪</code> </td><td> <code>⍷</code>               </td><td> <code>⊣∾∊˜¬⊸/⊢</code></td> </tr>
<tr><td> <code>⍳</code> </td><td> <code>↕</code>               </td><td> <code>⊐</code></td>        </tr>
<tr><td> <code>⍸</code> </td><td> <code>/</code>               </td><td> <code>⍋</code></td>        </tr>
<tr><td> <code>⍋</code> </td><td> <code>⍋</code>               </td><td> <code>⍋⊐</code></td>       </tr>
<tr><td> <code>⍒</code> </td><td> <code>⍒</code>               </td><td> <code>⍒⊐</code></td>       </tr>
<tr><td> <code>≢</code> </td><td> <code>≠</code>               </td><td> <code>≢</code></td>        </tr>
<tr><td> <code>⍎</code> </td><td colspan=2><code>•BQN</code> (maybe <code>•ParseFloat</code>)</td>  </tr>
<tr><td> <code>⍕</code> </td><td colspan=2><code>•Fmt</code> (maybe <code>•Repr</code>)</td>        </tr>
<tr><td> <code>⊥</code> </td><td>                              </td><td> <code>{+⟜(𝕨⊸×)´⌽𝕩}</code>    </td></tr>
<tr><td> <code>⊤</code> </td><td>                              </td><td> <code>{𝕨|>⌊∘÷`⌾⌽𝕨«˜<𝕩}</code></td></tr>
<tr><td> <code>⌹</code> </td><td><code>Inverse</code>,         </td><td> <code>Solve</code> from <a href="https://github.com/mlochbaum/bqn-libs/blob/master/matrix.bqn">here</a></td></tr>
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
<tr><td> <code>f⌸</code>  </td><td><code>⊔⊐</code>   </td><td><code>⊐⊸⊔</code>       </td></tr>
<tr><td> <code>f⌺B</code> </td><td colspan=2> <code>B⊸↕</code>                       </td></tr>
<tr><td> <code>A⌶</code>  </td><td colspan=2> <code>•Something</code>                </td></tr>
<tr><td> <code>f&</code>  </td><td colspan=2> Nothing yet                            </td></tr>
</table>
