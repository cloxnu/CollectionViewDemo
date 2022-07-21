# CollectionViewDemo
A demo about UICollectionViewTransitionLayout

---

复现该 crash 的方式：双手捏合或拉伸使得当前 `UICollectionView` 进入交互式布局过渡模式，然后松开手指。在这次布局过渡动画结束前，再一次捏合或拉伸，再松开手指，即可复现该 crash。

To reproduce the crash: pinch or stretch your fingers to put the `UICollectionView` into interactive layout transition mode, and then release your fingers. Before the end of this layout transition, pinch or stretch again and release your fingers again to reproduce the crash.

在代码层面上，调用 `UICollectionView` 对象的 `startInteractiveTransition(to:completion:)` 后，此 collection view 开始进行布局过渡，
此时更改 `transitionProgress` 属性可以调节过渡进度，如果此时用户手势停止或打断，`finishInteractiveTransition()` 或 `cancelInteractiveTransition()` 将被调用。
完成过渡或取消过渡被调用后，此 collection view 会立即执行新布局或旧布局的过渡动画。在此动画结束前，用户再一次捏合或拉伸了并释放了，即此时又会先后调用 `startInteractiveTransition(to:completion:)` 和 `finishInteractiveTransition()`，
在最后一次调用后，该应用 crash，控制台打印了 crash 原因: 
"the collection was not prepared for an interactive transition. see startInteractiveTransitionToCollectionViewLayout:completion:"，
和另一抱错信息: "*** Assertion failure in -[UICollectionView _finishInteractiveTransitionShouldFinish:finalAnimation:], UICollectionView.m:6770"。

At the code level, after calling `startInteractiveTransition(to:completion:)` of the `UICollectionView` object, the collection view starts the layout transition.
If the user gesture is finished or cancelled at this time, `finishInteractiveTransition()` or `cancelInteractiveTransition()` will be called.
When finish transition or cancel transition is called, this collection view will immediately execute the transition animation of the new layout or the old layout. Before this animation ends, the user pinches or stretches and releases again, i.e. `startInteractiveTransition(to:completion:)` and `finishInteractiveTransition()` are called again.
After the last call, the application crashes and the console prints the reason for the crash: 
"The collection was not prepared for an interactive transition. see startInteractiveTransitionToCollectionViewLayout:completion:",
and another error message: "*** Assertion failure in -[UICollectionView _finishInteractiveTransitionShouldFinish:finalAnimation:], UICollectionView.m:6770". .

